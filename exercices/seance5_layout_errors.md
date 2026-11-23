# Séance 5 : diagnostiquer cinq erreurs de layout

Chaque cas a été reproduit dans un test Flutter sur un écran de 360 × 800 dp, pour vérifier le message réel.

## 1. `Row(children: [Text(titreLong)])`

- **Erreur observée** : `A RenderFlex overflowed by 666 pixels on the right.`
- **Cause** : le texte est plus large que la ligne, et un `Row` ne coupe ni ne passe à la ligne ce qu'il contient.
- **Correction** : entourer le texte d'un `Expanded` (ou `Flexible`), et ajouter `overflow: TextOverflow.ellipsis` pour couper proprement.

## 2. `Column(children: [ListView(...)])`

- **Erreur observée** : `Vertical viewport was given unbounded height.`
- **Cause** : une `Column` donne une hauteur illimitée à ses enfants, et une `ListView` essaie de prendre toute la hauteur disponible, donc elle ne sait pas quelle taille choisir.
- **Correction** : `Expanded(child: ListView(...))`. Pour une liste courte, `shrinkWrap: true` fonctionne aussi, mais on perd l'avantage de ne construire que ce qui est visible.

## 3. `Container(child: Expanded(...))`

- **Erreur observée** : `Incorrect use of ParentDataWidget.`
- **Cause** : `Expanded` ne fonctionne que comme enfant direct d'un `Row`, d'une `Column` ou d'un `Flex`. Dans un `Container`, il n'a personne à qui demander de la place.
- **Correction** : retirer l'`Expanded`, ou placer le `Container` dans un `Row` ou une `Column` et mettre l'`Expanded` à cet endroit.

## 4. `Row(children: [TextField()])`

- **Erreur observée** : exception sur la largeur non bornée (`InputDecorator ... unbounded width`).
- **Cause** : un `TextField` veut occuper toute la largeur disponible, mais un `Row` lui donne une largeur illimitée.
- **Correction** : `Expanded(child: TextField())`, ou un `SizedBox` avec une largeur fixe.

## 5. `Container(width: 500, ...)`

- **Observation** : pas d'erreur dans un `Scaffold` ni dans un `Center`, mais la largeur obtenue est de **360** et non de 500.
- **Cause** : les contraintes descendent du parent, et un enfant ne peut pas dépasser le maximum que son parent lui laisse. Les 500 demandés sont ramenés à 360.
- **À surveiller** : dans un `Row`, la largeur est illimitée sur l'axe principal, donc le `Container` fait vraiment 500 et provoque `A RenderFlex overflowed by 140 pixels`.
- **Correction** : ne pas fixer une largeur absolue. Pour plafonner une largeur, utiliser `ConstrainedBox(constraints: BoxConstraints(maxWidth: 500), ...)`, éventuellement dans un `Center`, ou adapter selon la place disponible avec `LayoutBuilder`.

## Ce qui ressort

Les cinq cas viennent de la même règle du cours : les contraintes descendent, les tailles remontent, le parent positionne. Quand une erreur apparaît, il faut regarder quelles contraintes le parent donne à l'enfant.
