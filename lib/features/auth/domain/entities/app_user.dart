import 'auth_provider_type.dart';
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final AuthProviderType provider;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.provider,
    this.photoUrl,
  });
}