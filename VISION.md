# DartAssay vision

## Mission

Create **CanonFlow-Assay/DartAssay**, a project that helps humans and AI agents
write Android and iOS Flutter applications with a functional Dart core.

The product is one reviewed **Functional Dart and Flutter Profile** and one
reference mobile application. It teaches and verifies:

```text
pure Dart domain logic
  + immutable domain values
  + typed success and failure values
  + explicit effects
  + Flutter UI shell
  + deterministic tests
```

Flutter's object model remains welcome where the shell needs it: widgets,
platform APIs, and framework-owned UI state. The boundary is a functional core
and a Flutter shell, not a ban on Flutter objects.

## Product position

DartAssay lets a developer or AI agent build a new feature without putting
business decisions, mutable business state, network calls, storage calls,
clock access, or platform calls inside widgets.

It owns only the profile and evidence that the reference application is usable.
It does not own:

- a Flutter application generator or conversion engine;
- a general static-analysis platform, custom analyzer, or lint rule in M0/M1;
- a mobile backend, database, network client, or state-management package;
- Android or iOS signing, app-store publishing, tags, releases, or deployments.

## Milestone contract

### M0 — Contract

M0 creates the vision, profile, Result/Option proposal, repository
architecture, reference-app acceptance tests, CI contract, and non-goals.
It does not implement the reference application or create an analyzer, CLI, or
package for publication.

### Human Gate A

A human must explicitly approve or reject all three items in
[M0 Human Gate A](docs/M0-HUMAN-GATE-A.md):

1. the `Result<T, E>` and `Option<T>` representation;
2. the functional-core / Flutter-shell boundary; and
3. the reference order application scope.

No M1 implementation begins before that approval is recorded.

### M1 — Reference application

After Gate A, build `examples/reference_order_app`, pure domain tests, widget
tests, one integration test, Android debug qualification, macOS iOS
`--no-codesign` qualification, and an operational functional-skills file. M1
does not add a Dart analyzer or custom lint rule.

### M2 — Independent consumer exercise

Use one public Flutter repository read-only. Record build, tests, analyzer,
profile observations, false-positive candidates, and missing coverage. An
observation is not a defect until a human reviews it.

### M3 — Admission decision

Admit one rule only if the same problem appears in the reference app and the
consumer exercise; its scope is precise; positive, negative, and boundary
tests exist; false-positive policy is documented; and normal Flutter shell
code is not punished.
