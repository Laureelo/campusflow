# Séance 6 : choisir un gestionnaire d'état, avec arguments

| # | Situation | Critère | Choix | Compromis |
|---|---|---|---|---|
| 1 | Compteur de likes local à une carte | L'état appartient à un seul widget et n'est lu nulle part ailleurs : c'est un état éphémère | `setState` (dans un `StatefulWidget`) | Très simple et sans dépendance, mais l'état ne peut pas être partagé. Si la carte devait un jour avertir un autre écran, il faudrait changer d'outil. |
| 2 | Liste de tâches partagée par trois écrans, chargée depuis une API | L'état est partagé entre plusieurs écrans et il est asynchrone (chargement, erreur, donnée) | Riverpod, avec un `Notifier` ou un `AsyncNotifier` et `AsyncValue` | Il faut apprendre le vocabulaire (`Notifier`, `ref`, `AsyncValue`). En échange : pas de transmission de paramètres d'un widget à l'autre, une logique testable sans interface et des états de chargement traités explicitement. |
| 3 | Équipe de vingt développeurs, flux d'événements à auditer | Il faut une structure imposée et une traçabilité de ce qui s'est passé : chaque événement entrant est identifiable | BLoC (événements en entrée, états en sortie) | Plus de code à écrire pour chaque fonctionnalité, mais tout le monde suit la même organisation et chaque changement d'état est relié à un événement qu'on peut enregistrer. |

Le choix suit la portée de l'état : local pour un widget, partagé et asynchrone pour une application moyenne, et fortement encadré pour une grande équipe. `Provider` aurait pu convenir au cas 2, mais il dépend de l'arbre de widgets et il est moins sûr à la compilation, ce qui compte quand trois écrans lisent la même donnée.
