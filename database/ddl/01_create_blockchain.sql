
SET CURRENT SCHEMA CRYPTO;

-- ============================================================
-- BLOCKCHAIN
-- ============================================================

CREATE TABLE BLOCKCHAIN (
    ID BIGINT
        GENERATED ALWAYS AS IDENTITY
        PRIMARY KEY,
    NAME VARCHAR(100) NOT NULL,
    SYMBOL VARCHAR(20),
    CHAIN_ID VARCHAR(50),
    EXPLORER_URL VARCHAR(500),
    ACTIVE SMALLINT NOT NULL DEFAULT 1
);
