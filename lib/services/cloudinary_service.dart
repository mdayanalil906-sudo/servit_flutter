import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CloudinaryService {
  static Future<String?> uploadImage(
    String base64Image,
    String folder, {
    void Function(double)? onProgress,
  }) async {
    try {
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload');
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = AppConfig.cloudinaryUploadPreset;
      request.fields['folder'] = folder;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        utf8.encode(base64Image),
        filename: 'upload.jpg',
      ));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
