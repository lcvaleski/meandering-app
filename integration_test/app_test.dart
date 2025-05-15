import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sleepless_app/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sleepless_app/utils.dart';
import 'package:sleepless_app/screens/audio_list_screen.dart';
import 'package:sleepless_app/backend/services.dart';
import 'package:sleepless_app/models/user_model.dart';
import 'package:sleepless_app/blocs/auth_bloc.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await configurePurchasesSDK();
    await Firebase.initializeApp();
  });

  Future<void> navigateToHomeScreen(WidgetTester tester) async {
    // Create a mock auth service that returns authenticated state
    final mockAuthService = MockAuthService();
    final app = App(authService: mockAuthService);
    
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    
    // Wait for navigation to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  group('end-to-end test', () {
    testWidgets('tap on the female gender button, verify selected',
            (tester) async {
          await navigateToHomeScreen(tester);

          final genderSlider = find.byKey(const Key('genderSlider'));
          expect(genderSlider, findsOneWidget);

          expect(tester.widget<CupertinoSlidingSegmentedControl>(genderSlider).groupValue, 'male');

          final femaleButton = find.byKey(const Key('femaleKey'));
          await tester.tap(femaleButton);

          // Trigger a frame.
          await tester.pumpAndSettle();

          // Verify the state changed.
          expect(tester.widget<CupertinoSlidingSegmentedControl>(genderSlider).groupValue, 'female');
      });

    testWidgets('make sure the playback speed and volume dialogs load',
            (tester) async {
          await navigateToHomeScreen(tester);

          final meanderButton = find.byKey(const Key('meandering_card'));
          expect(meanderButton, findsOneWidget);

          // bring up the play screen
          await tester.tap(meanderButton);
          await tester.pumpAndSettle();

          final appBar = find.byKey(const Key('playScreenAppBar'));
          expect(appBar, findsOneWidget);

          // make sure no dialogs are present at first
          var volumeDialog = find.byKey(const Key('volume'));
          expect(volumeDialog, findsNothing);
          var speedDialog = find.byKey(const Key('speed'));
          expect(speedDialog, findsNothing);

          // ensure the volume dialog loads
          final volumeButton = find.byKey(const Key('volumeButton'));
          expect(volumeButton, findsOneWidget);
          await tester.tap(volumeButton);
          await tester.pumpAndSettle();
          volumeDialog = find.byKey(const Key('volume'));
          expect(volumeDialog, findsOneWidget);

          // make the volume dialog disappear
          await tester.tap(appBar, warnIfMissed: false); // tap away from the dialog
          await tester.pumpAndSettle();
          volumeDialog = find.byKey(const Key('volume'));
          expect(volumeDialog, findsNothing);

          // ensure the speed dialog appears
          final speedButton = find.byKey(const Key('speedButton'));
          expect(speedButton, findsOneWidget);
          await tester.tap(speedButton);
          await tester.pumpAndSettle();
          speedDialog = find.byKey(const Key('speed'));
          expect(speedDialog, findsOneWidget);

          // make the volume dialog disappear
          await tester.tap(appBar, warnIfMissed: false); // tap away from the dialog
          await tester.pumpAndSettle();
          speedDialog = find.byKey(const Key('speed'));
          expect(speedDialog, findsNothing);
    });

    final scenarios = [
      {'storyType': 'meandering'},
      {'storyType': 'boring'},
    ];

    for (var scenario in scenarios) {
      testWidgets(
          'verify ${scenario['storyType']} library button tap behaviors',
              (WidgetTester tester) async {
                await navigateToHomeScreen(tester);

                final button = find.byKey(Key('${scenario['storyType']}_library'));
                expect(button, findsOneWidget);

                await tester.tap(button);
                await tester.pumpAndSettle();

                final appBar = find.byKey(const Key('audioListScreenAppBar'));
                expect(appBar, findsOneWidget);

                // make sure routes are named as expected for Firebase analytics
                final routeName = ModalRoute.of(tester.element(find.byType(AudioListScreen)))?.settings.name;
                expect(routeName, 'audio_library_list/${scenario['storyType']}_male');
      });
    }

    testWidgets('tap on a library button then the first play button, Subscribe to access modal should pop up',
            (tester) async {
          await navigateToHomeScreen(tester);

          final meanderButton = find.byKey(const Key('meandering_library'));
          expect(meanderButton, findsOneWidget);

          await tester.tap(meanderButton);
          await tester.pumpAndSettle();

          final appBar = find.byKey(const Key('audioListScreenAppBar'));
          expect(appBar, findsOneWidget);

          await tester.tap(find.byKey(const ValueKey('audioItem')).at(0));
          await tester.pumpAndSettle();

          final subscriptionModal = find.byKey(const Key('subscriptionModal'));
          expect(subscriptionModal, findsOneWidget);
        });
  });
}

// Mock AuthService for testing
class MockAuthService extends AuthService {
  final _mockUser = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
  );

  @override
  Future<UserModel> signUpWithEmailAndPassword(UserRegistrationModel user) async {
    return _mockUser;
  }

  @override
  Future<UserModel> logInWithEmailAndPassword(String email, String password) async {
    return _mockUser;
  }

  @override
  Future<void> logout() async {
    // No-op for testing
  }

  @override
  Future<void> deleteAccount() async {
    // No-op for testing
  }

  @override
  Future<UserModel?> checkForExistingUser() async {
    return _mockUser;
  }

  @override
  Stream<AuthState> get authStateChanges => Stream.value(AuthenticatedState(user: _mockUser));

  @override
  Future<UserModel> signInWithGoogle() {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }
}