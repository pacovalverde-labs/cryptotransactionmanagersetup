# Crypto Transaction Manager — Setup

Setup, database scripts, configuration examples, and technical documentation for **Crypto Transaction Manager**.

This repository contains the resources required to prepare the environment used by the Java desktop application:

**Main project:** `CryptoTransactionManager`  
**Main repository:** `crypto-transaction-manager`  
**Setup repository:** `crypto-transaction-manager-setup`

---

## Purpose

`CryptoTransactionManager` is a Java Swing desktop application for importing, analyzing, storing, and manually managing cryptocurrency transactions obtained from blockchain explorer URLs.

The application uses:

- Java
- Java Swing
- JDBC
- IBM Db2
- HTML parsing / scraping
- Git

This repository does **not** contain the main Java application.

Its purpose is to provide:

- IBM Db2 database creation scripts.
- Schema and table definitions.
- Constraints and indexes.
- Initial catalog data.
- Configuration examples.
- Installation instructions.
- Database documentation.
- Development and maintenance documentation.
- Resources required to prepare a new development or test environment.

---

# Repository structure

```text
crypto-transaction-manager-setup/
│
├── README.md
│
├── database/
│   │
│   ├── ddl/
│   │   ├── 00_create_schema.sql
│   │   ├── 01_create_blockchain.sql
│   │   ├── 02_create_protocol.sql
│   │   ├── 03_create_import_source.sql
│   │   ├── 04_create_cryptocurrency.sql
│   │   ├── 05_create_own_address.sql
│   │   ├── 06_create_movement.sql
│   │   ├── 07_create_movement_cryptocurrency.sql
│   │   ├── 08_create_movement_web_data.sql
│   │   ├── 09_create_indexes.sql
│   │   └── 10_create_constraints.sql
│   │
│   └── data/
│       ├── 01_blockchains.sql
│       ├── 02_protocols.sql
│       └── 03_cryptocurrencies.sql
│
├── docs/
│   │
│   ├── architecture/
│   │   ├── database-design.md
│   │   └── application-architecture.md
│   │
│   ├── installation/
│   │   ├── prerequisites.md
│   │   ├── db2-installation.md
│   │   ├── database-setup.md
│   │   ├── eclipse-setup.md
│   │   └── first-run.md
│   │
│   ├── configuration/
│   │   ├── database-connection.md
│   │   └── configuration-example.md
│   │
│   └── development/
│       ├── adding-blockchains.md
│       ├── adding-parsers.md
│       └── database-conventions.md
│
├── config/
│   └── configConnectionCryptotx.example.txt
│
└── .gitignore
```

The structure may evolve as the application grows.

---

# Database

## Database engine

The project currently uses:

**IBM Db2**

The database used by the application is:

```text
CRYPTOTX
```

The application objects are stored under the schema:

```text
CRYPTO
```

This separation keeps the database name and application schema independent.

Conceptually:

```text
CRYPTOTX
└── CRYPTO
    ├── BLOCKCHAIN
    ├── PROTOCOL
    ├── IMPORT_SOURCE
    ├── CRYPTOCURRENCY
    ├── OWN_ADDRESS
    ├── OWN_ADDRESS_BLOCKCHAIN
    ├── MOVEMENT
    ├── MOVEMENT_CRYPTOCURRENCY
    └── MOVEMENT_WEB_DATA
```

---

# Database naming conventions

Db2 normalizes unquoted SQL identifiers to uppercase.

For this reason, database objects in this project use:

```text
UPPER_SNAKE_CASE
```

Examples:

```sql
CRYPTO.BLOCKCHAIN
CRYPTO.CRYPTOCURRENCY
CRYPTO.MOVEMENT
CRYPTO.MOVEMENT_WEB_DATA
```

SQL examples should normally use the schema-qualified table name:

```sql
SELECT *
FROM CRYPTO.MOVEMENT;
```

Quoted identifiers should normally be avoided unless preserving case is specifically required.

---

# Database model

## BLOCKCHAIN

Stores supported blockchain networks.

Examples:

- Polygon
- Avalanche C-Chain
- BNB Smart Chain
- Algorand
- Sonic
- Celo
- Astar
- Hedera
- Solana
- Cardano
- IOTA

Typical information includes:

```text
ID
NAME
SYMBOL
CHAIN_ID
EXPLORER_URL
ACTIVE
```

---

## PROTOCOL

Stores protocols, exchanges, wallets, bridges, and other platforms associated with transactions.

Examples:

- Aave
- Folks Finance
- pact.fi
- Binance
- MEXC
- KuCoin
- Venus Protocol
- Moola

Typical types include:

```text
DEX
LENDING
CEX
WALLET
BRIDGE
STAKING
```

---

## CRYPTOCURRENCY

Stores native assets and tokens.

Typical information includes:

```text
ID
BLOCKCHAIN_ID
NAME
TICKER
CONTRACT_ADDRESS
DECIMALS
IS_NATIVE
ACTIVE
```

A ticker must not be considered globally unique.

For example, different versions of:

```text
USDC
USDT
BTC
ETH
```

may exist on different blockchain networks.

---

## OWN_ADDRESS

Stores blockchain addresses controlled or monitored by the application user.

A single address may be associated with one or several compatible blockchain networks through:

```text
OWN_ADDRESS_BLOCKCHAIN
```

The transaction tables deliberately keep origin and destination addresses as textual values because external addresses do not necessarily belong to the application's own-address catalog.

---

## MOVEMENT

Represents a blockchain operation.

Supported or planned movement types include:

```text
TRANSFER
SWAP
DEPOSIT
WITHDRAW
STAKE
UNSTAKE
CLAIM
BORROW
REPAY
SUPPLY
APPROVE
BRIDGE
ADD_LIQUIDITY
REMOVE_LIQUIDITY
GOVERNANCE
UNKNOWN
```

The model is deliberately generic because blockchain transactions can represent much more than simple transfers.

Typical information includes:

```text
ID
BLOCKCHAIN_ID
URL
TX_HASH
MOVEMENT_TYPE
AUTO_DESCR
USER_DESCR
TX_TIMESTAMP
STATUS
FROM_ADDRESS
TO_ADDRESS
PROTOCOL_ID
IMPORT_SOURCE_ID
CREATED_AT
UPDATED_AT
```

Automatic descriptions and user descriptions are stored separately so that automatically detected information can be reviewed and corrected without losing the original analysis.

---

## MOVEMENT_CRYPTOCURRENCY

Represents the many-to-many relationship between a movement and the assets involved in it.

An operation can contain multiple cryptocurrencies with different roles.

Example:

```text
100 USDC -> 0.021 PAXG
```

can be represented as:

```text
USDC | INPUT  | 100
PAXG | OUTPUT | 0.021
```

Possible roles include:

```text
INPUT
OUTPUT
FEE
COLLATERAL
REWARD
```

---

## MOVEMENT_WEB_DATA

Stores information obtained when a blockchain explorer page is downloaded.

Typical fields include:

```text
MOVEMENT_ID
HTTP_STATUS
FETCH_STATUS
CONTENT_TYPE
HTML_CONTENT
FETCHED_AT
ERROR_MESSAGE
```

HTML is stored as Db2 `CLOB` because it is textual data.

---

## IMPORT_SOURCE

Stores information about file-import operations.

This makes it possible to retain information such as:

```text
FILE_NAME
FILE_PATH
IMPORTED_AT
TOTAL_LINES
TOTAL_URLS
TOTAL_IMPORTED
TOTAL_ERRORS
```

and associate imported movements with their original source.

---

# Prerequisites

Before running the application, the following software is required.

## Java

Install a Java Development Kit compatible with the version used by the main project.

Verify the installation with:

```bash
java -version
javac -version
```

---

## IBM Db2

A working IBM Db2 installation is required.

The current development environment uses a local Db2 database.

The Db2 Command Line Processor can be used to create the database and verify the installation.

Example:

```bash
db2start
```

---

## Database administration tool

DBeaver is recommended for:

- Executing SQL scripts.
- Inspecting tables.
- Viewing constraints and indexes.
- Testing queries.
- Browsing database data.

Other Db2-compatible tools may also be used.

---

## Java IDE

The main project is currently developed with:

```text
Eclipse
```

The Swing user interface can also be edited with WindowBuilder.

---

# Creating the database

The physical Db2 database must exist before running the DDL scripts.

From a Db2 command environment:

```bash
db2start
db2 CREATE DATABASE CRYPTOTX
db2 LIST DATABASE DIRECTORY
db2 CONNECT TO CRYPTOTX
```

After connecting, verify the active database:

```sql
VALUES CURRENT SERVER;
```

---

# Creating the application schema

Run:

```text
database/ddl/00_create_schema.sql
```

The script creates:

```sql
CRYPTO
```

The remaining database objects belong to this schema.

---

# DDL execution order

The files in `database/ddl` are numbered intentionally.

Run them in numerical order:

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

The order is important because some tables depend on objects created earlier.

The general sequence is:

```text
Schema
   ↓
Tables
   ↓
Indexes
   ↓
Constraints
```

Primary keys may be defined directly in the corresponding `CREATE TABLE` statements.

Foreign keys, unique constraints, and other cross-table integrity rules are kept separately where practical.

---

# Initial data

After the schema has been created, optional catalog data can be inserted.

Run the files in:

```text
database/data/
```

in numerical order.

For example:

```text
01_blockchains.sql
02_protocols.sql
03_cryptocurrencies.sql
```

These scripts populate reference data used by the Java application.

They should not contain personal transaction history, wallet secrets, passwords, private keys, or other confidential information.

---

# Connection configuration

The Java application requires a Db2 connection configuration file.

An example configuration is provided as:

```text
config/configConnectionCryptotx.example.txt
```

Copy the example and create your local configuration file.

For example:

```text
configConnectionCryptotx.txt
```

Configure values appropriate for your Db2 installation, such as:

```text
Server
Port
Database
Username
Password
```

The exact format must match the configuration loader used by the Java application.

---

# Security

## Do not commit credentials

The real database configuration file must not be committed to Git.

Files containing any of the following must remain private:

- Database passwords.
- Private keys.
- Seed phrases.
- API secrets.
- Authentication tokens.
- Exchange credentials.
- Personal wallet information that should not be public.

Only example configuration files with dummy values belong in this repository.

Example:

```text
configConnectionCryptotx.example.txt
```

not:

```text
configConnectionCryptotx.txt
```

---

# Java application

This repository prepares the infrastructure required by the main application.

The Java project uses JDBC repositories to access Db2 tables.

Examples include:

```text
BlockchainRepository
ProtocolRepository
CryptocurrencyRepository
OwnaddressRepository
MovementRepository
```

The application expects the database schema to exist before it starts.

If the database or configuration is unavailable, the application cannot initialize its repositories successfully.

---

# Typical installation procedure

A new developer or user can prepare the project approximately as follows:

```text
1. Install Java.
2. Install IBM Db2.
3. Install or configure DBeaver.
4. Create the CRYPTOTX database.
5. Execute database/ddl/00_create_schema.sql.
6. Execute the remaining DDL scripts in numerical order.
7. Execute the initial data scripts.
8. Clone the main crypto-transaction-manager repository.
9. Configure the required Java dependencies.
10. Create the local Db2 connection configuration file.
11. Verify the database connection.
12. Run CryptoTransactionManager.
```

Detailed instructions are available under:

```text
docs/installation/
```

---

# Verifying the installation

After running the database scripts, some basic checks can be performed.

Verify the database:

```sql
VALUES CURRENT SERVER;
```

Verify the schema:

```sql
VALUES CURRENT SCHEMA;
```

List blockchains:

```sql
SELECT *
FROM CRYPTO.BLOCKCHAIN
ORDER BY ID;
```

List protocols:

```sql
SELECT *
FROM CRYPTO.PROTOCOL
ORDER BY ID;
```

List cryptocurrencies:

```sql
SELECT *
FROM CRYPTO.CRYPTOCURRENCY
ORDER BY ID;
```

List movements:

```sql
SELECT *
FROM CRYPTO.MOVEMENT
ORDER BY ID DESC;
```

Additional diagnostic queries are available under:

```text
database/maintenance/
database/examples/
```

---

# Database data types

The project uses exact decimal types for cryptocurrency amounts.

Typical mappings include:

```text
Db2                         Java
--------------------------  --------------------
BIGINT                      long / Long
VARCHAR                     String
DECIMAL                     BigDecimal
TIMESTAMP                   java.sql.Timestamp
CLOB                        String / character data
SMALLINT                    boolean-like 0 / 1
```

Cryptocurrency amounts should not use:

```text
FLOAT
REAL
DOUBLE
```

when exact decimal precision is required.

Java code should use:

```java
java.math.BigDecimal
```

for those values.

---

# Transaction import workflow

The main application follows approximately this workflow:

```text
Source file
    │
    ▼
Detect URLs
    │
    ▼
Check duplicates
    │
    ▼
Detect blockchain
    │
    ▼
HTTP request
    │
    ▼
Store HTTP / HTML data
    │
    ▼
Analyze transaction
    │
    ▼
Detect protocol
    │
    ▼
Detect assets and amounts
    │
    ▼
Generate automatic description
    │
    ▼
User review
    │
    ▼
Save movement
```

The database has been designed to support heterogeneous transactions including transfers, swaps, lending, staking, bridges, governance operations, and other DeFi activity.

---

# Development notes

## Adding a blockchain

Adding a blockchain can require:

1. Adding the blockchain to `CRYPTO.BLOCKCHAIN`.
2. Adding its native cryptocurrency.
3. Adding relevant tokens.
4. Supporting its explorer URL.
5. Implementing or extending a transaction parser.
6. Testing representative transactions.

See:

```text
docs/development/adding-blockchains.md
```

---

## Adding a parser

Blockchain explorers do not expose transaction data in a common HTML format.

The Java application therefore uses specialized parsing logic where required.

A generic analyzer may detect common information, while explorer-specific parsers can provide additional support for networks or explorers whose HTML structure differs significantly.

See:

```text
docs/development/adding-parsers.md
```

---

# Maintenance scripts

The directory:

```text
database/maintenance/
```

contains scripts intended for development and maintenance operations.

These may include:

```text
checks.sql
truncate_tables.sql
reset_database.sql
```

Some maintenance scripts may delete data.

Read them carefully before execution.

They should **not** be executed automatically against a database containing valuable production data.

---

# Versioning

The setup repository should remain compatible with the corresponding version of the Java application.

Recommended versioning:

```text
crypto-transaction-manager
v1.0.0

crypto-transaction-manager-setup
v1.0.0
```

When database changes are introduced, the setup repository should be updated accordingly.

Examples:

```text
New table
New column
New foreign key
New index
New catalog data
Configuration change
```

Compatible releases should ideally use matching Git tags.

---

# Database evolution

During early development, the database schema may still change significantly.

For development installations, recreating the database from the latest DDL scripts may sometimes be simpler than applying incremental changes.

As the project matures and existing installations need to preserve data, database migration scripts can be introduced.

A possible future structure is:

```text
database/
├── ddl/
├── data/
└── migrations/
    ├── V001__initial_schema.sql
    ├── V002__add_review_fields.sql
    └── V003__add_new_constraints.sql
```

---

# Relationship with the main repository

The repositories have different responsibilities.

## `crypto-transaction-manager`

Contains the application itself:

- Java source code.
- Swing forms.
- Models.
- Services.
- Repositories.
- Transaction analyzers.
- Blockchain explorer parsers.
- Application resources.

## `crypto-transaction-manager-setup`

Contains the environment and infrastructure documentation:

- Db2 DDL.
- Initial SQL data.
- Constraints.
- Indexes.
- Configuration examples.
- Installation documentation.
- Database documentation.
- Maintenance scripts.

Application source code should not normally be duplicated between repositories.

---

# Current project status

The project is under active development.

Current development areas include:

- Blockchain catalog management.
- Protocol management.
- Cryptocurrency management.
- Own-address management.
- Manual movement management.
- Automatic transaction analysis.
- HTML acquisition and storage.
- Detection of assets involved in a transaction.
- Importing transaction URLs from files.
- Explorer-specific parsing logic.

Support for blockchain explorers and transaction types will be expanded incrementally.

---

# Disclaimer

This project processes cryptocurrency transaction information and blockchain explorer data.

It does not store blockchain private keys and should never require seed phrases or wallet private keys.

Explorer parsing depends on third-party websites whose HTML structure and behavior may change without notice.

Automatically detected transaction information should therefore be considered subject to review.

---

# Author

Francisco G. Valverde