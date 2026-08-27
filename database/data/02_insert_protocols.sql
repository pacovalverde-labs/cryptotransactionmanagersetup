-- ============================================================
-- CryptoTransactionManager
-- Datos iniciales para CRYPTO.PROTOCOL
-- IBM Db2
--
-- Convención del proyecto:
-- usar siempre el esquema explícito CRYPTO.TABLA.
-- ============================================================


-- ============================================================
-- LENDING / MONEY MARKETS
-- ============================================================

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Aave', 'LENDING', 'https://aave.com', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Folks Finance', 'LENDING', 'https://folks.finance', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Venus Protocol', 'LENDING', 'https://venus.io', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Starlay Finance', 'LENDING', 'https://starlay.finance', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Moola Market', 'LENDING', 'https://moola.market', 1);


-- ============================================================
-- DEX / TRADING
-- ============================================================

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('pact.fi', 'DEX', 'https://www.pact.fi', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Nomiswap', 'DEX', 'https://nomiswap.io', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('CoW Protocol', 'DEX', 'https://cow.fi', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('ArthSwap', 'DEX', 'https://app.arthswap.org', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('SushiSwap', 'DEX', 'https://www.sushi.com', 1);


-- ============================================================
-- STAKING
-- ============================================================

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Stader Labs', 'STAKING', 'https://www.staderlabs.com', 1);

-- Se conserva la URL histórica que aparece en links.txt.
INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Zillet', 'STAKING', 'https://v1.zillet.io/staking', 1);


-- ============================================================
-- BRIDGES
-- ============================================================

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Messina', 'BRIDGE', 'https://messina.one', 1);


-- ============================================================
-- CENTRALIZED EXCHANGES
-- ============================================================

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Binance', 'CEX', 'https://www.binance.com', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('MEXC', 'CEX', 'https://www.mexc.com', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('KuCoin', 'CEX', 'https://www.kucoin.com', 1);


-- ============================================================
-- WALLETS
-- ============================================================

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('MetaMask', 'WALLET', 'https://metamask.io', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Exodus Wallet', 'WALLET', 'https://exodus.com', 1);

INSERT INTO CRYPTO.PROTOCOL (NAME, TYPE, WEBSITE, ACTIVE)
VALUES ('Atomic Wallet', 'WALLET', 'https://atomicwallet.io', 1);


COMMIT;


-- ============================================================
-- COMPROBACIÓN
-- ============================================================

SELECT
    ID,
    NAME,
    TYPE,
    WEBSITE,
    ACTIVE
FROM CRYPTO.PROTOCOL
ORDER BY TYPE, NAME;
