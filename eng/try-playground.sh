#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# != 1 || -z "$1" || -e "$1" || -L "$1" ]]; then
  printf '%s\n' 'Usage: eng/try-playground.sh <fresh-output-directory>' >&2
  exit 64
fi
mkdir -p -- "$(dirname -- "$1")"
mkdir -- "$1"
output="$(cd -- "$1" && pwd)"

finish() {
  local verdict="$1" stage="$2" command_exit="$3"
  shift 3
  printf '%s\n' "$@" | tee -- "$output/qualification.txt"
  printf '{"schemaVersion":"canonflow.assay.dart-local-qualification/v1","verdict":"%s","stage":"%s","commandExitCode":%s}\n' \
    "$verdict" "$stage" "$command_exit" > "$output/qualification.json"
  case "$verdict" in
    Fail) exit 1 ;;
    Inconclusive) exit 2 ;;
    ToolFailure) exit 3 ;;
  esac
}

app="$root/examples/reference_order_app"
if [[ ! -f "$app/pubspec.yaml" || ! -f "$app/pubspec.lock" || ! -d "$app/test" ]] ||
  [[ -z "$(find "$app/test" -type f -name '*_test.dart' -print -quit)" ]]; then
  finish Inconclusive app-inputs null 'INCONCLUSIVE: reference application inputs or tests are missing.'
fi

sdk="${DARTASSAY_FLUTTER:-$HOME/.cache/dartassay-flutter-3.47.0/bin/flutter}"
if [[ ! -x "$sdk" && -z "${DARTASSAY_FLUTTER:-}" ]]; then
  sdk="$(command -v flutter || true)"
fi
if [[ ! -x "$sdk" ]]; then
  finish Inconclusive sdk null 'INCONCLUSIVE: the Flutter SDK is unavailable.'
fi
sdk="$(cd -- "$(dirname -- "$sdk")" && pwd)/$(basename -- "$sdk")"
dart="$(dirname -- "$sdk")/dart"
if [[ ! -x "$dart" ]]; then
  finish Inconclusive sdk null 'INCONCLUSIVE: Dart is missing from the Flutter SDK directory.'
fi
if "$sdk" --version > "$output/sdk.txt" 2>&1; then
  if ! grep -qm 1 '^Flutter 3\.47\.0 ' "$output/sdk.txt"; then
    finish Inconclusive sdk 0 'INCONCLUSIVE: exact Flutter 3.47.0 is required.'
  fi
else
  finish ToolFailure sdk "$?" 'TOOL FAILURE: the Flutter version probe failed. See sdk.txt.'
fi

cd -- "$app"
sha256sum pubspec.lock > "$output/lock.sha256"
check_lock() {
  if ! sha256sum --check --status "$output/lock.sha256"; then
    finish Fail lock null 'FAIL: the reviewed pubspec.lock changed during qualification.'
  fi
}

if "$sdk" pub get --offline --enforce-lockfile > "$output/resolution.log" 2>&1; then
  check_lock
else
  resolution_exit="$?"
  check_lock
  finish Inconclusive resolution "$resolution_exit" 'INCONCLUSIVE: locked offline dependency resolution failed. See resolution.log.'
fi

run_required() {
  local stage="$1" log="$2" command_exit
  shift 2
  if "$@" > "$output/$log" 2>&1; then
    return
  else
    command_exit="$?"
  fi
  if ((command_exit >= 126)); then
    finish ToolFailure "$stage" "$command_exit" "TOOL FAILURE: $stage command could not complete. See $log."
  fi
  finish Fail "$stage" "$command_exit" "FAIL: $stage did not pass. See $log."
}

run_required format format.log "$dart" format --output=none --set-exit-if-changed lib test integration_test
run_required analysis analysis.log "$sdk" analyze --no-pub
run_required tests tests.log "$sdk" test --no-pub test --reporter expanded
check_lock
if ! tail -n 1 "$output/tests.log" | grep -Eq '^[0-9]+:[0-9]+ \+[1-9][0-9]*: All tests passed!$'; then
  finish Inconclusive tests 0 'INCONCLUSIVE: the test report lacks a nonempty, unskipped pass summary. See tests.log.'
fi
cd -- "$root"
run_required layout layout.log bash .github/scripts/check_layout.sh

finish Inconclusive local-complete 0 'Domain/application/widget checks: PASS on pinned Flutter 3.47.0.' \
  'Device integration: INCONCLUSIVE until run on a qualified device.' \
  'Android debug: INCONCLUSIVE until a qualified Android runner executes the build.' \
  'iOS no-codesign: INCONCLUSIVE until macOS/Xcode runs the build.' \
  'M1 candidate: INCONCLUSIVE. Human review remains separate.'
