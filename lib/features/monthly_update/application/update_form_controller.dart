import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/money/money.dart';
import '../../../core/money/money_format.dart';
import '../../../core/money/money_parser.dart';
import '../../../core/time/year_month.dart';
import '../../../shared/models/catalog.dart';
import '../../../shared/models/item_kind.dart';
import '../../../shared/models/snapshot.dart';
import '../../../shared/providers/catalog_providers.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/snapshot_providers.dart';
import '../../../shared/services/wealth_calculator.dart';

/// Una riga del form: la voce, il testo scritto e l'importo interpretato.
@immutable
class DraftLine {
  const DraftLine({
    required this.key,
    required this.itemName,
    required this.categoryName,
    required this.kind,
    required this.amount,
    required this.text,
    this.itemId,
    this.categoryId,
    this.isInvestment = false,
    this.categoryOrder = 0,
    this.itemOrder = 0,
    this.error,
  });

  final String key;
  final String? itemId;
  final String? categoryId;
  final String itemName;
  final String categoryName;
  final ItemKind kind;
  final bool isInvestment;
  final int categoryOrder;
  final int itemOrder;
  final Money amount;
  final String text;
  final MoneyParseError? error;

  String get categoryKey => categoryId ?? 'name:$categoryName';

  DraftLine withText(String newText) {
    try {
      return _copy(text: newText, amount: MoneyParser.parse(newText));
    } on MoneyParseException catch (e) {
      return _copy(text: newText, error: e.error);
    }
  }

  DraftLine _copy({
    required String text,
    Money? amount,
    MoneyParseError? error,
  }) => DraftLine(
    key: key,
    itemId: itemId,
    categoryId: categoryId,
    itemName: itemName,
    categoryName: categoryName,
    kind: kind,
    isInvestment: isInvestment,
    categoryOrder: categoryOrder,
    itemOrder: itemOrder,
    amount: amount ?? this.amount,
    text: text,
    error: error,
  );

  SnapshotItem toSnapshotItem() => SnapshotItem(
    itemId: itemId,
    categoryId: categoryId,
    itemName: itemName,
    categoryName: categoryName,
    kind: kind,
    isInvestment: isInvestment,
    categoryOrder: categoryOrder,
    itemOrder: itemOrder,
    amount: amount,
  );
}

/// Gruppo di righe della stessa categoria, per la visualizzazione.
@immutable
class DraftGroup {
  const DraftGroup({
    required this.key,
    required this.name,
    required this.kind,
    required this.lines,
  });

  final String key;
  final String name;
  final ItemKind kind;
  final List<DraftLine> lines;

  Money get total => Money.sum(lines.map((l) => l.amount));
}

@immutable
class UpdateFormState {
  const UpdateFormState({
    required this.month,
    required this.lines,
    this.snapshotId,
    this.previousNetWorth,
    this.previousMonth,
    this.prefilledFrom,
    this.dirty = false,
    this.saving = false,
    this.missing = false,
    this.lockMonth = false,
  });

  final YearMonth month;

  /// Presente se si sta modificando un aggiornamento esistente.
  final String? snapshotId;
  final List<DraftLine> lines;
  final Money? previousNetWorth;
  final YearMonth? previousMonth;

  /// Mese da cui sono stati copiati i valori iniziali.
  final YearMonth? prefilledFrom;
  final bool dirty;
  final bool saving;

  /// L'aggiornamento richiesto non esiste più.
  final bool missing;

  /// Modifica aperta dallo storico: il mese non si cambia.
  final bool lockMonth;

  bool get isEditing => snapshotId != null;
  bool get hasErrors => lines.any((l) => l.error != null);

  SnapshotTotals get totals =>
      WealthCalculator.totals(lines.map((l) => l.toSnapshotItem()));

  Change get change => WealthCalculator.change(
    totals.netWorth,
    previousNetWorth,
    comparedTo: previousMonth,
  );

  List<DraftGroup> get groups {
    final byKey = <String, List<DraftLine>>{};
    for (final line in lines) {
      byKey.putIfAbsent(line.categoryKey, () => []).add(line);
    }
    final groups = [
      for (final entry in byKey.entries)
        DraftGroup(
          key: entry.key,
          name: entry.value.first.categoryName,
          kind: entry.value.first.kind,
          lines: entry.value,
        ),
    ];
    int orderOf(DraftGroup g) => g.lines.first.categoryOrder;
    groups.sort((a, b) {
      // Prima le attività, poi le passività.
      final byKind = a.kind.index.compareTo(b.kind.index);
      return byKind != 0 ? byKind : orderOf(a).compareTo(orderOf(b));
    });
    return groups;
  }

  UpdateFormState copyWith({
    List<DraftLine>? lines,
    bool? dirty,
    bool? saving,
  }) => UpdateFormState(
    month: month,
    snapshotId: snapshotId,
    lines: lines ?? this.lines,
    previousNetWorth: previousNetWorth,
    previousMonth: previousMonth,
    prefilledFrom: prefilledFrom,
    dirty: dirty ?? this.dirty,
    saving: saving ?? this.saving,
    missing: missing,
    lockMonth: lockMonth,
  );
}

/// Apertura del form: un aggiornamento esistente oppure un mese.
typedef UpdateFormArgs = ({String? snapshotId, YearMonth? month});

final updateFormProvider = NotifierProvider.autoDispose
    .family<UpdateFormController, UpdateFormState, UpdateFormArgs>(
      UpdateFormController.new,
    );

/// Stato del form di aggiornamento mensile. I totali si ricalcolano a ogni
/// tasto, in centesimi.
class UpdateFormController extends Notifier<UpdateFormState> {
  UpdateFormController(this.args);

  final UpdateFormArgs args;
  int _customCounter = 0;

  List<Snapshot> get _snapshots =>
      ref.read(snapshotsProvider).value ?? const [];
  Catalog get _catalog => ref.read(catalogProvider).value ?? Catalog.empty;

  @override
  UpdateFormState build() {
    final snapshotId = args.snapshotId;
    if (snapshotId != null) {
      final snapshot = _snapshots.where((s) => s.id == snapshotId).firstOrNull;
      if (snapshot == null) {
        return UpdateFormState(
          month: args.month ?? ref.read(currentMonthProvider),
          lines: const [],
          missing: true,
        );
      }
      return _fromSnapshot(snapshot, lockMonth: true);
    }
    return _forMonth(args.month ?? ref.read(currentMonthProvider));
  }

  /// Nuovo mese: se esiste già un aggiornamento lo apre in modifica,
  /// altrimenti parte dai valori dell'aggiornamento più vicino.
  UpdateFormState _forMonth(YearMonth month) {
    final existing = _snapshots.where((s) => s.month == month).firstOrNull;
    if (existing != null) return _fromSnapshot(existing, lockMonth: false);

    final previous = _latestBefore(month);
    // I valori partono dall'ultimo aggiornamento precedente: si presume che
    // nulla sia cambiato finché l'utente non dice il contrario. Per un mese
    // più vecchio del primo aggiornamento si usa il primo successivo, invece
    // di partire da zero.
    final source = previous ?? _earliestAfter(month);
    final sourceAmounts = <String, Money>{
      for (final item in source?.items ?? const <SnapshotItem>[])
        if (item.itemId != null) item.itemId!: item.amount,
    };
    final catalog = _catalog;
    final lines = [
      for (final category in catalog.activeCategories)
        for (final item in catalog.itemsOf(category.id))
          _line(
            key: item.id,
            itemId: item.id,
            categoryId: category.id,
            itemName: item.name,
            categoryName: category.name,
            kind: category.kind,
            isInvestment: category.isInvestment,
            categoryOrder: category.sortOrder,
            itemOrder: item.sortOrder,
            amount: sourceAmounts[item.id] ?? Money.zero,
          ),
    ];
    return UpdateFormState(
      month: month,
      lines: lines,
      previousNetWorth: previous == null
          ? null
          : WealthCalculator.totals(previous.items).netWorth,
      previousMonth: previous?.month,
      prefilledFrom: source?.month,
    );
  }

  /// Modifica: le righe sono quelle salvate. Per i mesi passati restano i
  /// nomi di allora; per l'aggiornamento più recente valgono nomi e categorie
  /// attuali e si aggiungono anche le voci nuove.
  UpdateFormState _fromSnapshot(Snapshot snapshot, {required bool lockMonth}) {
    final isLatest = !_snapshots.any((s) => s.month.isAfter(snapshot.month));
    final catalog = _catalog;
    final lines = <DraftLine>[];
    for (var i = 0; i < snapshot.items.length; i++) {
      final saved = snapshot.items[i];
      // L'aggiornamento più recente rappresenta la situazione di oggi: per le
      // voci ancora esistenti valgono nome e categoria attuali, così una voce
      // rinominata (per esempio da "ETF" a "Conto Fineco") compare col nome
      // nuovo. I mesi passati conservano invece i nomi di allora.
      final item = isLatest ? catalog.itemById(saved.itemId) : null;
      final category = item == null
          ? null
          : catalog.categoryById(item.categoryId);
      if (item != null && category != null) {
        lines.add(
          _line(
            key: item.id,
            itemId: item.id,
            categoryId: category.id,
            itemName: item.name,
            categoryName: category.name,
            kind: category.kind,
            isInvestment: category.isInvestment,
            categoryOrder: category.sortOrder,
            itemOrder: item.sortOrder,
            amount: saved.amount,
          ),
        );
      } else {
        lines.add(
          _line(
            key: saved.itemId ?? 'row-$i',
            itemId: saved.itemId,
            categoryId: saved.categoryId,
            itemName: saved.itemName,
            categoryName: saved.categoryName,
            kind: saved.kind,
            isInvestment: saved.isInvestment,
            categoryOrder: saved.categoryOrder,
            itemOrder: saved.itemOrder,
            amount: saved.amount,
          ),
        );
      }
    }
    if (isLatest) {
      final present = {for (final l in lines) l.itemId};
      for (final category in catalog.activeCategories) {
        for (final item in catalog.itemsOf(category.id)) {
          if (present.contains(item.id)) continue;
          lines.add(
            _line(
              key: item.id,
              itemId: item.id,
              categoryId: category.id,
              itemName: item.name,
              categoryName: category.name,
              kind: category.kind,
              isInvestment: category.isInvestment,
              categoryOrder: category.sortOrder,
              itemOrder: item.sortOrder,
              amount: Money.zero,
            ),
          );
        }
      }
    }
    final previous = _latestBefore(snapshot.month);
    return UpdateFormState(
      month: snapshot.month,
      snapshotId: snapshot.id,
      lines: lines,
      previousNetWorth: previous == null
          ? null
          : WealthCalculator.totals(previous.items).netWorth,
      previousMonth: previous?.month,
      lockMonth: lockMonth,
    );
  }

  Snapshot? _earliestAfter(YearMonth month) {
    Snapshot? result;
    for (final s in _snapshots) {
      if (s.month.isAfter(month) &&
          (result == null || s.month.isBefore(result.month))) {
        result = s;
      }
    }
    return result;
  }

  Snapshot? _latestBefore(YearMonth month) {
    Snapshot? result;
    for (final s in _snapshots) {
      if (s.month.isBefore(month) &&
          (result == null || s.month.isAfter(result.month))) {
        result = s;
      }
    }
    return result;
  }

  DraftLine _line({
    required String key,
    required String? itemId,
    required String? categoryId,
    required String itemName,
    required String categoryName,
    required ItemKind kind,
    required bool isInvestment,
    required int categoryOrder,
    required int itemOrder,
    required Money amount,
  }) => DraftLine(
    key: key,
    itemId: itemId,
    categoryId: categoryId,
    itemName: itemName,
    categoryName: categoryName,
    kind: kind,
    isInvestment: isInvestment,
    categoryOrder: categoryOrder,
    itemOrder: itemOrder,
    amount: amount,
    text: amount.isZero ? '' : MoneyFormat.input(amount),
  );

  void updateAmount(String key, String text) {
    state = state.copyWith(
      dirty: true,
      lines: [
        for (final line in state.lines)
          if (line.key == key) line.withText(text) else line,
      ],
    );
  }

  /// Cambia mese (non in modifica dallo storico). I valori non salvati
  /// vengono sostituiti: l'interfaccia chiede conferma prima.
  void selectMonth(YearMonth month) {
    if (state.lockMonth || month == state.month) return;
    if (month.isAfter(ref.read(currentMonthProvider))) return;
    state = _forMonth(month);
  }

  /// Crea la voce nel catalogo e la aggiunge al form con valore zero.
  Future<String> addItem({
    required String name,
    required String categoryId,
  }) async {
    final item = await ref
        .read(catalogProvider.notifier)
        .createItem(categoryId: categoryId, name: name);
    final category = _catalog.categoryById(categoryId);
    if (!ref.mounted) return item.id;
    final key = state.lines.any((l) => l.key == item.id)
        ? 'new-${++_customCounter}'
        : item.id;
    state = state.copyWith(
      dirty: true,
      lines: [
        ...state.lines,
        _line(
          key: key,
          itemId: item.id,
          categoryId: categoryId,
          itemName: item.name,
          categoryName: category?.name ?? '',
          kind: category?.kind ?? ItemKind.asset,
          isInvestment: category?.isInvestment ?? false,
          categoryOrder: category?.sortOrder ?? 0,
          itemOrder: item.sortOrder,
          amount: Money.zero,
        ),
      ],
    );
    return key;
  }

  /// Salva in modo atomico. Tocca solo questo aggiornamento: i mesi
  /// successivi ricalcolano la loro variazione, ma i loro dati non cambiano.
  Future<Snapshot> save() async {
    if (state.hasErrors) throw const AppFailure(FailureKind.invalidData);
    state = state.copyWith(saving: true);
    try {
      final saved = await ref
          .read(snapshotsProvider.notifier)
          .save(
            SnapshotDraft(
              month: state.month,
              snapshotId: state.snapshotId,
              items: [for (final line in state.lines) line.toSnapshotItem()],
            ),
          );
      if (ref.mounted) state = state.copyWith(saving: false, dirty: false);
      return saved;
    } catch (_) {
      if (ref.mounted) state = state.copyWith(saving: false);
      rethrow;
    }
  }
}
