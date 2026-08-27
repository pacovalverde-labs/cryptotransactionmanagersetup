# Database connection

The Java application connects to IBM Db2 through a configuration object, a loader, and a
connection factory supplied by the project database library.

## Current connection flow

The attached `Main` source performs these steps:

```java
Db2Config config = Db2ConfigLoader.load(configFile);
String decryptedPassword = AesCipher.decrypt(config.getPassword(), decryptionSecret);
config.setPassword(decryptedPassword);
Db2ConnectionFactory connectionFactory = new Db2ConnectionFactory(config);
```

Repositories receive the same `Db2ConnectionFactory` and request JDBC connections as needed.
This keeps credentials and JDBC construction out of Swing panels.

## Required settings

| Setting | Development value or rule |
|---|---|
| Server/host | `localhost` for a local Db2 installation |
| Port | Commonly `50000`; use the instance's actual `SVCENAME` |
| Database | `CRYPTOTX` |
| Username | A Db2 account with application privileges |
| Password | Encrypted value if the current loader/decryption flow is retained |

The resulting JDBC type 4 URL is conceptually:

```text
jdbc:db2://localhost:50000/CRYPTOTX
```

The connection library may build this URL internally. Do not add a second URL-building path in
the UI.

## Configuration filename

The established local filename is:

```text
configConnectionCryptotx.txt
```

The setup repository should contain only a safe example:

```text
config/configConnectionCryptotx.example.txt
```

The real file must be ignored by Git.

## Current limitation: hard-coded path

The attached `Main` snapshot assigns an absolute Windows path to `DB_CONFIG_FILE`. That allows
one workstation to run but is not portable. A distributable application should resolve the path
in this order or another documented order:

1. JVM system property, for example `cryptotx.config`.
2. Environment variable, for example `CRYPTOTX_CONFIG`.
3. A documented user-local default.
4. Fail with an actionable message if no file exists.

Example path resolution:

```java
String configPath = System.getProperty("cryptotx.config");

if (configPath == null || configPath.isBlank()) {
    configPath = System.getenv("CRYPTOTX_CONFIG");
}

if (configPath == null || configPath.isBlank()) {
    throw new IllegalStateException(
            "Database configuration path is not set. "
            + "Use -Dcryptotx.config=... or CRYPTOTX_CONFIG."
    );
}
```

On Windows:

```text
-Dcryptotx.config=C:\Users\USER\AppData\Local\CryptoTransactionManager\configConnectionCryptotx.txt
```

On Linux:

```bash
export CRYPTOTX_CONFIG="$XDG_CONFIG_HOME/cryptotx/configConnectionCryptotx.txt"
```

If `XDG_CONFIG_HOME` is unset, choose and document an equivalent user-local path. Do not use a
repository-relative credential file for production-like environments.

## Configuration keys

The exact accepted key spelling is defined by `Db2ConfigLoader`, which lives in the project
database library rather than the attached application source. Keep the example file synchronized
with that loader. The canonical setup documentation uses these logical keys:

```properties
server=localhost
port=50000
database=CRYPTOTX
username=cryptotx_app
password=ENCRYPTED_PASSWORD_VALUE
```

If the loader uses `host` rather than `server`, or `user` rather than `username`, update both the
loader and example together or retain the exact names already implemented. A configuration file
can look correct to a person while silently failing if its key names do not match the loader.

See [Configuration example](configuration-example.md).

## Password handling

The current application decrypts `config.getPassword()` with `AesCipher`. Apply these rules:

- Store only ciphertext in the configuration file when this flow is enabled.
- Do not hard-code the decryption secret in committed Java source.
- Do not store the decryption secret beside the ciphertext in the same file.
- Prefer a user prompt, protected operating-system secret store, or environment-based secret for
  local development.
- Clear mutable `char[]` secrets after use when the cipher API permits it.
- Never print plaintext passwords, ciphertext, decryption secrets, seed phrases, or private keys.

Encryption does not make a committed credential safe when the decryption secret is committed in
the same repository.

## JDBC driver

Use IBM's JDBC 4 driver, normally `db2jcc4.jar`. DBeaver's private driver installation does not
put the driver on the application's build or runtime classpath.

The application-side driver version and Db2 server version must be compatible. Do not add both
old and new IBM driver JARs because classpath ordering can hide the intended version.

## Connection lifecycle

Repositories currently open connections through `Db2ConnectionFactory` and close them with
try-with-resources. Preserve these rules:

- Do not hold a JDBC connection for the lifetime of a Swing panel.
- Let a repository method open and close its own connection for an isolated operation.
- Let a service supply one shared connection when several repository calls must form a single
  transaction.
- Disable auto-commit inside such a service transaction, then commit once or roll back on error.
- Restore or close the connection in a `finally`/try-with-resources path.

## Connection test

First test the same credentials outside the application:

```text
db2 CONNECT TO CRYPTOTX USER cryptotx_app USING ********
```

Or use DBeaver's **Test Connection**.

Then run this query through the Java connection or DBeaver:

```sql
VALUES CURRENT SERVER;
VALUES CURRENT USER;

SELECT COUNT(*)
FROM CRYPTO.BLOCKCHAIN;
```

The server should be `CRYPTOTX`, and the count query should succeed for the application user.

## Timeouts and network behavior

Set finite JDBC connection and socket timeouts in the connection library or driver properties.
A Swing application should fail with an actionable message rather than wait indefinitely when
Db2 is unavailable. Perform any potentially slow connection check outside the Event Dispatch
Thread once the main UI is visible.

## Troubleshooting

### Configuration file cannot be read

Check the resolved absolute path, file permissions, encoding, and working directory. Include the
path in the error message only when it does not reveal sensitive information.

### Password decryption error

Confirm the file contains ciphertext in the format produced by the same cipher library and that
the secret source is correct. Do not fall back silently to treating arbitrary ciphertext as a
plaintext password.

### Authentication error

Test the same account in Db2 CLP or DBeaver. If external tools work, compare loader key names,
whitespace handling, encryption/decryption, and the selected database.

### Connection refused or timeout

Verify `db2start`, host, port/`SVCENAME`, TCP/IP configuration, and firewall rules.

### `SQL0204N` for `CRYPTO` objects

The connection may point to the wrong database, the schema was not created, or the account lacks
privileges. Project SQL should use names such as `CRYPTO.BLOCKCHAIN`, not an unqualified or plural
variant.

### Works in DBeaver but not Eclipse

DBeaver has its own driver and stored settings. Confirm Eclipse's runtime classpath and the
application's actual configuration file separately.
