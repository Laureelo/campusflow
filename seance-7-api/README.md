# CampusFlow, séance 7

CampusFlow connecté à une API REST avec connexion par jeton. C'est la suite de `seance-6-riverpod` : mêmes écrans, mais les données viennent maintenant d'un serveur.

## Ce qui a changé par rapport à la séance 6

- `api/` : le serveur simulé (json-server et `db.json`), voir son README.
- `lib/core/` : le client Dio, la lecture du jeton dans le stockage sécurisé et l'intercepteur qui ajoute l'en-tête `Authorization`.
- `lib/data/` : le contrat `TaskRepository` avec deux versions, `ApiTaskRepository` (appelle l'API) et `FakeTaskRepository` (données en mémoire, pour les tests). Même principe pour les cours et la connexion.
- `lib/providers/` : `TasksNotifier` est maintenant un `AsyncNotifier`. Les écrans gèrent les trois états (chargement, erreur avec bouton Retry, données).
- Création (POST), case cochée (PATCH) et suppression (DELETE) passent par le repository.
- Connexion : `/login` renvoie un jeton, rangé avec `flutter_secure_storage`. Si le serveur répond 401, le jeton est effacé et l'application revient sur l'écran de connexion.

Les écrans ne connaissent pas Dio : ils lisent seulement les providers.

## Lancer

Dans un premier terminal :

```
cd api
npm install
npm start
```

Dans un second :

```
flutter pub get
flutter run -d edge
```

Compte de démonstration : `awa@campus.test`, mot de passe `campus123`.

L'adresse de l'API dépend de l'appareil. Dans un navigateur ou sur ordinateur c'est `http://localhost:3000`. Sur l'émulateur Android, `localhost` désigne l'émulateur lui-même, donc le code utilise `http://10.0.2.2:3000`. Pour un téléphone réel, on donne l'adresse de l'ordinateur sur le réseau :

```
flutter run --dart-define=API_URL=http://192.168.1.20:3000
```

## Tests

```
flutter test
```

Les tests du repository utilisent un faux adaptateur HTTP, ceux des écrans utilisent `FakeTaskRepository`. Aucun ne demande que le serveur tourne.

## Limites

- L'application a été essayée dans le navigateur (Edge) et par les tests, pas sur un émulateur Android.
- Le jeton est un simple texte aléatoire gardé en mémoire par le serveur, il disparaît quand on le relance. Ce n'est pas un vrai JWT.
- Les textes de l'interface sont en anglais.
