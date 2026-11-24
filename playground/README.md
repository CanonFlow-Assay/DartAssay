# DartAssay reference order app

The reference order app exercises the M1 Functional Dart and Flutter Profile
with a pure domain, an application layer and a Flutter shell.
[Reference app](../examples/reference_order_app/README.md), [evidence contract](../CONTRACT.md)

From the repository root, select the pinned Flutter 3.47.0 SDK, make the
locked packages available in the pub cache, and choose a fresh output
directory.

```sh
DARTASSAY_FLUTTER=/path/to/flutter-3.47.0/bin/flutter \
  python3 playground/run.py --output artifacts/order-app-qualification
```

The wrapper runs the local Flutter qualifier and emits JSON on stdout.
The evidence directory retains the qualifier result and raw logs under
`native/`. The JSON includes the child exit and evidence hashes.

Successful local checks still produce `Inconclusive` with exit `2`.
Device integration, Android and iOS require separate runs. A failed local
check produces `Fail` with exit `1`. Missing application inputs, an
unavailable SDK or unsatisfied offline resolution produce
`Inconclusive`. A missing or contradictory qualifier result produces
`ToolFailure` with exit `3`. Invalid arguments or a reused output path
return `64`.
