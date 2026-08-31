import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spend_wise/main.dart';

void main() {
  testWidgets('SpendWise shows bottom navigation tabs', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const SpendWiseApp());
    await tester.pumpAndSettle();

    expect(find.text('Expenses'), findsWidgets);
    expect(find.text('Todo'), findsOneWidget);
  });
}
