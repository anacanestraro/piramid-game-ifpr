import 'package:image_picker/image_picker.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/profile_photo.dart';
import 'profile_photo_mapper.dart';
import 'profile_photo_picker.dart';

class ImagePickerProfilePhotoPicker implements ProfilePhotoPicker {
  // Uma foto de perfil não precisa de mais que 1024px.
  // Reduzir antes de enviar economiza upload e armazenamento.
  static const _maxDimension = 1024.0;
  static const _imageQuality = 85;

  final ImagePicker _picker;

  ImagePickerProfilePhotoPicker({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  @override
  Future<Result<ProfilePhoto?>> pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
        imageQuality: _imageQuality,
      );

      if (file == null) return const Result.success(null);

      return Result.success(await ProfilePhotoMapper.fromXFile(file));
    } catch (e) {
      return Result.failure(
        Failure('Não foi possível abrir a galeria.', exception: e),
      );
    }
  }
}