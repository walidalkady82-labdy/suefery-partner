enum ItemStatus { pending, available, outOfStock, substituted }
extension ItemStatusExtension on ItemStatus {
  String get name => toString().split('.').last;
  static ItemStatus fromString(String status) {
    return ItemStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => ItemStatus.pending,
    );
  }
}