# mobile_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# BrgyPilaSmart 🏛️

A Flutter mobile app for barangay residents to request documents (Clearance, Certificate of Residency, ID, etc.) and track their status in real time — powered by Firebase.

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/    app_constants.dart   # routes, doc types, statuses
│   ├── theme/        app_theme.dart       # colors, typography, component styles
│   └── utils/        app_utils.dart       # validators, formatters, snackbar
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── document_request.dart
│   └── services/
│       ├── auth_service.dart              # Firebase Auth + Firestore user
│       └── request_service.dart          # Firestore CRUD for requests
│
└── presentation/
    ├── screens/
    │   ├── auth/        login_screen.dart, registration_screen.dart
    │   ├── home/        home_screen.dart
    │   ├── request/     request_categories_screen.dart, request_form_screen.dart, confirmation_screen.dart
    │   ├── tracker/     status_tracker_screen.dart
    │   └── profile/     profile_screen.dart
    └── widgets/
        ├── common/      app_widgets.dart (AppButton, AppTextField, AppCard, StatusBadge…)
        │                bottom_nav.dart
        └── forms/       image_upload_widget.dart
```

---

## 🚀 Firebase Setup (Required)

### Step 1 — Create Firebase Project
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a project named **BrgyPilaSmart**
3. Enable **Authentication** → Email/Password
4. Enable **Cloud Firestore** → Start in production mode
5. Enable **Firebase Storage**

### Step 2 — Connect Flutter App
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In your project root
flutterfire configure --project=YOUR_PROJECT_ID
```
This generates `lib/firebase_options.dart` automatically.

### Step 3 — Deploy Security Rules
```bash
firebase deploy --only firestore:rules,storage
```

### Step 4 — Add Fonts
Download [Poppins](https://fonts.google.com/specimen/Poppins) and place in:
```
assets/fonts/
  Poppins-Regular.ttf
  Poppins-Medium.ttf
  Poppins-SemiBold.ttf
  Poppins-Bold.ttf
```

### Step 5 — Run
```bash
flutter pub get
flutter run
```

---

## 🗂️ Firestore Collections

### `users/{uid}`
| Field | Type | Description |
|-------|------|-------------|
| fullName | String | |
| email | String | |
| contactNumber | String | |
| address | String | |
| gender | String | |
| birthdate | Timestamp | |
| idImageUrl | String? | Firebase Storage URL |
| isVerified | Boolean | Set by admin |

### `requests/{requestId}`
| Field | Type | Description |
|-------|------|-------------|
| userId | String | Owner UID |
| userName | String | |
| documentType | String | |
| purpose | String | |
| additionalInfo | String? | |
| idImageUrl | String? | |
| status | String | Requested / Verified / Printed / Ready |
| referenceNo | String | e.g. BP-2026-0882 |
| createdAt | Timestamp | |
| timeline | Array | List of StatusUpdate objects |

---

## 👑 Admin Panel
The admin panel (for updating request statuses) is a separate web app. 
To update a request status, call `RequestService().updateStatus(id, newStatus)` 
from an admin-authenticated session.

---

## 📱 Document Types Supported
- Barangay Clearance
- Certificate of Residency
- Barangay ID
- Certificate of Indigency
- Business Clearance

---

## 🔑 Adding Admin Users
In Firebase Console → Functions or directly in Firestore, set a custom claim:
```js
admin.auth().setCustomUserClaims(uid, { admin: true });
```
This allows the Firestore rules to grant admins update access on requests.
