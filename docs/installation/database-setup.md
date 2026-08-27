# Database setup

This guide creates the `CRYPTO` application schema, tables, indexes, constraints, and initial
catalog data inside the `CRYPTOTX` database.

## Before you begin

Confirm that:

- Db2 is installed and the instance is running.
- The `CRYPTOTX` database exists.
- The executing user can create the `CRYPTO` schema and its objects.
- The setup repository contains the numbered files described in its root `README.md`.
- You know whether the target database is disposable. Reset and truncate scripts can destroy
  data and must not be run casually.

Connect and verify the target before executing DDL:

```text
db2 CONNECT TO CRYPTOTX
db2 "VALUES CURRENT SERVER"
db2 "VALUES CURRENT USER"
```

In DBeaver, verify the connection editor also points to `CRYPTOTX`.

## DDL execution order

Run the files in `database/ddl` in numerical order:

```text
00_create_schema.sql
01_create_blockchain.sql
02_create_protocol.sql
03_create_import_source.sql
04_create_cryptocurrency.sql
05_create_own_address.sql
06_create_movement.sql
07_create_movement_cryptocurrency.sql
08_create_movement_web_data.sql
09_create_indexes.sql
10_create_constraints.sql
```

The order follows foreign-key dependencies. Primary keys may be declared with their tables;
cross-table constraints and indexes can be added later by the numbered scripts.

### Execute with DBeaver

1. Open an SQL editor for the `CRYPTOTX` connection.
2. Open `00_create_schema.sql`.
3. Execute the complete script. In the current DBeaver workflow, **Alt+X** executes a script.
4. Inspect the execution log for errors.
5. Repeat for the remaining DDL files in order.
6. Refresh the connection or schema tree after object creation.

Do not rely on editor autocomplete alone to choose the schema. The project convention is to
write schema-qualified names explicitly.

### Execute with the Db2 CLP

From the setup repository root, a typical invocation is:

```text
db2 -td; -vf database/ddl/00_create_schema.sql
```

Repeat for each numbered file. `-td;` treats the semicolon as the statement terminator, `-v`
echoes statements, and `-f` reads the file. Stop and investigate any nonzero SQLCODE instead
of continuing blindly.

## Schema verification

After `00_create_schema.sql`:

```sql
SELECT SCHEMANAME
FROM SYSCAT.SCHEMATA
WHERE SCHEMANAME = 'CRYPTO';
```

Setting the current schema is convenient but does not replace qualification in project SQL:

```sql
SET CURRENT SCHEMA CRYPTO;

SELECT *
FROM CRYPTO.BLOCKCHAIN;
```

## Table verification

Expected tables:

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

Query the catalog:

```sql
SELECT TABNAME, TYPE
FROM SYSCAT.TABLES
WHERE TABSCHEMA = 'CRYPTO'
ORDER BY TABNAME;
```

Inspect columns:

```sql
SELECT TABNAME, COLNO, COLNAME, TYPENAME, LENGTH, SCALE, NULLS
FROM SYSCAT.COLUMNS
WHERE TABSCHEMA = 'CRYPTO'
ORDER BY TABNAME, COLNO;
```

Confirm that `MOVEMENT_CRYPTOCURRENCY.AMOUNT` uses `DECIMAL(31,18)` in the current DDL.
`DECIMAL(38,18)` was rejected by the development Db2 environment.

## Load initial data

After all structural scripts succeed, execute:

```text
database/data/01_blockchains.sql
database/data/02_protocols.sql
database/data/03_cryptocurrencies.sql
```

These scripts are ordered because cryptocurrency inserts resolve `BLOCKCHAIN_ID` from
`CRYPTO.BLOCKCHAIN`.

The current blockchain catalog includes EVM and non-EVM networks such as Ethereum, Polygon,
Avalanche C-Chain, BNB Smart Chain, Sonic, Fantom Opera, Celo, Astar, Algorand, Osmosis,
Kava, Hedera, Solana, Cardano, IOTA, and others.

Initial data scripts should be rerunnable only if they explicitly prevent duplicates. If the
current scripts use plain `INSERT`, run them once on a clean catalog or clear the appropriate
development data first.

## Verify initial data

```sql
SELECT ID, NAME, SYMBOL, CHAIN_ID, EXPLORER_URL, ACTIVE
FROM CRYPTO.BLOCKCHAIN
ORDER BY NAME;

SELECT ID, NAME, TYPE, WEBSITE, ACTIVE
FROM CRYPTO.PROTOCOL
ORDER BY TYPE, NAME;

SELECT C.ID,
       B.NAME AS BLOCKCHAIN,
       C.NAME,
       C.TICKER,
       C.CONTRACT_ADDRESS,
       C.DECIMALS,
       C.IS_NATIVE,
       C.ACTIVE
FROM CRYPTO.CRYPTOCURRENCY C
LEFT JOIN CRYPTO.BLOCKCHAIN B
       ON B.ID = C.BLOCKCHAIN_ID
ORDER BY B.NAME, C.TICKER, C.NAME;
```

## Verify foreign keys and indexes

```sql
SELECT CONSTNAME, TABNAME, TYPE, ENFORCED
FROM SYSCAT.TABCONST
WHERE TABSCHEMA = 'CRYPTO'
ORDER BY TABNAME, CONSTNAME;

SELECT TABNAME, INDNAME, UNIQUERULE
FROM SYSCAT.INDEXES
WHERE TABSCHEMA = 'CRYPTO'
ORDER BY TABNAME, INDNAME;
```

At minimum, confirm the relationships described in
[Database design](../architecture/database-design.md).

## Grant application access

The exact `GRANT` statements depend on who owns the schema and how Db2 authentication is
configured. A typical application account needs:

- `CONNECT` on database `CRYPTOTX`
- `USAGE` on schema `CRYPTO`
- `SELECT`, `INSERT`, `UPDATE`, and `DELETE` on application tables as required
- privileges on generated identities implicit in table access

Apply least privilege. Do not run the desktop application as the Db2 instance owner merely
to avoid configuring grants.

## Development rebuilds

During early development it may be simpler to rebuild a disposable schema from current DDL.
Before using `reset_database.sql`, `truncate_tables.sql`, `DROP SCHEMA`, or a recursive delete:

1. Confirm the connection and database name.
2. Confirm no valuable or production data is present.
3. Back up data that cannot be reproduced.
4. Read the entire maintenance script.
5. Execute it manually and review the result.

Never wire destructive maintenance scripts into normal application startup.

## Common errors

### `SQL0204N ... is an undefined name`

Check that the correct database is selected, `CRYPTO` exists, and the SQL uses the correct
singular table name, for example `CRYPTO.BLOCKCHAIN` rather than `BLOCKCHAINS`.

### Object exists already

The script has probably been executed before. Do not ignore the error if later statements may
depend on a clean state. Choose between keeping the existing object, applying a migration, or
rebuilding a confirmed disposable database.

### Foreign-key creation fails

Verify parent tables and primary keys were created first. Also inspect existing data for rows
that do not have a valid parent.

### Cryptocurrency inserts create no row

Many initial token statements use `INSERT ... SELECT ... FROM CRYPTO.BLOCKCHAIN` with an exact
`WHERE NAME = '...'` condition. If the blockchain name does not match or has not been inserted, the statement
can succeed while inserting zero rows.

Continue with [Database connection](../configuration/database-connection.md).
