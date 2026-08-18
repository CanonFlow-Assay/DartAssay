# Human Gate A — decision requested

**Current decision:** approve or reject the following M1 contract as one
bundle. An approval authorizes the reference-application implementation only;
it does not authorize an analyzer, CLI, generator, package publication,
release, tag, deployment, signing, or store submission.

## Items requiring approval

1. **Result and Option:** use the sealed `Result<T, E>` / `Ok` / `Err` and
   `Option<T>` / `Some` / `None` representation in the profile.
2. **Boundary:** use a pure Dart functional core with an explicit-effect
   application layer and Flutter shell; permit Flutter framework state in the
   shell but keep it out of domain logic.
3. **Scope:** implement the offline `reference_order_app` order draft exactly
   as specified in [the acceptance contract](REFERENCE-ORDER-APP-ACCEPTANCE.md).

## Record

- Decision: **APPROVED**
- Decider: Human approver (recorded on pull request #1)
- Date (UTC): 2026-08-18
- Notes: Approved for candidate
  `ed0438856b38d9f1ff928446f96dc85df34c7d7a`. M1 is limited to the offline
  reference order application and must prove defensive handling of inbound and
  exposed collections; `final` alone is not deep immutability.

M1 may start only after its M0 CI prerequisite is satisfied.
