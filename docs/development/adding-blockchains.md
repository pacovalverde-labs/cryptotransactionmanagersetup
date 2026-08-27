# Adding blockchains

Adding a blockchain is a catalog, explorer-detection, asset, parser, and test change. A row in
`CRYPTO.BLOCKCHAIN` makes the network visible to the application, but it does not by itself make
every transaction on that network analyzable.

## 1. Collect authoritative network data

Record:

- canonical network name
- native asset symbol
- chain ID or network identifier, when one exists
- preferred explorer base URL
- representative transaction URL patterns
- native asset decimals
- relevant token contract addresses and decimals
- whether the explorer is shared with other networks
- whether the explorer renders useful server-side HTML or requires another data source

Do not infer a token contract from its ticker. Verify contract addresses against an authoritative
project or explorer source before publishing them as initial data.

## 2. Add the blockchain catalog row

Add the row to `database/data/01_blockchains.sql`, not only through the local Swing form.

EVM example:

```sql
INSERT INTO CRYPTO.BLOCKCHAIN (
    NAME,
    SYMBOL,
    CHAIN_ID,
    EXPLORER_URL,
    ACTIVE
)
VALUES (
    'Example Network',
    'EXM',
    '12345',
    'https://explorer.example.org',
    1
);
```

Non-EVM example:

```sql
INSERT INTO CRYPTO.BLOCKCHAIN (
    NAME,
    SYMBOL,
    CHAIN_ID,
    EXPLORER_URL,
    ACTIVE
)
VALUES (
    'Example Chain',
    'EXC',
    NULL,
    'https://scan.example.org',
    1
);
```

`CHAIN_ID` is `VARCHAR(50)` intentionally. Use the authoritative text identifier for networks
such as Cosmos SDK chains; do not force all identifiers into a numeric EVM model.

Keep the name stable. Cryptocurrency seed scripts frequently resolve the foreign key with
`WHERE NAME = '...'`, so an uncoordinated rename can make later inserts create zero rows.

## 3. Add the native cryptocurrency

Add an entry to `database/data/03_cryptocurrencies.sql`:

```sql
INSERT INTO CRYPTO.CRYPTOCURRENCY (
    BLOCKCHAIN_ID,
    NAME,
    TICKER,
    CONTRACT_ADDRESS,
    DECIMALS,
    IS_NATIVE,
    ACTIVE
)
SELECT
    ID,
    'Example Coin',
    'EXM',
    NULL,
    18,
    1,
    1
FROM CRYPTO.BLOCKCHAIN
WHERE NAME = 'Example Network';
```

Native fee assets normally have no token contract on their own network. Do not invent a contract
address. A wrapped representation such as WETH or WPOL is a separate token with a contract and
`IS_NATIVE = 0`.

## 4. Add relevant tokens

Create separate records for each network deployment:

```sql
INSERT INTO CRYPTO.CRYPTOCURRENCY (
    BLOCKCHAIN_ID,
    NAME,
    TICKER,
    CONTRACT_ADDRESS,
    DECIMALS,
    IS_NATIVE,
    ACTIVE
)
SELECT
    ID,
    'Example USD',
    'xUSD',
    '0x0000000000000000000000000000000000000000',
    6,
    0,
    1
FROM CRYPTO.BLOCKCHAIN
WHERE NAME = 'Example Network';
```

Replace the zero address with a verified contract before committing. Distinguish native,
wrapped, bridged, and protocol receipt/debt tokens even when their display tickers are similar.

For lending integrations, consider both the user's underlying assets and any receipt or debt
tokens that appear in explorer events. Do not assume protocol token contracts are the same on
every deployment.

## 5. Update URL detection

Test every URL form that should map to the new blockchain:

- standard transaction URL
- transaction-group or bundle URL
- alternate explorer host or legacy host
- query parameters and fragments
- URL-encoded transaction identifiers
- shared explorer vendor with a network-specific path

Prefer parsing the URI host and path instead of using a broad substring search. Normalize the
host to lowercase, remove a trailing dot, and decide explicitly whether `www.` variants are
accepted.

Do not treat address or token pages as transactions merely because they use the same explorer.
For example, distinguish `/tx/` from `/address/` and `/token/`.

If the application loads detection from `CRYPTO.BLOCKCHAIN.EXPLORER_URL`, ensure the service
catalog is reloaded after inserting or editing a network.

## 6. Decide parser coverage

Classify the explorer:

| Situation | Action |
|---|---|
| Existing parser already supports the vendor and page structure | Add detection and regression tests |
| Vendor is shared but the network exposes different fields | Extend cautiously or add a network specialization |
| Server HTML contains generic transaction data | Use generic extraction plus small normalization rules |
| Page structure is materially different | Add an explorer-specific parser |
| HTML is only an application shell | Investigate an official API or embedded JSON source within project policy |

EVM compatibility does not guarantee identical explorer HTML. Avalanche C-Chain is EVM, but a
Snowtrace/Routescan Aave supply can require explorer-specific extraction beyond a generic EVM
parser. Likewise, Algorand transaction groups on Allo require logic different from a single EVM
transaction.

See [Adding parsers](adding-parsers.md).

## 7. Add representative fixtures

Keep sanitized test cases for:

- simple native transfer
- fungible-token transfer
- failed transaction
- contract interaction
- multi-asset transaction
- fee detection
- protocol action relevant to the project
- an unknown action that must remain partial rather than be misclassified

When permitted, store small HTML or JSON fixtures used by unit tests. Do not rely exclusively on
live explorer pages: they change, rate-limit, and make tests nondeterministic. Remove personal
labels and secrets; public transaction data can still reveal financial history, so select
fixtures deliberately.

## 8. Validate persistence and UI

1. Rebuild or update the development catalog.
2. Verify the blockchain row:

```sql
SELECT *
FROM CRYPTO.BLOCKCHAIN
WHERE NAME = 'Example Network';
```

3. Verify its assets:

```sql
SELECT C.*
FROM CRYPTO.CRYPTOCURRENCY C
JOIN CRYPTO.BLOCKCHAIN B
  ON B.ID = C.BLOCKCHAIN_ID
WHERE B.NAME = 'Example Network'
ORDER BY C.IS_NATIVE DESC, C.TICKER;
```

4. Reload the Blockchain and Cryptocurrency panels.
5. Analyze each representative URL.
6. Confirm `BLOCKCHAIN_ID`, transaction hash, addresses, status, assets, roles, amounts, fee,
   HTTP metadata, and stored HTML.
7. Save and reload the movement.
8. Confirm existing blockchains still parse correctly.

## 9. Update documentation

In the same change:

- update supported-network documentation
- update seed scripts
- document the explorer and limitations
- list parser coverage and known partial cases
- add fixtures/tests
- note any new dependency or configuration key

## Completion checklist

- [ ] Blockchain row added with schema-qualified SQL
- [ ] Stable network name and correct chain ID recorded
- [ ] Native asset added with `IS_NATIVE = 1`
- [ ] Verified token contracts added as network-specific rows
- [ ] Transaction URLs distinguished from address/token pages
- [ ] Generic or specialized parser selected
- [ ] Representative fixtures and negative cases tested
- [ ] UI catalogs reload correctly
- [ ] Movement and associated details persist correctly
- [ ] Existing networks pass regression tests
- [ ] Documentation updated
