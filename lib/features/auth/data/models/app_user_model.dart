import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/extensions/enum_extensions.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_provider_type.dart';

// Envolve a entidade AppUser, adicionando conversões para Firebase,
// Firestore e cache local. O domínio (AppUser) não conhece nenhum deles.
class AppUserModel extends AppUser {
  static const _googleProviderId = 'google.com';

  const AppUserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.provider,
    super.photoUrl,
  });

  factory AppUserModel.fromEntity(AppUser user) {
    return AppUserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      provider: user.provider,
      photoUrl: user.photoUrl,
    );
  }

  // Converte o User do Firebase Auth para o nosso model.
  factory AppUserModel.fromFirebaseUser(User user) {
    final email = user.email ?? '';
    final displayName = user.displayName?.trim() ?? '';

    final isGoogle = user.providerData
        .any((info) => info.providerId == _googleProviderId);

    return AppUserModel(
      uid: user.uid,
      // Cadastro por e-mail não tem nome: usa a parte antes do @.
      name: displayName.isNotEmpty ? displayName : email.split('@').first,
      email: email,
      photoUrl: user.photoURL,
      provider: isGoogle
          ? AuthProviderType.google
          : AuthProviderType.emailPassword,
    );
  }

  // Lido do cache local. Retorna null se o conteúdo estiver incompleto,
  // para um cache corrompido nunca derrubar o app.
  static AppUserModel? fromCacheJson(Map<String, dynamic> json) {
    final uid = json['uid'];
    final name = json['name'];
    final email = json['email'];
    final providerRaw = json['provider'];

    if (uid is! String || name is! String || email is! String) return null;
    if (providerRaw is! String) return null;

    final provider = AuthProviderType.values.byNameOrNull(providerRaw);
    if (provider == null) return null;

    return AppUserModel(
      uid: uid,
      name: name,
      email: email,
      provider: provider,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  // Documento salvo na coleção "users". O uid é o id do documento,
  // por isso não é repetido aqui dentro.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider.name,
    };
  }

  // Cache local da sessão. Nunca contém senha nem token.
  Map<String, dynamic> toCacheJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider.name,
    };
  }
}