# Project IRIS - PostGIS Pilot Schema

This project contains a small PostgreSQL/PostGIS schema for the Project IRIS pilot.

It stores parcels, substations, peatlands, screening layers, source information and evidence for basic spatial screening.

## Tech Stack

- PostgreSQL 16
- PostGIS 3.4
- Docker
- SQL
- PowerShell

## Project Structure

```text
migrations/      SQL migrations
seeds/           Sample test data
verification/    Spatial verification queries
tests/           SQL tests
docs/            Schema diagram
compose.yaml     PostgreSQL/PostGIS container
init-db.ps1      Initialize the database
reset-db.ps1     Rebuild the database
```

## Setup

Docker and PowerShell are required.

Start and initialize the database:

```powershell
.\init-db.ps1
```

To delete the current database and rebuild everything:

```powershell
.\reset-db.ps1
```

The scripts run the migrations, load the sample data and run the tests and verification queries.

## Database Schemas

The project uses two schemas:

- `iris_staging` - reserved for raw/source data before it is moved into the core schema.
- `iris_core` - contains the main pilot tables.

Core tables:

- `parcel`
- `substation`
- `peatland`
- `screening_layer`
- `source_run`
- `evidence`

## Country-Aware Keys

`country_code` is required for all core entities.

Source identifiers are unique within a country using:

```text
(country_code, source_id)
```

The relationship between evidence and parcel also includes `country_code` so that records cannot be linked across countries.

## Geometry and CRS

The project uses the canonical column name `geom`.

Geometry types:

| Table | Geometry |
|---|---|
| parcel | MultiPolygon |
| substation | Point |
| peatland | MultiPolygon |
| screening_layer | MultiPolygon |

All geometries are stored using EPSG:4326 (WGS 84).

For distance queries, the geometry is converted to PostGIS `geography` so the distance can be calculated in metres.

## Indexes

GiST indexes are added to the geometry columns.

Additional indexes are included for common country/region filtering and the evidence-to-parcel relationship.

## Sample Data

`seeds/seed.sql` contains a small synthetic dataset for testing.

The sample parcel and peatland intentionally overlap so that `ST_Intersects` can be tested.

The sample data is only for development and does not represent real parcels or environmental data.

## Verification

Run:

```powershell
Get-Content .\verification\verify.sql |
    docker compose exec -T db psql -U iris -d iris
```

The queries check:

- geometry type and SRID
- geometry validity
- parcel/peatland intersection
- nearby substation distance
- evidence relationship
- spatial query plan

## Tests

Run:

```powershell
Get-Content .\tests\test_schema.sql |
    docker compose exec -T db psql -v ON_ERROR_STOP=1 -U iris -d iris
```

The tests check the main schema requirements such as required tables, `country_code`, geometry columns and the sample spatial intersection.

## Assumptions

This is a small pilot implementation, so I kept the design simple.

The staging schema does not contain source-specific tables because no external dataset is used in this assignment.

The sample data is synthetic and EPSG:4326 is used as the common storage CRS. For a production system, the staging model, source metadata and CRS strategy could be extended depending on the real data sources and countries.

Spatial screening results should be treated as preliminary. They do not confirm ownership, planning permission, grid capacity, environmental eligibility or project readiness.

## Schema Diagram

The Mermaid schema diagram is available in:

```text
docs/schema.md
```