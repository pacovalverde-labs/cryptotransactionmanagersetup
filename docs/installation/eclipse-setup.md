# Eclipse setup

This guide imports and configures the main `CryptoTransactionManager` Java project in Eclipse.
The setup repository contains documentation and SQL; the Java source remains in the main
repository.

## Install a compatible JDK

The current source requires **Java 22 or later** because it uses unnamed lambda parameters,
for example:

```java
button.addActionListener(_ -> performAction());
```

Verify the JDK outside Eclipse:

```bash
java -version
javac -version
```

Then configure it in Eclipse:

1. Open **Window > Preferences > Java > Installed JREs**.
2. Add the JDK home directory if it is not listed.
3. Select the JDK as the workspace default, or select it specifically for the project.
4. Under **Java > Compiler**, use a compliance level supported by that JDK.

If Eclipse does not offer the selected language level, update Eclipse before changing source
code to work around the IDE.

## Import the project

Choose the route matching the repository metadata:

### Existing Eclipse project

1. Clone `crypto-transaction-manager`.
2. In Eclipse choose **File > Import > General > Existing Projects into Workspace**.
3. Select the cloned repository directory.
4. Keep **Copy projects into workspace** disabled when you want Eclipse to work directly in
   the clone.
5. Finish the import.

### Git import

1. Choose **File > Import > Git > Projects from Git**.
2. Clone the repository or select an existing local repository.
3. Import it as an existing Eclipse project when `.project` is present.

## Verify the source layout

The expected base package is:

```text
com.pacovalverde.cryptotx
```

Representative packages:

```text
app
model
repository
service
parser
importer
ui
ui.form
ui.dialog
```

Resources such as `/images/polygon.png` must be inside a source/resource folder included on
the runtime classpath. `MainWindow.class.getResource("/images/polygon.png")` expects that
absolute classpath location.

## Configure project libraries

The current source needs at least these dependency groups:

| Dependency | Provides |
|---|---|
| IBM Data Server Driver | `com.ibm.db2.jcc.*`; normally `db2jcc4.jar` |
| Project Db2 library | `Db2Config`, `Db2ConfigLoader`, `Db2ConnectionFactory` |
| Cipher library | `AesCipher` |
| HTML parser, when used by analyzer code | for example jsoup |

To add a local JAR:

1. Right-click the project and choose **Build Path > Configure Build Path**.
2. Open **Libraries**.
3. Prefer **Add JARs** for a JAR stored inside the project or **Add External JARs** for a
   machine-local dependency.
4. Apply changes and rebuild.

An external JAR path is machine-specific. For a team project, prefer a reproducible dependency
mechanism or a documented local `lib` process rather than committing Eclipse metadata that
points to one developer's drive.

Do not assume that a driver installed in DBeaver is visible to Eclipse.

## Configure dependent source projects

If the database or cipher libraries are available as Eclipse projects instead of JARs:

1. Import those projects into the workspace.
2. Open **Build Path > Projects** for `CryptoTransactionManager`.
3. Add the dependent project.
4. Confirm the exported packages match the imports used by `Main`.

Avoid adding both the same project and an old JAR copy; duplicate versions can cause confusing
runtime class loading.

## Install WindowBuilder

WindowBuilder is optional for compilation and runtime but useful for editing Swing forms.

1. Install the WindowBuilder Swing Designer component compatible with the Eclipse release.
2. Restart Eclipse.
3. Open a Swing panel or frame with **Open With > WindowBuilder Editor**.
4. Switch between **Source** and **Design** as needed.

The application deliberately uses absolute positioning in several generated panels. When the
main content pane is manually positioned, retain:

```java
contentPane.setLayout(null);
```

Use `setJMenuBar(menuBar)` for the frame menu so it automatically occupies the frame width.

WindowBuilder can invoke the no-argument constructors intended for design-time rendering.
Runtime constructors receive repositories and services. Keep design-time constructors free of
unconditional database access so the designer remains usable.

## Set file encoding

Use UTF-8 for Java, Markdown, SQL, and configuration example files:

1. Open **Project > Properties > Resource**.
2. Set **Text file encoding** to UTF-8.

This avoids corruption in multilingual descriptions and blockchain metadata.

## Configure the database file path

The attached `Main` snapshot uses a hard-coded Windows path for
`configConnectionCryptotx.txt`. Before running on another workstation, replace that development
placeholder with one of these project policies:

- a JVM system property
- an environment variable
- a user-directory path
- a relative local path outside version control

For an immediate local test, update the constant to the actual local file, but do not commit a
personal absolute path.

See [Database connection](../configuration/database-connection.md) and
[Configuration example](../configuration/configuration-example.md).

## Run configuration

1. Open `com.pacovalverde.cryptotx.app.Main`.
2. Choose **Run As > Java Application**.
3. If more than one main class exists, select the correct one.
4. In **Run Configurations**, verify:
   - project JDK
   - working directory
   - configuration-path property or environment variable, if implemented
   - VM arguments required by the chosen configuration policy

Example VM property for a future configurable path:

```text
-Dcryptotx.config=C:\path\to\configConnectionCryptotx.txt
```

This property only works after `Main` is changed to read it; the attached snapshot does not yet
do so.

## Resolve common Eclipse errors

### `_` is a keyword or unnamed variables are unsupported

Eclipse is compiling with an older Java level. Select JDK 22 or later and align project compiler
compliance.

### Imports from `com.pacovalverde.jdbc` or `com.pacovalverde.cipher` fail

The corresponding project library is missing, is the wrong version, or is not on the build
path.

### `com.ibm.db2.jcc` driver not found at runtime

Add `db2jcc4.jar` to the runtime classpath, not merely to DBeaver.

### WindowBuilder shows database errors

Ensure the no-argument design constructor does not initialize repositories or load rows.
Database-backed initialization belongs in the runtime constructor.

### Icon resource is null

Confirm `images/polygon.png` is present in a source/resource folder and copied to the output
directory.

After the project compiles with no errors, continue with [First run](first-run.md).
