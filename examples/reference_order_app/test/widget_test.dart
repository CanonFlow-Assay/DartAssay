import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reference_order_app/main.dart';

Future<void> addValid(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('add-line')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const ValueKey('name-line-1')), 'Tea');
  await tester.enterText(find.byKey(const ValueKey('quantity-line-1')), '3');
  await tester.enterText(find.byKey(const ValueKey('price-line-1')), '1.25');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty draft and typed validation failure render',
      (tester) async {
    await tester.pumpWidget(const OrderPlayground());
    expect(find.text('Draft order'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm')));
    await tester.pumpAndSettle();
    expect(find.text('No order lines'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('edited draft derives exact total and ready state',
      (tester) async {
    await tester.pumpWidget(const OrderPlayground());
    await addValid(tester);
    expect(find.text('Total: 3.75'), findsOneWidget);
    expect(find.text('Review order'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('confirm')));
    await tester.tap(find.byKey(const ValueKey('confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Ready to confirm'), findsOneWidget);
  });
  testWidgets('all editable value faults render without exceptions',
      (tester) async {
    await tester.pumpWidget(const OrderPlayground());
    await tester.tap(find.byKey(const ValueKey('add-line')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('quantity-line-1')), '0');
    await tester.enterText(find.byKey(const ValueKey('price-line-1')), '-1.00');
    await tester.ensureVisible(find.byKey(const ValueKey('confirm')));
    await tester.tap(find.byKey(const ValueKey('confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Empty item name'), findsOneWidget);
    expect(find.text('Quantity less than one'), findsOneWidget);
    expect(find.text('Negative price'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('editing after confirmation clears ready state', (tester) async {
    await tester.pumpWidget(const OrderPlayground());
    await addValid(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('confirm')));
    await tester.tap(find.byKey(const ValueKey('confirm')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('quantity-line-1')));
    await tester.enterText(find.byKey(const ValueKey('quantity-line-1')), '0');
    await tester.pumpAndSettle();
    expect(find.text('Ready to confirm'), findsNothing);
  });
}
