#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/generated

{
  echo "# Repo audit"
  echo
  date
  echo
  for repo in source_repos/*; do
    if [ -d "$repo/.git" ] || [ -d "$repo" ]; then
      echo "## $repo"
      echo
      echo "### Files depth 3"
      find "$repo" -maxdepth 3 -type f | sort | sed 's/^/- /' | head -300
      echo
      echo "### Manifests"
      find "$repo" -maxdepth 3 \( -name "pubspec.yaml" -o -name "package.json" -o -name "LICENSE*" -o -name "README*" \) -type f | sort | sed 's/^/- /'
      echo
    fi
  done
} > docs/generated/REPO_AUDIT_RAW.md

echo "Generado docs/generated/REPO_AUDIT_RAW.md"
