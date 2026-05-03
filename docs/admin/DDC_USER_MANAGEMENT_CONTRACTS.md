# DDC User Management Contracts

Date: 2026-04-26

## Endpoints

- `GET /admin/users?limit=&offset=&query=&status=&plan=&locale=`
- `GET /admin/users/{user_id}`
- `GET /admin/users/{user_id}/summary`
- `GET /admin/users/{user_id}/usage`
- `GET /admin/users/{user_id}/privacy`
- `GET /admin/users/{user_id}/support`

## UserManagementRow

- `user_id`
- `display_name`
- `email_masked`
- `plan`
- `status`
- `locale`
- `last_seen_at`
- `ai_calls_count`
- `useful_missions_count`
- `fallback_rate`
- `support_flags`
- `privacy_request_status`

## UserSummary

- `user_id`
- `display_name`
- `email_masked`
- `plan`
- `status`
- `locale`
- `created_at`
- `last_seen_at`
- `organization_id`
- `support_flags`
- `privacy_request_status`

## UserUsageSummary

- `user_id`
- `capture_events`
- `missions_generated`
- `missions_completed`
- `ai_calls_count`
- `fallback_rate`
- `latency_ms_avg`

## UserPrivacySummary

- `user_id`
- `privacy_request_status`
- `open_requests`
- `encrypted_collections`
- `sensitive_data_excluded`

## UserSupportSummary

- `user_id`
- `support_flags`
- `open_request_count`
- `requests`

## Envelope

List responses use:

- `items`
- `total`
- `limit`
- `offset`
- `next_offset`
- `fetched_at`
