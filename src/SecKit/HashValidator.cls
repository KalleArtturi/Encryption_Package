Class SecKit.HashValidator
{

/// Compares two strings agains each other in a time-constant manner and returns boolean
ClassMethod CompareHash(a As %String, b As %String) As %Boolean
{
    If ($L(a) '= $L(b)) Quit 0
    Set result = 1  // Start with 1 (true)
    For i=1:1:$L(a) {
        Set result = result & ($A(a, i) = $A(b, i))  // Use & for bitwise AND
    }
    Quit result
}

}