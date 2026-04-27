// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;

// class BackendService {
//   static const String _baseUrl =
//       'https://dna-gen-backend-production.up.railway.app';
//   static const String _authenticateEndpoint = '/api/authenticate';

//   Future<Map<String, dynamic>> authenticateImageUrl(String imageUrl) async {
//     try {
//       final uri = Uri.parse('$_baseUrl$_authenticateEndpoint');

//       print('🔗 Sending request to: $uri');
//       print('📷 Image URL: $imageUrl');

//       final response = await http
//           .post(
//             uri,
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({'imageUrl': imageUrl}),
//           )
//           .timeout(
//             const Duration(seconds: 60),
//             onTimeout: () {
//               throw 'Request timeout - backend took too long to respond';
//             },
//           );

//       print('✅ Response status: ${response.statusCode}');
//       print('📦 Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body) as Map<String, dynamic>;
//         return data;
//       } else {
//         throw 'Server returned ${response.statusCode}: ${response.body}';
//       }
//     } on SocketException {
//       throw 'No internet connection';
//     } on http.ClientException {
//       throw 'Connection failed - check backend URL';
//     } on FormatException {
//       throw 'Invalid response format from server';
//     } catch (e) {
//       throw 'Failed to authenticate image: ${e.toString()}';
//     }
//   }

//   // Health check to verify backend is running
//   Future<bool> checkHealth() async {
//     try {
//       final uri = Uri.parse('$_baseUrl/health');
//       final response = await http.get(uri).timeout(const Duration(seconds: 10));

//       print('Health check: ${response.statusCode}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('❌ Health check failed: $e');
//       return false;
//     }
//   }
// }


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