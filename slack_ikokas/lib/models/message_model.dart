class FileAttachment {
  final String name;
  final String url;
  final String permalink;
  final bool isImage;
  final bool isVideo;
  final bool isAudio;

  FileAttachment({
    required this.name,
    required this.url,
    required this.permalink,
    required this.isImage,
    required this.isVideo,
    required this.isAudio,
  });
}

class MessageModel {
  final String text;
  final String user;
  final String ts;
  final List<FileAttachment> attachments;

  MessageModel({
    required this.text,
    required this.user,
    required this.ts,
    this.attachments = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    List<FileAttachment> attachments = [];
    if (json['files'] != null) {
      for (var f in json['files']) {
        String name = f['name'] ?? 'Unknown File';
        String url = f['url_private'] ?? '';
        String permalink = f['permalink'] ?? f['url_private'] ?? '';
        String mimetype = f['mimetype'] ?? '';
        String filetype = f['filetype'] ?? '';
        
        bool isImage = mimetype.startsWith('image/') || ['jpg', 'jpeg', 'png', 'gif'].contains(filetype.toLowerCase());
        bool isVideo = mimetype.startsWith('video/') || ['mp4', 'mov', 'avi', 'mkv'].contains(filetype.toLowerCase());
        bool isAudio = mimetype.startsWith('audio/') || ['mp3', 'm4a', 'wav', 'ogg'].contains(filetype.toLowerCase());
        
        attachments.add(FileAttachment(
          name: name,
          url: url,
          permalink: permalink,
          isImage: isImage,
          isVideo: isVideo,
          isAudio: isAudio,
        ));
      }
    }

    return MessageModel(
      text: json['text'] ?? '',
      user: json['user'] ?? json['username'] ?? 'Unknown',
      ts: json['ts'] ?? '',
      attachments: attachments,
    );
  }
}
