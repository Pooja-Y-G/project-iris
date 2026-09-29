CREATE TABLE iris_core.parcel (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    country_code VARCHAR(2) NOT NULL,
    region_code TEXT,
    source_id TEXT NOT NULL,
    source_date DATE NOT NULL,

    geom geometry(MultiPolygon, 4326) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_parcel_country_source
    UNIQUE (country_code, source_id),

    CONSTRAINT uq_parcel_country_id
    UNIQUE (country_code, id)
);


CREATE TABLE iris_core.substation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    country_code VARCHAR(2) NOT NULL,
    region_code TEXT,
    source_id TEXT NOT NULL,
    source_date DATE NOT NULL,

    geom geometry(Point, 4326) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_substation_country_source
        UNIQUE (country_code, source_id)
);


CREATE TABLE iris_core.peatland (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    country_code VARCHAR(2) NOT NULL,
    region_code TEXT,
    source_id TEXT NOT NULL,
    source_date DATE NOT NULL,

    geom geometry(MultiPolygon, 4326) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_peatland_country_source
        UNIQUE (country_code, source_id)
);


CREATE TABLE iris_core.screening_layer (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    country_code VARCHAR(2) NOT NULL,
    region_code TEXT,
    source_id TEXT NOT NULL,
    source_date DATE NOT NULL,

    layer_type TEXT NOT NULL,

    geom geometry(MultiPolygon, 4326) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_screening_layer_country_source
        UNIQUE (country_code, source_id)
);