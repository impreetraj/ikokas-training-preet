import 'package:dio/dio.dart';
import '../constants.dart';

class WhatsAppService {
  final Dio _dio = Dio();

  Future<String?> sendOTP(String phoneNumber, String otp) async {
    final String url = 'https://graph.facebook.com/v19.0/${Constants.phoneNumberId}/messages';

    final payload = {
      "messaging_product": "whatsapp",
      "to": phoneNumber,
      "type": "template",
      "template": {
        "name": Constants.otpTemplateName, 
        "language": {
          "code": "en_US"
        },
      }
    };

    try {
      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Constants.metaAccessToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Message sent successfully: ${response.data}');
        return null; 
      } else {
        return 'Failed: ${response.data}';
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data != null ? e.response!.data.toString() : e.message;
      return 'DioError: $errorMsg';
    } catch (e) {
      return 'Error: $e';
    }
  }

  
  Future<Map<String, dynamic>?> sendTextMessage(String phoneNumber, String messageText) async {
    // Naya URL: Ab app seedha Render server (Backend) ko message bhejegi
    final String url = 'https://api-whatsapp-cloud.onrender.com/api/messages/send';

    // Naya Payload jo aapke Node.js backend me define kiya gaya hai
    final payload = {
      "phone": phoneNumber,
      "message": messageText
    };

    try {
      final response = await _dio.post(
        url,
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Message sent successfully!');
        return response.data; // e.g. { "success": true, "data": { "messageId": "..." } }
      } else {
        return {'error': 'Failed: ${response.data}'};
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data != null ? e.response!.data.toString() : e.message;
      return {'error': 'API Error:\n$errorMsg'};
    } catch (e) {
      return {'error': 'Error: $e'};
    }
  }

  // Nayi API: Home screen ke liye saari chats mangwana
  Future<List<dynamic>> getChats() async {
    final String url = 'https://api-whatsapp-cloud.onrender.com/api/chats';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return response.data; // List of chats return hogi
      }
    } catch (e) {
      print('Error fetching chats: $e');
    }
    return [];
  }

  // Nayi API: Chat screen ke liye purani messages ki history mangwana
  Future<List<dynamic>> getChatHistory(String phone) async {
    final String url = 'https://api-whatsapp-cloud.onrender.com/api/chats/$phone';
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return response.data; // List of messages return hogi
      }
    } catch (e) {
      print('Error fetching chat history: $e');
    }
    return [];
  }
}
