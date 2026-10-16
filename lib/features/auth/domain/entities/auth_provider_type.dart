enum AuthProviderType { emailPassword, google }

extension AuthProviderTypeLabel on AuthProviderType {
  String get label {
    switch (this) {
      case AuthProviderType.emailPassword:
        return 'E-mail e senha';
      case AuthProviderType.google:
        return 'Google';
    }
  }
}