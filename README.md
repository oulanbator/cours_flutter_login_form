# TP : Formulaire de login


## Exercice 1 - Création du formulaire

- Modifier le widget Login page pour qu'il ait un champ username et password, et un bouton de connexion
- Il est nécessaire de 'suivre' la valeur des champs pour pouvoir les envoyer au service d'authentification lors de la validation du formulaire. Choisissez l'implémentation qui vous convient le mieux (onChange, controllers, Form avec validation, ...)

## Exercice 2 - Creation du service d'authentification

Le service d'authentification ne va pas communiquer avec un backend dans ce TP. Il va donc être relativement simple :
- il doit être fournit à l'ensemble de notre application et doit donc **extend ChangeNotifier**
- il contient une propriété isLoggedIn (bool) qui va permettre de savoir si l'on est authentifié ou non
- il contient une méthode **login()** qui valide les identifiants "admin/password"
- il contient une méthode **logout()**
- login et logout vont intéragir avec **isLoggedIn** et notifier les listener de notre service (pour appeler un nouveau rendu)

Nous devons fournir de service à l'ensemble de notre application avec **ChangeNotifierProvider** :
- modifier la fonction **main()** pour refléter cela

Nous devons rediriger l'utilisateur vers **LoginPage** ou **HomePage** en fonction de la valeur de **isLoggedIn** :
- pour faire simple nous pouvons implémenter cela directement dans le fichier app.dart
- mettez en place la logique à l'aide de **Consumer**

Enfin, lors de la soumission ddu formulaire de connexion, **LoginPage** doit intéragir avec **AuthService** afin de valider les identifiants fournis :
- Implémentez cette logique
