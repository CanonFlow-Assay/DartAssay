#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
sdk="${DARTASSAY_FLUTTER:-$HOME/.cache/dartassay-flutter-3.47.0/bin/flutter}"
if [[ ! -x "$sdk" ]]; then sdk="$(command -v flutter)"; fi
output="${1:-}"
if [[ -z "$output" || -e "$output" ]]; then echo "Usage: eng/try-playground.sh <fresh-output-directory>" >&2; exit 64; fi
mkdir -p "$output"
output="$(cd "$output" && pwd)"
"$sdk" --version > "$output/sdk.txt" 2>&1
if ! head -1 "$output/sdk.txt" | grep -Fq 'Flutter 3.47.0 '; then
  echo 'INCONCLUSIVE: exact Flutter 3.47.0 is required.' | tee "$output/qualification.txt"; exit 2
fi
dart="$(dirname "$sdk")/dart"
app="$root/examples/reference_order_app"
cd "$app"
lock_before="$(sha256sum pubspec.lock)"
"$sdk" pub get --offline > "$output/resolution.log" 2>&1
if [[ "$(sha256sum pubspec.lock)" != "$lock_before" ]]; then echo 'FAIL: resolution changed the reviewed lock.' >&2; exit 1; fi
"$dart" format --output=none --set-exit-if-changed lib test integration_test > "$output/format.log" 2>&1
"$sdk" analyze --no-pub > "$output/analysis.log" 2>&1
"$sdk" test --no-pub test --reporter expanded > "$output/tests.log" 2>&1
cd "$root"
bash .github/scripts/check_layout.sh > "$output/layout.log" 2>&1
printf '%s\n' 'Domain/application/widget checks: PASS on pinned Flutter 3.47.0.' \
  'Device integration: INCONCLUSIVE until run on a qualified device.' \
  'Android debug: INCONCLUSIVE until a qualified Android runner executes the build.' \
  'iOS no-codesign: INCONCLUSIVE; requires macOS/Xcode.' \
  'M1 candidate: INCONCLUSIVE. Human review remains separate.' | tee "$output/qualification.txt"
exit 2
