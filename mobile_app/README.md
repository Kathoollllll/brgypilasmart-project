# BrgyPilaSmart Mobile App

## Project Description

BrgyPilaSmart is a Barangay Service Request Mobile Application where residents can request barangay documents online and track the status of their requests.

This system helps reduce long queues and improves the efficiency of barangay services.

---

# Features

## Resident Features

- User Registration
- User Login
- Request Barangay Documents
- Upload Valid ID
- Track Request Status
- Real-time Request Updates

---

# Technologies Used

## Frontend
- Flutter

## Backend
- Firebase Authentication
- Cloud Firestore

## Other Tools
- GitHub
- VS Code

---

# Firebase Services Used

- Firebase Authentication
- Cloud Firestore

---

# Installation Guide

## 1. Clone the Repository

```bash
git clone <repository-link>
```

---

## 2. Open the Project

Open the project using VS Code or Android Studio.

---

## 3. Install Dependencies

```bash
flutter pub get
```

---

## 4. Run the Application

```bash
flutter run
```

---

# Firebase Setup

## Required Firebase Services

- Authentication
- Firestore Database

## Authentication Method

- Email/Password Authentication

---

# Firestore Collections

## users

```text
user_id
- name
- email
```

## requests

```text
request_id
- user_id
- document_type
- status
- id_images
- created_at
```

---

# Notes

This project is developed for educational purposes only.