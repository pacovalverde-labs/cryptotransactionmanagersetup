
SET CURRENT SCHEMA CRYPTO;

-- ============================================================
-- IMPORT_SOURCE
-- ============================================================

CREATE TABLE IMPORT_SOURCE (
    ID BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    FILE_NAME VARCHAR(255),
    FILE_PATH VARCHAR(1000),
    IMPORTED_AT TIMESTAMP,
    TOTAL_LINES INTEGER,
    TOTAL_URLS INTEGER,
    TOTAL_IMPORTED INTEGER,
    TOTAL_ERRORS INTEGER
);
