# Offline reference-order playground

This M1 candidate implements the Gate A approved offline order draft. It is a teaching/reference application, not a checkout system. No order is submitted, saved or sent over the network.

The domain is pure Dart: immutable `OrderDraft`, `OrderLine`, `ReadyOrder`, `ItemName`, `Quantity` and integer-cent `Money`. Expected failures are `Result<ReadyOrder, List<OrderFault>>` values; collections are copied and exposed unmodifiable. The pure application reducer accepts typed events. Flutter renders the resulting view and dispatches events.

With the exact Flutter 3.47.0 pin:

```sh
flutter pub get --offline
flutter analyze --no-pub
flutter test --no-pub test
flutter run -d chrome
```

Use `flutter pub get` without `--offline` only when intentionally preparing the SDK dependency cache. SDK/lock changes need review. No external runtime package was added.

The app supports adding, editing and removing order lines; validates every declared fault; calculates integer-cent totals; and displays a ready-to-confirm state only after a successful confirmation attempt. Editing clears the prior confirmation. Parsing rejects malformed/inexact prices and amounts outside the shared VM/web safe-integer bound.

The 16 domain/application tests and four widget tests cover empty/invalid/edited/ready states, duplicate identifiers, repeatability, collection aliasing, invalid events, exact cents and overflow. The source-import architecture check is bounded; it is not a Dart semantic-purity analyzer. The approved agent skill remains a placeholder until human M1 approval.

A real Flutter integration journey is in `integration_test/order_journey_test.dart`:

```sh
flutter test --no-pub integration_test -d linux
# Or use a qualified Android/iOS device identifier.
```

Linux execution needs GTK development tools and a display. Widget tests do not substitute for this device lane. The generated Android, iOS, Linux and web shells are development scaffolds; their existence is not evidence that those platforms have been built/tested. Android debug and iOS no-codesign remain explicit qualification obligations.

From the repository root, `bash eng/try-playground.sh artifacts/playground/<fresh-name>` reproduces pinned local checks and reports the pending platform lanes as Inconclusive. Historical M0 evidence remains unchanged.
