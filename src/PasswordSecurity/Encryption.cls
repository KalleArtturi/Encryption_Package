Class src.PaswordSecurity.Encryption
{
/// Encypts a any given string
ClassMethod EncryptString(plain as %String, keyid as %Stirng) as %String
{
    Quit $SYSTEM.Encryption.AESCBCManagedKeyEncrypt(plain, keyid)
}


/// Decrypts a any given string
ClassMethod DecryptString(encrypted as %String, keyid as %String) as %String
{
     Try {
        Quit $SYSTEM.Encryption.AESCBCManagedKeyDecrypt(encrypted, keyid)
    } Catch ex {
        // In case of any error, return empty string
        Quit ""
    }
}
}