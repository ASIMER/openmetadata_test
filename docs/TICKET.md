# Ticket — User Story 7354786

> Transcribed from the source work item and the kickoff Teams thread.
> Original screenshots: `OpenMetadata/screens/` (project repo).

## R&D: Evaluate OpenMetadata for Snowflake Data Cataloging

- **Type / ID:** User Story `7354786`
- **Assigned to:** Maliarenko, Illia
- **State:** New
- **Area:** GPS-Applications \ GPS Atlas
- **Iteration:** GPS-Applications \ FY27Q1 \ Q1_It.2
- **Tags:** Atlas

### Description
> As a data platform stakeholder, I want to evaluate OpenMetadata as a data cataloging
> capability for **Snowflake** so that we can improve dataset discovery, lineage visibility,
> and metadata governance for reporting and analytics users.

### Acceptance Criteria
1. OpenMetadata is connected to a **non-production Snowflake** environment and successfully
   ingests metadata for an agreed pilot scope.
2. The pilot demonstrates core catalog capabilities including **dataset discovery, ownership,
   schema visibility, and lineage** where available.
3. Key evaluation criteria are documented, including **functional fit, implementation effort,
   security considerations, and support model** implications.
4. A **recommendation** is made on whether to **proceed, defer, or reject** OpenMetadata for
   broader adoption.
5. Findings are shared with stakeholders in a concise readout with identified next steps.

### Business value
> Gives the business a fact-based view of whether OpenMetadata can improve trust and
> discoverability across Snowflake data assets — reducing time spent finding the right data,
> improving transparency into upstream/downstream dependencies, and strengthening metadata
> governance for reporting teams.

## Kickoff thread (Teams) — operational context
- Need a **pre-prod instance** of OpenMetadata; eventual home is an **ECS instance in Analytics
  pre-prod** (AWS). Reference shared: the OpenMetadata *local-docker-deployment* quickstart (v1.12.x).
- **An instance was needed by Monday EOD** (hence this minimal, reproducible scaffold).
- A repository was to be created and **must follow the org standards**; the name hinted in the
  thread is **`GPS.DATALAKE.OPENMETADATA`**.

## Scope mapping (how this repo addresses each criterion)
| Acceptance criterion | Where it is handled |
|---|---|
| 1 — connect non-prod Snowflake, ingest pilot scope | `ingestion/connections/snowflake.yaml` + `make ingest-snowflake` |
| 2 — discovery / ownership / schema / lineage | OpenMetadata UI (Explore) + `snowflake_lineage.yaml` |
| 3 — document functional fit / effort / security / support | `docs/EVALUATION.md`, `docs/sources/snowflake.md` |
| 4 — proceed/defer/reject recommendation | `docs/EVALUATION.md` (Recommendation) |
| 5 — stakeholder readout | `docs/EVALUATION.md` (Readout) |
