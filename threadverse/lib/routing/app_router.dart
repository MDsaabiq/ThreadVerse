import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:threadverse/core/constants/app_constants.dart';
import 'package:threadverse/features/auth/presentation/screens/login_screen.dart';
import 'package:threadverse/features/auth/presentation/screens/signup_screen.dart';
import 'package:threadverse/features/auth/presentation/screens/splash_screen.dart';
import 'package:threadverse/features/home/presentation/screens/home_screen.dart';
import 'package:threadverse/features/post/presentation/screens/create_post_screen.dart';
import 'package:threadverse/features/post/presentation/screens/post_detail_screen.dart';
import 'package:threadverse/features/community/presentation/screens/community_screen.dart';
import 'package:threadverse/features/community/presentation/screens/create_community_screen.dart';
import 'package:threadverse/features/profile/presentation/screens/profile_screen.dart';
import 'package:threadverse/features/settings/presentation/screens/settings_screen.dart';

/// App routing configuration using GoRouter
/// Handles navigation, deep linking, and route guards
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.routeSplash,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.routeSplash,
        name: 'splash',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),

      // Authentication Routes
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppConstants.routeSignup,
        name: 'signup',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SignupScreen()),
      ),

      // Home Routes
      GoRoute(
        path: AppConstants.routeHome,
        name: 'home',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const HomeScreen()),
      ),

      // Post Routes
      GoRoute(
        path: '${AppConstants.routePost}/:postId',
        name: 'post-detail',
        pageBuilder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return MaterialPage(
            key: state.pageKey,
            child: PostDetailScreen(postId: postId),
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeCreatePost,
        name: 'create-post',
        pageBuilder: (context, state) {
          final communityId = state.uri.queryParameters['communityId'];
          return MaterialPage(
            key: state.pageKey,
            child: CreatePostScreen(communityId: communityId),
          );
        },
      ),

      GoRoute(
        path: AppConstants.routeCreateCommunity,
        name: 'create-community',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const CreateCommunityScreen(),
        ),
      ),

      // Community Routes
      GoRoute(
        path: '${AppConstants.routeCommunity}/:communityId',
        name: 'community',
        pageBuilder: (context, state) {
          final communityId = state.pathParameters['communityId']!;
          return MaterialPage(
            key: state.pageKey,
            child: CommunityScreen(communityId: communityId),
          );
        },
      ),

      // Profile Routes
      GoRoute(
        path: '${AppConstants.routeProfile}/:username',
        name: 'profile',
        pageBuilder: (context, state) {
          final username = state.pathParameters['username']!;
          return MaterialPage(
            key: state.pageKey,
            child: ProfileScreen(username: username),
          );
        },
      ),

      // Settings Routes
      GoRoute(
        path: AppConstants.routeSettings,
        name: 'settings',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SettingsScreen()),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.routeHome),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
