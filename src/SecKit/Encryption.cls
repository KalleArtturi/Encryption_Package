Class SecKit.Encryption
{
/// Encypts a any given string
ClassMethod EncryptString(plain as %String, keyid as %String, ByRef output as %String) as %Status
{
    try {
        Set output = $SYSTEM.Encryption.AESCBCManagedKeyEncrypt(plain, keyid)
        return $$$OK
    } catch ex {
        set output = ""
        return $$$ERROR($$$GeneralError, ex.DisplayString())
    }
}


/// Decrypts a any given string
ClassMethod DecryptString(encrypted as %String, keyid as %String, ByRef output as %String) as %Status
{
    try {
        Set output = $SYSTEM.Encryption.AESCBCManagedKeyDecrypt(encrypted, keyid)
        return $$$OK
    } catch ex {
        set output = ""
        return $$$ERROR($$$GeneralError, "Decryption failed: " _ ex.DisplayString())
    }
}
}