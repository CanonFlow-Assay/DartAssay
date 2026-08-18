# Reference order application acceptance tests

## Purpose and boundary

`examples/reference_order_app` is a small offline proof that the profile works
in Flutter. It is not an ONDC client, checkout product, backend, database, or
network client. It uses no network, storage, database, clock, or platform
plugin.

M0 specifies these tests; it does not implement them. M1 begins only after
Human Gate A approval.

## Typed domain vocabulary

The application will use named values:

- `OrderDraft`
- `OrderLine`
- `ItemName`
- `Quantity`
- `Money`
- `OrderFault`
- `ReadyOrder`

The pure evaluator has this result type:

```dart
Result<ReadyOrder, List<OrderFault>>
```

`List<OrderFault>` must not be exposed as a mutable domain collection.

## User acceptance scenarios

1. A user can add a line, enter an item name, set its quantity, set its unit
   price, and review the derived order total.
2. Attempting confirmation on an empty order shows `No order lines` without
   throwing.
3. An empty item name produces `Empty item name`; a quantity below one produces
   `Quantity less than one`; a negative price produces `Negative price`.
4. A duplicate line identifier produces `Duplicate line identifier`.
5. A valid order displays a ready-to-confirm state after confirmation is
   attempted.
6. Every reported fault is rendered to the user without an exception.

## Required automated evidence in M1

| Lane | Minimum evidence |
| --- | --- |
| Domain unit | Evaluate valid and invalid drafts, no mutation of caller-owned collections, exhaustive result handling. |
| Negative | Invalid events and values, including all listed faults. |
| Repeatability | Same `OrderDraft` input returns an equal result and does not alter the input. |
| Widget | Empty draft, edited draft, validation-failure, and ready-to-confirm UI states. |
| Integration | Add item → set quantity → set price → review total → attempt confirmation → ready state. |
| Android | Debug build on a qualified Android runner. |
| iOS | `--no-codesign` build only on a macOS runner. |

Unavailable emulators, SDKs, or platform runners are **INCONCLUSIVE**, never
passed. The integration test is one critical journey, not proof across every
device.
