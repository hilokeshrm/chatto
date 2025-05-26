# chatto

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


lib/
├── main.dart
├── app/
│   ├── app.dart                # Root widget with MaterialApp
│   └── theme.dart              # Material 3 theme
├── core/
│   ├── constants/              # App-wide constants
│   │   └── app_colors.dart
│   ├── services/               # Firebase and other service providers
│   │   ├── firebase_service.dart
│   │   └── auth_service.dart
│   └── utils/                  # Utilities and helper methods
├── features/
│   ├── chat/
│   │   ├── pages/
│   │   │   └── chat_page.dart
│   │   ├── widgets/
│   │   │   └── chat_bubble.dart
│   │   └── models/
│   │       └── message_model.dart
│   ├── discover/
│   │   ├── pages/
│   │   │   └── discover_page.dart
│   │   └── widgets/
│   │       └── discover_card.dart
│   └── menu/
│       ├── pages/
│       │   └── menu_page.dart
│       └── widgets/
│           └── settings_tile.dart
├── navigation/
│   └── bottom_nav.dart         # BottomNavBar logic
└── firebase_options.dart       # Firebase config
