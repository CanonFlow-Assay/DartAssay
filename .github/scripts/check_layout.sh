#!/usr/bin/env bash
set -euo pipefail

# This is deliberately a repository-layout check, not a profile analyzer.
# Semantic enforcement is out of scope until a human admits a rule in M3.
required_paths=(
  LICENSE
  README.md
  VISION.md
  AGENTS.md
  CONTRIBUTING.md
  SECURITY.md
  CODE_OF_CONDUCT.md
  analysis_options.yaml
  pubspec.yaml
  pubspec.lock
  .github/pull_request_template.md
  .github/workflows/ci.yml
  docs/FUNCTIONAL-DART-FLUTTER-PROFILE-v0.1.md
  skills/dart-flutter-functional/SKILL.md
  examples/reference_order_app/README.md
)

for path in "${required_paths[@]}"; do
  if [[ ! -f "$path" ]]; then
    printf 'Missing required repository path: %s\n' "$path" >&2
    exit 1
  fi
done

if ! grep --fixed-strings --quiet -- 'publish_to: none' pubspec.yaml; then
  printf 'The root workspace must remain non-publishable.\n' >&2
  exit 1
fi

printf 'Repository layout contract passed.\n'
