-- ============================================================
-- Project IRIS - automated schema tests
-- Raises an exception if a critical contract is violated.
-- ============================================================

DO $$
BEGIN

    -- Required schemas
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'iris_core'
    ) THEN
        RAISE EXCEPTION 'TEST FAILED: iris_core schema missing';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.schemata
        WHERE schema_name = 'iris_staging'
    ) THEN
        RAISE EXCEPTION 'TEST FAILED: iris_staging schema missing';
    END IF;


    -- Required core tables
    IF (
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = 'iris_core'
          AND table_name IN (
              'parcel',
              'substation',
              'peatland',
              'screening_layer',
              'source_run',
              'evidence'
          )
    ) <> 6 THEN
        RAISE EXCEPTION 'TEST FAILED: required core tables missing';
    END IF;


    -- country_code must be NOT NULL on persisted business entities
    IF EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_schema = 'iris_core'
          AND table_name IN (
              'parcel',
              'substation',
              'peatland',
              'screening_layer',
              'source_run',
              'evidence'
          )
          AND column_name = 'country_code'
          AND is_nullable <> 'NO'
    ) THEN
        RAISE EXCEPTION 'TEST FAILED: nullable country_code detected';
    END IF;


    -- Canonical geom column must exist on spatial entities
    IF (
        SELECT COUNT(*)
        FROM information_schema.columns
        WHERE table_schema = 'iris_core'
          AND table_name IN (
              'parcel',
              'substation',
              'peatland',
              'screening_layer'
          )
          AND column_name = 'geom'
    ) <> 4 THEN
        RAISE EXCEPTION 'TEST FAILED: canonical geom column missing';
    END IF;


    -- Synthetic fixture must demonstrate peatland intersection
    IF NOT EXISTS (
        SELECT 1
        FROM iris_core.parcel p
        JOIN iris_core.peatland pt
          ON p.country_code = pt.country_code
        WHERE ST_Intersects(p.geom, pt.geom)
    ) THEN
        RAISE EXCEPTION 'TEST FAILED: expected spatial intersection missing';
    END IF;

END
$$;

SELECT 'All Project IRIS schema tests passed.' AS test_result;