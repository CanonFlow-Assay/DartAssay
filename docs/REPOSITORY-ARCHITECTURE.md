# Repository architecture

```text
DartAssay/
├── docs/                         # reviewed contract, profile, evidence policy
├── skills/dart-flutter-functional/
│   └── SKILL.md                  # non-operational until M1 evidence exists
├── examples/reference_order_app/ # M1 Flutter app; placeholder in M0
├── .github/                      # CI and Draft-PR template
├── analysis_options.yaml          # built-in analyzer configuration only
└── pubspec.yaml                  # non-publishable repository workspace
```

The M1 application will keep a pure Dart domain beneath an application reducer
and Flutter shell:

```text
Flutter widgets -> UiEvent -> pure reducer -> UiState + commands
      ^                                           |
      |---------------- shell executes commands --|

pure Dart domain <- application reducer
```

The domain does not import Flutter or effectful APIs. The shell owns framework
state and platform adapters. Neither the root workspace nor the reference app
will be published as a Dart package in the first milestone.
