import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threadverse/core/constants/app_constants.dart';
import 'package:threadverse/core/network/api_client.dart';
import 'package:threadverse/core/theme/app_theme.dart';
import 'package:threadverse/core/theme/theme_controller.dart';
import 'package:threadverse/routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();
  runApp(const ProviderScope(child: ThreadVerseApp()));
}

/// Main application widget
class ThreadVerseApp extends ConsumerWidget {
  const ThreadVerseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theming
      theme: AppTheme.lightTheme,
      darkTheme:
          themeState.useAmoled ? AppTheme.amoledTheme : AppTheme.darkTheme,
      themeMode: themeState.themeMode,
      // Routing
      routerConfig: AppRouter.router,
    );
  }
}
