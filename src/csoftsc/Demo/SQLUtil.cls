Class csoftsc.Demo.SQLUtil
{

ClassMethod RandomZip() As %String [ SqlProc ]
{
    quit ##class(%PopulateUtils).USZip()
}

ClassMethod RandomName() As %String [ SqlProc ]
{
    quit ##class(%PopulateUtils).FirstName()
}

ClassMethod RandomPhone() As %String [ SqlProc ]
{
    quit ##class(%PopulateUtils).USPhone()
}

}
