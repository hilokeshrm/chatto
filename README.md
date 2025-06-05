# Pingly - one on one messaging app

## Overview and Objectives
A simple, clean, and minimal one-on-one chat application aimed at a small to medium community. Users register via Google Account, see a list of all registered members, and can message anyone privately with text and emojis. No presence indicators or notifications. Messages are stored indefinitely. Initial focus is on an MVP with potential for future expansion.

## Target Audience
- Friends or community members who want easy, direct one-on-one communication.  
- Users comfortable with a minimal, straightforward chat experience.

## Core Features and Functionality
- User registration and login with Google Account.  
- Display a list of all registered users with display names.  
- Open messaging: any user can message any other user.  
- Support for text messages and emojis.  
- Chat history stored and accessible indefinitely.  
- No online/offline presence indicators.  
- No push notifications initially (Partially Working).  
- Clean and minimal user interface design.

## High-Level Technical Stack Recommendations
- *Frontend:* Flutter — for building clean, cross-platform (iOS & Android) apps with a single codebase.  
- *Backend & Real-time Database:* Firebase Firestore — handles real-time messaging well, scales with usage, and integrates smoothly with Flutter.  
- *Authentication:* Firebase Authentication with email/password signup — simple and secure out of the box.  
- *Storage:* Firestore for message storage; no heavy media storage needed now.  
- *Hosting:* Not needed initially as Firebase handles backend and authentication.

*Why this stack?*  
Firebase + Flutter is a popular combo for rapid MVP development of chat apps due to real-time data syncing, minimal backend setup, and scalability options as your user base grows.

## Conceptual Data Model
- *Users Collection:*  
  - userId (unique identifier)  
  - displayName  
  - email (for authentication only, not public)  

- *Messages Collection:*  
  - messageId  
  - senderId  
  - receiverId  
  - messageText  
  - timestamp  

## User Interface Design Principles
- Clean, minimal layout focusing on usability and clarity.  
- User list screen with display names only, simple scrollable list.  
- Chat screen showing message bubbles with text and emojis, with timestamps.  
- Simple navigation flow: registration/login → user list → chat screen.  

## Security Considerations
- Use Firebase Authentication to securely manage user identity.  
- Secure Firestore rules to ensure users can only read their own messages and write messages they send.  
- Since it’s an open messaging environment, consider basic abuse prevention in future iterations (e.g., user blocking or reporting).

## Development Phases or Milestones
1. MVP Setup: User registration/login, user list display, basic one-on-one chat with text & emoji support.  
2. Testing and user feedback collection.  
3. Improvements based on feedback (UI tweaks, bug fixes).  
4. Potential feature additions (notifications, presence, media support, blocking) in later versions.

## Potential Challenges and Solutions
- *Real-time syncing:* Firebase handles this well, but test performance on different network speeds.  
- *Security & privacy:* Open messaging requires future attention to abuse prevention; start simple but plan to add moderation tools later.  
- *Scalability:* Firebase scales automatically, but design data model to keep queries efficient (e.g., indexing).  

## Future Expansion Possibilities
- Push notifications for new messages.  
- Presence indicators (online/offline status).  
- Support for images, videos, and other media types.  
- User profiles with avatars and status messages.  
- Blocking and reporting features for community safety.  
- Group chats or channels.

---

# App Structure

```
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


```
