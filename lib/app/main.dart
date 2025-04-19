import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sleepless_app/screens/home_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sleepless_app/screens/login_screen.dart';
import 'package:sleepless_app/screens/play_screen.dart';
import 'package:sleepless_app/screens/signup_screen.dart';
import 'package:sleepless_app/screens/splash_screen.dart';
import 'package:sleepless_app/screens/account_screen.dart';
import 'package:sleepless_app/widgets/scaffold_with_nav_bar.dart';
import '../firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import '../utils.dart';

bool get isTestEnv => Platform.environment.containsKey('FLUTTER_TEST');

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      name: splashRoute.name,
      path: splashRoute.path,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      name: loginRoute.name,
      path: loginRoute.path,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      name: signUpRoute.name,
      path: signUpRoute.path,
      builder: (context, state) => const SignupScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
          ) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: homeRoute.name,
              path: homeRoute.path,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              name: accountRoute.name,
              path: accountRoute.path,
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {

    // setup Firebase Analytics if we're NOT in a testing environment
    FirebaseAnalyticsObserver? observer;
    if (!isTestEnv) {
      final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
      observer = FirebaseAnalyticsObserver(analytics: analytics);
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      title: 'Sleepless',
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFF1B1E40),
      ),
      routerConfig: _router,
    );
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await configurePurchasesSDK();

  runApp(const App());
}