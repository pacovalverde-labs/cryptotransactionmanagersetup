# IBM Db2 installation

This guide prepares a local Db2 server for development. It intentionally avoids depending on
a specific fix pack; use an IBM-supported Db2 release compatible with the operating system and
JDBC driver used by the project.

The current IBM documentation describes Db2 12.1 Community Edition installation on Windows.
Always check the [official Db2 installation documentation](https://www.ibm.com/docs/en/db2/12.1.x?topic=idds-installing-db2-database-servers-by-using-db2-setup-wizard-windows)
for the selected release before installing.

## Windows installation

1. Download Db2 Community Edition or the licensed Db2 edition available to the environment
   from IBM.
2. Extract the complete installation archive to a local directory.
3. Sign in with a local administrator account.
4. Start the installer through `setup.exe` using **Run as administrator**. IBM advises not to
   launch an internal `.msi` directly.
5. Choose a typical/standard server installation unless the environment has special storage,
   directory, or security requirements.
6. Create or select the Db2 service account requested by the installer.
7. Keep the default instance or record the custom instance name.
8. Enable operating-system security for Db2 objects when appropriate.
9. Record the selected TCP/IP service port. `50000` is common, but the installed value is the
   source of truth.
10. Complete the installer and reboot if requested.

On Windows, the installer commonly creates the `DB2ADMNS` and `DB2USERS` groups. Ensure the
development account has the required local Db2 permissions without granting unnecessary
administrator rights.

Open **Db2 Command Window** and verify the installation:

```text
db2level
db2val
db2start
db2 get instance
```

IBM documents `db2start` as the command that starts the database manager for the current
instance: [db2start command](https://www.ibm.com/docs/en/db2/11.5.x?topic=commands-db2start-start-db2).

## Linux installation

The exact package names and prerequisites depend on the Db2 release and distribution. Follow
the IBM installation page for that combination. A typical high-level procedure is:

1. Install the operating-system prerequisites required by the selected Db2 build.
2. Extract the Db2 server archive.
3. Run the prerequisite check supplied by IBM.
4. Install with the graphical setup program or the documented response-file workflow.
5. Create the Db2 instance and fenced user if the installer did not do so.
6. Sign in as the instance owner or source its profile.
7. Start and validate the instance.

Typical verification from the instance owner's shell:

```bash
db2level
db2val
db2start
db2 get instance
```

Do not copy Windows user, service, or path instructions directly to Linux.

## Confirm TCP/IP configuration

The desktop application uses a JDBC type 4 connection and therefore needs a host and port.
Inspect the configured service name:

```text
db2 get dbm cfg
```

Look for `SVCENAME`. If it contains a service name rather than a number, resolve that name in
the operating system's services file. Confirm that Db2 is listening and that the local firewall
allows the chosen port when the Java application runs on another machine.

For a local-only development installation, bind the service conservatively and avoid exposing
Db2 directly to the public internet.

## Create the project database

Start the instance and create the physical database:

```text
db2start
db2 CREATE DATABASE CRYPTOTX USING CODESET UTF-8 TERRITORY US
db2 LIST DATABASE DIRECTORY
db2 CONNECT TO CRYPTOTX
```

The basic `CREATE DATABASE` procedure is also described in IBM's
[database creation documentation](https://www.ibm.com/docs/en/db2/11.5.x?topic=databases-creating).

`CRYPTOTX` is the established project database name. Do not replace it with the longer Java
project name in the setup scripts.

Verify the connection:

```text
db2 "VALUES CURRENT SERVER"
db2 "VALUES CURRENT USER"
```

Terminate or reset the CLP connection when finished:

```text
db2 CONNECT RESET
```

## Create a dedicated application user

Db2 LUW authentication commonly relies on operating-system or configured external users. The
exact user-creation method therefore depends on the installation. Prefer a dedicated account
for the application instead of embedding an instance-owner credential.

Grant only the privileges required to connect and use the `CRYPTO` schema. During initial
development, a schema owner may create the objects; routine application execution normally
needs data access rather than instance administration.

Record the final values privately:

| Setting | Example only |
|---|---|
| Host | `localhost` |
| Port | `50000` |
| Database | `CRYPTOTX` |
| User | `cryptotx_app` |
| Password | never commit |

## Locate the JDBC driver

The project requires `db2jcc4.jar`. Depending on the installation, it may be under the Db2
Java directory, often beneath the installation's `sqllib/java` location. Do not assume a path;
locate the file in the installed copy or obtain the current driver from IBM.

IBM's current documentation recommends the JDBC 4 driver and notes that older driver JARs are
not supported at current levels: [supported JDBC drivers](https://www.ibm.com/docs/en/db2/11.5.x?topic=java-supported-drivers-jdbc-sqlj).

## Connect with DBeaver

1. Create a new **Db2 for LUW** connection.
2. Enter host, port, database `CRYPTOTX`, username, and password.
3. Let DBeaver obtain its own compatible driver if needed.
4. Use **Test Connection**.
5. Connect and check:

```sql
VALUES CURRENT SERVER;
VALUES CURRENT USER;
```

DBeaver's driver and the Eclipse project's driver are configured independently.

## Troubleshooting

### `db2` is not recognized

Open the Db2-provided command environment on Windows. On Linux, sign in as the instance owner
or source the instance profile before running CLP commands.

### Database manager is not active

Run:

```text
db2start
```

Then verify the current instance with `db2 get instance`.

### JDBC connection refused

Check:

- instance is started
- host and `SVCENAME`/port are correct
- TCP/IP is enabled
- firewall permits the connection
- database is cataloged and named `CRYPTOTX`

### Authentication failure

Test the same username and password with the Db2 CLP or DBeaver. If DBeaver connects but Java
does not, inspect the application's configuration keys, encrypted password, decryption secret,
and JDBC URL.

After Db2 is operational, continue with [Database setup](database-setup.md).
