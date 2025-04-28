# sustainU

**A Flutter & PostgreSQL-powered app for NYU students to share meal swipes, leftover groceries, and restaurant deals.**

---

## Project Overview

SustainU is a proof‑of‑concept mobile application built in Flutter, with a backend API (Django/Flutter/FastAPI) and Postgres database. It allows users to:

- **Browse** campus event leftovers, extra groceries, and restaurant deals.
- **Share** their own meal swipes with fellow students.
- **Claim** available meal swipes.
- **Earn & redeem** incentives for dining dollars and merch.
- **Manage** a simple profile.

---

## Prerequisites

1. **Flutter SDK**  
   - Follow the [official install guide](https://flutter.dev/docs/get-started/install) for your OS.  
   - Make sure `flutter doctor` reports no errors.

2. **Android Studio** (or Xcode for iOS)  
   - Install the Android SDK and set up at least one AVD (emulator), or have a physical device connected.  
   - For iOS, install Xcode and open the simulator at least once.

3. **PostgreSQL**  
   - Install PostgreSQL (v12+ recommended).  
   - Create a database and user for sustainU (see **Database Setup** below).

---

## Setup Instructions

## 1. Clone the repo

```bash
git clone https://github.com/eileenxu9/sustainU.git
cd sustainU
```

## 2. Database Setup

1. **Create a database user & database**  
   ```sql
   CREATE USER sustainu_user WITH PASSWORD 'your_password';
   CREATE DATABASE sustainu OWNER sustainu_user;
   ```

2. **Run any provided migrations or schema scripts**  
   If there’s a SQL file in `backend/db/schema.sql`, for example:
   ```bash
   psql -U sustainu_user -d sustainu -f backend/db/schema.sql
   ```

## 3. Backend Configuration & Launch

1. **Install dependencies**  
   ```bash
   pip install -r requirements.txt
   ```

2. **Start the server**  
   ```bash
   python manage.py runserver
   ```

## 4. Front-end (Flutter) Setup

1. **Get packages**  
   From the root (or your Flutter app folder):
   ```bash
   flutter pub get
   flutter clean
   ```

2. **Run on emulator or device**  
   - **Android:**  
     ```bash
     flutter run -d emulator-5554
     ```
   - **iOS (macOS only):**  
     ```bash
     flutter run -d "iPhone-16"
     ```

## 5. Building for Release

- **Android APK:**
  ```bash
  flutter build apk --release
  ```
  The output APK will be in `build/app/outputs/flutter-apk/app-release.apk`.

- **iOS Archive (macOS only):**
  ```bash
  flutter build ios --release
  ```
