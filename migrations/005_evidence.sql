CREATE TABLE iris_core.evidence (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    country_code VARCHAR(2) NOT NULL,
    source_id TEXT NOT NULL,
    source_date DATE NOT NULL,

    parcel_id BIGINT NOT NULL,
    evidence_type TEXT NOT NULL,
    description TEXT,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_evidence_country_source
        UNIQUE (country_code, source_id),

    CONSTRAINT fk_evidence_parcel
        FOREIGN KEY (country_code, parcel_id)
        REFERENCES iris_core.parcel(country_code, id)
        ON DELETE CASCADE
);