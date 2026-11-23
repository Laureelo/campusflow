# CampusFlow

Dépôt du TP de programmation mobile du Master 1 MSI (enseignant : Moctar Compaoré). CampusFlow est une application de suivi des cours, des échéances et des tâches d'un étudiant. Elle est construite séance après séance, de la décision de plateforme jusqu'à une application Flutter connectée à une API avec connexion.

## Où trouver quoi

| Séance | Sujet | Dossier |
|---|---|---|
| 1 | Écosystème mobile : fiche comparative, autopsie de Windows Phone, décision | `docs/seance-1-plateforme` |
| 2 | UX/UI : persona, parcours, wireframes, design system v1 | `docs/seance-2-conception` |
| 3 | Dart : modèles `Task`, `Course`, `User`, `fromJson`, dépôt simulé, tests | `seance-3-models` |
| 4 | Projet Flutter, thème centralisé, package et image | `seance-4-init` |
| 5 | Écrans Échéances, Détail, Formulaire, version tablette | `seance-5-screens` |
| 6 | go_router, Riverpod, filtres | `seance-6-riverpod` |
| 7 | API json-server, Dio, repositories, `AsyncNotifier`, connexion par jeton | `seance-7-api` |
| 3 à 6 | Exercices individuels | `exercices` |

Chaque dossier de code est l'état du projet à la fin de la séance. Le suivant part d'une copie du précédent, comme le demande l'énoncé. L'application complète est dans `seance-7-api`, son README explique comment la lancer avec l'API.

## L'historique

Les séances 1 à 6 ont d'abord été faites dans des dépôts séparés (du 26 octobre au 12 novembre). Je les ai regroupés ici en gardant leurs commits, leurs dates et leurs messages. Les commits du 23 novembre sont la séance 7 et quelques corrections de mise en conformité avec l'énoncé : adresses des routes (`/taches`, `/cours`, `/profil`), route `/login` en séance 6 et étapes du parcours en séance 2.

## Choix de nom

Le code est en anglais. Les adresses de l'application et de l'API (`/taches`, `/cours`, `/utilisateurs`) reprennent celles de l'énoncé. Les documents de conception sont en français.

## Ce qui n'a pas pu être fait

Je n'ai pas d'émulateur Android : Android Studio et le SDK Android ne sont pas installés sur mon poste, donc `flutter doctor` signale encore l'Android toolchain. Les applications ont été lancées dans le navigateur (Edge) et vérifiées par les tests (`flutter test` dans chaque dossier). La partie « émulateur » de la séance 4 et l'adresse `10.0.2.2` de la séance 7 n'ont donc pas été essayées sur un appareil Android.
