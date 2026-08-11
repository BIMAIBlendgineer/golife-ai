# CI/CD and Release Automation

## Required jobs
- ai-gateway-test
- web-backend-test
- mobile-flutter-analyze
- mobile-flutter-test
- admin-lint
- admin-typecheck
- admin-build
- gitleaks
- billing-contract-test
- store-copy-lint
- release-gate

## Release artifact
```json
{
  "releaseVersion": "x.y.z",
  "scope": "premium_scoped",
  "ci": "green",
  "deviceQa": "pass",
  "billing": "pass|disabled",
  "privacy": "pass",
  "storeAssets": "pass"
}
```
