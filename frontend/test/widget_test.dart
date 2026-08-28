import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('app launches to the home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const JMeApp());

    expect(find.text('J_ME'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Signup'), findsOneWidget);
  });
}
