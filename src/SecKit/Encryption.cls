Class src.SecKit.Encryption
{
/// Encypts a any given string
ClassMethod EncryptString(plain as %String, keyid as %Stirng) as %String
{
    Set encrypted = $SYSTEM.Encryption.AESCBCManagedKeyEncrypt(plain, keyid)
    return encrypted
}


/// Decrypts a any given string
ClassMethod DecryptString(encrypted as %String, keyid as %String) as %String
{
     Try {
        set plain = $SYSTEM.Encryption.AESCBCManagedKeyDecrypt(encrypted, keyid)
    } Catch ex {
        // In case of any error, return empty string
        Quit ""
    }
}
}