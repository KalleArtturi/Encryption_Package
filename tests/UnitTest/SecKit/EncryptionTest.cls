/// Unit tests for SecKit.Encryption class
Class UnitTest.SecKit.EncryptionTest Extends %UnitTest.TestCase
{

/// Setup method - runs before all tests
Method OnBeforeAllTests() As %Status
{
    // Create a test Key for all tests to use
    Set ..KeyId = %System.Encryption.CreateEncryptionKey("UnitTestKey","AES","256","","")
    If ..KeyId = "" {
        Write !, "WARNING: Could not create test encryption Key!", !
        Write !, "Tests may fail without a valid Key.", !
        Quit $$$ERROR($$$GeneralError, "Failed to create test Key")
    }

    Quit $$$OK
}

/// Cleanup method - runs after all tests
Method OnAfterAllTests() As %Status
{
    If ..KeyId '= "" {
        Do %System.Encryption.DeactivateEncryptionKey(..KeyId, .sc)
        Set ..KeyId = ""
    }
    Quit $$$OK
}

Property KeyId As %String;

/// Test successful encryption
Method TestEncryptStringSuccess()
{
    Set plainText = "This is for school and im working on it at 9pm. Why?"
    Set sc = ##class(SecKit.Encryption).EncryptString(plainText, ..KeyId, .output)

    Do $$$AssertStatusOK(sc, "Encryption should succeed")
    Do $$$AssertNotEquals(output, "", "Encrypted output should not be empty")
    Do $$$AssertNotEquals(output, plainText, "Encrypted string should differ from plain text")
    Do $$$LogMessage("Encrypted value: " _ output)
}

/// Test successful decryption
Method TestDecryptStringSuccess()
{
    Set plainText = "Because this is actually pretty fun to do."
    Set sc = ##class(SecKit.Encryption).EncryptString(plainText, ..KeyId, .encrypted)
    Do $$$AssertStatusOK(sc, "Encryption should succeed")

    Set sc = ##class(SecKit.Encryption).DecryptString(encrypted, ..KeyId, .output)
    Do $$$AssertStatusOK(sc, "Decryption should succeed")
    Do $$$AssertEquals(output, plainText, "Decrypted string should match original")
}

/// Test encryption and decryption round-trip with various inputs
Method TestEncryptDecryptRoundTrip()
{
    Set testCases = $ListBuild(
        "Simple text",
        "Text with numbers 12345",
        "Special chars: !@#$%^&*()",
        "Multiple words with spaces",
        "Line"_$Char(10)_"break",
        "Tab"_$Char(9)_"character"
    )

    For i=1:1:$ListLength(testCases) {
        Set originalText = $List(testCases, i)

        Set sc = ##class(SecKit.Encryption).EncryptString(originalText, ..KeyId, .encrypted)
        Do $$$AssertStatusOK(sc, "Encryption failed for: " _ originalText)

        Set sc = ##class(SecKit.Encryption).DecryptString(encrypted, ..KeyId, .decrypted)
        Do $$$AssertStatusOK(sc, "Decryption failed for: " _ originalText)

        Do $$$AssertEquals(decrypted, originalText, "Round-trip failed for: " _ originalText)
    }
}

/// Test encryption with empty string
Method TestEncryptEmptyString()
{
    Set plainText = ""
    Set sc = ##class(SecKit.Encryption).EncryptString(plainText, ..KeyId, .output)

    Do $$$AssertStatusOK(sc, "Encryption of empty string should succeed")

    // Decrypt and verify
    Set sc = ##class(SecKit.Encryption).DecryptString(output, ..KeyId, .decrypted)
    Do $$$AssertStatusOK(sc, "Decryption should succeed")
    Do $$$AssertEquals(decrypted, plainText, "Empty string should decrypt correctly")
}

/// Test decryption with invalid encrypted string
Method TestDecryptInvalidString()
{
    Set invalidEncrypted = "This is not a valid encrypted string"
    Set sc = ##class(SecKit.Encryption).DecryptString(invalidEncrypted, ..KeyId, .output)

    Do $$$AssertStatusNotOK(sc, "Decryption of invalid string should fail")
    Do $$$AssertEquals(output, "", "Output should be empty on failure")
}

/// Test decryption with wrong Key
Method TestDecryptWithWrongKey()
{
    Set wrongKey = "NONEXISTENT_KEY_ID"
    Set plainText = "Secret Message"

    Set sc = ##class(SecKit.Encryption).EncryptString(plainText, ..KeyId, .encrypted)
    Do $$$AssertStatusOK(sc, "Encryption should succeed")

    Set sc = ##class(SecKit.Encryption).DecryptString(encrypted, wrongKey, .output)
    Do $$$AssertStatusNotOK(sc, "Decryption with wrong Key should fail")
    Do $$$AssertEquals(output, "", "Output should be empty on failure")
}

/// Test encryption with invalid Key
Method TestEncryptWithInvalidKey()
{
    Set plainText = "This is some text that should not be encrypted"
    Set invalidKey = "INVALID_KEY_12345"
    Set sc = ##class(SecKit.Encryption).EncryptString(plainText, invalidKey, .encrypted)

    Do $$$AssertStatusNotOK(sc, "Encryption with invalid key should fail")
    Do $$$AssertEquals(encrypted, "", "Output should be empty when using invalid key")
}
/// Test encryption with very long string
Method TestEncryptLongString()
{
    Set longText = ""
    For i=1:1:1000 {
        Set longText = longText _ "Lorem ipsum dolor sit amet, consectetur adipiscing elit. and what ever it is after that. "
    }

    Set sc = ##class(SecKit.Encryption).EncryptString(longText, ..KeyId, .encrypted)
    Do $$$AssertStatusOK(sc, "Encryption of long string should succeed")
    Do $$$AssertTrue($Length(encrypted) > 0, "Encrypted long string should not be empty")

    Set sc = ##class(SecKit.Encryption).DecryptString(encrypted, ..KeyId, .decrypted)
    Do $$$AssertStatusOK(sc, "Decryption should succeed")
    Do $$$AssertEquals(decrypted, longText, "Long string should decrypt correctly")
}

/// Test encryption with special characters and unicode
Method TestEncryptSpecialCharacters()
{
    Set specialText = "!@#$%^&*()_+-=[]{}|;':"",./<>?`~" _ $Char(9) _ $Char(10) _ $Char(13)

    Set sc = ##class(SecKit.Encryption).EncryptString(specialText, ..KeyId, .encrypted)
    Do $$$AssertStatusOK(sc, "Encryption should succeed")

    Set sc = ##class(SecKit.Encryption).DecryptString(encrypted, ..KeyId, .decrypted)
    Do $$$AssertStatusOK(sc, "Decryption should succeed")
    Do $$$AssertEquals(decrypted, specialText, "Special characters should be preserved")
}

/// Test decryption with empty encrypted string
Method TestDecryptEmptyString()
{
    Set sc = ##class(SecKit.Encryption).DecryptString("", ..KeyId, .output)
    Do $$$AssertStatusNotOK(sc, "Decryption of empty string should fail")
    Do $$$AssertEquals(output, "", "Output should be empty")
}

/// Test encryption with numeric strings
Method TestEncryptNumericStrings()
{
    Set testNumbers = $ListBuild("123", "0", "999999999", "-456", "3.14159")

    For i=1:1:$ListLength(testNumbers) {
        Set numStr = $List(testNumbers, i)

        Set sc = ##class(SecKit.Encryption).EncryptString(numStr, ..KeyId, .encrypted)
        Do $$$AssertStatusOK(sc, "Encryption failed for: " _ numStr)

        Set sc = ##class(SecKit.Encryption).DecryptString(encrypted, ..KeyId, .decrypted)
        Do $$$AssertStatusOK(sc, "Decryption failed for: " _ numStr)
        Do $$$AssertEquals(decrypted, numStr, "Numeric string failed: " _ numStr)
    }
}

/// Test that output parameter is properly set on error
Method TestOutputParameterOnError()
{
    Set output = "INITIAL_VALUE"
    Set sc = ##class(SecKit.Encryption).EncryptString("test", "INVALID_KEY", .output)

    Do $$$AssertStatusNotOK(sc, "Should fail with invalid Key")
    Do $$$AssertEquals(output, "", "Output should be empty string on error")
}

/// Test status error messages contain useful information
Method TestErrorMessageContent()
{
    Set sc = ##class(SecKit.Encryption).DecryptString("invalid", ..KeyId, .output)

    Do $$$AssertStatusNotOK(sc, "Should return error status")

    // Check that error message is not empty
    Set errorMsg = $System.Status.GetErrorText(sc)
    Do $$$AssertTrue($Length(errorMsg) > 0, "Error message should not be empty")
    Do $$$LogMessage("Error message: " _ errorMsg)
}

}


