import '../domain/order.dart';

final class LineInput {
  const LineInput(this.id, this.name, this.quantity, this.price);
  final String id;
  final String name;
  final String quantity;
  final String price;
}

final class OrderState {
  OrderState(Iterable<LineInput> lines,
      {this.attempted = false, this.eventFault = const None(), this.nextId = 1})
      : lines = List.unmodifiable(lines);
  final List<LineInput> lines;
  final bool attempted;
  final Option<OrderFault> eventFault;
  final int nextId;
}

sealed class OrderEvent {
  const OrderEvent();
}

final class AddLine extends OrderEvent {
  const AddLine();
}

final class EditLine extends OrderEvent {
  const EditLine(this.id, this.field, this.value);
  final String id;
  final LineField field;
  final String value;
}

final class RemoveLine extends OrderEvent {
  const RemoveLine(this.id);
  final String id;
}

final class ConfirmOrder extends OrderEvent {
  const ConfirmOrder();
}

enum LineField { name, quantity, price }

OrderState reduce(OrderState state, OrderEvent event) => switch (event) {
      AddLine() => OrderState(
          [...state.lines, LineInput('line-${state.nextId}', '', '1', '0.00')],
          nextId: state.nextId + 1),
      ConfirmOrder() =>
        OrderState(state.lines, attempted: true, nextId: state.nextId),
      EditLine(:final id, :final field, :final value) =>
        state.lines.any((line) => line.id == id)
            ? OrderState(
                state.lines.map((line) => line.id != id
                    ? line
                    : LineInput(
                        id,
                        field == LineField.name ? value : line.name,
                        field == LineField.quantity ? value : line.quantity,
                        field == LineField.price ? value : line.price)),
                nextId: state.nextId)
            : OrderState(state.lines,
                eventFault: const Some(OrderFault.unknownLine),
                nextId: state.nextId),
      RemoveLine(:final id) => state.lines.any((line) => line.id == id)
          ? OrderState(state.lines.where((line) => line.id != id),
              nextId: state.nextId)
          : OrderState(state.lines,
              eventFault: const Some(OrderFault.unknownLine),
              nextId: state.nextId),
    };
Result<ReadyOrder, List<OrderFault>> evaluateInput(OrderState state) {
  final faults = <OrderFault>[];
  final lines = <OrderLine>[];
  for (final input in state.lines) {
    final quantity = RegExp(r'^-?[0-9]+$').hasMatch(input.quantity.trim())
        ? int.tryParse(input.quantity.trim())
        : null;
    final priceText = input.price.trim();
    final priceMatch =
        RegExp(r'^(-?)([0-9]+)(?:[.]([0-9]{1,2}))?$').firstMatch(priceText);
    final units =
        priceMatch == null ? null : int.tryParse(priceMatch.group(2)!);
    final decimals = priceMatch?.group(3) ?? '';
    final cents = units == null || units > maxSafeCents ~/ 100
        ? null
        : (units * 100 + int.parse(decimals.padRight(2, '0'))) *
            (priceMatch!.group(1) == '-' ? -1 : 1);
    if (quantity == null) faults.add(OrderFault.invalidQuantity);
    if (cents == null) faults.add(OrderFault.invalidPrice);
    lines.add(OrderLine(input.id, ItemName(input.name), Quantity(quantity ?? 0),
        Money(cents ?? 0)));
  }
  final outcome = evaluate(OrderDraft(lines));
  return switch (outcome) {
    Ok(:final value) =>
      faults.isEmpty ? Ok(value) : Err(List.unmodifiable(faults)),
    Err(:final error) => Err(List.unmodifiable([...faults, ...error])),
  };
}

final class OrderView {
  OrderView(this.total, this.status, Iterable<String> faults)
      : faults = List.unmodifiable(faults);
  final String total;
  final String status;
  final List<String> faults;
}

OrderView present(OrderState state) {
  final eventFaults = switch (state.eventFault) {
    Some(:final value) => [value.message],
    None() => <String>[]
  };
  return switch (evaluateInput(state)) {
    Ok(:final value) => OrderView(formatMoney(value.total),
        state.attempted ? 'Ready to confirm' : 'Review order', eventFaults),
    Err(:final error) => OrderView(
          '—', state.attempted ? 'Review validation faults' : 'Draft order', [
        ...eventFaults,
        if (state.attempted) ...error.map((fault) => fault.message)
      ]),
  };
}
