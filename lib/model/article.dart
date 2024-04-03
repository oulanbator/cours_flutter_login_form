class Article {
  final String title;
  final String body;

  Article({required this.title, required this.body});

  Article.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        body = json['body'] as String;
}
