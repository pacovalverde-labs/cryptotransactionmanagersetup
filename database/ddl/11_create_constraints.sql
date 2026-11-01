-- ============================================================
-- Crypto Transaction Manager
-- Constraints
-- IBM DB2
-- Schema: CRYPTO
-- ============================================================

SET CURRENT SCHEMA CRYPTO;

-- ============================================================
-- CRYPTOCURRENCY
-- ============================================================

ALTER TABLE CRYPTO.CRYPTOCURRENCY
    ADD CONSTRAINT FK_CRYPTOCURRENCY_BLOCKCHAIN
    FOREIGN KEY (BLOCKCHAIN_ID)
    REFERENCES CRYPTO.BLOCKCHAIN (ID);

-- ============================================================
-- MOVEMENT
-- ============================================================

ALTER TABLE CRYPTO.MOVEMENT
    ADD CONSTRAINT FK_MOVEMENT_BLOCKCHAIN
    FOREIGN KEY (BLOCKCHAIN_ID)
    REFERENCES CRYPTO.BLOCKCHAIN (ID);

ALTER TABLE CRYPTO.MOVEMENT
    ADD CONSTRAINT FK_MOVEMENT_PROTOCOL
    FOREIGN KEY (PROTOCOL_ID)
    REFERENCES CRYPTO.PROTOCOL (ID);

ALTER TABLE CRYPTO.MOVEMENT
    ADD CONSTRAINT FK_MOVEMENT_IMPORT_SOURCE
    FOREIGN KEY (IMPORT_SOURCE_ID)
    REFERENCES CRYPTO.IMPORT_SOURCE (ID);

-- The same explorer URL should not be imported twice.
ALTER TABLE CRYPTO.MOVEMENT
    ADD CONSTRAINT UQ_MOVEMENT_URL
    UNIQUE (URL);

-- ============================================================
-- MOVEMENT_CRYPTOCURRENCY
-- ============================================================

ALTER TABLE CRYPTO.MOVEMENT_CRYPTOCURRENCY
    ADD CONSTRAINT FK_MOV_CRYPTO_MOVEMENT
    FOREIGN KEY (MOVEMENT_ID)
    REFERENCES CRYPTO.MOVEMENT (ID);

ALTER TABLE CRYPTO.MOVEMENT_CRYPTOCURRENCY
    ADD CONSTRAINT FK_MOV_CRYPTO_CRYPTOCURRENCY
    FOREIGN KEY (CRYPTOCURRENCY_ID)
    REFERENCES CRYPTO.CRYPTOCURRENCY (ID);

-- ============================================================
-- MOVEMENT_WEB_DATA
-- ============================================================

ALTER TABLE CRYPTO.MOVEMENT_WEB_DATA
    ADD CONSTRAINT FK_MOVEMENT_WEB_DATA_MOVEMENT
    FOREIGN KEY (MOVEMENT_ID)
    REFERENCES CRYPTO.MOVEMENT (ID);

-- ============================================================
-- OWN_ADDRESS
-- ============================================================

ALTER TABLE CRYPTO.OWN_ADDRESS
    ADD CONSTRAINT UQ_OWN_ADDRESS_ADDRESS
    UNIQUE (ADDRESS);

-- ============================================================
-- OWN_ADDRESS_BLOCKCHAIN
-- ============================================================

ALTER TABLE CRYPTO.OWN_ADDRESS_BLOCKCHAIN
    ADD CONSTRAINT FK_OAB_ADDRESS
    FOREIGN KEY (OWN_ADDRESS_ID)
    REFERENCES CRYPTO.OWN_ADDRESS (ID);

ALTER TABLE CRYPTO.OWN_ADDRESS_BLOCKCHAIN
    ADD CONSTRAINT FK_OAB_BLOCKCHAIN
    FOREIGN KEY (BLOCKCHAIN_ID)
    REFERENCES CRYPTO.BLOCKCHAIN (ID);

-- An address cannot be associated twice with the same blockchain.
ALTER TABLE CRYPTO.OWN_ADDRESS_BLOCKCHAIN
    ADD CONSTRAINT UQ_OAB_ADDRESS_BLOCKCHAIN
    UNIQUE (OWN_ADDRESS_ID, BLOCKCHAIN_ID);

-- ============================================================
-- BOOLEAN-LIKE FIELDS
-- ============================================================

ALTER TABLE CRYPTO.BLOCKCHAIN
    ADD CONSTRAINT CK_BLOCKCHAIN_ACTIVE
    CHECK (ACTIVE IN (0, 1));

ALTER TABLE CRYPTO.PROTOCOL
    ADD CONSTRAINT CK_PROTOCOL_ACTIVE
    CHECK (ACTIVE IN (0, 1));

ALTER TABLE CRYPTO.CRYPTOCURRENCY
    ADD CONSTRAINT CK_CRYPTOCURRENCY_ACTIVE
    CHECK (ACTIVE IN (0, 1));

ALTER TABLE CRYPTO.CRYPTOCURRENCY
    ADD CONSTRAINT CK_CRYPTOCURRENCY_IS_NATIVE
    CHECK (IS_NATIVE IS NULL OR IS_NATIVE IN (0, 1));

ALTER TABLE CRYPTO.OWN_ADDRESS
    ADD CONSTRAINT CK_OWN_ADDRESS_SOFT_DELETED
    CHECK (SOFT_DELETED IN (0, 1));