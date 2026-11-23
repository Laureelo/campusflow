# API simulée de CampusFlow

Serveur REST local fabriqué avec json-server (version 0.17) à partir de `db.json`. Il contient trois ressources : `taches`, `cours` et `utilisateurs`.

## Lancer

```
npm install
npm run raw
```

Ouvrir http://localhost:3000/taches dans le navigateur affiche le JSON brut des tâches.

## Routes

| Méthode | Adresse | Rôle |
|---|---|---|
| GET | /taches | liste des tâches |
| POST | /taches | créer une tâche |
| PATCH | /taches/:id | modifier une tâche (par exemple `{"done": true}`) |
| DELETE | /taches/:id | supprimer une tâche |
| GET | /cours | liste des cours |
| GET | /utilisateurs | liste des utilisateurs |

json-server écrit directement dans `db.json` : après des essais, `git checkout db.json` remet les données de départ.
