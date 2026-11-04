# campusflow_app

Three screens of CampusFlow in Flutter (90-minute workshop).

## Screens

- **Deadlines**: list of tasks (`ListView.builder` of `ListTile`), floating button, `NavigationBar`.
- **Detail**: `Column` and `Card` with a "Mark as done" `FilledButton`.
- **Form**: `Form`, `TextFormField`, validators, `SnackBar`, scrollable.
- **Tablet**: from 840 dp, `LayoutBuilder` shows the list and the detail side by side.

The models (`Task`, `Course`, `User`) come from the `campusflow_models` workshop.

## Structure

```
lib/models/      Task, Course, User
lib/data/        sample data
lib/screens/     the screens
lib/utils/       date formatting
test/            widget tests
```

## Run

```
flutter pub get
flutter run -d edge
flutter test
```
