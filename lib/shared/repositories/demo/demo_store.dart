import '../../models/profile.dart';
import '../../models/snapshot.dart';
import '../../models/wealth_category.dart';
import '../../models/wealth_item.dart';

/// Dati della modalità demo. Vivono solo in memoria: non toccano mai il
/// database e si perdono uscendo dalla demo.
class DemoStore {
  DemoStore({
    required List<WealthCategory> categories,
    required List<WealthItem> items,
    required List<Snapshot> snapshots,
    required this.profile,
  }) : categories = [...categories],
       items = [...items],
       snapshots = [...snapshots];

  final List<WealthCategory> categories;
  final List<WealthItem> items;
  final List<Snapshot> snapshots;
  Profile profile;

  int _counter = 0;

  String nextId(String prefix) => 'demo-$prefix-${++_counter}';
}
