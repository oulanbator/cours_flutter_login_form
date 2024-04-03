import 'package:cours_flutter_login_form/model/article.dart';
import 'package:cours_flutter_login_form/service/article_service.dart';
import 'package:cours_flutter_login_form/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () =>
                Provider.of<AuthService>(context, listen: false).logout(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder(
        future: ArticleService().fetchArticles(),
        builder: ((context, snapshot) {
          // Si la data se charge correctement
          if (snapshot.hasData) {
            List<Article> articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) => _listElement(articles[index]),
            );
          }
          // Si on a une erreur
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }
          // En attendant la résolution du future
          return const Center(
            child: CircularProgressIndicator(),
          );
        }),
      ),
    );
  }

  _listElement(Article article) {
    return ListTile(
      title: Text(article.title),
      subtitle: Text(article.body),
    );
  }
}
