# Configuration example

This document defines the safe example that belongs in the setup repository. It must contain
dummy values only.

## Example file

Create:

```text
config/configConnectionCryptotx.example.txt
```

with this template:

```properties
# Crypto Transaction Manager - IBM Db2 connection example
# Copy this file to a private location and replace the example values.

server=localhost
port=50000
database=CRYPTOTX
username=cryptotx_app
password=REPLACE_WITH_ENCRYPTED_PASSWORD
```

The real local file is normally named:

```text
configConnectionCryptotx.txt
```

The key names must exactly match `Db2ConfigLoader`. The loader implementation is supplied by the
project database library, so verify whether the installed version uses `server`/`username` or
equivalent names such as `host`/`user`. Do not maintain two undocumented formats.

## Field reference

| Key | Required | Example | Meaning |
|---|---:|---|---|
| `server` | Yes | `localhost` | Db2 server hostname or IP address |
| `port` | Yes | `50000` | Db2 TCP service port |
| `database` | Yes | `CRYPTOTX` | Physical Db2 database name |
| `username` | Yes | `cryptotx_app` | Db2 authentication user |
| `password` | Yes | placeholder only | Ciphertext expected by the current startup flow |

Do not add the schema as a substitute for the database. The database is `CRYPTOTX`; application
objects are addressed with the schema `CRYPTO` in SQL.

## Local copy examples

### Windows

A user-local location can be:

```text
C:\Users\USER\AppData\Local\CryptoTransactionManager\configConnectionCryptotx.txt
```

Example contents:

```properties
server=localhost
port=50000
database=CRYPTOTX
username=cryptotx_app
password=ENCRYPTED_VALUE_CREATED_LOCALLY
```

### Linux

A user-local location can be:

```text
$XDG_CONFIG_HOME/cryptotx/configConnectionCryptotx.txt
```

or, when `XDG_CONFIG_HOME` is not defined, a documented application directory under the user's
configuration directory.

The contents use the same property format.

## Referencing the file

The recommended portable policy is a JVM property or environment variable.

JVM property:

```text
-Dcryptotx.config=C:\path\to\configConnectionCryptotx.txt
```

Environment variable:

```text
CRYPTOTX_CONFIG=/private/path/configConnectionCryptotx.txt
```

The attached `Main` snapshot still uses a hard-coded constant, so this policy requires the path
resolution change shown in [Database connection](database-connection.md).

## Git exclusions

The repository should ignore the real file while keeping the example:

```gitignore
configConnectionCryptotx.txt
config/configConnectionCryptotx.txt
!config/configConnectionCryptotx.example.txt
```

Adjust patterns to the repository layout, but test them:

```bash
git check-ignore -v config/configConnectionCryptotx.txt
git status --short
```

The example should remain tracked; the real file must not appear in `git status`.

## Values that must never appear in the example

- real database usernames tied to a person
- real or encrypted production passwords
- the password used to decrypt the database password
- wallet private keys or seed phrases
- API keys, exchange credentials, or access tokens
- personal wallet-address catalogs or transaction history

Even ciphertext can be sensitive and should not be published as a sample.

## Plaintext alternative for isolated development

If a future loader explicitly supports plaintext only for a disposable local environment, make
that a separate, visible configuration mode. Do not guess whether a value is encrypted. For
example:

```properties
passwordFormat=encrypted
password=REPLACE_WITH_ENCRYPTED_PASSWORD
```

This key is a design recommendation and must not be added to the example until `Db2ConfigLoader`
implements it.

## Validation checklist

- [ ] File is UTF-8 text
- [ ] Keys match the actual loader version
- [ ] Database is exactly `CRYPTOTX`
- [ ] Host and port match the Db2 instance
- [ ] Password value matches the configured encryption mode
- [ ] Decryption secret comes from a separate private source
- [ ] Real file is ignored by Git
- [ ] Example contains placeholders only
- [ ] Application user can query `CRYPTO.BLOCKCHAIN`

For the complete startup and security flow, see
[Database connection](database-connection.md).
