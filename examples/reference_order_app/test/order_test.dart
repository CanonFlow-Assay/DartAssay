import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:reference_order_app/domain/order.dart';
import 'package:reference_order_app/application/order_state.dart';

OrderLine line(
        {String id = '1',
        String name = 'Tea',
        int quantity = 2,
        int cents = 125}) =>
    OrderLine(id, ItemName(name), Quantity(quantity), Money(cents));
List<OrderFault> faults(Result<ReadyOrder, List<OrderFault>> result) =>
    switch (result) {
      Err(:final error) => error,
      Ok() => throw StateError('Expected rejection'),
    };
ReadyOrder ready(Result<ReadyOrder, List<OrderFault>> result) =>
    switch (result) {
      Ok(:final value) => value,
      Err() => throw StateError('Expected ready order'),
    };
void main() {
  test('valid order totals exact integer cents', () {
    expect(
        ready(evaluate(
                OrderDraft([line(), line(id: '2', quantity: 3, cents: 99)])))
            .total
            .cents,
        547);
  });
  test('empty order is a typed failure', () {
    expect(faults(evaluate(OrderDraft([]))), [OrderFault.noOrderLines]);
  });
  test('every declared domain fault is retained', () {
    expect(
        faults(evaluate(
            OrderDraft([line(name: ' ', quantity: 0, cents: -1), line()]))),
        [
          OrderFault.emptyItemName,
          OrderFault.quantityLessThanOne,
          OrderFault.negativePrice,
          OrderFault.duplicateLineIdentifier
        ]);
  });
  test('quantity boundary one and zero price are valid', () {
    expect(
        ready(evaluate(OrderDraft([line(quantity: 1, cents: 0)]))).total.cents,
        0);
  });
  test('zero and negative quantities are rejected', () {
    for (final q in [0, -1]) {
      expect(faults(evaluate(OrderDraft([line(quantity: q)]))),
          contains(OrderFault.quantityLessThanOne));
    }
  });
  test('negative price is rejected', () {
    expect(faults(evaluate(OrderDraft([line(cents: -1)]))),
        [OrderFault.negativePrice]);
  });
  test('arithmetic overflow fails closed on VM and web', () {
    expect(
        faults(evaluate(OrderDraft([line(quantity: 2, cents: maxSafeCents)]))),
        contains(OrderFault.amountTooLarge));
    expect(
        faults(evaluate(OrderDraft([
          line(quantity: 1, cents: maxSafeCents),
          line(id: '2', quantity: 1, cents: 1)
        ]))),
        contains(OrderFault.amountTooLarge));
  });
  test('inbound and exposed draft collections are defensively immutable', () {
    final input = [line()];
    final draft = OrderDraft(input);
    input.clear();
    expect(draft.lines.length, 1);
    expect(() => draft.lines.clear(), throwsUnsupportedError);
  });
  test('ready lines and error collections are immutable', () {
    final order = ready(evaluate(OrderDraft([line()])));
    expect(() => order.lines.clear(), throwsUnsupportedError);
    expect(
        () => faults(evaluate(OrderDraft([]))).clear(), throwsUnsupportedError);
  });
  test('repeat evaluation preserves input and the same value outcome', () {
    final draft = OrderDraft([line()]);
    final a = ready(evaluate(draft));
    final b = ready(evaluate(draft));
    expect(a.total.cents, b.total.cents);
    expect(
        a.lines.map(
            (x) => (x.id, x.name.value, x.quantity.value, x.unitPrice.cents)),
        b.lines.map(
            (x) => (x.id, x.name.value, x.quantity.value, x.unitPrice.cents)));
    expect(draft.lines.single.quantity.value, 2);
  });
  test('pure event journey edits, reviews, and confirms', () {
    final empty = OrderState([]);
    var state = reduce(empty, const AddLine());
    state = reduce(state, const EditLine('line-1', LineField.name, 'Tea'));
    state = reduce(state, const EditLine('line-1', LineField.quantity, '3'));
    state = reduce(state, const EditLine('line-1', LineField.price, '1.25'));
    expect(present(state).total, '3.75');
    expect(present(state).status, 'Review order');
    state = reduce(state, const ConfirmOrder());
    expect(present(state).status, 'Ready to confirm');
    expect(empty.lines, isEmpty);
    state = reduce(state, const EditLine('line-1', LineField.quantity, '0'));
    expect(state.attempted, false);
    expect(present(reduce(state, const ConfirmOrder())).faults,
        contains('Quantity less than one'));
  });
  test('malformed numeric inputs are values and never throw', () {
    for (final value in ['', 'abc', '1.234', 'NaN', 'Infinity', '1e3']) {
      final state =
          OrderState([LineInput('1', 'Tea', value, value)], attempted: true);
      expect(present(state).faults, isNotEmpty);
      expect(present(state).status, 'Review validation faults');
    }
  });
  test('price decoding rejects huge or inexact amounts', () {
    for (final value in ['9007199254740991', '0.001']) {
      expect(
          faults(
              evaluateInput(OrderState([LineInput('1', 'Tea', '1', value)]))),
          contains(OrderFault.invalidPrice));
    }
  });
  test('unknown edits and removals retain data and report a fault', () {
    final state = OrderState([const LineInput('1', 'Tea', '1', '1.00')]);
    for (final event in [
      const EditLine('missing', LineField.name, 'X'),
      const RemoveLine('missing')
    ]) {
      final next = reduce(state, event);
      expect(next.lines.single.name, 'Tea');
      expect(present(next).faults, ['Unknown line identifier']);
    }
  });
  test('remove does not reuse identifiers or mutate previous state', () {
    final added = reduce(OrderState([]), const AddLine());
    final removed = reduce(added, const RemoveLine('line-1'));
    expect(reduce(removed, const AddLine()).lines.single.id, 'line-2');
    expect(added.lines.length, 1);
  });
  test('domain and application stay free of Flutter and effect imports', () {
    for (final folder in ['lib/domain', 'lib/application']) {
      for (final file
          in Directory(folder).listSync(recursive: true).whereType<File>()) {
        final text = file.readAsStringSync();
        expect(
            text,
            isNot(matches(RegExp(
                r"import\s+['\x22](?:package:flutter/|dart:(?:io|html|js_interop))"))),
            reason: file.path);
      }
    }
  });
}
