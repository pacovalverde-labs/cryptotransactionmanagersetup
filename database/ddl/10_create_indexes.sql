-- ============================================================
-- Crypto Transaction Manager
-- Additional indexes
-- IBM DB2
-- Schema: CRYPTO
-- ============================================================

SET CURRENT SCHEMA CRYPTO;

-- ============================================================
-- CRYPTOCURRENCY
-- ============================================================

-- Used when retrieving all assets belonging to a blockchain.
CREATE INDEX CRYPTO.IX_CRYPTOCURRENCY_BLOCKCHAIN
    ON CRYPTO.CRYPTOCURRENCY (BLOCKCHAIN_ID);

-- ============================================================
-- MOVEMENT
-- ============================================================

-- Transaction hash lookups.
CREATE INDEX CRYPTO.IX_MOVEMENT_TX_HASH
    ON CRYPTO.MOVEMENT (TX_HASH);

-- Movements by blockchain.
CREATE INDEX CRYPTO.IX_MOVEMENT_BLOCKCHAIN
    ON CRYPTO.MOVEMENT (BLOCKCHAIN_ID);

-- Movements associated with a protocol.
CREATE INDEX CRYPTO.IX_MOVEMENT_PROTOCOL
    ON CRYPTO.MOVEMENT (PROTOCOL_ID);

-- Movements belonging to an import batch.
CREATE INDEX CRYPTO.IX_MOVEMENT_IMPORT_SOURCE
    ON CRYPTO.MOVEMENT (IMPORT_SOURCE_ID);

-- Useful for chronological searches and transaction history.
CREATE INDEX CRYPTO.IX_MOVEMENT_TX_TIMESTAMP
    ON CRYPTO.MOVEMENT (TX_TIMESTAMP);

-- ============================================================
-- MOVEMENT_CRYPTOCURRENCY
-- ============================================================

-- Assets belonging to a movement.
CREATE INDEX CRYPTO.IX_MOV_CRYPTO_MOVEMENT
    ON CRYPTO.MOVEMENT_CRYPTOCURRENCY (MOVEMENT_ID);

-- Movements in which a cryptocurrency appears.
CREATE INDEX CRYPTO.IX_MOV_CRYPTO_CRYPTOCURRENCY
    ON CRYPTO.MOVEMENT_CRYPTOCURRENCY (CRYPTOCURRENCY_ID);

-- ============================================================
-- MOVEMENT_WEB_DATA
-- ============================================================

-- Web data belonging to a movement.
CREATE INDEX CRYPTO.IX_MOVEMENT_WEB_DATA_MOVEMENT
    ON CRYPTO.MOVEMENT_WEB_DATA (MOVEMENT_ID);

-- ============================================================
-- OWN_ADDRESS_BLOCKCHAIN
-- ============================================================

-- The UNIQUE constraint
-- (OWN_ADDRESS_ID, BLOCKCHAIN_ID)
-- already provides an index whose first column is OWN_ADDRESS_ID.
--
-- This additional index is useful for searches starting from
-- BLOCKCHAIN_ID.

CREATE INDEX CRYPTO.IX_OAB_BLOCKCHAIN
    ON CRYPTO.OWN_ADDRESS_BLOCKCHAIN (BLOCKCHAIN_ID);