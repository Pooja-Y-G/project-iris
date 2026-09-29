CREATE TABLE iris_core.source_run (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    country_code VARCHAR(2) NOT NULL,
    source_id TEXT NOT NULL,
    source_date DATE NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_source_run_country_source
        UNIQUE (country_code, source_id)
);