import 'package:flutter/material.dart';
import 'application/order_state.dart';

void main() => runApp(const OrderPlayground());

class OrderPlayground extends StatelessWidget {
  const OrderPlayground({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'DartAssay Order Playground',
        theme: ThemeData(
            colorSchemeSeed: const Color(0xff006c67), useMaterial3: true),
        home: const OrderPage(),
      );
}

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  OrderState state = OrderState([]);
  void dispatch(OrderEvent event) => setState(() {
        state = reduce(state, event);
      });
  @override
  Widget build(BuildContext context) {
    final view = present(state);
    return Scaffold(
        appBar: AppBar(title: const Text('Order draft · functional Dart')),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(padding: const EdgeInsets.all(20), children: [
                  const Text('Build an order. Inspect every outcome.',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Offline M1 reference application. No order is sent or stored.'),
                  const SizedBox(height: 16),
                  for (final line in state.lines)
                    Card(
                        key: ValueKey('card-${line.id}'),
                        child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(children: [
                              TextFormField(
                                  key: ValueKey('name-${line.id}'),
                                  initialValue: line.name,
                                  decoration: const InputDecoration(
                                      labelText: 'Item name'),
                                  onChanged: (text) => dispatch(
                                      EditLine(line.id, LineField.name, text))),
                              Row(children: [
                                Expanded(
                                    child: TextFormField(
                                        key: ValueKey('quantity-${line.id}'),
                                        initialValue: line.quantity,
                                        decoration: const InputDecoration(
                                            labelText: 'Quantity'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (text) => dispatch(EditLine(
                                            line.id,
                                            LineField.quantity,
                                            text)))),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: TextFormField(
                                        key: ValueKey('price-${line.id}'),
                                        initialValue: line.price,
                                        decoration: const InputDecoration(
                                            labelText: 'Unit price'),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        onChanged: (text) => dispatch(EditLine(
                                            line.id, LineField.price, text))))
                              ]),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                      onPressed: () =>
                                          dispatch(RemoveLine(line.id)),
                                      child: const Text('Remove line'))),
                            ]))),
                  OutlinedButton.icon(
                      key: const ValueKey('add-line'),
                      onPressed: () => dispatch(const AddLine()),
                      icon: const Icon(Icons.add),
                      label: const Text('Add line')),
                  const SizedBox(height: 16),
                  Text('Total: ${view.total}',
                      key: const ValueKey('total'),
                      style: const TextStyle(fontSize: 24)),
                  Text(view.status, key: const ValueKey('status')),
                  for (final fault in view.faults)
                    Text(fault,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  const SizedBox(height: 12),
                  FilledButton(
                      key: const ValueKey('confirm'),
                      onPressed: () => dispatch(const ConfirmOrder()),
                      child: const Text('Attempt confirmation')),
                  const SizedBox(height: 20),
                  const Text(
                      'Requirements: nonempty order and names; quantity ≥ 1; price ≥ 0; unique line identifiers. Domain decisions are pure. Flutter owns rendering and events.'),
                ]))));
  }
}
