import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_provider_type.dart';

class AppUserModel extends AppUser {
  static const _googleProviderId = 'google.com';

  const AppUserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.provider,
    super.photoUrl,
  });

  // Converte o User do Firebase Auth para o nosso model.
  factory AppUserModel.fromFirebaseUser(User user) {
    final email = user.email ?? '';
    final displayName = user.displayName?.trim() ?? '';

    final isGoogle = user.providerData
        .any((info) => info.providerId == _googleProviderId);

    return AppUserModel(
      uid: user.uid,
      name: displayName.isNotEmpty ? displayName : email.split('@').first,
      email: email,
      photoUrl: user.photoURL,
      provider: isGoogle
          ? AuthProviderType.google
          : AuthProviderType.emailPassword,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider.name,
    };
  }
}