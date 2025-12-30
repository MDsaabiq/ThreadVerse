# ✅ ThreadVerse - Complete Setup & Development Guide

Welcome to **ThreadVerse**! This guide will help you set up, run, and develop the application.

---

## 🚀 Quick Start (5 minutes)

### Prerequisites
- Flutter 3.38.5+
- Dart 3.10.4+
- Modern web browser
- Git

### Run Immediately

```bash
# 1. Navigate to project
cd threadverse

# 2. Install dependencies
flutter pub get

# 3. Build web version
flutter build web

# 4. Serve locally
cd build/web
python3 -m http.server 8080

# 5. Open browser
# Visit: http://localhost:8080
```

✅ **App is running!** You should see the ThreadVerse splash screen.

---

## 📁 Project Structure Overview

```
threadverse/
│
├── lib/
│   ├── main.dart                          # App entry point
│   │
│   ├── core/                              # Shared resources
│   │   ├── constants/
│   │   │   ├── app_colors.dart            # Color palette
│   │   │   └── app_constants.dart         # Constants, regex, routes
│   │   ├── theme/
│   │   │   └── app_theme.dart             # Material 3 themes (3 modes)
│   │   ├── utils/                         # Helper functions
│   │   └── widgets/                       # Reusable widgets
│   │
│   ├── features/                          # Feature modules
│   │   ├── auth/                          # 🔐 Authentication
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── splash_screen.dart
│   │   │   │   │   ├── login_screen.dart
│   │   │   │   │   └── signup_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   ├── repositories/
│   │   │   │   └── services/
│   │   │   └── domain/
│   │   │
│   │   ├── home/                          # 🏠 Home feed
│   │   │   ├── presentation/screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── data/
│   │   │
│   │   ├── post/                          # 📝 Posts & comments
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   ├── create_post_screen.dart
│   │   │   │   │   └── post_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── data/
│   │   │
│   │   ├── community/                     # 👥 Communities
│   │   │   ├── presentation/screens/
│   │   │   │   └── community_screen.dart
│   │   │   └── data/
│   │   │
│   │   ├── profile/                       # 👤 User profiles
│   │   │   ├── presentation/screens/
│   │   │   │   └── profile_screen.dart
│   │   │   └── data/
│   │   │
│   │   └── settings/                      # ⚙️ Settings
│   │       └── presentation/screens/
│   │           └── settings_screen.dart
│   │
│   └── routing/
│       └── app_router.dart                # Go Router configuration
│
├── web/                                   # Web-specific assets
├── assets/                                # Images, icons, fonts
├── test/                                  # Unit & widget tests
│
├── pubspec.yaml                           # Dependencies
├── analysis_options.yaml                  # Lint rules
│
├── README.md                              # Project overview
├── ARCHITECTURE.md                        # Database & system design
├── FEATURE_GUIDE.md                       # How to add features
└── VIVA_EXPLANATION.md                    # Presentation & Q&A
```

---

## 🎯 Understanding the Architecture

### Three-Layer Architecture

**Presentation Layer** (UI)
```
screens/          → Complete pages (e.g., LoginScreen)
├── Widgets        → Reusable components
└── Providers      → State management (Riverpod)
```

**Domain Layer** (Business Logic)
```
models/           → Pure Dart classes
└── interfaces/   → Abstract repository contracts
```

**Data Layer** (Data Access)
```
services/api/     → API calls
repositories/     → Repository implementations
└── models/DTO    → API response objects
```

### Data Flow

```
UI Widget
    ↓
ref.watch(provider)
    ↓
FutureProvider
    ↓
Repository.getMethod()
    ↓
API.request()
    ↓
HTTP Call
    ↓
Parse Response
    ↓
Return to Widget
    ↓
UI Updates
```

---

## 🛠️ Development Workflow

### 1. Feature Development

```bash
# Navigate to project
cd threadverse

# Create feature structure
mkdir -p lib/features/myfeature/{presentation/{screens,widgets},data/{models,repositories,services},domain}

# Edit files in your favorite editor
# The build system auto-hot-reloads changes
```

### 2. Running in Development Mode

#### For Web (Recommended)
```bash
flutter run -d web
```

#### For Linux Desktop
```bash
# First install build tools
sudo apt-get install cmake ninja-build pkg-config libgtk-3-dev

flutter run -d linux
```

### 3. Making Changes

All changes to Dart files in `lib/` are auto-detected:

```bash
# File: lib/features/auth/presentation/screens/login_screen.dart
# Save → Auto-reload → See changes immediately
```

### 4. Building for Production

```bash
# Web (CanvasKit renderer for better graphics)
flutter build web --release --web-renderer=canvaskit

# Output in: build/web/
```

---

## 📚 Key Files Explained

### `lib/main.dart`
```dart
// Entry point of the app
// Sets up ProviderScope for Riverpod
// Configures themes and routing
```

### `lib/core/constants/app_constants.dart`
```dart
// All app-wide constants
// Routes, API endpoints, regex patterns
// Limits (max post length, etc)
```

### `lib/core/theme/app_theme.dart`
```dart
// Material 3 themes
// Light, Dark, AMOLED modes
// Customize colors, fonts, spacing
```

### `lib/routing/app_router.dart`
```dart
// All routes defined here
// Deep linking support
// Error handling
```

### `lib/features/[feature]/presentation/screens/`
```dart
// Feature's main screens
// Use Riverpod providers for state
// Call repositories for data
```

---

## 🎨 Theme System

### Using Themes

```dart
// Access theme
Color primary = Theme.of(context).primaryColor;
TextStyle title = Theme.of(context).textTheme.headlineMedium!;

// Access custom colors
import 'package:threadverse/core/constants/app_colors.dart';
Color upvote = AppColors.upvote;
Color downvote = AppColors.downvote;
```

### Three Themes Available

1. **Light Mode** (Default on day)
   - White backgrounds
   - Dark text
   - Subtle shadows

2. **Dark Mode** (Default on night)
   - Dark gray backgrounds
   - Light text
   - Reduced eye strain

3. **AMOLED Mode** (Battery saving)
   - Pure black backgrounds
   - Only on OLED displays
   - Maximum battery life

---

## 🔄 State Management with Riverpod

### Provider Types

```dart
// Simple provider (singleton)
final myServiceProvider = Provider((ref) => MyService());

// Async provider (fetch data)
final postsProvider = FutureProvider((ref) async {
  return await repo.getPosts();
});

// Family provider (with parameters)
final postProvider = FutureProvider.family<Post, String>((ref, postId) async {
  return await repo.getPost(postId);
});

// State notifier (mutable state)
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
```

### Using in Widgets

```dart
// In ConsumerWidget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch provider (rebuilds when data changes)
    final data = ref.watch(postsProvider);

    // Handle loading/error/success states
    return data.when(
      data: (posts) => ListView(children: posts.map(PostCard.new)),
      loading: () => const LoadingWidget(),
      error: (err, st) => ErrorWidget(error: err),
    );
  }
}
```

---

## 🚦 Navigation

### Navigate Between Screens

```dart
// Using go_router
import 'package:go_router/go_router.dart';

// Navigate by path
context.go('/post/123');

// Navigate by name
context.pushNamed('post-detail', pathParameters: {'id': '123'});

// Navigate with query parameters
context.go('/create-post?communityId=r_flutter');

// Go back
context.pop();
```

### Add New Route

```dart
// In lib/routing/app_router.dart
GoRoute(
  path: '/myroute/:id',
  name: 'my-route',
  pageBuilder: (context, state) {
    final id = state.pathParameters['id']!;
    return MaterialPage(
      key: state.pageKey,
      child: MyScreen(id: id),
    );
  },
),
```

---

## 🔐 Authentication Flow

### Current Implementation
1. User enters credentials
2. Validate on client side
3. Show success message
4. Navigate to home (TODO: Connect to backend)

### When Backend is Ready
1. Send credentials to `/api/auth/login`
2. Receive JWT token
3. Store token in SharedPreferences
4. Include token in all API requests
5. Auto-refresh token before expiration
6. Clear token on logout

---

## 🐛 Debugging

### Enable Debug Logging

```dart
// In lib/main.dart
void main() {
  // Enable verbose logging
  debugPrint('ThreadVerse starting...');
  
  runApp(const ThreadVerseApp());
}
```

### Hot Reload Issues

If hot reload doesn't work:
```bash
# Full restart
flutter run -d web
# Press 'R'
```

### Check Errors

```bash
# Run analyzer
flutter analyze

# Check for issues
flutter pub outdated

# Lint your code
dart fix --dry-run  # Preview
dart fix           # Apply fixes
```

---

## 📝 Adding New Features

### Complete Example: Add "Like" Feature

```bash
# 1. Create feature folder
mkdir -p lib/features/like/data/{models,repositories,services}

# 2. Create models
# lib/features/like/data/models/like_dto.dart
class LikeDTO {
  final String userId;
  final String targetId;
  final String targetType;
  
  LikeDTO.fromJson(Map json) : ...
}

# 3. Create API
# lib/features/like/data/services/like_api.dart
class LikeAPI {
  Future<void> likePost(String postId) async {
    await _dio.post('/api/posts/$postId/like');
  }
}

# 4. Create repository
# lib/features/like/data/repositories/like_repository.dart
abstract class LikeRepository {
  Future<void> likePost(String postId);
  Future<void> unlikePost(String postId);
}

# 5. Create providers
# lib/features/like/presentation/providers.dart
final likePostProvider = StateNotifierProvider((ref) {
  return LikeNotifier(repo);
});

# 6. Use in UI
# In PostCard widget:
IconButton(
  icon: const Icon(Icons.favorite),
  onPressed: () => ref.read(likePostProvider.notifier).like(post.id),
)
```

---

## 📊 Project Statistics

```
📦 Project Size
├── Dart Code: ~5000+ lines
├── Files: 40+ Dart files
├── Features: 7 (Auth, Home, Post, Comment, Community, Profile, Settings)
├── Themes: 3 (Light, Dark, AMOLED)
└── Responsive breakpoints: 3 (Mobile, Tablet, Desktop)

🎨 UI Components
├── Screens: 7
├── Custom Widgets: 0 (using Material components)
├── Colors: 25+ in palette
└── Animations: Smooth transitions

🔧 Technical
├── State Management: Riverpod
├── Navigation: Go Router
├── HTTP Client: Dio
├── Code Architecture: Clean Architecture
└── Design System: Material 3
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Generate coverage report
flutter test --coverage

# View coverage
# Linux: genhtml coverage/lcov.info -o coverage/
# macOS: open coverage/index.html
```

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Project overview |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Database & system design |
| [FEATURE_GUIDE.md](FEATURE_GUIDE.md) | How to add features |
| [VIVA_EXPLANATION.md](VIVA_EXPLANATION.md) | Presentation & viva answers |

---

## 🚀 Next Steps

### For Backend Development
1. Create separate `threadverse-backend` folder
2. Initialize Node.js project with Express
3. Setup MongoDB connection
4. Implement API endpoints
5. Add authentication (JWT)
6. Connect Flutter frontend to backend

```bash
# Backend setup (separate folder)
mkdir ../threadverse-backend
cd ../threadverse-backend
npm init -y
npm install express mongoose dotenv
```

### For Frontend Enhancement
1. Implement Riverpod providers for each feature
2. Add API service calls
3. Create unit and widget tests
4. Optimize performance with caching
5. Add offline support

---

## 💡 Tips & Best Practices

### Code Quality
✅ Run `flutter format lib/` before committing
✅ Run `flutter analyze` to catch issues
✅ Follow Dart naming conventions
✅ Write meaningful comments
✅ Keep functions small (<50 lines)

### Performance
✅ Use `const` constructors
✅ Cache network images
✅ Lazy-load lists with ListView.builder
✅ Use proper indexing in database
✅ Profile with DevTools

### Security
✅ Never hardcode API keys
✅ Validate input on both frontend & backend
✅ Use HTTPS for all API calls
✅ Hash passwords (backend)
✅ Clear sensitive data on logout

### Architecture
✅ Keep layers separate
✅ Use dependency injection
✅ Make repositories abstract
✅ Test business logic
✅ Document complex logic

---

## 🤝 Contributing

```bash
# Create feature branch
git checkout -b feature/amazing-feature

# Make changes
git add .
git commit -m "feat: Add amazing feature"

# Format code
flutter format lib/

# Analyze
flutter analyze

# Push to GitHub
git push origin feature/amazing-feature

# Create Pull Request
```

---

## 📞 Support

- 📧 Email: support@threadverse.com
- 🐛 Found a bug? Open an issue
- 💡 Have an idea? Start a discussion
- 📚 Need help? Check FEATURE_GUIDE.md

---

## 📋 Checklist for Using This Project

- [ ] Clone repository
- [ ] Run `flutter pub get`
- [ ] Read README.md
- [ ] Review ARCHITECTURE.md
- [ ] Build and run web version
- [ ] Navigate around the app
- [ ] Read FEATURE_GUIDE.md
- [ ] Try adding a small feature
- [ ] Read VIVA_EXPLANATION.md for context
- [ ] Setup backend (separate folder)
- [ ] Connect frontend to backend API

---

## 🎉 You're All Set!

```
 _______ _                        _     _____                      
|__   __| |                      | |   |_   _|                     
   | |  | |__  _ __ ___  __ _  __| |     | |  __   _____ _ ___  ___
   | |  | '_ \| '__/ _ \/ _` |/ _` |     | | / /\ / / _ \ '__/ __|
   | |  | | | | | |  __/ (_| | (_| |    _| |/ / \/ /  __/ |  \__ \
   |_|  |_| |_|_|  \___|\__,_|\__,_|   |_|\_/\_/ \_\___|_|  |___/
```

Happy coding! 🚀

