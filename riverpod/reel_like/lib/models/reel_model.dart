class ReelModel {
  final String id;
  final String title;
  final String videoUrl;
  final DateTime createdAt;
  final int likes;

  ReelModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.createdAt,
    this.likes = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'videoUrl': videoUrl,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
    };
  }

  factory ReelModel.fromMap(Map<String, dynamic> map, String id) {
    return ReelModel(
      id: id,
      title: map['title'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      likes: map['likes'] ?? 0,
    );
  }
}
