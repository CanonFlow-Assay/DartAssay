sealed class Result<T, E> {
  const Result();
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}

sealed class Option<T> {
  const Option();
}

final class Some<T> extends Option<T> {
  const Some(this.value);
  final T value;
}

final class None<T> extends Option<T> {
  const None();
}

final class ItemName {
  const ItemName(this.value);
  final String value;
}

final class Quantity {
  const Quantity(this.value);
  final int value;
}

final class Money {
  const Money(this.cents);
  final int cents;
}

enum OrderFault {
  noOrderLines('No order lines'),
  emptyItemName('Empty item name'),
  quantityLessThanOne('Quantity less than one'),
  negativePrice('Negative price'),
  duplicateLineIdentifier('Duplicate line identifier'),
  invalidQuantity('Invalid quantity'),
  invalidPrice('Invalid price'),
  unknownLine('Unknown line identifier'),
  amountTooLarge('Amount exceeds safe integer range');

  const OrderFault(this.message);
  final String message;
}

final class OrderLine {
  const OrderLine(this.id, this.name, this.quantity, this.unitPrice);
  final String id;
  final ItemName name;
  final Quantity quantity;
  final Money unitPrice;
}

final class OrderDraft {
  OrderDraft(Iterable<OrderLine> lines) : lines = List.unmodifiable(lines);
  final List<OrderLine> lines;
}

final class ReadyOrder {
  ReadyOrder._(Iterable<OrderLine> lines, this.total)
      : lines = List.unmodifiable(lines);
  final List<OrderLine> lines;
  final Money total;
}

// Keep integer arithmetic exact on Dart VM and JavaScript targets.
const maxSafeCents = 9007199254740991;
Result<ReadyOrder, List<OrderFault>> evaluate(OrderDraft draft) {
  final faults = <OrderFault>[];
  final ids = <String>{};
  var total = 0;
  if (draft.lines.isEmpty) faults.add(OrderFault.noOrderLines);
  for (final line in draft.lines) {
    if (!ids.add(line.id)) faults.add(OrderFault.duplicateLineIdentifier);
    if (line.name.value.trim().isEmpty) faults.add(OrderFault.emptyItemName);
    if (line.quantity.value < 1) faults.add(OrderFault.quantityLessThanOne);
    if (line.unitPrice.cents < 0) faults.add(OrderFault.negativePrice);
    final positive = line.quantity.value > 0 && line.unitPrice.cents >= 0;
    if (line.quantity.value.abs() > maxSafeCents ||
        line.unitPrice.cents.abs() > maxSafeCents ||
        (positive &&
            line.unitPrice.cents > maxSafeCents ~/ line.quantity.value)) {
      faults.add(OrderFault.amountTooLarge);
    } else if (positive) {
      final subtotal = line.quantity.value * line.unitPrice.cents;
      if (total > maxSafeCents - subtotal) {
        faults.add(OrderFault.amountTooLarge);
      } else {
        total += subtotal;
      }
    }
  }
  return faults.isEmpty
      ? Ok(ReadyOrder._(draft.lines, Money(total)))
      : Err(List.unmodifiable(faults));
}

String formatMoney(Money money) =>
    '${money.cents ~/ 100}.${(money.cents % 100).toString().padLeft(2, '0')}';
