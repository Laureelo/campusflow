# API simulée de CampusFlow

Serveur REST local fabriqué avec json-server (version 0.17) à partir de `db.json`. Il contient trois ressources : `taches`, `cours` et `utilisateurs`.

## Deux façons de le lancer

```
npm install
npm run raw
```

`raw` lance json-server tel quel, sans authentification. Ouvrir http://localhost:3000/taches dans le navigateur affiche le JSON brut des tâches. json-server écrit directement dans `db.json` : après des essais, `git checkout db.json` remet les données de départ.

```
npm start
```

`start` lance `server.js`, qui ajoute la connexion. Les données repartent de `db.json` à chaque démarrage (la copie de travail est dans `.data/`, ignorée par Git).

## Routes

| Méthode | Adresse | Rôle |
|---|---|---|
| POST | /login | reçoit `{email, password}`, renvoie `{token, user}` ou 401 |
| GET | /me | utilisateur du jeton |
| GET | /taches | liste des tâches |
| POST | /taches | créer une tâche |
| PATCH | /taches/:id | modifier une tâche (par exemple `{"done": true}`) |
| DELETE | /taches/:id | supprimer une tâche |
| GET | /cours | liste des cours |
| GET | /utilisateurs | liste des utilisateurs |

Avec `npm start`, toutes les routes sauf `/login` demandent l'en-tête `Authorization: Bearer <jeton>` et répondent 401 sinon. Un jeton disparaît quand le serveur redémarre, ce qui permet de voir l'application revenir sur l'écran de connexion.

Comptes de démonstration : `awa@campus.test` ou `issa@campus.test`, mot de passe `campus123`.
