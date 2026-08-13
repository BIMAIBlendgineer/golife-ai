# DDC — Delivery Contracts

## MissionSet
```json
{
  "missionSetId": "ms_x",
  "date": "2026-05-16",
  "sourceState": "live",
  "missions": [
    {
      "missionId": "m_x",
      "title": "Concrete title",
      "action": "Concrete action",
      "effort": "low",
      "reason": "Why this mission is ranked",
      "evidenceRefs": ["ev_x"],
      "scoreBreakdown": {
        "urgency": 0.2,
        "effortFit": 0.3,
        "privacyFit": 0.2,
        "feedbackMemory": 0.3
      }
    }
  ],
  "trace": {
    "rankingVersion": "mission_ranker_v1",
    "fallbackUsed": false,
    "policyVersion": "policy_v1"
  }
}
```

## Entitlement
```json
{
  "plan": "free|premium|pro",
  "trial": {"active": true, "expiresAt": "..."},
  "limits": {
    "dailyMissionRefreshes": 3,
    "aiAssistedCaptures": 20,
    "exportBundles": 1
  },
  "billing": {
    "provider": "app_store|google_play|revenuecat|stripe|disabled",
    "status": "active|expired|trial|grace|disabled"
  }
}
```

## Source state
Every mobile/admin response must expose one of:

```text
live
fallback
offline
local
degraded
```
