SET CURRENT SCHEMA CRYPTO;

-- ============================================================
-- CRYPTO.BLOCKCHAINS PRESENTES EN links.txt
-- ============================================================

-- Bitcoin
INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Bitcoin', 'BTC', NULL, 'https://mempool.space', 1);

-- EVM / compatibles EVM
INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Ethereum', 'ETH', '1', 'https://etherscan.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Polygon', 'POL', '137', 'https://polygonscan.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Avalanche C-Chain', 'AVAX', '43114', 'https://snowtrace.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('BNB Smart Chain', 'BNB', '56', 'https://bscscan.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Sonic', 'S', '146', 'https://sonicscan.org', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Fantom Opera', 'FTM', '250', 'https://ftmscan.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Celo', 'CELO', '42220', 'https://celoscan.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Astar', 'ASTR', '592', 'https://astar.blockscout.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('KCC', 'KCS', '321', 'https://scan.kcc.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Metis Andromeda', 'METIS', '1088', 'https://andromeda-explorer.metis.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('HyperEVM', 'HYPE', '999', 'https://hyperevmscan.io', 1);

-- Cosmos SDK / IBC
INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Osmosis', 'OSMO', 'osmosis-1', 'https://www.mintscan.io/osmosis', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Kava', 'KAVA', 'kava_2222-10', 'https://www.mintscan.io/kava', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Fetch.ai', 'FET', NULL, 'https://www.mintscan.io/fetchai', 1);

-- Otras arquitecturas
INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Algorand', 'ALGO', NULL, 'https://allo.info', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Hedera', 'HBAR', '295', 'https://hashscan.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('IOTA', 'IOTA', NULL, 'https://explorer.iota.org', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Solana', 'SOL', NULL, 'https://explorer.solana.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Cardano', 'ADA', NULL, 'https://cexplorer.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('XRP Ledger', 'XRP', NULL, 'https://bithomp.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Stacks', 'STX', NULL, 'https://explorer.hiro.so', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Zcash', 'ZEC', NULL, 'https://blockchair.com/zcash', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Zilliqa', 'ZIL', NULL, 'https://otterscan.zilliqa.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Dash', 'DASH', NULL, 'https://dash.atomicwallet.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Verge', 'XVG', NULL, 'https://verge-CRYPTO.BLOCKCHAIN.info', 1);

-- ============================================================
-- CRYPTO.BLOCKCHAINS ADICIONALES IMPORTANTES
-- ============================================================

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Arbitrum One', 'ETH', '42161', 'https://arbiscan.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Base', 'ETH', '8453', 'https://base.blockscout.com', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('OP Mainnet', 'ETH', '10', 'https://explorer.optimism.io', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('TRON', 'TRX', NULL, 'https://tronscan.org', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Cosmos Hub', 'ATOM', 'cosmoshub-4', 'https://www.mintscan.io/cosmos', 1);

INSERT INTO CRYPTO.BLOCKCHAIN (NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE)
VALUES ('Polkadot', 'DOT', NULL, 'https://polkadot.subscan.io', 1);

COMMIT;

-- ============================================================
-- COMPROBACIÓN
-- ============================================================

SELECT
    ID,
    NAME,
    SYMBOL,
    CHAIN_ID,
    EXPLORER_URL,
    ACTIVE
FROM CRYPTO.BLOCKCHAIN
ORDER BY NAME;
