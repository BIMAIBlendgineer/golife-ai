# SPEC — Mobile Premium App

## Responsibilities
- capture evidence;
- store local LifeGraph;
- apply privacy controls;
- request mission set;
- display missions;
- show reason/evidence;
- collect feedback;
- support export/delete UI;
- show degraded/fallback state.

## Non-responsibilities
- admin;
- raw provider routing;
- model keys;
- enterprise identity;
- hidden prompts.

## Offline rules
- Last mission set viewable offline.
- Feedback can be queued offline.
- Source state must show offline/degraded.
- No premium AI claim when fallback/local output is used.
