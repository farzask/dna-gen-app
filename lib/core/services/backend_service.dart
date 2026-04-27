import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendService {
  static const String _baseUrl = 'https://api.dnagen.ai/api';

  Future<String> embedWatermark({
    required File image,
    required String fingerprint,
  }) async {
    final uri = Uri.parse('$_baseUrl/embed');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['fingerprint'] = fingerprint;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return json['download_url'] as String;
      }
      throw Exception(json['message'] ?? 'Embed failed');
    }
    throw Exception('Embed request failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> verifyWatermark({required File image}) async {
    final uri = Uri.parse('$_baseUrl/verify');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['success'] == true) {
        return json;
      }
      throw Exception('Verification returned unsuccessful response');
    }
    throw Exception('Verify request failed: ${response.statusCode}');
  }
}