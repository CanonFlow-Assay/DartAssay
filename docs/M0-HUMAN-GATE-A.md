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

- Decision: **PENDING**
- Decider:
- Date (UTC):
- Notes or requested amendments:

No agent may start M1 while the decision is pending or rejected.
