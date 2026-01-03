import 'package:flutter/foundation.dart';

/// App-wide constants for ThreadVerse
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ThreadVerse';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Community-Driven Discussions';

  // API Configuration - Production: Render, Development: localhost
  static const String baseUrl = 'https://threadverse.onrender.com/api/v1/';

  static const int apiTimeout = 30000; // 30 seconds

  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 50;

  // Content Limits
  static const int maxPostTitleLength = 300;
  static const int maxPostBodyLength = 40000;
  static const int maxCommentLength = 10000;
  static const int maxCommunityNameLength = 21;
  static const int maxUsernameLength = 20;
  static const int maxBioLength = 200;

  // Timeouts
  static const int splashDuration = 2; // seconds
  static const int toastDuration = 3; // seconds

  // Local Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUsername = 'username';
  static const String keyThemeMode = 'theme_mode';
  static const String keyIsFirstLaunch = 'is_first_launch';

  // Routes (will be defined in routing)
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeHome = '/home';
  static const String routePost = '/post';
  static const String routeCommunity = '/community';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';
  static const String routeCreatePost = '/create-post';
  static const String routeCreateCommunity = '/create-community';

  // Post Types
  static const String postTypeText = 'text';
  static const String postTypeImage = 'image';
  static const String postTypeLink = 'link';
  static const String postTypePoll = 'poll';

  // Sort Types
  static const String sortHot = 'hot';
  static const String sortNew = 'new';
  static const String sortTop = 'top';
  static const String sortControversial = 'controversial';

  // Time Filters
  static const String timeToday = 'today';
  static const String timeWeek = 'week';
  static const String timeMonth = 'month';
  static const String timeYear = 'year';
  static const String timeAll = 'all';

  // Regex Patterns
  static final RegExp usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,20}$');
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp urlRegex = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
  );
}
