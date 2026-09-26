import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GeminiService {
  final Dio _dio = Dio();

  Future<String> getChatResponse(String message) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key not found or invalid. Please check your .env file.');
      }

  
      final String modelName = 'gemini-flash-latest'; 
      
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
        data: {
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content['parts'] != null && content['parts'].isNotEmpty) {
            return content['parts'][0]['text'];
          }
        }
        return 'No response from AI.';
      } else {
        throw Exception('Failed to load response: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        return 'Network Error: ${e.message}';
      }
      return 'Error: $e';
    }
  }
}

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});
