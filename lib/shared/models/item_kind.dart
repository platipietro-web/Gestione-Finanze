/// Attività (qualcosa che possiedi) o passività (un debito).
enum ItemKind {
  asset('asset'),
  liability('liability');

  const ItemKind(this.dbValue);

  /// Valore salvato nel database (enum `item_kind`).
  final String dbValue;

  static ItemKind fromDb(String value) =>
      values.firstWhere((kind) => kind.dbValue == value, orElse: () => asset);
}
