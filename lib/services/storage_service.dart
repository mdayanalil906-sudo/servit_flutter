import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'firebase_service.dart';

class StorageService {
  static Future<String> uploadFile(
    File file,
    String path, {
    void Function(double)? onProgress,
  }) async {
    final ref = FirebaseService.storageRef(path);
    final task = ref.putFile(file);
    task.snapshotEvents.listen((snapshot) {
      if (onProgress != null && snapshot.totalBytes > 0) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });
    await task;
    return await ref.getDownloadURL();
  }

  static Future<String> uploadProfilePhoto(
    File file,
    String uid,
    String folder,
  ) async {
    final ext = file.path.split('.').last;
    final path = '$folder/$uid/profile.${ext}';
    return await uploadFile(file, path);
  }

  static Future<XFile?> pickImage() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  static Future<XFile?> captureImage() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.camera);
  }
}
