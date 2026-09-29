# Project IRIS — Canonical PostGIS Pilot Schema

A minimal, reproducible PostgreSQL/PostGIS implementation for the Project IRIS pilot.

The project models country-aware geospatial entities used for preliminary parcel screening, including parcels, substations, peatlands, screening layers, source metadata, and supporting evidence.

## Technology

- PostgreSQL 16
- PostGIS 3.4
- SQL
- Docker / Docker Compose
- PowerShell for local orchestration

## Project Structure

```text
project-iris/
├── migrations/
│   ├── 001_extensions.sql
│   ├── 002_schemas.sql
│   ├── 003_source_run.sql
│   ├── 004_core_tables.sql
│   ├── 005_evidence.sql
│   └── 006_indexes.sql
├── seeds/
│   └── seed.sql
├── verification/
│   └── verify.sql
├── tests/
│   └── test_schema.sql
├── docs/
│   └── schema.md
├── compose.yaml
├── init-db.ps1
├── reset-db.ps1
└── README.md
```

## Quick Start

### Prerequisites

The implementation requires:

- Docker
- Docker Compose
- PowerShell

No local PostgreSQL or PostGIS installation is required.

### Start and initialize

```powershell
.\init-db.ps1
```

This command:

1. Starts PostgreSQL/PostGIS.
2. Waits for the database health check.
3. Applies SQL migrations in order.
4. Loads deterministic fixtures.
5. Runs automated schema tests.
6. Runs verification queries.

### Reset and rebuild

To destroy the local database and rebuild it completely from the repository:

```powershell
.\reset-db.ps1
```

This provides a reproducible clean-database test without manual database configuration.

## Schemas

Two PostgreSQL schemas are created:

### `iris_staging`

Reserved as the ingestion boundary for source-specific/raw data before controlled promotion into the canonical model.

The pilot deliberately does not introduce source-specific staging tables because no external production dataset is required for this assignment.

### `iris_core`

Contains the canonical pilot entities:

- `parcel`
- `substation`
- `peatland`
- `screening_layer`
- `source_run`
- `evidence`

## Canonical Naming

The implementation uses the requested canonical names where applicable:

- `geom`
- `country_code`
- `region_code`
- `source_id`
- `source_date`
- `created_at`

The name `geometry` is intentionally not used as a core geometry column.

## Country-Aware Design

Every persisted core entity contains a non-null `country_code`.

Source identifiers are unique within their country scope using composite constraints such as:

```text
(country_code, source_id)
```

The evidence-to-parcel relationship is also country-scoped:

```text
evidence(country_code, parcel_id)
        →
parcel(country_code, id)
```

This prevents relationships from silently crossing country boundaries.

## Geometry and CRS Policy

Canonical spatial data is stored using EPSG:4326 (WGS 84).

Geometry contracts:

| Entity | Geometry |
|---|---|
| parcel | MultiPolygon, SRID 4326 |
| substation | Point, SRID 4326 |
| peatland | MultiPolygon, SRID 4326 |
| screening_layer | MultiPolygon, SRID 4326 |

EPSG:4326 is used as the canonical interchange/storage CRS for this pilot.

For operations requiring metric distances, the verification queries cast geometry to PostGIS `geography`, so distances are evaluated in metres rather than treating longitude/latitude degrees as metric units.

For a larger production workload, country-specific projected coordinate systems or additional derived/indexed representations should be evaluated based on the spatial operations and target regions.

## Indexing

Spatial entities use GiST indexes on `geom`.

Relational/filter indexes are provided for frequently used country and region filters.

Evidence also has an index supporting its parcel relationship.

## Deterministic Fixtures

`seeds/seed.sql` provides a small synthetic fixture set containing:

- one parcel
- one substation
- one peatland
- one screening layer
- source-run metadata
- one evidence record

The parcel and peatland deliberately overlap so that spatial intersection behaviour can be verified.

Fixture geometries are synthetic and must not be interpreted as real parcel, environmental, planning, ownership, or grid data.

## Verification

Run:

```powershell
Get-Content .\verification\verify.sql |
    docker compose exec -T db psql -U iris -d iris
```

Verification demonstrates:

- geometry type
- SRID
- geometry validity
- parcel/peatland intersection
- nearby-substation lookup
- evidence relationship
- spatial query planning/index availability

Because the fixture dataset is intentionally tiny, PostgreSQL may choose a sequential scan instead of a GiST index when that is cheaper. The index itself is part of the schema contract and can be inspected with PostgreSQL query planning tools.

## Automated Tests

Run:

```powershell
Get-Content .\tests\test_schema.sql |
    docker compose exec -T db psql -v ON_ERROR_STOP=1 -U iris -d iris
```

The tests fail immediately when critical schema contracts are violated.

They currently verify:

- required schemas
- required core entities
- non-null `country_code`
- canonical `geom` columns
- expected spatial intersection behaviour

## Assumptions and Deliberate Simplifications

This submission implements the minimum reproducible pilot contract rather than a production ingestion platform.

Deliberate simplifications include:

- synthetic fixtures instead of proprietary or paid data
- no production credentials or external APIs
- no source-specific staging adapters
- one canonical storage CRS
- a generalized `screening_layer` entity
- minimal source-run metadata

The schema can evolve by adding source-specific staging adapters, richer provenance, additional screening categories, projected CRS strategies, and more detailed evidence models without changing the basic canonical naming conventions.

## Screening Interpretation

Spatial results produced by this pilot are preliminary and indicative.

An intersection or proximity result is evidence for further investigation, not proof of development suitability.

Ownership, planning status, grid capacity, environmental eligibility, transferability, permitting, and project readiness require independent verification.

The schema does not represent a permit, grid reservation, ownership confirmation, or development-readiness decision.

## Schema Diagram

See:

```text
docs/schema.md
```

for the Mermaid entity relationship diagram.