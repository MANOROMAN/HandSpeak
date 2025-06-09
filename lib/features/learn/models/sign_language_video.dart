class SignLanguageVideo {
  final String title;
  final String videoId;
  final String thumbnailUrl;
  final SignLanguageType type;
  final String category;
  final String? description;

  SignLanguageVideo({
    required this.title,
    required this.videoId,
    required this.type,
    required this.category,
    this.description,
  }) : thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  factory SignLanguageVideo.fromJson(Map<String, dynamic> json) {
    return SignLanguageVideo(
      title: json['title'] as String,
      videoId: json['videoId'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      type: SignLanguageType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SignLanguageType.turkish,
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoId': videoId,
      'category': category,
      'description': description,
      'type': type.toString(),
    };
  }
}

enum SignLanguageType {
  turkish,
  american,
}
