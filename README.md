# Offline School Manager

A local-first Flutter school/play-school management system. All business data and selected photos are stored on-device. No cloud API, analytics SDK, login service, or remote database is included.

## Included
- Dashboard with students, teachers, outstanding fees, today's birthdays and quick actions.
- Student CRUD with photo capture/gallery, search and class filtering.
- Teacher CRUD with salary tracking.
- Monthly fee records with PAID/PARTIAL/PENDING state calculation.
- Defaulter list and WhatsApp reminder deep-link.
- Local scheduled reminder notifications.
- Settings for school name and reminder preferences.
- SQLite foreign keys, indexes, transactions and safe parameterized queries.
- Local image persistence in application documents.
- GitHub Actions Android build workflow.

## Run
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

For an Android release build:
```bash
flutter build apk --release
```

The repository intentionally does not include generated `android/`, `ios/`, `build/` or `.dart_tool/` directories. The GitHub workflow creates the Android host project with `flutter create` before building.

## Important
This is an offline app. WhatsApp is an optional external hand-off: the app creates a pre-filled message and asks Android to open WhatsApp. The school data itself remains local.
