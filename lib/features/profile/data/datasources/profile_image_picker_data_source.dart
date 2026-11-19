import 'package:image_picker/image_picker.dart';

class ProfileImagePickerDataSource {
  ProfileImagePickerDataSource({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickImage() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );
  }
}
