import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

// Origens possíveis da nova foto de perfil.
enum PhotoSource { gallery, camera }

// Pergunta ao usuário de onde vem a nova foto.
// Só devolve a escolha: quem decide o que fazer com ela é a tela.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key});

  // Retorna null se o usuário fechar sem escolher.
  static Future<PhotoSource?> show(BuildContext context) {
    return showModalBottomSheet<PhotoSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => const PhotoSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Text(
                'Alterar foto de perfil',
                style: AppTextStyles.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _SourceTile(
              icon: Icons.photo_library_rounded,
              label: 'Escolher da galeria',
              source: PhotoSource.gallery,
            ),
            _SourceTile(
              icon: Icons.photo_camera_rounded,
              label: 'Tirar uma foto',
              source: PhotoSource.camera,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final PhotoSource source;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        label,
        style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () => Navigator.of(context).pop(source),
    );
  }
}