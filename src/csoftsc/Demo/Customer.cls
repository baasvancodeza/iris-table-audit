Class csoftsc.Demo.Customer Extends csoftsc.PersistentAudit.Base [ CompileAfter = (Address, csoftsc.Demo.CustomerHistory) ]
{

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
<Value>MobileNumber</Value>
</Value>
<Value name="5">
<Value>ReseidentialAddress</Value>
</Value>
<Value name="6">
<Value>Email</Value>
</Value>
<Value name="7">
<Value>CreateDateTimeStamp</Value>
</Value>
<Value name="8">
<Value>UpdateDateTimeStamp</Value>
</Value>
<Value name="9">
<Value>CreateJob</Value>
</Value>
<Value name="10">
<Value>UpdateJob</Value>
</Value>
<Value name="11">
<Value>CreateSystemUser</Value>
</Value>
<Value name="12">
<Value>UpdateSystemUser</Value>
</Value>
<Value name="13">
<Value>CreateBusinessHost</Value>
</Value>
<Value name="14">
<Value>UpdateBusinessHost</Value>
</Value>
<Value name="15">
<Value>MarketingNewsletter</Value>
</Value>
<Value name="16">
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
