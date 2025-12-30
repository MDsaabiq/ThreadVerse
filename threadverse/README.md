# 🚀 ThreadVerse - Community Discussion Platform

A production-ready, full-stack community discussion platform built with **Flutter (Web)** frontend and **Node.js/MongoDB** backend. Inspired by Reddit's architecture with modern design principles.

---

## 📋 Quick Start

```bash
# Install dependencies
flutter pub get

# Build web version
flutter build web

# Run server
cd build/web && python3 -m http.server 8080

# Access at http://localhost:8080
```

## 🏗️ Architecture

**Clean Architecture** with three layers:
- **Presentation** - UI Screens & Widgets
- **Domain** - Business Logic & Models
- **Data** - Repositories & API Services

## ✨ Features

- ✅ Authentication (Login/Signup)
- ✅ Posts (Text, Image, Link, Poll)
- ✅ Comments (Threaded)
- ✅ Voting System
- ✅ Communities
- ✅ User Profiles
- ✅ Light/Dark/AMOLED themes
- ✅ Responsive design

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Framework** | Flutter 3.38.5 |
| **Language** | Dart 3.10.4 |
| **State Mgmt** | Riverpod 2.6.1 |
| **Navigation** | Go Router 15.1 |
| **HTTP Client** | Dio 5.7.0 |
| **Design** | Material 3 |

## 📁 Project Structure

```
lib/
├── core/                 # Constants, themes, utilities
├── features/            # Feature modules (auth, home, post, etc.)
├── routing/             # Navigation configuration
└── main.dart

samples, guidance on mobile development, and a full API reference.
