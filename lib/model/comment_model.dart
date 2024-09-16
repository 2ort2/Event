class CommentModel {
  String id;
  String userId;
  String userName;
  String userImage;
  String content;
  List<String> likes;
  DateTime timestamp;
  List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.content,
    required this.likes,
    required this.timestamp,
    this.replies = const [],
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      userImage: map['userImage'],
      content: map['content'],
      likes: List<String>.from(map['likes'] ?? []), // Conversion explicite en List<String>
      timestamp: (map['timestamp'] ).toDate(),
      replies: (map['replies'] as List<dynamic>? ?? []).map((reply) => CommentModel.fromMap(reply as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'content': content,
      'likes': likes,
      'timestamp': timestamp,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }
}
