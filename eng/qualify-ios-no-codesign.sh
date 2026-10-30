#!/usr/bin/env bash
# Local M1 platform qualification; no signing, release or license acceptance.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="${1:-}"
if [[ -z "$output" || -e "$output" ]]; then
  echo 'Usage: eng/qualify-ios-no-codesign.sh <fresh-output-directory>' >&2
  exit 64
fi
mkdir -p "$output"
output="$(cd "$output" && pwd)"
candidate="$(git -C "$root" rev-parse HEAD)"
host="$(uname -s)"
record() {
  printf '{"schema":"dartassay-ios-local-qualification/0.1","candidateCommit":"%s","host":"%s","status":"%s","reason":"%s","humanApproval":false}\n' "$candidate" "$host" "$1" "$2" > "$output/qualification.json"
}
record Running 'Platform execution has not completed.'
uname -a > "$output/host.txt"
if [[ "$host" != Darwin ]]; then
  record Inconclusive 'Actual iOS no-codesign qualification requires macOS and Xcode.'
  exit 2
fi
if [[ -n "$(git -C "$root" status --porcelain)" ]]; then
  record Inconclusive 'Candidate worktree must be clean before platform qualification.'
  exit 2
fi
if ! command -v xcodebuild >/dev/null || ! command -v xcrun >/dev/null; then
  record Inconclusive 'Xcode developer tools are unavailable.'
  exit 2
fi
if ! xcodebuild -version > "$output/xcode.txt" 2>&1; then
  record Inconclusive 'Xcode version evidence is unavailable.'
  exit 2
fi
if ! xcodebuild -checkFirstLaunchStatus > "$output/xcode-readiness.log" 2>&1; then
  record Inconclusive 'Xcode first-launch or license readiness is incomplete; no terms were accepted.'
  exit 2
fi
if ! xcrun --sdk iphoneos --show-sdk-version > "$output/ios-sdk.txt" 2>&1; then
  record Inconclusive 'An iPhoneOS SDK is unavailable.'
  exit 2
fi
sdk="${DARTASSAY_FLUTTER:-}"
if [[ -z "$sdk" ]]; then sdk="$(command -v flutter || true)"; fi
if [[ -z "$sdk" || ! -x "$sdk" ]]; then
  record Inconclusive 'The exact Flutter SDK executable is unavailable.'
  exit 2
fi
if ! "$sdk" --version > "$output/flutter.txt" 2>&1; then
  record Inconclusive 'Flutter version evidence is unavailable.'
  exit 2
fi
if ! head -1 "$output/flutter.txt" | grep -Fq 'Flutter 3.47.0 '; then
  record Inconclusive 'Exact Flutter 3.47.0 is required.'
  exit 2
fi
if ! grep -Fq 'Dart 3.13.0 ' "$output/flutter.txt"; then
  record Inconclusive 'Exact Dart 3.13.0 is required.'
  exit 2
fi
app="$root/examples/reference_order_app"
fingerprint() {
  (cd "$root"; git ls-files -z -- examples/reference_order_app | xargs -0 shasum -a 256) | shasum -a 256 | cut -d ' ' -f 1
}
before="$(fingerprint)"
lock="$(shasum -a 256 "$app/pubspec.lock")"
printf '%s\n' "$before" > "$output/source-before.sha256"
cd "$app"
if ! "$sdk" pub get --offline > "$output/resolution.log" 2>&1; then
  record Inconclusive 'Pinned offline dependency resolution did not complete.'
  exit 2
fi
if [[ "$(shasum -a 256 pubspec.lock)" != "$lock" ]]; then
  record Inconclusive 'Dependency resolution changed the reviewed lock.'
  exit 2
fi
set +e
"$sdk" build ios --debug --no-codesign --no-pub > "$output/build.log" 2>&1
result=$?
set -e
after="$(fingerprint)"
printf '%s\n' "$after" > "$output/source-after.sha256"
if [[ "$before" != "$after" ]]; then
  record Inconclusive 'Authored application inputs changed; review migrations and run a fresh candidate.'
  exit 2
fi
if [[ "$result" -ne 0 ]]; then
  record Fail 'The real no-codesign build failed; inspect the retained build log.'
  exit 1
fi
record Pass 'Actual debug iOS build completed without code signing; no device or human acceptance is inferred.'
