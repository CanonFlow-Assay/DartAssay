# CI and qualification policy

Every pull request runs the current stable Flutter SDK and records the exact
Flutter and Dart versions in its log. It runs dependency resolution with a
committed lockfile check, formatting, `flutter analyze`, `flutter test` when a
test directory exists, and the repository-layout check. M0 has no
implementation test directory, so it records that test lane as not applicable
rather than representing an absence of tests as a pass.

After M1, CI also runs the reference widget and integration lanes where runner
support exists, Android debug build on a qualified Android runner, and iOS
`--no-codesign` build only on macOS. A missing runner, emulator, SDK, or
reference application is recorded as **INCONCLUSIVE** or **NOT_APPLICABLE**;
it is never reported as passed.

M0's workflow explicitly reports the reference and platform lanes as not yet
applicable because Gate A intentionally prevents the application from existing.
That status is evidence of the milestone boundary, not a mobile build claim.
