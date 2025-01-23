import 'package:flutter/cupertino.dart';
import 'package:sleepless_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App has male/female elements', (tester) async {
    await tester.pumpWidget(const App());

    final mFinder = find.text('Male');
    final fFinder = find.text('Female');

    expect(mFinder, findsOneWidget);
    expect(fFinder, findsOneWidget);
  });

  testWidgets('App has meandering/boring/weather library buttons', (tester) async {
    await tester.pumpWidget(const App());

    final meanderingFinder = find.byKey(Key('meandering_library'));
    final boringFinder = find.byKey(Key('boring_library'));
    final weatherFinder = find.byKey(Key('weather_library'));

    expect(meanderingFinder, findsOneWidget);
    expect(boringFinder, findsOneWidget);
    expect(weatherFinder, findsOneWidget);
  });

  testWidgets('App has email submission button', (tester) async {
    await tester.pumpWidget(const App());

    final meanderingFinder = find.text('support@coventrylabs.net');

    expect(meanderingFinder, findsOneWidget);
  });

  testWidgets('App has EULA button', (tester) async {
    await tester.pumpWidget(const App());

    final eulaFinder = find.text('EULA');

    expect(eulaFinder, findsOneWidget);
  });

  testWidgets('App has Privacy Policy button', (tester) async {
    await tester.pumpWidget(const App());

    final privacyFinder = find.text('Privacy');

    expect(privacyFinder, findsOneWidget);
  });
}