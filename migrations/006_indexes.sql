-- Spatial indexes
CREATE INDEX idx_parcel_geom
    ON iris_core.parcel
    USING GIST (geom);

CREATE INDEX idx_substation_geom
    ON iris_core.substation
    USING GIST (geom);

CREATE INDEX idx_peatland_geom
    ON iris_core.peatland
    USING GIST (geom);

CREATE INDEX idx_screening_layer_geom
    ON iris_core.screening_layer
    USING GIST (geom);


-- Relational/filtering indexes
CREATE INDEX idx_parcel_country_region
    ON iris_core.parcel (country_code, region_code);

CREATE INDEX idx_substation_country_region
    ON iris_core.substation (country_code, region_code);

CREATE INDEX idx_peatland_country_region
    ON iris_core.peatland (country_code, region_code);

CREATE INDEX idx_screening_layer_country_region
    ON iris_core.screening_layer (country_code, region_code);

CREATE INDEX idx_evidence_parcel
    ON iris_core.evidence (parcel_id);