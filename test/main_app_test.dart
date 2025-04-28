import 'package:flutter/cupertino.dart';
import 'package:sleepless_app/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sleepless_app/backend/services.dart';
import 'package:sleepless_app/models/user_model.dart';
import 'package:sleepless_app/blocs/auth_bloc.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> navigateToHomeScreen(WidgetTester tester) async {
    // Create a mock auth service that returns authenticated state
    final mockAuthService = MockAuthService();
    final app = App(authService: mockAuthService);
    
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();
    
    // Wait for navigation to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  testWidgets('App has male/female elements', (tester) async {
    await navigateToHomeScreen(tester);
    
    final mFinder = find.text('Male');
    final fFinder = find.text('Female');

    expect(mFinder, findsOneWidget);
    expect(fFinder, findsOneWidget);
  });

  testWidgets('App has meandering/boring/weather library buttons', (tester) async {
    await navigateToHomeScreen(tester);
    
    final meanderingFinder = find.byKey(Key('meandering_library'));
    final boringFinder = find.byKey(Key('boring_library'));

    expect(meanderingFinder, findsOneWidget);
    expect(boringFinder, findsOneWidget);
  });

  testWidgets('App has email submission button', (tester) async {
    await navigateToHomeScreen(tester);
    
    final meanderingFinder = find.text('support@coventrylabs.net');

    expect(meanderingFinder, findsOneWidget);
  });

  testWidgets('App has EULA button', (tester) async {
    await navigateToHomeScreen(tester);
    
    final eulaFinder = find.text('EULA');

    expect(eulaFinder, findsOneWidget);
  });

  testWidgets('App has Privacy Policy button', (tester) async {
    await navigateToHomeScreen(tester);
    
    final privacyFinder = find.text('Privacy');

    expect(privacyFinder, findsOneWidget);
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
  Future<UserModel?> checkForExistingUser() async {
    return _mockUser;
  }

  @override
  Stream<AuthState> get authStateChanges => Stream.value(AuthenticatedState(user: _mockUser));
}