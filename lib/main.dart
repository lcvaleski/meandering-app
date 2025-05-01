import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sleepless_app/screens/home_screen.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sleepless_app/screens/login_screen.dart';
import 'package:sleepless_app/screens/signup_screen.dart';
import 'package:sleepless_app/screens/splash_screen.dart';
import 'package:sleepless_app/screens/account_screen.dart';
import 'package:sleepless_app/widgets/scaffold_with_nav_bar.dart';
import 'backend/firebase_auth_service.dart';
import 'backend/services.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'app/routes.dart';
import 'utils.dart';
import 'blocs/auth_bloc.dart';
import 'package:uni_links/uni_links.dart';

bool get isTestEnv => Platform.environment.containsKey('FLUTTER_TEST');

class App extends StatefulWidget {
  final AuthService? authService;

  const App({super.key, this.authService});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc authBloc;
  late final GlobalKey<NavigatorState> routerKey;
  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc(authService: widget.authService)..add(CheckAuthStatus());
    routerKey = GlobalKey<NavigatorState>(debugLabel: 'GO Router Key');
    _initDeepLinkHandling();
  }

  Future<void> _initDeepLinkHandling() async {
    // Handle any initial links (if app was opened from terminated state)
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(Uri.parse(initialLink));
      }
    } catch (e) {
      print('Error handling initial deep link: $e');
    }

    // Listen for deep link events while app is running
    _deepLinkSubscription = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      print('Error handling deep link: $err');
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'meandering' && uri.host == 'auth') {
      // Get the FirebaseAuthService instance from the AuthBloc
      final authService = authBloc.authService as FirebaseAuthService;
      // Handle the sign-in link
      authService.handleEmailLink(uri.toString()).then((success) {
        if (success) {
          // Trigger a check of auth status which will redirect if needed
          authBloc.add(CheckAuthStatus());
        }
      }).catchError((error) {
        // You might want to show an error message to the user
        print('Error completing sign-in: $error');
      });
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    authBloc.close();
    super.dispose();
  }

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

    return BlocProvider(
      create: (context) => authBloc,
      child: Builder(
        builder: (context) {
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
            routerConfig: GoRouter(
              navigatorKey: routerKey,
              initialLocation: '/splash',
              refreshListenable: GoRouterRefreshStream<AuthState>(
                context.read<AuthBloc>().stream,
              ),
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
              redirect: (context, state) {
                final authState = context.read<AuthBloc>().state;
                final isAuthPage = state.matchedLocation == '/login' ||
                    state.matchedLocation == '/signup';
                final isSplashPage = state.matchedLocation == '/splash';

                // Don't redirect while loading
                if (authState is AuthLoadingState) {
                  return isSplashPage ? null : '/splash';
                }

                // After loading, don't allow going back to splash
                if (isSplashPage && authState is! AuthLoadingState) {
                  if (authState is AuthenticatedState) {
                    return '/';
                  }
                  return '/login';
                }

                if (authState is AuthenticatedState) {
                  // If user is authenticated and trying to access auth pages, redirect to home
                  if (isAuthPage) {
                    return '/';
                  }
                  return null;
                }

                // If user is not authenticated and trying to access protected pages
                if (authState is UnAuthenticatedState) {
                  if (!isAuthPage) {
                    return '/login';
                  }
                  return null;
                }

                return null;
              },
            ),
          );
        },
      ),
    );
  }
}

class GoRouterRefreshStream<T> extends ChangeNotifier {
  GoRouterRefreshStream(Stream<T> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<T> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
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