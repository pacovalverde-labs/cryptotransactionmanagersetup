# First run

Use this guide after Db2, the schema, Eclipse, dependencies, and local configuration have been
prepared.

## Preflight checks

### 1. Confirm Db2

```text
db2start
db2 CONNECT TO CRYPTOTX
db2 "VALUES CURRENT SERVER"
```

### 2. Confirm the schema

Run in DBeaver or the Db2 CLP:

```sql
SELECT TABNAME
FROM SYSCAT.TABLES
WHERE TABSCHEMA = 'CRYPTO'
ORDER BY TABNAME;
```

The result should include the nine application tables described in
[Database design](../architecture/database-design.md).

### 3. Confirm catalog data

```sql
SELECT COUNT(*) AS BLOCKCHAINS
FROM CRYPTO.BLOCKCHAIN;

SELECT COUNT(*) AS PROTOCOLS
FROM CRYPTO.PROTOCOL;

SELECT COUNT(*) AS ASSETS
FROM CRYPTO.CRYPTOCURRENCY;
```

At least the blockchains and protocols required for the first tests should exist.

### 4. Confirm local configuration

- The configuration file exists at the path used by `Main`.
- Host, port, database `CRYPTOTX`, username, and encrypted password are correct.
- The decryption secret supplied to `AesCipher.decrypt` matches the value used to encrypt the
  password.
- Neither the real configuration file nor the decryption secret is committed to Git.

### 5. Confirm the classpath

The project must compile with:

- IBM `db2jcc4.jar`
- the project Db2 connection library
- the cipher library
- any HTML parsing library used by the analyzer

## Start the application

In Eclipse:

1. Open `com.pacovalverde.cryptotx.app.Main`.
2. Choose **Run As > Java Application**.
3. Watch the Eclipse console during startup.
4. The `Crypto Transaction Manager` main window should open.

`Main` schedules UI creation on the Swing Event Dispatch Thread, loads configuration,
decrypts the database password, creates the connection factory, repositories, services, and
then `MainWindow`.

If any startup dependency fails, the application displays **Database error** and prints the
exception in the console. Read both the dialog and the first relevant exception/cause.

## First functional checks

### Blockchain tab

1. Open **Blockchain**.
2. Confirm the table loads initial catalog rows.
3. Use the filter if present.
4. Select a row and confirm its details appear.
5. Press **Reload** and confirm the table refreshes.

Create/edit/delete tests should be performed only against a development database. A safe first
write test is to create an inactive temporary blockchain record, edit its label, then delete it.

### Protocol and Cryptocurrency tabs

Confirm both catalogs load. Cryptocurrency rows should show the associated blockchain where
available. The same ticker may appear on multiple networks; this is expected.

### Own Addresses tab

Confirm the form loads even when no personal address has been recorded. Never use a seed phrase
or private key here; the table stores only public blockchain addresses and descriptive data.

### Movement tab

1. Confirm existing movements load, or the empty table appears without error.
2. Choose **New**.
3. Paste a known explorer transaction URL.
4. Use the transaction analysis action.
5. Wait for the background `SwingWorker` to finish.
6. Review blockchain, protocol, transaction metadata, descriptions, asset rows, and web-data
   fields.
7. Open the stored HTML dialog if HTML was acquired.
8. Save only after reviewing the automatically detected data.

Automatic analysis can be partial. Explorer HTML changes, rate limiting, bot protection, and
unsupported transaction types should produce warnings rather than be treated as verified data.

### Import Movements tab

For the first import test, use a small TXT file containing a few representative explorer URLs.
The intended workflow is:

1. Select TXT and choose the source file.
2. Run the preview/analysis step.
3. Inspect logs and the result table.
4. Correct blocking problems.
5. Commit only when the preview has no blocking errors.

Do not begin with the complete historical `links.txt`; a small file makes configuration and
parser problems easier to isolate.

## Verify writes in Db2

After saving a test movement:

```sql
SELECT *
FROM CRYPTO.MOVEMENT
ORDER BY ID DESC
FETCH FIRST 10 ROWS ONLY;

SELECT *
FROM CRYPTO.MOVEMENT_CRYPTOCURRENCY
ORDER BY ID DESC
FETCH FIRST 20 ROWS ONLY;

SELECT ID, MOVEMENT_ID, HTTP_STATUS, FETCH_STATUS, CONTENT_TYPE, FETCHED_AT,
       ERROR_MESSAGE
FROM CRYPTO.MOVEMENT_WEB_DATA
ORDER BY ID DESC
FETCH FIRST 10 ROWS ONLY;
```

If `MovementService` saves several tables in one operation, confirm either all expected rows
are present or none were committed after an induced failure.

## Common startup failures

### Configuration file not found

The attached `Main` source uses an absolute development path. Point it to the local file or
implement the configurable-path policy described in
[Database connection](../configuration/database-connection.md).

### Password decryption fails

The stored password is not encrypted with the expected secret, the wrong cipher library is on
the classpath, or plaintext was supplied where ciphertext is expected. Do not log either secret.

### `No suitable driver` or driver class not found

Add the current IBM JDBC 4 driver to the application runtime classpath.

### Table not found

Check database `CRYPTOTX`, schema `CRYPTO`, and singular table names. The code queries names
such as `CRYPTO.BLOCKCHAIN` and `CRYPTO.MOVEMENT`.

### UI opens but catalogs are empty

Run the initial data scripts and verify the Java user has `SELECT` privileges. Also confirm the
application is not connected to another database with the same schema name.

### Analysis hangs or the window freezes

Network work must execute outside the Event Dispatch Thread. Confirm the current analysis path
uses `SwingWorker`; then inspect network timeouts and explorer response behavior.

## Completion criteria

The installation is ready when:

- the main window opens without startup errors
- Blockchain, Protocol, Cryptocurrency, and Movement data can be loaded
- a development CRUD change can be saved and reloaded
- a representative URL returns either a structured result or a clear partial-analysis warning
- saved movement, asset, and web-data rows are consistent
- no real credentials or wallet secrets appear in version control
