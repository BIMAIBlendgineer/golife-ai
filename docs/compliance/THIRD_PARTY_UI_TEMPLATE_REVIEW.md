# Third Party UI Template Review

Date: 2026-04-26
Reference reviewed:
- `https://github.com/shadcnstore/shadcn-dashboard-landing-template`

## Review summary

The referenced repository appears to be publicly published under the MIT license.

Evidence reviewed:
- GitHub repository page declares `MIT license`
- README states the template is MIT-licensed and usable for commercial projects

Repository page reviewed:
- https://github.com/shadcnstore/shadcn-dashboard-landing-template

## Usage decision

Allowed:
- visual inspiration only
- studying layout density
- studying sidebar + topbar hierarchy
- studying dashboard information grouping

Not allowed in this rollout:
- direct code copy
- direct asset copy
- importing template structure wholesale into GoLife
- introducing unrelated demo apps, auth flows, marketing pages, or route conventions from the template

## Clean-room rule

GoLife admin will remain a clean-room implementation:

- own route map
- own component names
- own data contracts
- own copy
- own palette and product framing

## Reason

Even with an MIT-licensed upstream reference, this project needs a GoLife-specific operational surface and must avoid accidental product drift. The template is helpful as a visual benchmark, not as the code foundation.
