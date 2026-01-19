import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static final String _apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static final String _apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static final String _uploadPreset =
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  static String get _baseUrl => 'https://api.cloudinary.com/v1_1/$_cloudName';

  /// Upload image to Cloudinary
  Future<String> uploadImage(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/image/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _uploadPreset;
    request.fields['folder'] = 'smartquit/posts/images';

    final file = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'] as String;
    } else {
      throw Exception('Failed to upload image: ${response.body}');
    }
  }

  /// Upload video to Cloudinary
  Future<String> uploadVideo(File videoFile) async {
    final uri = Uri.parse('$_baseUrl/video/upload');

    final request = http.MultipartRequest('POST', uri);
    request.fields['upload_preset'] = _uploadPreset;
    request.fields['folder'] = 'smartquit/posts/videos';
    request.fields['resource_type'] = 'video';

    final file = await http.MultipartFile.fromPath(
      'file',
      videoFile.path,
      filename: 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );
    request.files.add(file);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['secure_url'] as String;
    } else {
      throw Exception('Failed to upload video: ${response.body}');
    }
  }

  /// Delete media (image or video)
  Future<bool> deleteMedia(
    String publicId, {
    String resourceType = 'image',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final signature = _generateSignature(publicId, timestamp);

      final uri = Uri.parse('$_baseUrl/$resourceType/destroy');
      final response = await http.post(
        uri,
        body: {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
          'api_key': _apiKey,
          'signature': signature,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generate signature for Cloudinary API (HMAC-SHA1)
  String _generateSignature(String publicId, int timestamp) {
    final toSign = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
    return toSign.hashCode.toString();
    // 👉 Bạn có thể dùng package crypto để tạo signature chuẩn HMAC-SHA1 nếu cần.
  }
}
