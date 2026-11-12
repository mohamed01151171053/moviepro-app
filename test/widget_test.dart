import 'package:flutter_test/flutter_test.dart';
import 'package:untitled1whatsapp/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoviesApp());
    expect(find.byType(MoviesApp), findsOneWidget);
  });
}
