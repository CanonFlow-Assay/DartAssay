# DartAssay

DartAssay is a public Apache-2.0 project for a reviewed Functional Dart and
Flutter Profile, plus a small reference Flutter application that demonstrates
the profile in use.

Its purpose is to help people and AI agents create Flutter features with a
functional Dart core: immutable values, typed expected failures, explicit
effects, a Flutter UI shell, and deterministic tests.

## Status

This isolated branch contains an **M1 reference-application candidate** under the recorded [Gate A approval](docs/M0-HUMAN-GATE-A.md). The pure domain/application and Flutter shell are implemented; platform and independent review obligations remain visible in the [candidate record](docs/ASTRA-M1-CANDIDATE.md).

The intended reference application is documented at
[examples/reference_order_app](examples/reference_order_app/README.md), and is runnable in this candidate.

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

The root remains a non-publishable contract workspace. Run the application tests from `examples/reference_order_app` or use `bash eng/try-playground.sh <fresh-output>`; the latter retains pending device/mobile lanes as Inconclusive.

`pubspec.lock` is committed. A dependency resolution that changes it must be
reviewed and committed intentionally.

## Boundaries

DartAssay does not convert legacy applications, prove business correctness, or
replace Flutter tests, security review, or testing on real mobile devices. It
does not create a state-management framework, backend, database, network
client, analyzer, CLI, generator, signing flow, release, or store deployment.

See [CONTRIBUTING.md](CONTRIBUTING.md) before proposing a change.
The [phase-1 playground convergence note](docs/PLAYGROUND-CONVERGENCE.md)
records why no new Dart feature is introduced before the existing human gate.
