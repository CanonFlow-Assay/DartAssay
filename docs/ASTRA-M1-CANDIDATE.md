# Astra M1 candidate

The 29 October 2026 owner request authorizes local implementation/playgrounds across the assay family. Gate A already records approval of the M1 reference-order contract. This isolated worktree implements that approved scope and does not change main or the preexisting M1 checkout.

Use [the app guide](../examples/reference_order_app/README.md) and [the original acceptance contract](REFERENCE-ORDER-APP-ACCEPTANCE.md). Current local checks use the cached exact Flutter 3.47.0 / Dart 3.13.0 SDK. A preliminary run on installed Flutter 3.47.6 also passed, but is separate evidence.

M1's pure domain and application/widget slices are implemented. A real Linux integration journey and an unsigned Android debug build have now completed on the exact pinned SDK. Android build success does not establish emulator/device behavior. iOS no-codesign, independent tester/judge records and human candidate approval remain separate. No platform lane can be inferred from unit/widget tests. The legacy M0 CI workflow has not been represented as a passing M1 qualification.

`eng/qualify-ios-no-codesign.sh <fresh-output-directory>` prepares the real macOS/Xcode lane, using `DARTASSAY_FLUTTER` to select the exact SDK. It checks Xcode readiness without accepting terms, resolves dependencies offline, refuses a changed lock or authored application, and executes `flutter build ios --debug --no-codesign`. On Linux it writes **Inconclusive** and exits 2. This development runner does not sign, publish or imply device/human acceptance. Local platform evidence and artifact hashes are indexed in `../brainstorm/astra/platform-phase2.json` in the enclosing workspace (outside this repository); historical candidate proof remains bound to `5925ca8`.

No analyzer, custom lint, generator, package publication, release, signing, deployment, state-management framework, backend, persistence or live provider was added. The development script is a local check orchestrator, not a DartAssay checker CLI.
