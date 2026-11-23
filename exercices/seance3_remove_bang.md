# Séance 3 : supprimer tout usage de « ! »

Le code de départ était :

```dart
String resume(Task t) {
  return t.titre + ' : ' + t.description!.trim();
}
```

Le `!` dit au compilateur « fais-moi confiance, ce n'est pas null ». Si la description est absente, le programme plante à l'exécution. Les trois corrections sont dans `seance3_remove_bang.dart`, avec la description en `String?`.

| Correction | Idée | Résultat si la description est absente |
|---|---|---|
| `??` | Valeur par défaut : `(task.description ?? 'None').trim()` | `Flutter workshop : None` |
| `if` | On traite le cas null à part, puis le compilateur sait que la valeur n'est plus null | `Flutter workshop : no description` |
| `?.` | On ne fait rien si c'est null : `task.description?.trim()` | `Flutter workshop` (sans les deux-points) |

Pour moi, le `if` est le plus lisible quand le cas null demande un traitement particulier, `??` convient quand il existe une valeur par défaut évidente, et `?.` quand on peut simplement ignorer l'absence.

Lancer : `dart run seance3_remove_bang.dart`
