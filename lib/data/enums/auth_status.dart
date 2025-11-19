enum AuthStatus {
  authenticated,
  awaitingVerification,
  unauthenticated,
  inProgress,
  failure,
  none,
}

extension AuthStatusExtension on AuthStatus {
  String get name => toString().split('.').last;

  static AuthStatus fromString(String status) {
    return AuthStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => AuthStatus.none,
    );
  }
}