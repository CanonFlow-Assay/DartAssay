# DartAssay

DartAssay is a public Apache-2.0 project for a reviewed Functional Dart and
Flutter Profile, plus a small reference Flutter application that demonstrates
the profile in use.

Its purpose is to help people and AI agents create Flutter features with a
functional Dart core: immutable values, typed expected failures, explicit
effects, a Flutter UI shell, and deterministic tests.

## Status

This repository is at **M0 — Contract**. It deliberately contains no Flutter
application, analyzer, CLI, code generator, or publishable package. M1 is
blocked on [Human Gate A](docs/M0-HUMAN-GATE-A.md).

The intended reference application is documented at
[examples/reference_order_app](examples/reference_order_app/README.md), but
will only be implemented after Gate A approval.

## Read first

- [Vision and non-goals](VISION.md)
- [Functional Dart and Flutter Profile v0.1](docs/FUNCTIONAL-DART-FLUTTER-PROFILE-v0.1.md)
- [Repository architecture](docs/REPOSITORY-ARCHITECTURE.md)
- [Reference application acceptance tests](docs/REFERENCE-ORDER-APP-ACCEPTANCE.md)
- [CI and qualification policy](docs/CI-QUALIFICATION.md)

## Local contract checks

Install Flutter 3.47.0 (the CI pin), then run:

```sh
flutter pub get
dart format --set-exit-if-changed .
flutter analyze
bash .github/scripts/check_layout.sh
```

M0 has no implementation test directory, so `flutter test` is intentionally
not applicable until Gate A admits M1. CI reports that status explicitly; M1
will run `flutter test` for the root and reference application suites.

`pubspec.lock` is committed. A dependency resolution that changes it must be
reviewed and committed intentionally.

## Boundaries

DartAssay does not convert legacy applications, prove business correctness, or
replace Flutter tests, security review, or testing on real mobile devices. It
does not create a state-management framework, backend, database, network
client, analyzer, CLI, generator, signing flow, release, or store deployment.

See [CONTRIBUTING.md](CONTRIBUTING.md) before proposing a change.
