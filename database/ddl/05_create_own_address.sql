
SET CURRENT SCHEMA CRYPTO;

-- ============================================================
-- OWN_ADDRESS
-- ============================================================

CREATE TABLE CRYPTO.OWN_ADDRESS (
    ID BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,
    ADDRESS VARCHAR(255) NOT NULL,
    LABEL VARCHAR(150),
    NOTES VARCHAR(1000),
    SOFT_DELETED SMALLINT
        NOT NULL
        DEFAULT 0,

    CONSTRAINT UQ_OWN_ADDRESS_ADDRESS
        UNIQUE (ADDRESS)
);