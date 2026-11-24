import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/app_feedback.dart';
import '../../../../../core/ui/primary_button.dart';
import '../../../../../core/ui/status_message.dart';
import '../../services/profile_photo_mapper.dart';

// Captura uma foto pela câmera (webcam no Chrome, câmera no celular).
// Devolve a foto com context.pop(ProfilePhoto), ou nada se o usuário
// voltar sem tirar foto.
//
// O CameraController fica na tela (e não na ViewModel) porque é um
// controlador de widget, como o TextEditingController: só existe
// enquanto a tela está aberta e precisa ser descartado com ela.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  // A câmera sempre gera JPEG; usado se o arquivo não informar o tipo.
  static const _capturedContentType = 'image/jpeg';

  CameraController? _controller;
  String? _errorMessage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _startCamera() async {
    // Ao tentar novamente, volta para o estado de carregamento.
    if (_errorMessage != null) setState(() => _errorMessage = null);

    CameraController? controller;

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _showError('Nenhuma câmera encontrada neste dispositivo.');
        return;
      }

      // Prefere a câmera frontal (selfie); se não houver, usa a primeira.
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() => _controller = controller);
    } on CameraException catch (e) {
      await controller?.dispose();
      _showError(_messageFor(e));
    } catch (_) {
      await controller?.dispose();
      _showError('Não foi possível abrir a câmera.');
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final file = await controller.takePicture();
      final photo = await ProfilePhotoMapper.fromXFile(
        file,
        fallbackContentType: _capturedContentType,
      );

      if (!mounted) return;
      context.pop(photo);
    } catch (_) {
      if (!mounted) return;
      AppFeedback.showError(context, 'Não foi possível tirar a foto.');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
  }

  // Os códigos de erro mudam entre web, Android e iOS,
  // então a verificação é feita por trechos do código.
  String _messageFor(CameraException e) {
    final code = e.code.toLowerCase();

    if (code.contains('denied') || code.contains('permission')) {
      return 'Permissão da câmera negada. Libere o acesso nas '
          'configurações do navegador ou do celular.';
    }

    if (code.contains('notfound')) {
      return 'Nenhuma câmera encontrada neste dispositivo.';
    }

    return 'Não foi possível abrir a câmera.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tirar foto',
          style: AppTextStyles.sora(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    final errorMessage = _errorMessage;

    if (errorMessage != null) {
      return StatusMessage(
        icon: Icons.no_photography_rounded,
        title: 'Câmera indisponível',
        message: errorMessage,
        actionLabel: 'Tentar novamente',
        onAction: _startCamera,
      );
    }

    final controller = _controller;

    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CameraPreview(controller),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Tirar foto',
            icon: Icons.camera_alt_rounded,
            isLoading: _isCapturing,
            onPressed: _capture,
          ),
        ],
      ),
    );
  }
}