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

    final meanderingFinder = find.text('Meandering library');
    final boringFinder = find.text('Boring library');
    final weatherFinder = find.text('Weather library');

    expect(meanderingFinder, findsOneWidget);
    expect(boringFinder, findsOneWidget);
    expect(weatherFinder, findsOneWidget);
  });

  testWidgets('App has email submission button', (tester) async {
    await tester.pumpWidget(const App());

    final meanderingFinder = find.text('support@coventrylabs.net');

    expect(meanderingFinder, findsOneWidget);
  });
}