class AuthModel {
  final String accessToken;
  final String userId;
  final String teamName;

  AuthModel({
    required this.accessToken,
    required this.userId,
    required this.teamName,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    String token = '';
    String uid = '';
    
    if (json.containsKey('authed_user')) {
      token = json['authed_user']['access_token'] ?? '';
      uid = json['authed_user']['id'] ?? '';
    } else {
      token = json['access_token'] ?? '';
    }

    return AuthModel(
      accessToken: token,
      userId: uid,
      teamName: json['team']?['name'] ?? 'Slack Workspace',
    );
  }
}
