import 'package:flutter_test/flutter_test.dart';
import 'package:diyabet_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: DiyabetApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DiyabetApp), findsOneWidget);
  });
}
