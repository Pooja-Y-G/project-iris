-- ============================================================
-- Project IRIS - deterministic development fixtures
-- All geometries use EPSG:4326.
-- Data below is synthetic and for verification only.
-- ============================================================


-- 1. Source runs
INSERT INTO iris_core.source_run
    (country_code, source_id, source_date)
VALUES
    ('DE', 'demo_parcels', DATE '2026-01-01'),
    ('DE', 'demo_substations', DATE '2026-01-01'),
    ('DE', 'demo_peatlands', DATE '2026-01-01'),
    ('DE', 'demo_screening', DATE '2026-01-01');


-- 2. Parcel
INSERT INTO iris_core.parcel
    (country_code, region_code, source_id, source_date, geom)
VALUES
(
    'DE',
    'BY',
    'parcel_001',
    DATE '2026-01-01',
    ST_Multi(
        ST_GeomFromText(
            'POLYGON((
                10.0000 48.0000,
                10.0100 48.0000,
                10.0100 48.0100,
                10.0000 48.0100,
                10.0000 48.0000
            ))',
            4326
        )
    )
);


-- 3. Substation
INSERT INTO iris_core.substation
    (country_code, region_code, source_id, source_date, geom)
VALUES
(
    'DE',
    'BY',
    'substation_001',
    DATE '2026-01-01',
    ST_SetSRID(
        ST_MakePoint(10.0150, 48.0050),
        4326
    )
);


-- 4. Peatland
-- Deliberately overlaps parcel_001.
INSERT INTO iris_core.peatland
    (country_code, region_code, source_id, source_date, geom)
VALUES
(
    'DE',
    'BY',
    'peatland_001',
    DATE '2026-01-01',
    ST_Multi(
        ST_GeomFromText(
            'POLYGON((
                10.0050 48.0050,
                10.0150 48.0050,
                10.0150 48.0150,
                10.0050 48.0150,
                10.0050 48.0050
            ))',
            4326
        )
    )
);


-- 5. Screening layer
INSERT INTO iris_core.screening_layer
    (country_code, region_code, source_id, source_date, layer_type, geom)
VALUES
(
    'DE',
    'BY',
    'screening_001',
    DATE '2026-01-01',
    'environmental_constraint',
    ST_Multi(
        ST_GeomFromText(
            'POLYGON((
                10.0200 48.0200,
                10.0300 48.0200,
                10.0300 48.0300,
                10.0200 48.0300,
                10.0200 48.0200
            ))',
            4326
        )
    )
);


-- 6. Evidence
INSERT INTO iris_core.evidence
    (
        country_code,
        source_id,
        source_date,
        parcel_id,
        evidence_type,
        description
    )
SELECT
    'DE',
    'evidence_001',
    DATE '2026-01-01',
    id,
    'peatland_overlap',
    'Synthetic fixture demonstrating parcel and peatland intersection.'
FROM iris_core.parcel
WHERE country_code = 'DE'
  AND source_id = 'parcel_001';