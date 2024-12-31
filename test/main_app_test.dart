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
}