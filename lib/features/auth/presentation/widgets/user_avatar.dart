import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/name_initials.dart';

// Foto de perfil do usuário logado.
// Mostra a foto da conta (Google ou a enviada pelo usuário) e,
// se não houver foto ou ela não carregar, as iniciais do nome.
class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    final initials = _InitialsCircle(name: name, size: size);

    if (url == null || url.isEmpty) return initials;

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Na web, se o servidor da imagem bloquear o carregamento por
        // CORS, o Flutter usa uma tag <img> do navegador no lugar.
        webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : initials,
        errorBuilder: (context, error, stackTrace) => initials,
      ),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  final String name;
  final double size;

  const _InitialsCircle({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.greenDeep],
        ),
      ),
      child: Text(
        NameInitials.of(name),
        style: AppTextStyles.sora(
          fontSize: size * .38,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}