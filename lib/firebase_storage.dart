import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file) async {
    try {
      final ref = _storage.ref('uploads/${DateTime.now().millisecondsSinceEpoch}${file.path.split('/').last}');
      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
