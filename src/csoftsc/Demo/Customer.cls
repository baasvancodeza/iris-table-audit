Class csoftsc.Demo.Customer Extends csoftsc.PersistentAudit.Base [ CompileAfter = (Address, csoftsc.Demo.CustomerHistory) ]
{

Index NameIndex On Name;

Index SurnameIndex On Surname;

Parameter HISTORYTABLECLASS = "csoftsc.Demo.CustomerHistory";

Property Name As %String [ Required ];

Property Surname As %String(MAXLEN = 100) [ Required ];

Property MobileNumber As %String [ Required ];

Property ReseidentialAddress As Address;

Property Email As %String(MAXLEN = 250);

Property MarketingNewsletter As %Boolean [ InitialExpression = 1, Required ];

Storage Default
{
<Data name="CustomerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Surname</Value>
</Value>
<Value name="4">
<Value>CreateDateTimeStamp</Value>
</Value>
<Value name="5">
<Value>ReseidentialAddress</Value>
</Value>
<Value name="6">
<Value>CreateJob</Value>
</Value>
<Value name="7">
<Value>MarketingNewsletter</Value>
</Value>
<Value name="8">
<Value>CreateSystemUser</Value>
</Value>
<Value name="9">
<Value>UpdateSystemUser</Value>
</Value>
<Value name="10">
<Value>CreateBusinessHost</Value>
</Value>
<Value name="11">
<Value>UpdateBusinessHost</Value>
</Value>
<Value name="12">
<Value>CreateClientIP</Value>
</Value>
<Value name="13">
<Value>UpdateClientIP</Value>
</Value>
<Value name="14">
<Value>CreateCSPSessionID</Value>
</Value>
<Value name="15">
<Value>UpdateCSPSessionID</Value>
</Value>
<Value name="16">
<Value>CreateRoutine</Value>
</Value>
<Value name="17">
<Value>UpdateRoutine</Value>
</Value>
<Value name="18">
<Value>Email</Value>
</Value>
<Value name="19">
<Value>MobileNumber</Value>
</Value>
<Value name="20">
<Value>UpdateDateTimeStamp</Value>
</Value>
<Value name="21">
<Value>UpdateJob</Value>
</Value>
<Value name="22">
<Value>Version</Value>
</Value>
</Data>
<DataLocation>^csoftsc.Demo.CustomerD</DataLocation>
<DefaultData>CustomerDefaultData</DefaultData>
<IdLocation>^csoftsc.Demo.CustomerD</IdLocation>
<IndexLocation>^csoftsc.Demo.CustomerI</IndexLocation>
<StreamLocation>^csoftsc.Demo.CustomerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
