# Reflection Safety Policy

GoLife AI supports reflection and daily organization. It does not provide diagnosis, treatment, therapy, or crisis care.

## Response Modes

- `supportive`: everyday reflection, planning, journaling, and organization
- `clinical`: requests that ask for diagnosis, treatment, or professional mental-health advice
- `crisis`: self-harm, suicide, immediate danger, or crisis language

## Product Boundary

- Reflection features may help users clarify thoughts, plan next actions, and review patterns.
- Reflection features must not present themselves as a therapist, clinician, or medical service.
- Crisis language must trigger a safe redirection message and must not produce reflective coaching.

## Operational Logging

- Admin and operational telemetry should record only metadata:
  - category
  - safe/unsafe outcome
  - endpoint
  - timestamp
- Raw reflection text must not be stored in operational audit payloads.

## UX Copy

- User-facing copy should state that GoLife supports organization and reflection, not clinical care.
- Crisis copy should direct the user toward immediate local emergency or crisis support.
