# campusflow_app

Three screens of CampusFlow in Flutter (90-minute workshop).

## Screens

- Deadlines: a list of tasks, a floating button and a navigation bar.
- Detail: a card with the task information and a "Mark as done" button.
- Form: a scrollable form with validation and a snackbar message.
- Tablet: from 840 dp wide, the list and the detail are shown side by side.

The models Task, Course and User come from the campusflow_models workshop.

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
