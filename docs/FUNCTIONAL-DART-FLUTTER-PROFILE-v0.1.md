# Functional Dart and Flutter Profile v0.1

## Status and intent

This is the proposed DartAssay profile. It becomes an operational agent skill
only after M1 proves it in the reference Flutter application and a human
approves the M1 candidate. It guides new work; it does not automatically
convert legacy Flutter applications or prove business correctness.

Flutter's official UI, view-model, repository, and service separation is a
compatibility boundary. DartAssay makes a complex or reused domain layer
functional without forcing a use-case class for trivial work.

## 1. Domain: pure Dart

- Domain code is pure Dart and must not import Flutter.
- It must not read time, random values, files, preferences, platform channels,
  databases, or network services.
- It must not mutate input objects.
- Use `final` fields and `const` constructors where possible.
- `final List<T>` prevents reassignment only; it does not make a list
  immutable. Do not expose mutable `List`, `Map`, or `Set` values from domain
  types. Copy a collection before storing or exposing it and use unmodifiable
  collections where needed.
- Use Dart 3 sealed classes for closed domain states and exhaustive `switch`
  expressions to consume them.
- Use records for short-lived local values and multiple return values. Do not
  use a record as a public domain object when a named type gives clearer
  meaning.
- Do not use `dynamic` in domain, application, or public API code.
- Do not use nullable values when absence has business meaning; use
  `Option<T>`.

## 2. Result and Option proposal — Gate A item 1

The proposed representation is deliberately small and uses Dart 3 sealed
classes and pattern matching:

```dart
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
```

Expected validation failures are values, not exceptions. Exceptions are for
broken invariants, unavailable platform code, or programmer defects.

## 3. Application: pure decision, explicit command

Application functions may coordinate domain logic but describe effects rather
than execute them:

```text
UiEvent + UiState
  -> pure reduce function
  -> next UiState + commands
  -> shell executes commands
```

Commands must not perform effects themselves. Put time, platform, storage,
network, and analytics behind injected interfaces, passed through constructors
or explicit composition functions. Never read global mutable state.

## 4. Flutter shell — Gate A item 2

Widgets display immutable UI state and send user events. They must not contain
business decisions or call repositories, services, storage, or platform
channels directly. The Flutter shell may use the mutable state the framework
requires; that state must not leak into the domain layer.

This boundary accommodates Flutter rather than replacing it: widgets, UI
adapters, view models, repositories, and platform services remain legitimate
shell concerns, while decisions are kept in the functional core.

## 5. Testing

Require all of the following after M1:

- unit tests for pure domain functions;
- widget tests for every reference UI state;
- one integration test for one critical user journey;
- negative tests for invalid events and values; and
- a repeatability test showing the same input yields the same result.

A unit test does not replace a widget test. A widget test does not replace an
integration test. An integration test does not prove behavior on every Android
or iOS device.
