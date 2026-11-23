# Séance 4 : prédire ce qui est reconstruit

```dart
class _CompteurState extends State<Compteur> {
  int n = 0;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Compteur'),
      Text('$n'),
      ElevatedButton(
        onPressed: () => setState(() => n++),
        child: const Text('+1'),
      ),
    ]);
  }
}
```

## 1. Quels widgets sont reconstruits après un appui ?

`setState` marque l'objet État comme « sale », donc sa méthode `build` est rappelée. Elle crée de nouveaux objets pour :

- la `Column`,
- le `Text('$n')`, dont le texte a changé,
- l'`ElevatedButton`, qui reçoit une nouvelle fonction `onPressed`.

## 2. Lesquels ne le sont pas, et pourquoi ?

- Le `const Text('Compteur')` et le `const Text('+1')` : un widget `const` est créé une seule fois à la compilation, donc l'objet est identique d'un `build` à l'autre. Flutter voit que c'est le même objet et ne le reconstruit pas.
- Tout ce qui est au-dessus du widget `Compteur` (par exemple le `Scaffold`) : `setState` ne reconstruit que le sous-arbre de l'État concerné.

## 3. Comment le vérifier avec DevTools ?

Dans le Flutter Inspector de DevTools (ou dans l'extension de l'éditeur), on active l'option qui compte les reconstructions de widgets : chaque widget affiche alors le nombre de fois où il a été reconstruit. Après quelques appuis sur « +1 », les deux `Text` constants restent à zéro alors que `Text('$n')` augmente.

On peut aussi mettre `debugPrintRebuildDirtyWidgets = true` pendant les tests, ce qui affiche dans la console les widgets reconstruits à chaque image.
