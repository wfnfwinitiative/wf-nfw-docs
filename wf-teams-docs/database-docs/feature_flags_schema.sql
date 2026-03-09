CREATE TABLE wfnfw.feature_flags (
    id BIGSERIAL PRIMARY KEY,
    feature_flag_name VARCHAR(100) NOT NULL UNIQUE,
    enabled BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_feature_flag_name ON wfnfw.feature_flags(feature_flag_name);


INSERT INTO wfnfw.feature_flags (feature_flag_name, enabled) VALUES ('voice_llm_service', false);
