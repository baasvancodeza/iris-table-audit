Class csoftsc.Demo.Address Extends (%SerialObject, %Populate, %XML.Adaptor, %JSON.Adaptor)
{

Property StreetNumber As %String(POPSPEC = "Random(2000)");

Property StreetName As %String(MAXLEN = 150, POPSPEC = "Street()");

Property Suburb As %String(MAXLEN = 100, POPSPEC = "Syllable()");

Property City As %String(MAXLEN = 100, POPSPEC = "City()");

Property ZipCode As %String(POPSPEC = "USZip()");

Storage Default
{
<Data name="AddressState">
<Value name="1">
<Value>StreetNumber</Value>
</Value>
<Value name="2">
<Value>StreetName</Value>
</Value>
<Value name="3">
<Value>Suburb</Value>
</Value>
<Value name="4">
<Value>City</Value>
</Value>
<Value name="5">
<Value>ZipCode</Value>
</Value>
</Data>
<State>AddressState</State>
<StreamLocation>^csoftsc.Demo.AddressS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
