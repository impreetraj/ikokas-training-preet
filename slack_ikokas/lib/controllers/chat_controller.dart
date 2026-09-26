import '../models/message_model.dart';
import '../services/slack_api_service.dart';

class ChatController {
  final SlackApiService _apiService = SlackApiService();

  Future<List<MessageModel>> fetchMessages(String channelId) async {
    try {
      final response = await _apiService.getMessages(channelId);
      if (response['ok'] == true) {
        final List<dynamic> messagesJson = response['messages'] ?? [];
        List<MessageModel> messages = [];
        for (var json in messagesJson) {
          String userStr = json['user'] ?? json['username'] ?? 'Unknown';
          if (userStr.startsWith('U') || userStr.startsWith('W')) {
            userStr = await _apiService.getUserName(userStr);
          }
          json['user'] = userStr;
          messages.add(MessageModel.fromJson(json));
        }
        return messages;
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch messages');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> sendMessage(String channelId, String text) async {
    try {
      final response = await _apiService.sendMessage(channelId, text);
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to send message');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateMessage(String channelId, String ts, String newText) async {
    try {
      final response = await _apiService.updateMessage(channelId, ts, newText);
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to update message');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteMessage(String channelId, String ts) async {
    try {
      final response = await _apiService.deleteMessage(channelId, ts);
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to delete message');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // File Upload
  Future<void> uploadFile(String channelId, String filePath, String filename) async {
    print('--- UPLOAD FILE STARTED ---');
    print('Channel ID: $channelId');
    print('File Path: $filePath');
    print('File Name: $filename');
    
    try {
      print('Calling API: files.upload');
      final response = await _apiService.uploadFile(
        channelId: channelId,
        filePath: filePath,
        filename: filename,
      );
      print('Upload API Response: $response');
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to upload file');
      }
      print('--- UPLOAD FILE SUCCESS ---');
    } catch (e) {
      print('--- UPLOAD FILE FAILED ---');
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Send Location
  Future<void> sendLocation(String channelId, double lat, double lng) async {
    print('--- SEND LOCATION STARTED ---');
    print('Lat: $lat, Lng: $lng');
    try {
      final response = await _apiService.sendLocation(channelId, lat, lng);
      print('Location API Response: $response');
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to send location');
      }
      print('--- SEND LOCATION SUCCESS ---');
    } catch (e) {
      print('--- SEND LOCATION FAILED ---');
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Send Contact
  Future<void> sendContact(String channelId, String name, String phone) async {
    print('--- SEND CONTACT STARTED ---');
    print('Name: $name, Phone: $phone');
    try {
      final response = await _apiService.sendContact(channelId, name, phone);
      print('Contact API Response: $response');
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to send contact');
      }
      print('--- SEND CONTACT SUCCESS ---');
    } catch (e) {
      print('--- SEND CONTACT FAILED ---');
      print('Error: $e');
      throw Exception('Network error: $e');
    }
  }
}
