# Hand Speak

Hand Speak is a Flutter application designed for sign language translation and learning. This app helps users communicate through sign language with features for learning, translating, and practicing.

## Features

- **Sign Language Learning**: Interactive lessons to learn sign language
- **Translation**: Translate between spoken language and sign language
- **Authentication**: User account management with email and Google Sign-in
- **Practice Tools**: Video recording for sign language practice
- **User Profiles**: Personalized learning experience

## Technology Stack

- Flutter for cross-platform mobile development
- Firebase Authentication for user management
- Firebase Firestore for database
- Firebase Storage for storing user videos and images
- Firebase Analytics for usage insights
- Camera API for video recording
- ML Kit for sign language detection

## Installation

1. Clone the repository
2. Install Flutter dependencies:
   ```
   flutter pub get
   ```
3. Run the app:
   ```
   flutter run
   ```

## Requirements

- Flutter SDK
- Firebase account with properly configured project
- Android Studio / VS Code with Flutter and Dart plugins

## Configuration

The app requires Firebase configuration. Make sure to:
- Set up Firebase Authentication with Email/Password and Google Sign-In
- Configure Firestore Database security rules
- Set up Firebase Storage rules for user content