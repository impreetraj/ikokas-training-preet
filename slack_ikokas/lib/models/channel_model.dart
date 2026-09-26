class ChannelModel {
  final String id;
  final String name;
  final bool isPrivate;

  ChannelModel({
    required this.id,
    required this.name,
    required this.isPrivate,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    String channelName = json['name'] ?? '';
    if (channelName.isEmpty) {
      channelName = json['user'] ?? 'Group Chat / DM';
    }

    return ChannelModel(
      id: json['id'] ?? '',
      name: channelName,
      isPrivate: json['is_private'] ?? json['is_group'] ?? json['is_im'] ?? false,
    );
  }
}
