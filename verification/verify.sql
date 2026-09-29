-- ============================================================
-- Project IRIS - verification queries
-- ============================================================

-- 1. Verify canonical geometry and SRID
SELECT
    source_id,
    ST_GeometryType(geom) AS geometry_type,
    ST_SRID(geom) AS srid,
    ST_IsValid(geom) AS valid
FROM iris_core.parcel;


-- 2. Verify parcel / peatland intersection
SELECT
    p.source_id AS parcel,
    pt.source_id AS peatland,
    ST_Intersects(p.geom, pt.geom) AS intersects
FROM iris_core.parcel p
JOIN iris_core.peatland pt
    ON p.country_code = pt.country_code;


-- 3. Find substations within 2 km of a parcel
SELECT
    p.source_id AS parcel,
    s.source_id AS substation,
    ROUND(
        ST_Distance(
            p.geom::geography,
            s.geom::geography
        )
    ) AS distance_metres
FROM iris_core.parcel p
JOIN iris_core.substation s
    ON p.country_code = s.country_code
WHERE ST_DWithin(
    p.geom::geography,
    s.geom::geography,
    2000
);


-- 4. Verify evidence linked to parcel
SELECT
    p.source_id AS parcel,
    e.evidence_type,
    e.description
FROM iris_core.evidence e
JOIN iris_core.parcel p
    ON p.id = e.parcel_id
   AND p.country_code = e.country_code;


-- 5. Demonstrate spatial index usage
EXPLAIN
SELECT *
FROM iris_core.parcel
WHERE geom && ST_MakeEnvelope(
    9.99,
    47.99,
    10.02,
    48.02,
    4326
);