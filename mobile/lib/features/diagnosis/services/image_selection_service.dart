import 'package:image_picker/image_picker.dart';

class ImageSelectionService {
  ImageSelectionService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickFromCamera() {
    return _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
  }

  static Future<XFile?> pickFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
  }
}
