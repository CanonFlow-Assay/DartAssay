# DartAssay M1 evidence contract

Gate A authorizes the offline reference order application under the
Functional Dart and Flutter Profile. M1 qualification uses the Flutter
toolchain and the repository's scripts. The analyzer, custom lint and
product CLI are outside the approved M1 scope.
[Gate A record](docs/M0-HUMAN-GATE-A.md), [reference app](examples/reference_order_app/README.md), [profile](docs/FUNCTIONAL-DART-FLUTTER-PROFILE-v0.1.md)

## Local qualification

Use the pinned Flutter **3.47.0** SDK, a populated dependency cache and a
fresh output directory. Run from the repository root.

```sh
DARTASSAY_FLUTTER=/path/to/flutter-3.47.0/bin/flutter \
  bash eng/try-playground.sh artifacts/order-app-qualification
```

The script checks the Flutter version and resolves application dependencies
with `--offline --enforce-lockfile`. Once the lock is confirmed, it checks
formatting and analysis, runs the domain, application and widget tests,
and checks the repository layout. It retains raw logs and writes the exit
interpretation to `qualification.json` in the output directory.

| Observation | Script result |
| --- | --- |
| Application inputs or tests are missing, the SDK is unavailable or mismatched, or offline resolution cannot satisfy the lock. | `Inconclusive`, exit `2` |
| `pubspec.lock` changes, or a local format, analysis, test or layout check fails. | `Fail`, exit `1` |
| The SDK version probe fails or a required check command cannot run. | `ToolFailure`, exit `3` |
| The test process exits successfully with incomplete, empty or skipped test evidence. | `Inconclusive`, exit `2` |
| All local checks succeed. | Local checks pass. Overall exit `2` retains unexecuted device, Android and iOS lanes. |
| The output path is empty or already exists. | Usage error, exit `64` |

The CI qualification policy defines the platform jobs and human review
requirements. The playground wrapper runs the same local script and
preserves its exit, result, and evidence hashes.
[CI qualification policy](docs/CI-QUALIFICATION.md), [playground wrapper](playground/README.md)
