import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  final String cloudName = 'dkxnoff36';
  final String apiKey = '321464193897924';
  final String apiSecret = '4HWQ6e4lNzRCw8AdsexOUccdd_4';

  Future<Map<String, dynamic>> uploadFile(File file, String resourceType) async {
    final String timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final String signature = _generateSignature(timestamp);
    final Uri uploadUrl = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

    final request = http.MultipartRequest('POST', uploadUrl)
      ..fields['timestamp'] = timestamp
      ..fields['api_key'] = apiKey
      ..fields['signature'] = signature
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseBody);
    } else {
      throw Exception('Failed to upload file: ${response.statusCode} - $responseBody');
    }
  }

  String _generateSignature(String timestamp) {
    final String dataToSign = 'timestamp=$timestamp$apiSecret';
    final hmacSha1 = Hmac(sha1, utf8.encode(apiSecret)); // HMAC-SHA1
    final digest = hmacSha1.convert(utf8.encode(dataToSign));
    return digest.toString();
  }

  Future<List<Map<String, dynamic>>> fetchUploadedFiles(String resourceType) async {
    final Uri listUrl = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/resources/$resourceType');
    
    final response = await http.get(listUrl, headers: {
      HttpHeaders.authorizationHeader: 'Basic ${base64Encode(utf8.encode("$apiKey:$apiSecret"))}',
      HttpHeaders.acceptHeader: 'application/json', // Ensure JSON response
    });

    if (response.statusCode == 200) {
      final List<dynamic> fileList = json.decode(response.body)['resources'];
      return fileList.cast<Map<String, dynamic>>();
    } else {
      print('Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to fetch uploaded files: ${response.statusCode} - ${response.body}');
    }
  }
}
