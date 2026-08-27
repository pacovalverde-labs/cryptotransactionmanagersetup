# Prerequisites

This checklist covers the software and information required to build and run
**Crypto Transaction Manager** from a clean workstation.

## Required software

### Java Development Kit

Use **JDK 22 or later** for the current source tree. The code uses `_` as an unnamed lambda
parameter, a Java language feature finalized in Java 22. An older JDK will report compilation
errors even though most of the application otherwise uses conventional Swing and JDBC APIs.

Verify both runtime and compiler:

```bash
java -version
javac -version
```

Eclipse must use the same JDK as the project's compiler compliance level. A JRE alone is not
enough for development.

### IBM Db2

Install a local or reachable Db2 for Linux, UNIX, and Windows server. The standard development
layout is:

| Setting | Value |
|---|---|
| Database | `CRYPTOTX` |
| Schema | `CRYPTO` |
| Default local host | `localhost` |
| Common Db2 TCP port | `50000`, unless changed during installation |

You need a Db2 user that can connect to `CRYPTOTX` and create or access the objects in
`CRYPTO`. See [Db2 installation](db2-installation.md).

### IBM JDBC driver

The Java project requires the IBM Data Server Driver for JDBC and SQLJ. Use `db2jcc4.jar`;
IBM's current driver documentation identifies it as the JDBC 4 driver and notes that the old
`db2jcc.jar` is no longer supported in current driver levels.

The driver may already be present in the Db2 installation. Otherwise download it from IBM or
use the dependency mechanism adopted by the main repository. See the official
[IBM JDBC driver installation documentation](https://www.ibm.com/docs/en/db2/11.5.x?topic=java-installing-updating-upgrading-data-server-driver-jdbc-sqlj-db2-linux-unix-windows-systems).

### Project libraries

The attached `Main` source imports classes from two project-specific library namespaces:

- `com.pacovalverde.jdbc.database.db2.*` for `Db2Config`, `Db2ConfigLoader`, and
  `Db2ConnectionFactory`.
- `com.pacovalverde.cipher.security.AesCipher` for password decryption.

Add the JARs or source projects that provide these packages. Do not commit third-party or
private binaries blindly; follow the main repository's dependency policy and license terms.

### Eclipse IDE

Use an Eclipse release that supports the selected JDK. Recommended components:

- Eclipse IDE for Java Developers
- Git integration (EGit, normally bundled)
- WindowBuilder Swing Designer, if forms will be edited visually

See [Eclipse setup](eclipse-setup.md).

### Git

Git is required to clone and update both repositories:

- `crypto-transaction-manager` — Java application
- `crypto-transaction-manager-setup` — database scripts and documentation

Verify:

```bash
git --version
```

## Recommended tools

### DBeaver

DBeaver is the recommended graphical Db2 client for this project. It is used to:

- create and inspect connections
- execute the numbered SQL scripts
- browse the `CRYPTO` schema
- inspect constraints and indexes
- validate queries and catalog data

DBeaver may download its own JDBC driver. The Java project still needs its own configured
driver; a driver available inside DBeaver is not automatically on Eclipse's build path.

### Command-line shell

Keep access to a Db2 command environment:

- **Windows:** Db2 Command Window or a shell initialized with the Db2 environment.
- **Linux:** a shell as the Db2 instance owner, or with the instance profile sourced.

The commands `db2start`, `db2 connect`, and `db2 list database directory` should be available.

## Required project information

Before first run, know or choose:

- Db2 host and port
- database name (`CRYPTOTX`)
- Db2 username
- Db2 password or encrypted password value expected by the loader
- location of `configConnectionCryptotx.txt`
- local decryption-key source used by the current application

Do not place a real password, decryption secret, wallet private key, seed phrase, or exchange
API secret in Git.

## Network access

Database-only CRUD screens can work with no public internet connection when Db2 is local.
Transaction analysis additionally requires outbound HTTPS access to blockchain explorers.
Explorers may rate-limit, block automated requests, require JavaScript, or change their HTML.

## Disk and permissions

Allow enough space for:

- Db2 installation and database files
- cloned repositories and Eclipse workspace
- downloaded explorer HTML stored as `CLOB`
- logs and temporary import data

On Windows, Db2 installation generally requires a local administrator account. Day-to-day
application work should use the least privileges necessary.

## Pre-installation checklist

- [ ] JDK 22 or later installed
- [ ] Eclipse uses that JDK
- [ ] Git installed
- [ ] Db2 server installed or reachable
- [ ] Db2 host, port, database, user, and password known
- [ ] `db2jcc4.jar` available to the Java project
- [ ] Project-specific database and cipher libraries available
- [ ] DBeaver installed or another Db2 client available
- [ ] Setup and application repositories cloned

Continue with [Db2 installation](db2-installation.md), then
[Database setup](database-setup.md).
