import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class SlackApiService {
  static final SlackApiService _instance = SlackApiService._internal();
  factory SlackApiService() => _instance;

  late Dio _dio;
  String? _accessToken;
  String? _username;

  SlackApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://slack.com/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
    ));
  }

  void setToken(String token, {String? username}) {
    _accessToken = token;
    _username = username;
  }
  
  final Map<String, String> _userNames = {};

  Future<String> getUserName(String userId) async {
    if (!userId.startsWith('U') && !userId.startsWith('W')) {
      return userId;
    }
    if (_userNames.containsKey(userId)) {
      return _userNames[userId]!;
    }
    try {
      final response = await _dio.get(
        'users.info',
        queryParameters: {'user': userId},
      );
      if (response.data['ok'] == true) {
        final name = response.data['user']['real_name'] ?? response.data['user']['name'] ?? userId;
        _userNames[userId] = name;
        return name;
      }
    } catch (_) {}
    // Fallback to the username provided during login if it fails (likely due to missing users:read scope)
    return _username ?? userId;
  }
  
  bool get hasToken => _accessToken != null;
  String? get accessToken => _accessToken;

  Future<Map<String, dynamic>> exchangeCode(String clientId, String clientSecret, String code, String redirectUri, {String? codeVerifier}) async {
    final data = <String, dynamic>{
      'client_id': clientId,
      'client_secret': clientSecret,
      'code': code,
      'redirect_uri': redirectUri,
    };
    if (codeVerifier != null) {
      data['code_verifier'] = codeVerifier;
    }
    
    final response = await _dio.post(
      'oauth.v2.access',
      data: data,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      )
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getChannels() async {
    final response = await _dio.get(
      'users.conversations', 
      queryParameters: {
        'types': 'public_channel,private_channel,mpim',
        'exclude_archived': true,
      }
    );
    
   
    
    return response.data;
  }

  
  Future<Map<String, dynamic>> createChannel(String name, {bool isPrivate = false}) async {
    final response = await _dio.post(
      'conversations.create',
      data: {
        'name': name,
        'is_private': isPrivate,
      }
    );
    return response.data;
  }

  
  Future<Map<String, dynamic>> openGroupChat(String userIds) async {
    final response = await _dio.post(
      'conversations.open',
      data: {
        'users': userIds,
      }
    );
    return response.data;
  }

  
  Future<Map<String, dynamic>> inviteToChannel(String channelId, String userIds) async {
    final response = await _dio.post(
      'conversations.invite',
      data: {
        'channel': channelId,
        'users': userIds,
      }
    );
    return response.data;
  }

  
  Future<Map<String, dynamic>> getMessages(String channelId) async {
    final response = await _dio.get(
      'conversations.history',
      queryParameters: {
        'channel': channelId,
      }
    );
    return response.data;
  }

  
  Future<Map<String, dynamic>> sendMessage(String channelId, String text) async {
    final data = <String, dynamic>{
      'channel': channelId,
      'text': text,
    };
    if (_username != null && _username!.isNotEmpty) {
      data['username'] = _username;
      data['icon_emoji'] = ':bust_in_silhouette:'; 
    }
    
    final response = await _dio.post(
      'chat.postMessage',
      data: data,
    );
    return response.data;
  }

  
  Future<Map<String, dynamic>> updateMessage(String channelId, String ts, String newText) async {
    final response = await _dio.post(
      'chat.update',
      data: {
        'channel': channelId,
        'ts': ts,
        'text': newText,
      }
    );
    return response.data;
  }

  // Delete Message
  Future<Map<String, dynamic>> deleteMessage(String channelId, String ts) async {
    final response = await _dio.post(
      'chat.delete',
      data: {
        'channel': channelId,
        'ts': ts,
      }
    );
    return response.data;
  }


  Future<Map<String, dynamic>> uploadFile({
    required String channelId,
    required String filePath,
    required String filename,
    String? messageText,
  }) async {
    final file = File(filePath);
    final length = await file.length();


    final getUrlResponse = await _dio.get(
      'files.getUploadURLExternal',
      queryParameters: {
        'filename': filename,
        'length': length.toString(),
      },
    );

    if (getUrlResponse.data['ok'] != true) {
      return getUrlResponse.data;
    }

    final uploadUrl = getUrlResponse.data['upload_url'];
    final fileId = getUrlResponse.data['file_id'];

 
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });


    await Dio().post(uploadUrl, data: formData);


    final completeResponse = await _dio.post(
      'files.completeUploadExternal',
      data: {
        'files': [
          {'id': fileId, 'title': filename}
        ],
        'channel_id': channelId,
        'initial_comment': messageText ?? '',
      },
    );

    return completeResponse.data;
  }


  Future<Map<String, dynamic>> sendLocation(String channelId, double lat, double lng) async {
    final locationUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    final data = <String, dynamic>{
      'channel': channelId,
      'text': '📍 *Current Location*\nI am sharing my location with you.\n$locationUrl',
    };

    if (_username != null && _username!.isNotEmpty) {
      data['username'] = _username;
      data['icon_emoji'] = ':round_pushpin:'; 
    }

    final response = await _dio.post('chat.postMessage', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> sendContact(String channelId, String name, String phone) async {
    final data = <String, dynamic>{
      'channel': channelId,
      'text': '👤 *Contact Shared*\n*Name:* $name\n*Phone:* $phone',
    };

    if (_username != null && _username!.isNotEmpty) {
      data['username'] = _username;
      data['icon_emoji'] = ':telephone_receiver:'; 
    }

    final response = await _dio.post('chat.postMessage', data: data);
    return response.data;
  }

  Future<Uint8List> downloadFileBytes(String url) async {
    try {
      final dioNoRedirect = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: false,
        validateStatus: (status) => status != null && status < 400,
      ));

      final redirectResponse = await dioNoRedirect.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );

      if (redirectResponse.statusCode == 302 || redirectResponse.statusCode == 301) {
        final finalUrl = redirectResponse.headers.value('location');
        if (finalUrl != null) {
          final response = await Dio().get<List<int>>(
            finalUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          return Uint8List.fromList(response.data!);
        }
      }
      
      // If it's a 200 OK, the file content is directly in redirectResponse
      return Uint8List.fromList(redirectResponse.data!);
    } catch (e) {
      throw Exception('Download failed: $e');
    }
  }
}
