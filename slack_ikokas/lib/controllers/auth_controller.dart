import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import '../services/slack_api_service.dart';
import '../models/auth_model.dart';

class AuthController {
  final SlackApiService _apiService = SlackApiService();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  final String _clientId = '12112620471601.12095320128551';
  final String _clientSecret = '55f220337075906ebd9e65143f26ee22';
  final String _redirectUri = 'slackikokas://oauth';

  AuthModel? currentUser;

  AuthController() {
    _appLinks = AppLinks();
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(values).replaceAll('=', '');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
  
  Future<void> loginWithOAuth(Function onSuccess, Function(String) onError) async {
  
    final scopes = [
      'channels:history',
      'channels:read',
      'channels:write',
      'chat:write',
      'files:read',
      'files:write',
      'groups:history',
      'groups:read',
      'im:history',
      'im:read',
      'mpim:history',
      'mpim:read',
      'users:read',
    ].join(',');
    
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    final authUrl = Uri.https('slack.com', '/oauth/v2/authorize', {
      'client_id': _clientId,
      'user_scope': scopes,
      'redirect_uri': _redirectUri,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    });

    // Listen for the redirect link
    _linkSubscription?.cancel();
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) async {
      if (uri.scheme == 'slackikokas' && uri.host == 'oauth') {
        final code = uri.queryParameters['code'];
        final error = uri.queryParameters['error'];
        
        if (error != null) {
          onError('OAuth Error: $error');
          return;
        }
        
        if (code != null) {
          try {
            final response = await _apiService.exchangeCode(_clientId, _clientSecret, code, _redirectUri, codeVerifier: codeVerifier);
            if (response['ok'] == true) {
              final authedUser = response['authed_user'];
              final token = authedUser?['access_token'] ?? response['access_token'];
              final userId = authedUser?['id'] ?? 'Unknown User';
              
              if (token == null) {
                onError('Token exchange failed: No access token returned.');
                return;
              }
              
              currentUser = AuthModel(accessToken: token, userId: userId, teamName: response['team']?['name'] ?? 'Slack Workspace');
              
              
              _apiService.setToken(token, username: userId);
              onSuccess();
            } else {
              onError('Token exchange failed: ${response['error']}');
            }
          } catch (e) {
            onError('Error exchanging token: $e');
          }
        }
      }
    });

    try {
      await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      onError('Could not launch browser: $e');
    }

  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
