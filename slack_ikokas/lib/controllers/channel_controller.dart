import '../models/channel_model.dart';
import '../services/slack_api_service.dart';

class ChannelController {
  final SlackApiService _apiService = SlackApiService();

  Future<List<ChannelModel>> fetchChannels() async {
    try {
      final response = await _apiService.getChannels();
      if (response['ok'] == true) {
        final List<dynamic> channelsJson = response['channels'] ?? [];
        return channelsJson.map((json) => ChannelModel.fromJson(json)).toList();
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch channels');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ChannelModel> createChannel(String name, bool isPrivate) async {
    try {
      final response = await _apiService.createChannel(name, isPrivate: isPrivate);
      if (response['ok'] == true) {
        return ChannelModel.fromJson(response['channel']);
      } else {
        throw Exception(response['error'] ?? 'Failed to create channel');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<ChannelModel> createGroupChat(String userIds) async {
    try {
      final response = await _apiService.openGroupChat(userIds);
      if (response['ok'] == true) {
        return ChannelModel.fromJson(response['channel']);
      } else {
        throw Exception(response['error'] ?? 'Failed to create group chat');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> inviteUser(String channelId, String userIds) async {
    try {
      final response = await _apiService.inviteToChannel(channelId, userIds);
      if (response['ok'] != true) {
        throw Exception(response['error'] ?? 'Failed to invite user');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
