
SET CURRENT SCHEMA CRYPTO;

-- ============================================================
-- PROTOCOL
-- ============================================================

CREATE TABLE PROTOCOL (
    ID BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,

    NAME VARCHAR(150) NOT NULL,
    TYPE VARCHAR(40),
    WEBSITE VARCHAR(500),
    ACTIVE SMALLINT NOT NULL DEFAULT 1
);
