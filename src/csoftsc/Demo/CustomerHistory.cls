Class csoftsc.Demo.CustomerHistory Extends csoftsc.PersistentAudit.HistoryBase [ CompileAfter = (Address,csoftsc.PersistentAudit.HistoryBase) ]
{

Property Name As %String;

Property Surname As %String(MAXLEN = 100);

Property MobileNumber As %String;

Property ReseidentialAddress As Address;

Property Email As %String(MAXLEN = 250);

Property MarketingNewsletter As %Boolean [ InitialExpression = 1, Required ];

Storage Default
{
<Data name="CustomerHistoryDefaultData">
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
<Value>CurrentRecordId</Value>
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
<Value>HistorizeDateTimeStamp</Value>
</Value>
<Value name="10">
<Value>CreateJob</Value>
</Value>
<Value name="11">
<Value>UpdateJob</Value>
</Value>
<Value name="12">
<Value>HistorizeJob</Value>
</Value>
<Value name="13">
<Value>CreateSystemUser</Value>
</Value>
<Value name="14">
<Value>UpdateSystemUser</Value>
</Value>
<Value name="15">
<Value>HistorizeSystemUser</Value>
</Value>
<Value name="16">
<Value>CreateBusinessHost</Value>
</Value>
<Value name="17">
<Value>UpdateBusinessHost</Value>
</Value>
<Value name="18">
<Value>HistorizeBusinessHost</Value>
</Value>
<Value name="19">
<Value>CreateClientIP</Value>
</Value>
<Value name="20">
<Value>UpdateClientIP</Value>
</Value>
<Value name="21">
<Value>HistorizeClientIP</Value>
</Value>
<Value name="22">
<Value>CreateCSPSessionID</Value>
</Value>
<Value name="23">
<Value>UpdateCSPSessionID</Value>
</Value>
<Value name="24">
<Value>HistorizeCSPSessionID</Value>
</Value>
<Value name="25">
<Value>CreateRoutine</Value>
</Value>
<Value name="26">
<Value>UpdateRoutine</Value>
</Value>
<Value name="27">
<Value>HistorizeRoutine</Value>
</Value>
<Value name="28">
<Value>MarketingNewsletter</Value>
</Value>
<Value name="29">
<Value>ReseidentialAddress</Value>
</Value>
<Value name="30">
<Value>Version</Value>
</Value>
</Data>
<DataLocation>^csoftsc.Demo.CustomerHistoryD</DataLocation>
<DefaultData>CustomerHistoryDefaultData</DefaultData>
<IdLocation>^csoftsc.Demo.CustomerHistoryD</IdLocation>
<IndexLocation>^csoftsc.Demo.CustomerHistoryI</IndexLocation>
<StreamLocation>^csoftsc.Demo.CustomerHistoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
