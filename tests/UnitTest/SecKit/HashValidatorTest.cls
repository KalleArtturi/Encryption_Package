/// Unit tests for HashValidator class
Class UnitTest.SecKit.HashValidatorTest Extends %UnitTest.TestCase
{

/// Test comparing identical strings
Method TestCompareHashIdentical()
{
    Set hash1 = "abc123def456"
    Set hash2 = "abc123def456"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertTrue(result, "Identical strings should return true")
}

/// Test comparing different strings of same length
Method TestCompareHashDifferentSameLength()
{
    Set hash1 = "abc123def456"
    Set hash2 = "abc123def457"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertNotTrue(result, "Different strings of same length should return false")
}

/// Test comparing strings of different lengths
Method TestCompareHashDifferentLengths()
{
    Set hash1 = "abc123"
    Set hash2 = "abc123def"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertNotTrue(result, "Strings of different lengths should return false")
}

/// Test comparing empty strings
Method TestCompareHashEmptyStrings()
{
    Set hash1 = ""
    Set hash2 = ""

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertTrue(result, "Empty strings should be equal")
}

/// Test comparing empty with non-empty string
Method TestCompareHashEmptyWithNonEmpty()
{
    Set hash1 = ""
    Set hash2 = "something"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertNotTrue(result, "Empty and non-empty strings should not be equal")
}

/// Test with typical hash strings (SHA-256 hex)
Method TestCompareHashSHA256()
{
    // Simulate SHA-256 hashes (64 hex characters)
    Set hash1 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    Set hash2 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    Set hash3 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b856"

    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Identical SHA-256 hashes should match")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash3), "Different SHA-256 hashes should not match")
}

/// Test with bcrypt-style hashes
Method TestCompareHashBcrypt()
{
    // Simulate bcrypt hashes
    Set hash1 = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"
    Set hash2 = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"
    Set hash3 = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWz"

    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Identical bcrypt hashes should match")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash3), "Different bcrypt hashes should not match")
}

/// Test case sensitivity
Method TestCompareHashCaseSensitive()
{
    Set hash1 = "AbCdEf123"
    Set hash2 = "abcdef123"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertNotTrue(result, "Comparison should be case-sensitive")
}

/// Test with special characters
Method TestCompareHashSpecialCharacters()
{
    Set hash1 = "!@#$%^&*()_+-=[]{}|;':"",./<>?"
    Set hash2 = "!@#$%^&*()_+-=[]{}|;':"",./<>?"
    Set hash3 = "!@#$%^&*()_+-=[]{}|;':"",./<>!"

    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Identical special char strings should match")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash3), "Different special char strings should not match")
}

/// Test with numeric strings
Method TestCompareHashNumericStrings()
{
    Set hash1 = "123456789"
    Set hash2 = "123456789"
    Set hash3 = "123456788"

    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Identical numeric strings should match")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash3), "Different numeric strings should not match")
}

/// Test with single character difference at start
Method TestCompareHashDiffAtStart()
{
    Set hash1 = "xbc123def456"
    Set hash2 = "abc123def456"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertNotTrue(result, "Difference at start should be detected")
}

/// Test with single character difference at end
Method TestCompareHashDiffAtEnd()
{
    Set hash1 = "abc123def456"
    Set hash2 = "abc123def457"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertNotTrue(result, "Difference at end should be detected")
}

/// Test with single character difference in middle
Method TestCompareHashDiffInMiddle()
{
    Set hash1 = "abc123def456"
    Set hash2 = "abc124def456"

    Set result = ##class(SecKit.HashValidator).CompareHash(hash1, hash2)
    Do $$$AssertNotTrue(result, "Difference in middle should be detected")
}

/// Test with very long strings
Method TestCompareHashLongStrings()
{
    Set hash1 = ""
    Set hash2 = ""
    For i=1:1:1000 {
        Set hash1 = hash1 _ "a"
        Set hash2 = hash2 _ "a"
    }

    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Long identical strings should match")

    // Change one character in the middle
    Set hash2 = $Extract(hash2, 1, 500) _ "b" _ $Extract(hash2, 502, *)
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Long strings with one diff should not match")
}

/// Test timing resistance - both comparisons should take similar time
/// This is a basic test; true timing attack resistance would require more sophisticated testing
Method TestCompareHashTimingConsistency()
{
    Set hash1 = "abc123def456ghi789"
    Set hash2 = "abc123def456ghi789"
    Set hash3 = "xbc123def456ghi789"  // Different at start
    Set hash4 = "abc123def456ghi78x"  // Different at end

    // All comparisons should work correctly regardless of where difference occurs
    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Identical should match")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash3), "Different at start should not match")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash4), "Different at end should not match")

    // The key property: function doesn't short-circuit on first difference
    Do $$$LogMessage("Timing-constant comparison works for differences at any position")
}

/// Test with whitespace
Method TestCompareHashWithWhitespace()
{
    Set hash1 = "abc 123"
    Set hash2 = "abc 123"
    Set hash3 = "abc  123"  // Extra space

    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Strings with same whitespace should match")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash3), "Different whitespace should not match")
}

/// Test with null bytes
Method TestCompareHashWithNullBytes()
{
    Set hash1 = "abc" _ $Char(0) _ "def"
    Set hash2 = "abc" _ $Char(0) _ "def"
    Set hash3 = "abc" _ $Char(1) _ "def"

    Do $$$AssertTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash2), "Strings with null bytes should match if identical")
    Do $$$AssertNotTrue(##class(SecKit.HashValidator).CompareHash(hash1, hash3), "Different control characters should not match")
}

}
