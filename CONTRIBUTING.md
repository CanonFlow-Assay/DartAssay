# Contributing

## Scope first

Check the active milestone in [VISION.md](VISION.md) and the human gate before
writing code. A contribution must not bypass the gate or broaden DartAssay into
a framework, analyzer, generator, backend, release process, or store workflow.

## Local checks

Use Flutter 3.47.0, which is pinned in CI. From the repository root, run:

```sh
flutter pub get
git diff --exit-code -- pubspec.lock
dart format --set-exit-if-changed .
flutter analyze
bash .github/scripts/check_layout.sh
```

Run `flutter test` after an approved milestone introduces a `test/` directory.
M0 has no implementation tests and CI reports that lane as not applicable.

Use committed `pubspec.lock` files for Flutter applications. Do not add a
dependency or accept a lockfile change incidentally.

## Pull requests

Open Draft PRs. State the milestone, the human gate status, the exact checks
run, unavailable qualifications, known limitations, and explicit nonclaims.
Do not claim an Android or iOS result without evidence from an appropriate
runner.

For M1 and later, preserve the profile boundary: pure Dart domain code has no
Flutter import or direct effect; widgets render immutable state and dispatch
events rather than make business decisions.
