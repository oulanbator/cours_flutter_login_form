import 'dart:convert';

import 'package:cours_flutter_login_form/constants.dart';
import 'package:cours_flutter_login_form/model/article.dart';
import 'package:http/http.dart' as http;

class ArticleService {
  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse(Constants.uriArticles));

    if (response.statusCode == 200) {
      return parseArticles(response.body);
    } else {
      throw Exception(
          'Failed to load articles. Status : ${response.statusCode}');
    }
  }

  List<Article> parseArticles(String responseBody) {
    final Map<String, dynamic> body = jsonDecode(responseBody);
    final List<dynamic> data = body['data'];

    return data.map((jsonElement) => Article.fromJson(jsonElement)).toList();
  }
}
