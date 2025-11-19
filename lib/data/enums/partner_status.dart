enum PartnerStatus { 
  //Partner is in the store, app is open, ready for orders
  active,
  //Partner is already handling too many orders
  busy,
  //partner is planned to join suefery
  planned,
  //Partner is closed or logged out
  inactive 
  }

  extension PartnerStatusExtension on PartnerStatus {
  String get name => toString().split('.').last;

  static PartnerStatus fromString(String status) {
    return PartnerStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => PartnerStatus.inactive,
    );
  }
}