class Chat {
  Chat({
    required this.id,
    required this.title,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'] as String,
        title: json['title'] as String,
      );

  final String id;
  final String title;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };
}
