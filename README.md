# TP : Formulaire de login


## Exercice 1 - Création du formulaire de login

- Modifier le widget Login page pour qu'il ait un champ username et password, et un bouton de connexion
- Il est nécessaire de 'suivre' la valeur des champs pour pouvoir les envoyer au service d'authentification lors de la validation du formulaire. Choisissez l'implémentation qui vous convient le mieux (onChange, controllers, Form avec validation, ...)

## Exercice 2 - Creation du service d'authentification

Ajouter le package provider au projet :

```
flutter pub add provider
```

Le service d'authentification ne va pas communiquer avec un backend dans cet exercice. Il va donc être relativement simple pour le moment :
- il doit être fourni à l'ensemble de notre application et doit donc **extend ChangeNotifier**
- il contient une propriété isLoggedIn (bool) qui va permettre de savoir si l'on est authentifié ou non
- il contient une méthode **login()** qui valide les identifiants "admin" / "password"
- il contient une méthode **logout()**
- login et logout vont mettre à jour **isLoggedIn** et **notifier les listener** de notre service (pour appeler un nouveau rendu).

Nous devons fournir de service à l'ensemble de notre application avec **ChangeNotifierProvider** :
- modifier la fonction **main()** pour refléter cela

Nous devons rediriger l'utilisateur vers **LoginPage** ou **HomePage** en fonction de la valeur de **isLoggedIn** :
- pour faire simple nous pouvons implémenter cela directement dans le fichier app.dart
- mettez en place la logique à l'aide de **Consumer**

Lors de la soumission du formulaire de connexion, **LoginPage** doit intéragir avec **AuthService** afin de valider les identifiants fournis (appel à la méthode **login()**) :
- Implémentez cette logique

Enfin, ajoutez un bouton ou un IconButton (dans l'AppBar par exemple) afin de se déconnecter :
- ce bouton doit également intéragir avec **AuthService** (appel de la méthode **logout()**)

#### Tips :
> Si besoin, aidez-vous des éléments vu dans [le TP sur le Panier de commandes](https://github.com/oulanbator/cours_flutter_panier_de_commandes)

## Exercice 3 - Connexion au backend

On souhaite une réelle authentification dans notre application. Dans une premier temps, on voudrait que la validation des identifiants soit faite par notre API. 
- Ajouter les package http au projet :
```
flutter pub add http
```

- Créer une classe Constants (dans /lib/constants.dart p.ex)
- Ajouter l'url de notre API et l'url d'authentification :
```
  static String apiBaseUrl = "https://bdew32324.webturtle.fr";
  static String uriAuthentification = "$apiBaseUrl/auth/login";
```

A l'exercice précédent nous avions communiqué directement les identifiants du formulaire à notre service. Ils seront mieux encapsulés dans une classe **Credentials** :
- implémenter cette classe avec deux propriétés de type String : **email** et **password**
- implémenter la méthode **toJson()** pour convertir notre objet en une Map que l'on pourra envoyer à notre API.
- modifier la soumission de votre formulaire de login pour tenir compte de ce changement

> Pensez à utiliser le plus possible ce genre de classe utilitaire dans votre code, cela le rend plus lisible et plus facilement maintenable.

Nous devons maintenant revoir l'implémentation de la méthode login (AuthService) :
- elle va communiquer avec l'API de manière asynchrone, elle est donc **async** et renvoie un **Future**
- modifier sa signature pour tenir compte du changement au niveau des paramètre reçu (elle reçoit désormais un Credential)
- nous allons avoir besoin de headers pour notre appel HTTP :
```
var headers = {'Content-Type': 'application/json; charset=utf-8'};
```

- Implémentez l'appel HTTP (POST) et la gestion de la réponse. Aidez-vous des appels POST que nous avons fait dans les précédents TP.

Pour le moment nous souhaitons princiaplement faire ceci en cas de succès (HTTP 200) :
```
isLoggedIn = true;
notifyListeners();
```

- Nous pouvons toutefois rendre notre application un peu plus intéractive en renvoyant un message... (AuthService)
```
if (response.statusCode == 200) {
  isLoggedIn = true;
  notifyListeners();
  return "Vous êtes connecté !";
} else {
  return "Failed to login: ${response.statusCode}";
}
```

- ...que l'on affichera avec un ScaffoldMessenger (LoginPage) :
```
authService.login(credential).then((message) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      content: Text(message),
    ),
  );
});
```

Tentez de vous connecter, avec le compte **admin@webturtle.fr** ou **bdew3@webturtle.fr** !
Top, en principe vous devriez pouvoir vous connecter en vous authentifiant auprès de notre backend !

## Exercice 3-bis - Echouer à afficher des données protégées

Pour le moment, on a réussit à se connecter, mais on ne peut toujorus pas accéder à des ressources protégées.

Allons droit au but pour démontrer cela. J'ai créé une table "articles" qui n'est pas accessible aux utilisateurs non authentifiés (plus précisément, aux **requêtes** non authentifiées).

- Créer une classe Article :
```
class Article {
  final String title;
  final String body;

  Article({required this.title, required this.body});

  Article.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        body = json['body'] as String;
}
```

- Ajouter l'url de la ressource à vos constantes :
```
static String uriArticles = "$apiBaseUrl/items/articles";
```

- Créer une service (ArticleService) pour requêter les données de cette table
```
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
```

- Mettre à jour HomePage pour afficher (ou plutôt essayer d'afficher ^^) les articles dans un ListView. Voici le code de l'ensemble du fichier :
```
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
```

Que se passe t'il ?

## Exercice 4 - Gestion des tokens

A ce stade, nous avons donc une application avec une page Home protégée (on ne peut y accéder qu'une fois "connecté"), mais il nous faut également accéder aux ressources protégées de notre API. Pour cela les requêtes doivent être authentifiées à l'aide du token que nous avons reçu lors de la connexion (pour le moment on n'a fait que réagir à une réponse HTTP 200, sans se préoccuper du contenu de la réponse).

Nous allons utiliser une classe utilitaire pour recevoir la réponse de l'API. Pour information, voici cette réponse :
```
{
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsIns5x8AnvwXk(...)",
    "expires": 900000,
    "refresh_token": "WQaii2GNVYhLsUb89rIU0Wt2mcewFBW-nt5GTBons(...)"
  }
}
```

Je vous donne le code pour l'objet métier dont nous avons besoin. Attention cette classe n'est adaptée que pour un appel HTTP réussi (200) :
```
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final int expires;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
  });

  AuthResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['data']['access_token'],
        refreshToken = json['data']['refresh_token'],
        expires = json['data']['expires'];
}
```

> Notez que je parse directement **json > data > maClé**. Cela va nous permettre d'écrire plus simplement notre méthode pour parser la réponse.

- Parsez les informations reçues :
```
if (response.statusCode == 200) {
  var authResponse = AuthResponse.fromJson(json.decode(response.body));
  await _handleSuccessAuthResponse(authResponse);
  isLoggedIn = true;
  notifyListeners();
  return "Vous êtes connecté !";
} else {
  return "Failed to login: ${response.statusCode}";
}
```

> Nous allons bientôt créer la méthode **_handleSuccessAuthResponse()** (notez qu'elle est asynchrone)

Ce que nous voulons c'est stocker les informations que nous avons reçues. Nous avons besoin de les stocker dans notre AuthService pour pouvoir les utiliser pendant que l'application est ouverte, et les stocker de manière plus durable si l'on souhaite garder en mémoire ces informations pour les prochaines fois où l'on ouvre l'application.

Il y a plusieurs type de "local storage". Pour des données légères et non sensibles il y a par exemple le package shared_preferences qui implémente des fonctions utilitaires faciles d'utilisation. Mais dans le cas d'informations sensibles comme ici, nous avons besoin de stocker les informations encryptées. Nous allons donc nous servir de flutter_secure_storage. A l'utilisation ce n'est cependant pas plus compliqué que shared_preferences.

- installer le package :
```
flutter pub add flutter_secure_storage
```

- dans notre service, nous allons créer trois propriétés pour stocker les éléments reçus, et instancier le secure storage :
```
final secureStorage = const FlutterSecureStorage();
String? _accessToken;
String? _accessTokenExpiration;
String? _refreshToken;
```

- Ajoutez ces clés à vos constantes pour éviter toute faute de frappe par la suite (leur valeur n'a pas vraiment d'importance, mais doit être unique pour chaque donnée que l'on souhaite stocker)
```
static String storageKeyAccessToken = "bdew32324.access_token";
static String storageKeyRefreshToken = "bdew32324.refresh_token";
static String storageKeyTokenExpire = "bdew32324.token_expiration";
```

- implémenter **_handleSuccessAuthResponse()**
```
Future<void> _handleSuccessAuthResponse(AuthResponse authResponse) async {
  // Set les variables dans auth manager
  _accessToken = authResponse.accessToken;
  _refreshToken = authResponse.refreshToken;
  // La réponse nous donne le temps de validité du token,
  // Mais ce que nous souhaitons stocker c'est sa date d'expiration
  DateTime expirationTime =
      DateTime.now().add(Duration(milliseconds: authResponse.expires));
  _accessTokenExpiration = expirationTime.toString();
  
  // Store values dans secure storage
  await secureStorage.write(
    key: Constants.storageKeyAccessToken,
    value: _accessToken!,
  );
  await secureStorage.write(
    key: Constants.storageKeyTokenExpire,
    value: _accessTokenExpiration!,
  );
  await secureStorage.write(
    key: Constants.storageKeyRefreshToken,
    value: _refreshToken!,
  );
}
```

Profitons-en pour tout de suite implémenter la procédure de logout comme il se doit.
Lors de la déconnexion, nous devons invalider les tokens auprès de l'API et supprimer les informations que nous venons de stocker.

- ajouter la ligne suivante à vos constantes :
```
static String uriLogout = "$apiBaseUrl/auth/logout";
```

- mettre à jour la méthode **logout()** :
```
void logout() async {
  // Fait un call HTTP pour invalider les tokens
  var payload = {"refresh_token": _refreshToken!};
  await http.post(Uri.parse(Constants.uriLogout), body: json.encode(payload));
  // Clean variables dans AuthManager
  _accessToken = null;
  _accessTokenExpiration = null;
  _refreshToken = null;
  // Supprime les valeurs du secure storage
  await secureStorage.delete(key: Constants.storageKeyAccessToken);
  await secureStorage.delete(key: Constants.storageKeyTokenExpire);
  await secureStorage.delete(key: Constants.storageKeyRefreshToken);

  isLoggedIn = false;
  notifyListeners();
}
```

Ouf !! Apparement, il n'y a pas grand chose qui a bougé.. on peut toujours se connecter et se déconnecter... mais maintenant nous avons un token pour faire des requêtes authentifiées !!

> Il sera probablement nécessaire à se stade de stoper puis relancer votre application !


## Exercice 5 - Authentifier une requête

L'authentification d'une requête se fait au travers des headers. Afin de permettre à tous nos services d'authentifier leurs requêtes, nous allons centraliser la création de ces headers dans notre AuthService.

- Créer une méthode publique pour obtenir les headers (AuthService), celle-ci s'appuie sur la méthode **_getAccessToken()** que nous allons créer plus loin :
```
Future<Map<String, String>> getAuthenticatedHeaders() async {
  final accessToken = await _getAccessToken();
  return {
    'Authorization': 'Bearer $accessToken',
    'Content-Type': 'application/json; charset=utf-8'
  };
}
```

> Notez que l'on ne renvoie pas directement notre **_accessToken**. En effet, celui-ci pourrait être expiré.

Nous verrons plus loin la logique liée au rafraichissement du token. Pour le moment, renvoyons juste le token que nous avons stocké.

- Implémenter la méthode **_getAccessToken()** :
```
Future<String> _getAccessToken() async {
  return _accessToken!;
}
```

Maintenant nous allons utiliser ces headers dans notre ArticleService afin d'authentifier la requête.

- Ajouter une propriété pour injecter AuthService dans notre ArticleService, ainsi qu'un constructeur adapté :
```
final AuthService authService;
ArticleService({required this.authService});
```

- Mettre à jour la méthode **fetchArticles()** pour passer les headers lors de notre requête :
```
Future<List<Article>> fetchArticles() async {
  var headers = await authService.getAuthenticatedHeaders(); // Ici

  final response = await http.get(Uri.parse(Constants.uriArticles), headers: headers); // Et Ici

  if (response.statusCode == 200) {
    return parseArticles(response.body);
  } else {
    throw Exception(
        'Failed to load articles. Status : ${response.statusCode}');
  }
}
```

Nous devons enfin passer notre AuthService lors de l'instanciation de ArticleService (dans le widget HomePage).

- Récupérer le AuthService avec **Provider.of** : 
```
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var auth = Provider.of<AuthService>(context); // Ici

(... reste de notre code ...)
```

- Injecter le service lors de l'intanciation de ArticleService
```
body: FutureBuilder(
  future: ArticleService(authService: auth).fetchArticles(), // Ici

(... reste de notre code ...)
```

Nous pouvons maintenant charger les articles dans notre page home ! Nos requêtes sont authentifiées !
Mais nous n'avons pas tout à fait fini..


## Exercice 6 - Restaurer notre session grâce au secure storage, et gérer le rafraîchissement du token

Bon nous y sommes presque mais il reste deux problèmes à régler..

Tout d'abord, essayez de vous authentifier, de fermer l'application (stoppez complètement le debug) lorsque vous êtes connectés, puis de relancer l'App. Que se passe t'il ?

> Ce comportement pourrait être souhaitable pour une application hautement sensible. D'ailleurs, généralement les application bancaires, ou plus généralement liées au paiement, vous obligent à vous identifier à nouveau dès lors que l'application a été fermée, voire même lorsque vous l'avez 'minimisée' pendant trop longtemps. 

Dans notre cas, nous souhaiterions toutefois que l'application se serve des informations stockées dans le secure storage pour rétablir notre connexion lorsque nous rouvrons l'App.

- Implémentez un constructeur pour AuthService. Celui-ci doit pouvoir aller chercher les valeurs stockées dans le secure storage :
```
AuthService() {
  _initAuthService();
}
```

- Un constructeur ne peut pas être lui-même async, nous allons donc placer la logique dans la méthode **_initAuthService()** :
```
Future<void> _initAuthService() async {
  // Récupère les valeurs dans le storage
  _accessToken =
      await secureStorage.read(key: Constants.storageKeyAccessToken);
  _accessTokenExpiration =
      await secureStorage.read(key: Constants.storageKeyTokenExpire);
  _refreshToken =
      await secureStorage.read(key: Constants.storageKeyRefreshToken);

  // Si le token est valide, on peut modifier isLoggedIn et notifier les listeners
  if (_isTokenValid()) {
    isLoggedIn = true;
    notifyListeners();
  } else {
    // Sinon, essayer de rafraichir le token
    // _tryToRefreshTokenAndLogin();
  }
}
```

> Notez que nous avons séparé la logique de la méthode **_isTokenValid()** car nous allons nous en reservir plus loin. Notez également que l'on a gardé commentée la méthode **_tryToRefreshTokenAndLogin()**. On y reviendra plus loin.

- Implémenter la méthode **_isTokenValid()** :
```
bool _isTokenValid() {
  // Si nous avons un token et une date d'expiration, vérifier si le token est encore valide
  if (_accessToken != null && _accessTokenExpiration != null) {
    final expirationTime = DateTime.parse(_accessTokenExpiration!);
    // Le token est valide si la date d'expiration est dans le futur
    return expirationTime.isAfter(DateTime.now());
  }
  // Sinon, renvoie false
  return false;
}
```

Notre premier problème est (quasiment) réglé. En l'état si vous fermez l'application et que vous la relancez, votre session devrait être restaurée. En effet, lors de son instanciation, AuthService va tenter de rétablir la session à partir des informations dans le secure storage, et si le token est encore valide, il va passer **isLoggedIn** à true !

Terminons le travail. Il reste à rafraichir le token s'il est expiré, pour cela nous allons nous servir du refreshToken que nous avons aussi gardé en mémoire. 

> Cette partie est plus difficilement testable (il faudrait attendre 15 minutes que notre accesToken expire).. Il va falloir me croire sur parole, je l'ai testé pour vous... En l'état, au bout de 15 minutes notre problème ressurgit !

- Ajouter cette variable à vos constantes :
```
static String uriRefreshToken = "$apiBaseUrl/auth/refresh";
```

- Implémentez la méthode **_tryToRefreshTokenAndLogin()** :
```
Future<void> _tryToRefreshTokenAndLogin() async {
  bool tokenRefreshed = await _tryToRefreshToken();
  if (tokenRefreshed) {
    isLoggedIn = true;
    notifyListeners();
  }
}
```

- Implémentez également la méthode **_tryToRefreshToken()** :
```
Future<bool> _tryToRefreshToken() async {
  // On n'essaie de refresh que si on a un refreshToken disponible
  if (_refreshToken == null) return false;

  final headers = {'Content-Type': 'application/json; charset=utf-8'};
  final body = {"refresh_token": _refreshToken!, "mode": "json"};

  final response = await http.post(
    Uri.parse(Constants.uriRefreshToken),
    headers: headers,
    body: json.encode(body),
  );

  bool success = false;
  if (response.statusCode == 200) {
    var authResponse = AuthResponse.fromJson(json.decode(response.body));
    await _handleSuccessAuthResponse(authResponse);
    success = true;
  }

  return success;
}
```

> Noubliez pas de décommenter la ligne "// _tryToRefreshTokenAndLogin();" dans **_initAuthService()**;

Une fois de plus nous avons séparé ces deux méthodes pour des questions de naming et parce que nous allons nous resservir de **_tryToRefreshToken()**..

Un dernier point à régler, vous vous souvenez que l'on a pas fini d'implémenter **_getAccessToken()** lorsque nous voulions récupérer les headers pour faire une requête authentifiée ?

C'est la dernière étape pour avoir un vrai service d'authentification pleinement fonctionnel !

- Implémentez **_getAccessToken()**, les commentaires sont dans le code :
```
Future<String> _getAccessToken() async {
  if (_isTokenValid()) {
    return _accessToken!;
  }
  // Si le token n'est pas valide, on essaie de refresh
  bool tokenRefreshed = await _tryToRefreshToken();
  if (tokenRefreshed) {
    return _accessToken!;
  }
  // Ce cas de figure ne devrais logiquement jamais arriver, mais si lorsque
  // l'on essaie de récupérer des headers : 1) le token n'est pas valide, et 2) on
  // ne parvient pas à refresh. Alors, on devrait probablement forcer la déconnexion.
  logout();
  return "";
}
```

Bravo ! Tout devrait fonctionner maintenant, c'est vraiment fini :) ! 


## Exercice 7 - Ajoutez une page pour créer un compte

- Constantes à ajouter à l'App
```
static String directusAuthenticatedUserRole = "3d1cdd82-7531-42db-a5cd-21a455179590";
static String directusUserCreatorToken = "phCG4_53ZGOShDuE1J3-pw27exBM7FBm";
static String uriUsers = "$apiBaseUrl/users";
```

- Méthode pour créer un account
```
Future<bool> createAccount(Credential credential) async {
  bool success = false;

  var payload = {
    "email": credential.email,
    "password": credential.password,
    "role": Constants.directusAuthenticatedUserRole
  };

  var headers = {
    'Authorization': 'Bearer ${Constants.directusUserCreatorToken}',
    'Content-Type': 'application/json; charset=utf-8'
  };

  final response = await http.post(
    Uri.parse(Constants.uriUsers),
    headers: headers,
    body: jsonEncode(payload),
  );

  if (response.statusCode == 200) {
    success = true;
  }

  return success;
}
```

- Déplacer la logique de routing dans un composant LoginRouter :
```
class LoginRouter extends StatelessWidget {
  const LoginRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, child) {
        if (auth.isLoggedIn) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
```

> Naviguez vers LoginRouter lorsque vous avez crée un utlisateur ou lorsque vous vous déconnectez.
