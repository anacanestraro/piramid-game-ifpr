import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../core/command/command_state.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_feedback.dart';
import '../../domain/entities/profile_photo.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/profile_photo_viewmodel.dart';
import 'photo_source_sheet.dart';
import 'user_avatar.dart';

// Avatar do usuário logado que, ao ser tocado, permite trocar a foto
// pela galeria ou pela câmera. Reutilizável em qualquer tela.
class ProfilePhotoButton extends StatelessWidget {
  final double size;

  const ProfilePhotoButton({super.key, this.size = 48});

  AuthViewModel get _authViewModel =>
      InjectionContainer.instance.authViewModel;

  ProfilePhotoViewModel get _viewModel =>
      InjectionContainer.instance.profilePhotoViewModel;

  Future<void> _onTap(BuildContext context) async {
    final source = await PhotoSourceSheet.show(context);
    if (source == null || !context.mounted) return;

    switch (source) {
      case PhotoSource.gallery:
        await _changeFromGallery(context);
      case PhotoSource.camera:
        await _changeFromCamera(context);
    }
  }

  Future<void> _changeFromGallery(BuildContext context) async {
    final command = _viewModel.pickFromGalleryCommand;
    await command.execute();

    if (!context.mounted) return;
    _showErrorIfAny(context, command.state.value);
  }

  Future<void> _changeFromCamera(BuildContext context) async {
    // A tela de captura devolve a foto com context.pop(photo).
    final photo = await context.push<ProfilePhoto>(AppRoutes.cameraCapture);
    if (photo == null || !context.mounted) return;

    final command = _viewModel.savePhotoCommand;
    await command.execute(photo);

    if (!context.mounted) return;
    _showErrorIfAny(context, command.state.value);
  }

  // Sucesso não precisa de mensagem: a foto nova já aparece no avatar.
  // Cancelar também não: o usuário sabe que desistiu.
  void _showErrorIfAny(BuildContext context, CommandState state) {
    if (state.isError) AppFeedback.showError(context, state.errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final user = _authViewModel.currentUser.value;
        final isBusy = _viewModel.isBusy.value;
        final canTap = user != null && !isBusy;

        return Semantics(
          button: true,
          label: 'Alterar foto de perfil',
          child: MouseRegion(
            cursor:
                canTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: canTap ? () => _onTap(context) : null,
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatar(
                      name: user?.name ?? '',
                      photoUrl: user?.photoUrl,
                      size: size,
                    ),
                    if (isBusy) _BusyOverlay(size: size),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: _EditBadge(size: size * .38),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Escurece o avatar e mostra o carregamento durante o envio.
class _BusyOverlay extends StatelessWidget {
  final double size;

  const _BusyOverlay({required this.size});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
        ),
        child: Center(
          child: SizedBox(
            width: size * .4,
            height: size * .4,
            child: const CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Ícone de câmera no canto, indicando que o avatar é editável.
class _EditBadge extends StatelessWidget {
  final double size;

  const _EditBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.photo_camera_rounded,
        size: size * .55,
        color: Colors.white,
      ),
    );
  }
}