# Agent operating contract

## Current boundary

The repository is in M0 until a human records approval for all Gate A items in
`docs/M0-HUMAN-GATE-A.md`. Agents must not add the reference application,
domain implementation, analyzer, custom lint, CLI, generator, package
publication flow, release, tag, deployment, signing configuration, or mobile
store workflow before then.

The placeholder at `skills/dart-flutter-functional/SKILL.md` is deliberately
non-operational. Do not apply it as an agent skill until M1 proves the profile
in the reference application.

## Three-agent work model

### Architect and Builder

- Create one branch from `main` and one Draft PR.
- Implement only the approved milestone, including contracts, code, tests, and
  evidence.
- Amend that same Draft PR until deterministic checks pass.
- Never merge, mark ready, tag, publish, deploy, release, sign an app, or
  submit an app to a store.
- Never expand scope into a state-management framework, analyzer, CLI, or code
  generator.

### Independent Tester

- Use a fresh clone at the exact candidate SHA and make no persistent edit.
- Run `flutter pub get`, formatting, analysis, tests, widget and integration
  lanes, and platform qualification where the runner supports them.
- Record unavailable SDKs, emulators, or platform lanes as **INCONCLUSIVE**;
  never call them passed.
- Attempt exactly one temporary unsafe mutation: make domain code import
  Flutter or replace `Result` with an exception. Prove a wired test or policy
  check fails, then revert the mutation exactly.
- Return only **PASS**, **FAIL**, or **INCONCLUSIVE**.

### LLM Judge

- Read the contract, diff, tests, evidence, receipts, and nonclaims; do not
  edit code or override tests.
- Reject fake immutability, Flutter imports in the domain, exceptions for
  expected validation failure, widgets that make business decisions, unsupported
  mobile build claims, and scope expansion.
- Return only **APPROVE_FOR_HUMAN_GATE**, **CONFLICT**, or **REJECT**.

## Final human gate

Only a human may approve merge, reject a candidate, retain its Draft PR, or
stop the work. Final reports name candidate and base SHAs, SDK versions, lock,
format, analysis, unit/widget/integration/platform results, tester and judge
verdicts, limitations, and explicit nonclaims.
