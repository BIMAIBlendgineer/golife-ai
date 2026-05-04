# Rollback Runbook

## Goal

Provide a fast rollback path for runtime regressions, safety regressions, and release-hygiene mistakes without re-enabling production mock behavior.

## Principles

- prefer explicit degraded state over silent mock reactivation
- revert code and config separately
- do not rollback by exposing secrets in git
- keep operational telemetry metadata-only during incident handling

## Git rollback

### Revert one merged PR or commit

```bash
git checkout main
git pull --ff-only origin main
git revert <merge_or_release_commit_sha>
git push origin main
```

### Close an unmerged PR

- close the PR without merge
- delete the remote branch
- delete the local branch

## AI Gateway rollback

Do not rollback by re-enabling:

- `AI_GATEWAY_ENABLE_MOCK=true` in production
- dev routing tokens in production

Verify after rollback:

```bash
curl -s http://<gateway-host>/health
curl -s http://<gateway-host>/ready
```

Then execute one minimal:

```bash
POST /v1/missions/daily
```

## Web backend rollback

Verify after rollback:

- `/health`
- `/public/mobile/runtime-config`
- `/admin/security/summary`
- `/admin/support/export-delete`

## Admin rollback

Verify after rollback:

- dashboard source-state badge
- support/export-delete page
- security summary page

## Mobile rollback

Verify after rollback:

- dashboard source-state label
- mission cards
- local export flow
- delete-all flow

## Configuration rollback

Restore previous external secret and env values from the deployment platform, then re-run:

```bash
curl -s http://<gateway-host>/health
curl -s http://<gateway-host>/ready
curl -s http://<backend-host>/health
```

## Final verification after any rollback

- relevant local or CI test suite is green
- `gitleaks git` remains clean
- no `.env` file was committed
- `main` remains deployable
