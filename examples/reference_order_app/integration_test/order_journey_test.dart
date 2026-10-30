import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:reference_order_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('add item → quantity → price → total → ready', (tester) async {
    await tester.pumpWidget(const OrderPlayground());
    await tester.tap(find.byKey(const ValueKey('add-line')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('name-line-1')), 'Tea');
    await tester.enterText(find.byKey(const ValueKey('quantity-line-1')), '3');
    await tester.enterText(find.byKey(const ValueKey('price-line-1')), '1.25');
    await tester.pumpAndSettle();
    expect(find.text('Total: 3.75'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('confirm')));
    await tester.tap(find.byKey(const ValueKey('confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Ready to confirm'), findsOneWidget);
  });
}
