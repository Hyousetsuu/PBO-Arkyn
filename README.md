# Arkyn 🎮

**Arkyn** is a premium, cross-platform digital game distribution and storefront application built using Flutter. Heavily inspired by Steam's iconic dark aesthetic, Arkyn provides gamers with an interactive hub to discover, purchase, and organize games, manage their social connections, and utilize a virtual wallet. It also equips administrators with a comprehensive dashboard to moderate content, review developer submissions, manage users, and track platform finances.

---

## 🚀 Key Features

### 👤 Gamer Features
- **Firebase Authentication**: Secure registration, login, and real-time state management.
- **Dynamic Storefront**: Curated tabs for "Featured & Recommended" and "Special Offers" showcasing game covers, prices, and developers.
- **Interactive Search**: Real-time queries to discover games within the store.
- **Game Details & Transactions**: Full information page (about text, genre categories, developer metadata) with an integrated checkout.
- **Virtual Wallet & Library**: Players top up their balances, purchase games, and instantly add them to their personal library.
- **Mutual Social System**: Add friends by email using atomic `WriteBatch` Firestore transactions to establish mutual friendships. Displays real-time online status.
- **Gamer Profiles**: Editable profiles where users can change their usernames, update avatars, check balances, and view transaction history.

### 🛡️ Administrator Features
- **Admin Dashboard**: A unified control center with tabs for **Games**, **Users**, **Requests**, and **Funds**.
- **Game Upload & Submission**: Custom form allowing developers/admins to upload games (specifying name, categories, price, image URL, description).
- **Approval Workflow**: Uploaded games are sent to a `pending` collection. Admins review and can either **Approve** (migrating the game to the live storefront) or **Reject** (deleting the entry).
- **User Moderation**: View a comprehensive directory of registered gamers.
- **Developer Funds Management**: Track platform transactions, developer earnings, and total funds.

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (v3.x or newer) - Cross-platform UI toolkit.
- **Language**: [Dart](https://dart.dev/)
- **Database**: [Cloud Firestore](https://firebase.google.com/docs/firestore) - Real-time NoSQL database.
- **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth) - Secured cloud authentication.
- **Storage**: [Firebase Storage](https://firebase.google.com/docs/storage) - Media asset hosting.

---

## 📂 Project Structure

```text
lib/
├── auth/
│   └── user_auth.dart          # Firebase Auth functions (register, login, logout)
├── models/
│   ├── content_model.dart      # Game/product data model (ContentModel)
│   └── user_model.dart         # User profile and inventory data model (UserModel)
├── screens/
│   ├── admin_dashboard.dart    # Main admin navigation hub
│   ├── admin_edit.dart         # Edit existing store listings
│   ├── admin_finance.dart      # Platform finances and developer payouts
│   ├── admin_game_detail.dart  # Admin preview of listing details
│   ├── admin_profile.dart      # Admin specific settings screen
│   ├── edit_game_screen.dart   # Listing configuration
│   ├── edit_profile.dart       # Gamer profile modification
│   ├── friends_screen.dart     # Mutual friends social page
│   ├── game_detail_screen.dart # Public game information page with purchase option
│   ├── game_page.dart          # General listing display
│   ├── home.dart               # User storefront (Featured, Specials, Categories)
│   ├── library_screen.dart     # Gamer purchased items inventory
│   ├── payment.dart            # Checkout flow and transaction handling
│   ├── product_list_page.dart  # Generic product view
│   ├── profile_screen.dart     # Personal gamer card and top-up screen
│   ├── requestadmin.dart       # Admin moderation panel (Pending/Approve/Reject)
│   ├── sign_in_screen.dart     # Auth login UI
│   ├── sign_up_screen.dart     # Auth registration UI
│   ├── upload_game.dart        # Game upload submission screen
│   └── users_list_screen.dart  # Registry view of all system users
├── services/
│   └── content_service.dart    # Cloud Firestore CRUD helper methods for game listings
└── widgets/
    ├── buy_button.dart         # Stylized store payment button
    ├── category_box.dart       # Interactive category badges
    └── game_card.dart          # Reusable storefront game thumbnail/card
```

---

## ⚙️ Configuration & Firebase Setup

To run this application locally, you must link it with your Firebase project:

### 1. Web configuration
Update your credentials in `lib/main.dart` if debugging/building for Web:
```dart
Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_API_KEY",
    appId: "YOUR_APP_ID",
    messagingSenderId: "YOUR_SENDER_ID",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
  ),
);
```

### 2. Android Configuration
Download `google-services.json` from the Firebase Console and place it at:
```text
android/app/google-services.json
```

### 3. iOS Configuration
Download `GoogleService-Info.plist` from the Firebase Console and place it at:
```text
ios/Runner/GoogleService-Info.plist
```

---

## 🏃 Getting Started

### 📋 Prerequisites
Ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.5.3 or newer)
- Android Studio / VS Code with Dart & Flutter Extensions
- Emulator or a physical testing device

### 💻 Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Hyousetsuu/PBO-Arkyn.git
   cd PBO-Arkyn
   ```

2. **Fetch Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the Project**
   ```bash
   # Run on any connected device
   flutter run

   # Target specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d chrome
   ```

4. **Run Unit Tests**
   ```bash
   flutter test
   ```

---

## 🎓 Academic Context
This project was developed for the **Object-Oriented Programming (Pemrograman Berorientasi Objek - PBO)** course (Semester 3), focusing on architecture patterns, client-server databases, real-time sync, transaction batch processing, and modular UI engineering.
