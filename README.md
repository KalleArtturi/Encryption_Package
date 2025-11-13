# Encryption_Package

This repository contains a small InterSystems ObjectScript package providing two utilities:

- `SecKit.Encryption` — simple wrappers around InterSystems managed-key AES encryption/decryption operations.
- `SecKit.HashValidator` — a time-constant string comparison helper intended for comparing hashes securely.

This README gives a concise user guide: what the package does, installation/import options, configuration (managed keys), usage examples, and how to run the bundled unit tests.

## What it does

- Encrypts and decrypts strings using the InterSystems managed-key AES helpers: the class methods `EncryptString` and `DecryptString` call `$SYSTEM.Encryption.AESCBCManagedKeyEncrypt` and `$SYSTEM.Encryption.AESCBCManagedKeyDecrypt` respectively and return an InterSystems status code plus the output via a ByRef parameter.
- Compares two strings in a way that avoids early short-circuiting (time-constant style) via `SecKit.HashValidator.CompareHash(a,b)` which returns a boolean (1 for equal, 0 for not equal).

## Requirements

- An InterSystems Cache/IRIS instance with Data Encryption / Managed Keys configured. The encryption helpers used by `SecKit.Encryption` rely on a managed key ID that must exist on the server where you run the code.
- Access to compile and run ObjectScript classes on the target instance (Management Portal, Terminal, or CI tooling).

## Installation / Import

Below are common ways to install or import this package into an InterSystems IRIS/Cache instance.

1) Management Portal / Class Editor
	- Open the Class Editor or navigate to the import tools in the Management Portal and compile the classes from `src/SecKit`.

2) Deploy from source control / CI
	- Copy the `src/SecKit` files into your server's source tree and compile them as part of your deployment pipeline.

3) ZPM (recommended)
	- The repository contains `module.xml` describing package metadata. Install using:
	```
	zpm:NAMESPACE>load /path/to/Encryption_Package
	zpm:NAMESPACE>test encryption_package
	```

## Configuration — Managed Key

You must have a managed encryption key configured on the server. Create or view managed keys in the Management Portal:

- System Administration > Security > Data Encryption > Managed Key Files

## Usage

Examples below assume the classes are compiled and available in the target namespace.

Encrypt a string

```objectscript
Set keyId = "<YOUR_MANAGED_KEY_ID>"
Set sc = ##class(SecKit.Encryption).EncryptString("Hello World", keyId, .encrypted)
If $System.Status.IsOK(sc) {
	Write "Encrypted: ", encrypted, !
} Else {
	Write "Encryption failed: ", $System.Status.GetErrorText(sc), !
}
```

Decrypt a string

```objectscript
Set sc = ##class(SecKit.Encryption).DecryptString(encrypted, keyId, .decrypted)
If $System.Status.IsOK(sc) {
	Write "Decrypted: ", decrypted, !
} Else {
	Write "Decryption failed: ", $System.Status.GetErrorText(sc), !
}
```

Compare hashes (time-constant style)

```objectscript
Set a = "e3b0c44298fc..."
Set b = "e3b0c44298fc..."
Set equal = ##class(SecKit.HashValidator).CompareHash(a, b)
If equal Write "Match", ! Else Write "No match", !
```

## Running unit tests

The repository includes unit tests under `tests/UnitTest/SecKit/`. The encryption tests automatically create and manage test encryption keys.

1. Run tests using ZPM
	 - After loading the package, run:
	 ```
	 zpm:NAMESPACE>test encryption_package
	 ```

2. Run tests from Management Portal
	 - Use the Test Runner to execute `UnitTest.SecKit.EncryptionTest` and `UnitTest.SecKit.HashValidatorTest`.

3. Run tests from a terminal session
	 - Example (replace `<instance>` and `<namespace>`):

```bash
iris session <instance> -U <namespace> "%UnitTest.TestRunner.RunTestClass('UnitTest.SecKit.EncryptionTest')"
iris session <instance> -U <namespace> "%UnitTest.TestRunner.RunTestClass('UnitTest.SecKit.HashValidatorTest')"
```

Notes

- Methods return InterSystems %Status values. Use `$System.Status.IsOK(sc)` and `$System.Status.GetErrorText(sc)` to check results.
- On error the encryption methods set the output ByRef parameter to an empty string.

## Security notes

- Do not store raw encryption keys in source control. Use platform-managed keys and limit access.
- `HashValidator.CompareHash` is implemented to avoid short-circuiting, which reduces simple timing differences. For high-security needs, perform environment-specific timing analysis.

## Files of interest

- `src/SecKit/Encryption.cls` — AES managed-key encrypt/decrypt wrappers
- `src/SecKit/HashValidator.cls` — time-constant string compare
- `tests/UnitTest/SecKit/EncryptionTest.cls` — unit tests for encryption
- `tests/UnitTest/SecKit/HashValidatorTest.cls` — unit tests for the comparator
- `module.xml` — ZPM package manifest

---

If you'd like, I can now add a small `Makefile` or shell script to compile the classes and run the tests, or create a GitHub Actions workflow example. Tell me which and I'll add it.



