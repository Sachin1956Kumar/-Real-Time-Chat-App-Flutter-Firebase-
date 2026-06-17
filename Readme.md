# Real-Time Chat App (Flutter + Firebase)

A cross-platform real-time chat application built with **Flutter** and **Firebase**, supporting user authentication, live one-to-one messaging, and online/offline presence tracking.

## Features

- **Authentication** — Email/password sign up and login (Firebase Authentication).
- **Real-Time Messaging** — Messages sync instantly between users using Firestore's live listeners (`snapshots()`), no manual refresh needed.
- **Online/Offline Presence** — See which users are currently online, updated automatically on login/logout.
- **Persistent Login** — Returning users skip the login screen automatically if their session is still valid (handled via Firebase's auth state stream).
- **Clean Chat UI** — WhatsApp-style message bubbles (sent vs. received), timestamps, and an auto-scrolling message list.

## Tech Stack

- **Framework:** Flutter (Dart)
- **Backend:** Firebase Authentication, Cloud Firestore
- **State Management:** Native Flutter `StreamBuilder` + `StatefulWidget` (no external state library needed for this scope)

## Project Structure

```
lib/
├── main.dart                  # App entry point, Firebase init, auth routing
├── firebase_options.dart      # Auto-generated Firebase config (see setup below)
├── models/
│   └── message.dart           # Message data model
├── services/
│   ├── auth_service.dart      # Signup / login / logout / presence logic
│   └── chat_service.dart      # Send / stream messages, chat room ID logic
└── screens/
    ├── login_screen.dart
    ├── signup_screen.dart
    ├── users_list_screen.dart # List of all users with online status
    └── chat_screen.dart       # 1-to-1 chat screen
```

## How Real-Time Messaging Works

Each pair of users gets a deterministic **chat room ID**, built by sorting both user IDs alphabetically and joining them (`uid1_uid2`). This guarantees that whether User A opens a chat with User B, or User B opens a chat with User A, they both land in the exact same Firestore document — so messages are never split across two different rooms.

Messages are stored in a subcollection (`chat_rooms/{roomId}/messages`) and read using Firestore's `snapshots()` listener, which pushes new data to the UI the instant a new message is written, with no polling or manual refresh required.

## Setup Instructions

### 1. Prerequisites
- Flutter SDK installed
- A free [Firebase](https://console.firebase.google.com) account

### 2. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com) → **Add Project**.
2. Name it anything (e.g., `flutter-chat-app`).
3. You can disable Google Analytics for this project — not needed here.

### 3. Enable the services this app needs
In your new Firebase project:
- Go to **Build → Authentication → Get Started** → enable **Email/Password** sign-in method.
- Go to **Build → Firestore Database → Create Database** → start in **test mode** for development (see Security Rules note below).

### 4. Connect Flutter to Firebase (FlutterFire CLI)
Run these once on your machine:

```bash
dart pub global activate flutterfire_cli
npm install -g firebase-tools
firebase login
```

Then, inside this project's root folder:

```bash
flutterfire configure
```

This will ask you to select your Firebase project and target platforms (Android/iOS/Web), then **automatically generate a real `lib/firebase_options.dart`** with your project's actual keys — replacing the placeholder file included in this repo.

> **Note:** `firebase_options.dart` is intentionally excluded via `.gitignore` since it contains project-specific keys. If you clone this repo, you must run `flutterfire configure` yourself to generate it — the app will not build without this step.

### 5. Install dependencies and run

```bash
flutter pub get
flutter run
```

### 6. (Recommended) Firestore Security Rules
Test mode leaves your database open to anyone. Before sharing this publicly, update your Firestore rules (Firebase Console → Firestore → Rules) to at least require authentication:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## How to Test

1. Run the app on two devices/emulators (or one emulator + Chrome for web).
2. Sign up with two different email addresses.
3. From one account, tap the other user in the chat list and start messaging — messages should appear instantly on both ends.

## Possible Future Improvements

- Group chat support.
- Image/file sharing in messages.
- Push notifications for new messages (Firebase Cloud Messaging).
- Message read receipts (sent/seen indicators).
- Typing indicators.

## Author

By :- Sachin Kumar — built to apply real-time database concepts and Firebase Authentication in a practical, cross-platform Flutter app.
