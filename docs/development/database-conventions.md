# Database conventions

These conventions apply to all SQL, Java persistence code, setup scripts, and database
documentation for **Crypto Transaction Manager**.

## Database and schema names

| Object | Convention |
|---|---|
| Physical database | `CRYPTOTX` |
| Application schema | `CRYPTO` |
| Tables and columns | `UPPER_SNAKE_CASE` |
| Java packages | `com.pacovalverde.cryptotx...` |
| Java members | `camelCase` |

Personal names are acceptable in the Java package namespace as software-author identity. Do not
use personal names in schemas, tables, columns, database users shown in examples, or domain
variables.

## Always qualify application tables

Use:

```sql
SELECT ID, NAME
FROM CRYPTO.BLOCKCHAIN;
```

Do not rely on:

```sql
SELECT ID, NAME
FROM BLOCKCHAIN;
```

This rule applies even when a script contains:

```sql
SET CURRENT SCHEMA CRYPTO;
```

Explicit qualification improves DBeaver resolution, avoids accidental access to a table with the
same name in another schema, and makes repository SQL self-explanatory.

## Unquoted uppercase identifiers

Db2 normalizes unquoted identifiers to uppercase. Define and reference project objects without
double quotes:

```sql
CREATE TABLE CRYPTO.IMPORT_SOURCE (...);
```

Avoid:

```sql
CREATE TABLE CRYPTO."ImportSource" (...);
```

Quoted mixed-case identifiers require exact casing in every query and add no benefit to this
project.

## Singular table names

Use the established singular names exactly:

```text
BLOCKCHAIN
PROTOCOL
IMPORT_SOURCE
CRYPTOCURRENCY
OWN_ADDRESS
OWN_ADDRESS_BLOCKCHAIN
MOVEMENT
MOVEMENT_CRYPTOCURRENCY
MOVEMENT_WEB_DATA
```

Do not write `BLOCKCHAINS`, `MOVEMENTS`, or another plural variant. This has already caused a
runtime table-not-found error during development.

## Primary keys and identities

Use:

```sql
ID BIGINT
    GENERATED ALWAYS AS IDENTITY
    PRIMARY KEY
```

Java must not generate these values. Repositories can obtain the identity with Db2's
`FINAL TABLE (INSERT ...)` pattern:

```sql
SELECT ID
FROM FINAL TABLE (
    INSERT INTO CRYPTO.MOVEMENT (URL, CREATED_AT, UPDATED_AT)
    VALUES (?, CURRENT TIMESTAMP, CURRENT TIMESTAMP)
);
```

Use `long` for required identifiers and `Long` for nullable foreign keys in Java.

## Foreign keys

Name constraints descriptively with stable prefixes:

```text
PK_   primary key when explicitly named
FK_   foreign key
UQ_   unique constraint
CK_   check constraint
```

Example:

```sql
CONSTRAINT FK_MOVEMENT_BLOCKCHAIN
    FOREIGN KEY (BLOCKCHAIN_ID)
    REFERENCES CRYPTO.BLOCKCHAIN (ID)
```

Even if the current schema was initially created with unqualified `REFERENCES BLOCKCHAIN`, new
and reorganized setup scripts should use `CRYPTO.BLOCKCHAIN` for clarity.

Index frequently queried foreign-key columns. Db2 does not automatically make every foreign key
an efficient application lookup path.

## Nullability

Declare `NOT NULL` only when the application can always provide a meaningful value. Imported
transactions are often partially recognized, so fields such as blockchain, protocol, timestamp,
and addresses may initially be `NULL`.

Do not use empty strings, zero IDs, or fake values such as `UNKNOWN_ADDRESS` to replace a true
unknown. Use catalog values such as `UNKNOWN` only when the field is explicitly a classification.

In JDBC, preserve nullable numeric values:

```java
long value = resultSet.getLong("BLOCKCHAIN_ID");
Long blockchainId = resultSet.wasNull() ? null : value;
```

For parameters, use `setNull(..., Types.BIGINT)` when the Java value is null.

## Boolean-like flags

The current schema uses `SMALLINT` flags:

```text
0 = false
1 = true
```

Examples include `ACTIVE`, `IS_NATIVE`, and `SOFT_DELETED`. Define a default and `NOT NULL` where
the state must always be known.

Use one mapping strategy consistently in repositories. Do not allow arbitrary values such as `2`
unless the column is intentionally expanded beyond a Boolean flag; a `CHECK` constraint for
`IN (0, 1)` can enforce this.

## Text lengths

Established sizes include:

| Purpose | Type |
|---|---|
| Network name | `VARCHAR(100)` |
| Asset/protocol name | `VARCHAR(150)` |
| Ticker | `VARCHAR(30)` |
| Address or transaction hash | `VARCHAR(255)` |
| Explorer base URL | `VARCHAR(500)` |
| Full transaction URL | `VARCHAR(2048)` |
| Descriptions/errors | `VARCHAR(2000)` |
| Downloaded HTML | `CLOB` |

Use `CLOB` for HTML because it is character data. Reserve `BLOB` for binary content.

## Exact numeric types

Current types:

```sql
AMOUNT    DECIMAL(31,18)
VALUE_USD DECIMAL(20,8)
VALUE_EUR DECIMAL(20,8)
```

`DECIMAL(38,18)` was rejected by the development Db2 environment. Keep
`MOVEMENT_CRYPTOCURRENCY.AMOUNT` at `DECIMAL(31,18)` unless a tested migration deliberately
changes it.

Use `java.math.BigDecimal` in Java. Do not convert through `float` or `double`.

Validate that a parsed value fits both precision and scale before saving, then give the user an
actionable validation error instead of relying on a low-level Db2 exception.

## Timestamps

Use `TIMESTAMP` for on-chain time, import time, fetch time, and audit columns. The current Java
models use `java.sql.Timestamp`.

Repositories should set audit fields in Db2 where practical:

```sql
CREATED_AT = CURRENT TIMESTAMP
UPDATED_AT = CURRENT TIMESTAMP
```

Preserve the semantic difference between:

- `TX_TIMESTAMP` — time recorded for the blockchain transaction
- `IMPORTED_AT` — file import time
- `FETCHED_AT` — explorer acquisition time
- `CREATED_AT` / `UPDATED_AT` — database row audit times

Document the timezone interpretation. A future migration to `java.time.Instant` or
`OffsetDateTime` should be coordinated across parser, model, repository, UI, and existing data.

## Addresses, hashes, and contracts

Store addresses and hashes as text. Do not make `MOVEMENT.FROM_ADDRESS` or `TO_ADDRESS` foreign
keys to `OWN_ADDRESS`; external counterparties are expected.

Address comparison rules differ by blockchain:

- EVM addresses are commonly presented with optional checksum casing.
- Other chains may be case-sensitive or use different encodings.

Do not apply a single global lowercase transformation without a blockchain-specific rule. If a
normalized comparison value is introduced later, preserve the original display value.

## Asset identity

- Never treat `TICKER` as globally unique.
- Prefer `(BLOCKCHAIN_ID, CONTRACT_ADDRESS)` for contract tokens.
- Native assets have `CONTRACT_ADDRESS IS NULL` and `IS_NATIVE = 1`.
- Wrapped native assets are tokens: they have a contract and `IS_NATIVE = 0`.
- Bridged and protocol receipt/debt assets remain separate records when their contracts differ.

If a unique constraint on contract address is added, account for nullable contracts and the
address-comparison rules of each blockchain.

## Movement URLs and transaction identifiers

`URL` records the original source. `TX_HASH` records the transaction or group identifier.

Before making `URL` unique, define URL normalization for:

- scheme and host casing
- `www.` variants
- trailing slashes
- fragments
- irrelevant query parameters
- URL-encoded group identifiers
- legacy and replacement explorer hosts

Index `TX_HASH`; do not assume it is globally unique across every blockchain without including
blockchain context.

## Automatic and user data

Keep generated and user-verified information separate:

```text
AUTO_DESCR  parser/analyzer output
USER_DESCR  user correction or annotation
```

A reanalysis may update automatic fields but must not overwrite user-authored content silently.
Apply the same principle to future confidence, review-state, or corrected-value fields.

## SQL style

- Write keywords in uppercase.
- Put one selected/inserted column per line for long statements.
- Use explicit column lists in every `INSERT`.
- Use prepared-statement placeholders in Java; never concatenate user values into SQL.
- End standalone statements with semicolons in setup scripts.
- Add `COMMIT;` to catalog scripts when the execution workflow expects it.
- Include a verification `SELECT` at the end of initial data scripts when useful.
- Keep destructive SQL in `database/maintenance`, clearly labeled.

Example:

```sql
SELECT
    ID,
    NAME,
    SYMBOL,
    CHAIN_ID,
    EXPLORER_URL,
    ACTIVE
FROM CRYPTO.BLOCKCHAIN
ORDER BY NAME;
```

## Script organization and versioning

The setup repository separates:

```text
database/ddl          object creation
database/data         non-secret initial catalogs
database/maintenance  explicit maintenance/destructive operations
database/examples     diagnostic and example queries
```

Number creation scripts in dependency order. Once a schema version has been released and user
data must be preserved, add a migration rather than rewriting history without notice.

Application and setup releases should use compatible version tags. A schema change normally
requires coordinated updates to:

- DDL or migration
- initial data where applicable
- Java model
- repository mapping and SQL
- services
- Swing forms
- tests
- architecture and installation documentation

## Review checklist

- [ ] Database is `CRYPTOTX`; schema is `CRYPTO`
- [ ] Every application table is schema-qualified
- [ ] Object names are unquoted `UPPER_SNAKE_CASE`
- [ ] Established singular table names are used
- [ ] Identity IDs are generated by Db2
- [ ] Nullable values preserve SQL `NULL`
- [ ] Cryptocurrency amounts use `DECIMAL`/`BigDecimal`
- [ ] Ticker is not treated as globally unique
- [ ] Addresses are not normalized with an unsafe global rule
- [ ] Automatic data does not overwrite user data
- [ ] SQL uses prepared parameters
- [ ] Destructive scripts are isolated and clearly marked
- [ ] Documentation and migrations accompany schema changes
