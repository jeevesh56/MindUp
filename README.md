# MindCare (Stress App)

A digital mental health and psychological support app for higher-ed students, built with Flutter and Firebase.

## Features
- AI Chatbot with trigger-word helpline popup
- Mood Tracker with Firestore storage + weekly/monthly charts
- Mood Garden growth stages and animations
- Stress-busting mini-games: Breathing, Memory Match, Bubble Pop (stub)
- Wellness streaks and rewards
- Anonymous peer support forum with anonymous auth and reactions (🤗/✋)

## Prerequisites
- Flutter 3.29.x
- Dart 3.7.x
- A Firebase project (iOS/Android/Web as needed)

## Firebase Setup
1. In Firebase Console, create a project and enable:
   - Authentication → Anonymous sign-in
   - Firestore → Start in test mode (for development) or set security rules
2. Add apps (Android/iOS/Web):
   - Android: add `applicationId`, download `google-services.json` into `android/app/`
   - iOS: download `GoogleService-Info.plist` into `ios/Runner/`
   - Web: follow `flutterfire` config
3. Initialize FlutterFire (optional but recommended):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Then update `main.dart` to use generated `DefaultFirebaseOptions` if you enabled it. This template calls `Firebase.initializeApp()` without options to keep it simple. For production, use the generated options.

## Running
```bash
flutter pub get
flutter run
```

If you hit vector_math or fl_chart errors, this repo pins:
- fl_chart: ^1.1.1
- dependency_overrides: vector_math ^2.2.0

## Collections
- `mood_entries`: { id, userId, moodScore, note, createdAt }
- `user_profiles`: { rewards: string[] }
- `forum_posts`: { id, authorUid, content, createdAt, hugs, highFives }

## Notes
- Chatbot uses a placeholder REST endpoint (`https://example.com/chatbot`). Replace with Dialogflow/Rasa/HuggingFace and add auth headers.
- Helpline popup uses `tel:` to dial a sample number. Replace with local hotlines.
- Firestore rules: tighten before production.

## Scripts
- Run tests:
```bash
flutter test
```
