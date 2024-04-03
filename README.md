# TP : Formulaire de login


## Exercice 1 - Création du formulaire

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

Lors de la soumission du formulaire de connexion, **LoginPage** doit intéragir avec **AuthService** afin de valider les identifiants fournis (appel à la méthode login) :
- Implémentez cette logique


#### Tips :
> Si besoin, aidez-vous des éléments vu dans [le TP sur le Panie de commandes](https://github.com/oulanbator/cours_flutter_panier_de_commandes)

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

## Exercice 4 - Gestion du token

Nous allons également vouloir une classe utilitaire pour recevoir la réponse de l'API. Après avoir observé cette réponse via un client HTTP, je vous donne le code pour cette classe. Attention cette classe n'est adaptée que pour un appel HTTP réussi (200) :
```
class AuthResult {
  final String accessToken;
  final String refreshToken;
  final int expires;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.expires,
  });

  AuthResult.fromJson(Map<String, dynamic> json)
      : accessToken = json['data']['access_token'],
        refreshToken = json['data']['refresh_token'],
        expires = json['data']['expires'];
}
```

Vous pouvez explorer les réponses d'erreur pour impléter des classes utilitaires pour ces cas de figure si vous le souhaitez.


```
// Map<String, dynamic> responseBody = json.decode(response.body);
// Map<String, dynamic> data = responseBody['data'];
// var result = AuthResult.fromJson(data);
// if (result.accessToken != null) {
//   isLoggedIn = true;
//   notifyListeners();
// }
```
