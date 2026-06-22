# Evaluation — OpenMetadata for Snowflake (User Story 7354786)

Fill this in as the pilot runs. It is the deliverable for acceptance criteria 3–5.
Keep it factual and concise — this becomes the stakeholder readout.

## 0. Pilot scope (agree before ingesting)
- Snowflake account (non-prod): `__________`
- Databases / schemas in scope: `__________`
- Approx. # tables/views: `__________`
- Auth method used: ☐ key-pair  ☐ password
- Role used (least-privilege): `OPENMETADATA_ROLE`

## 1. Functional fit
Rate each ☐ Strong ☐ Adequate ☐ Weak — with one line of evidence from the pilot.

| Capability | Rating | Evidence / notes |
|---|---|---|
| Dataset discovery & search | | |
| Schema visibility (tables, columns, types) | | |
| Ownership / stewardship | | |
| Lineage (table & column) | | |
| Descriptions / tags / glossary | | |
| Data profiling / quality (if trialed) | | |

## 2. Implementation effort
- Time to first running instance: `____`
- Time to first successful Snowflake ingest: `____`
- Friction encountered (auth, network, perf, errors): `____`
- Effort to operationalize (scheduling, ECS, upgrades): `____`

## 3. Security considerations
- Credential handling: ☐ key-pair ☐ password — stored where? (`.env` here; secrets manager in pre-prod)
- Snowflake privileges granted (least-privilege?): `____`  (see `docs/sources/snowflake.md`)
- OpenMetadata auth model (SSO/SAML available; basic auth used for the pilot): `____`
- Network exposure / data residency (ECS pre-prod): `____`
- Does ingestion read **data** or only **metadata**? (metadata + query history for lineage) `____`

## 4. Support model
- Open-source vs Collate (managed) — which fits? `____`
- Community/docs quality, release cadence, upgrade path: `____`
- Internal ownership if adopted: `____`

## 5. Recommendation
**Decision:** ☐ Proceed ☐ Defer ☐ Reject

Rationale (3–5 bullets):
- `____`

## 6. Stakeholder readout (next steps)
- Summary (2–3 sentences): `____`
- Identified next steps: `____`
- Open questions / risks: `____`
