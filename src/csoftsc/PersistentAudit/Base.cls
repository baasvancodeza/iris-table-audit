Include (%occErrors, csoftsc.PersistentAudit.Defines)

Class csoftsc.PersistentAudit.Base Extends (%Persistent, %XML.Adaptor, %Populate, %JSON.Adaptor) [ Abstract, NoExtent ]
{

Index CreateDateTimeStampIndex On CreateDateTimeStamp;

Index UpdateDateTimeStampIndex On UpdateDateTimeStamp;

Parameter VERSIONPROPERTY [ Final ] = "Version";

/// Override this parameter in the subclass and set it
/// to the name of the table that will contain the history records.
/// If not set, the historizing will not be done.
Parameter HISTORYTABLECLASS As String;

Property Version As %Integer [ InitialExpression = 1 ];

Property CreateDateTimeStamp As %TimeStamp [ InitialExpression = {$zdt($h,3)}, ReadOnly ];

/// Last Updated date and time
Property UpdateDateTimeStamp As %TimeStamp [ InitialExpression = {$zdt($h,3)}, SqlComputeCode = { Set {*} = $zdt($h,3)}, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by Job ID
Property CreateJob As %Integer [ InitialExpression = {$JOB}, ReadOnly ];

/// Last Updated by Job Id
Property UpdateJob As %Integer [ InitialExpression = {$JOB}, SqlComputeCode = { Set {*} = $JOB }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by System User
Property CreateSystemUser As %String(MAXLEN = 100) [ InitialExpression = {$USERNAME}, ReadOnly ];

/// Last Updated by System User
Property UpdateSystemUser As %String(MAXLEN = 100) [ InitialExpression = {$USERNAME}, SqlComputeCode = { Set {*} = $USERNAME}, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by Interoperability Host (if applicable)
Property CreateBusinessHost As %String(MAXLEN = "") [ InitialExpression = {$GET(%Ensemble("ConfigName"),"")}, ReadOnly ];

/// Last Updated by Interoperability Host (if applicable)
Property UpdateBusinessHost As %String(MAXLEN = "") [ InitialExpression = {$GET(%Ensemble("ConfigName"),"")}, SqlComputeCode = { Set {*} = $GET(%Ensemble("ConfigName"),"") }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Generates the code to insert a history record
/// entry for the compiled class</br>
/// To disable the auto historizing of records for a Persistent Class,
/// set the ^PersistentAudit(&quot;MyPackage.ClassName&quot;) to 0
ClassMethod GenerateHistorizeCode(
	pTrigger As %Boolean,
	pTriggerName As %String = "") As %Status [ ServerOnly = 1 ]
{
	#dim tHistTable As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	#dim tHistProp As %Dictionary.CompiledProperty

	Set sc = $$$OK
	Set tCompiledProp  = ""
	Try {
		Set tHistoryTableName = ""
		For i=1:1:%compiledclass.Parameters.Count()
		{
			Set tParam = %compiledclass.Parameters.GetAt(i)
			If ($FIND(tParam.Name, "HISTORYTABLECLASS") '= 0) {
				Set tHistoryTableName = tParam.Default
				Quit
			}
		}
		Set tHistTableDef = ##class(%Dictionary.CompiledClass).%OpenId(tHistoryTableName,0)
		If (tHistTableDef = "") {
			//set %code = 0
			Do %code.WriteLine("	// No history table")
			Return sc
		}
		// Calculate sql table name
		Set tSQLTableName =  $TRANSLATE($PIECE(%compiledclass.Name, ".", 1, *-1) , ".", "_") _ "." _ $PIECE(%compiledclass.Name, ".", *)
		
		// Create method code
	If (pTrigger = 1) {
		Do %code.WriteLine("	new tHistDisabled")
	} Else {
		Do %code.WriteLine("	set sc = $$$OK")
	}
	Do %code.WriteLine("	set tHistDisabled = $get(^PersistentAudit("""_%compiledclass.Name_"""),0)")
	Do %code.WriteLine("	if (tHistDisabled = 0) {")
	If (pTrigger = 1) {
    	Do %code.WriteLine("		new tId,sc,tCtr,tHistObj,SQLCODE")
    	Do %code.WriteLine("		set tId = {ID}")
    	Do %code.WriteLine("		set %ok = 1")
    	Do %code.WriteLine("		set %msg = """"")
	} Else {
    	Do %code.WriteLine("		set tId = pId")
	}
	Do %code.WriteLine("		#SQLCompile Select=Logical")
	Do %code.WriteLine("		set tHistObj = ##class(" _ tHistoryTableName _ ").%New()")
	
	// Process Properties
	Do %code.WriteLine("		set tHistObj.CurrentRecordId = tId")
	For i=1:1:%compiledclass.Properties.Count() {
		Set tCompiledProp = %compiledclass.Properties.GetAt(i)
		// Skip ISC properties
		If ($FIND(tCompiledProp.Name, "%") '= 0) {
			Continue
		}
		If (tCompiledProp.Transient = 1) {
			Continue
		}
		// Check if field in history table
		Set tHistPropFound = 0
		For j=1:1:tHistTableDef.Properties.Count() {
			Set tHistProp = tHistTableDef.Properties.GetAt(j)
			If (tHistProp.Name = tCompiledProp.Name) {
				Set tHistPropFound = 1
			}
		}
		If (tHistPropFound = 0) {
			Throw ##class(%Exception.General).%New("HistoryPropertyNotExist",$$$GeneralError,,"Property " _ tCompiledProp.Name _ " does not exist on the History table.")
		}
		// skip collections
		If (tCompiledProp.Collection '= "") {
			Continue
		}
		Set tPropertyClass = ##class(%Dictionary.CompiledClass).%OpenId(tCompiledProp.Type,0)
		// Create assignment code
		Set tAssignDirect = 0
		If (tPropertyClass.ClassType = "datatype") {
			Set tAssignDirect = 1
		}
		Set tAssignSerial = 0
		Set:(tPropertyClass.ClassType = "serial") tAssignSerial = 1
		If (tAssignDirect) {
			Do %code.WriteLine("		set tHistObj." _ tCompiledProp.Name _ "=" _ "{" _ tCompiledProp.Name _ "*O}")
		} Else {
			Do %code.WriteLine("		do tHistObj." _ tCompiledProp.Name _ "SetObjectId(" _ "{" _ tCompiledProp.Name _ "*O})")
		}
	} // end for non-collection property assignment
	
	// Process array collections
	For i=1:1:%compiledclass.Properties.Count() {
		Set tCompiledProp = %compiledclass.Properties.GetAt(i)
		// Skip ISC properties
		If ($FIND(tCompiledProp.Name, "%") '= 0) {
			Continue
		}
		If (tCompiledProp.Collection '= "array") {
			Continue
		}
		If (tCompiledProp.Transient = 1) {
			Continue
		}
		Set tPropertyClass = ##class(%Dictionary.CompiledClass).%OpenId(tCompiledProp.Type,0)
		Set tAssignDirect = 0
		If (tPropertyClass.ClassType = "datatype") {
			Set tAssignDirect = 1
		}
		// Select from the array table projection and assign
		Set tCursorName = $EXTRACT(tCompiledProp.Name,1,16) _ i _ "CursHst" _ pTriggerName
		If (pTrigger = 1) {
			Do %code.WriteLine("		new t"_ tCompiledProp.Name)
		}
		Do %code.WriteLine("		set tCtr = 0")
		Do %code.WriteLine("		&sql(DECLARE "_ tCursorName _" CURSOR FOR ")
		Do %code.WriteLine("			SELECT " _ tCompiledProp.Name _ " INTO :t" _ tCompiledProp.Name)
		Do %code.WriteLine("			FROM " _ tSQLTableName _ "_" _ tCompiledProp.Name)
		Do %code.WriteLine("			WHERE " _ $PIECE(%compiledclass.Name, ".", *) _ " = :tId)")
		Do %code.WriteLine("		&sql(OPEN " _ tCursorName _ ")")
		Do %code.WriteLine("		for {")
		Do %code.WriteLine("			&sql(FETCH " _ tCursorName _ ")")
		Do %code.WriteLine("			quit:(SQLCODE '= 0)")
		If (tAssignDirect) {
			Do %code.WriteLine("			do tHistObj." _ tCompiledProp.Name _ ".SetAt(t" _ tCompiledProp.Name _ ", $i(tCtr))")
		} Else {
			Do %code.WriteLine("			do tHistObj." _ tCompiledProp.Name _ ".SetObjectIdAt(t" _ tCompiledProp.Name _ ", $i(tCtr))")
		}
		Do %code.WriteLine("		}")
		Do %code.WriteLine("		&sql(CLOSE " _ tCursorName _ ")")
	}
	// End of if modified, Save and quit
	Do %code.WriteLine("		set sc = tHistObj.%Save(0)")
	If (pTrigger = 1) {
		Do %code.WriteLine("		if ($$$ISERR(sc)) {")
		Do %code.WriteLine("			set %ok = 0")
		Do %code.WriteLine("			set %msg = $System.Status.GetErrorText(sc)")
		Do %code.WriteLine("		}")
		Do %code.WriteLine("	}")
	} Else {
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	quit sc")
	}
	} Catch ex {
		Set sc = ex.AsStatus()
		Write !,"COMPILE ERROR: ",ex.DisplayString()
	}
	Quit sc
}

/// Automtically inserts the table entry when it is altered via SQL 
/// and ObjectScript
/// This is Compile-time generated code method in subclasses
Trigger StoreRecordChange [ CodeMode = objectgenerator, Event = UPDATE, Foreach = row/object, Order = 10 ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	} Else {
		Set sc = ##class(csoftsc.PersistentAudit.Base).GenerateHistorizeCode(1, "BU")
	}
	Quit sc
}

/// Automtically inserts the table endtry when it is deleted via SQL or ObjectScript
/// Compile-time generated code method in subclasses
Trigger ArchiveRecordOnDelete [ CodeMode = objectgenerator, Event = DELETE, Foreach = row/object, Order = 10 ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	} Else {
		Set sc = ##class(csoftsc.PersistentAudit.Base).GenerateHistorizeCode(1, "BD")
	}
	Quit sc
}

/// Used during compile time to determine
/// if it has a history table and set process values
/// that will be used during the compiling.
/// this is for the TimeLine generators
ClassMethod SetHasHistoryTable() As %Boolean
{
	Set tHasHisotry = 0
	Set tHistoryTableName =""
	For i=1:1:%compiledclass.Parameters.Count()
	{
		Set tParam = %compiledclass.Parameters.GetAt(i)
		If ($FIND(tParam.Name, "HISTORYTABLECLASS") '= 0) {
			Set tHistoryTableName = tParam.Default
			Quit
		}
	} ; for
	If (tHistoryTableName '= "") {
		Set tHasHistory = 1
	}
	Set %HistoryTableName = tHistoryTableName
	Set %HasHistory = tHasHistory
	Quit tHasHistory
}

/// Generated ClassMethod that will return a record&apos;s timeline
/// over its existance. This will be full records, where on records subsequent
/// to the first one will indicate which fields have changed.
/// This does NOT process array, list or Many-Relationship properties as part of its history
ClassMethod GetTimeLineDeltaJSON(
	pRecId As %Integer,
	Output pSC As %Status) As %Stream.TmpCharacter [ CodeMode = objectgenerator, GenerateAfter = (SetHasHistoryTable, AddFirstHistRecord, AddCurrentRecord, AddCurrentRecordDelte, AddHistRecordDelta) ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	Set tSC = $$$OK
	#dim tCompiledClass As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	try {
		if ('..SetHasHistoryTable()) {
			Set %code = 0
			Return tSC
		}
		
		Do %code.WriteLine("	Set pSC = $$$OK")
		Do %code.WriteLine("	Set tResult = """"")
		Do %code.WriteLine("	try {")
		Do %code.WriteLine("		Set tJSON = ##class(%Library.DynamicArray).%New()")

		Do %code.WriteLine("		&sql(declare tHistCurs cursor for")
		Do %code.WriteLine("			select id")
		Do %code.WriteLine("			into :tHistId")
		Do %code.WriteLine("			from " _ $REPLACE($PIECE(%HistoryTableName,".",1,*-1),".","_") _ ". " _ $PIECE(%HistoryTableName,".",*))
		Do %code.WriteLine("			where CurrentRecordId = :pRecId")
		Do %code.WriteLine("			order by id)")
		Do %code.WriteLine("		&sql(open tHistCurs)")
		Do %code.WriteLine("		$$$ThrowSQLIfError(SQLCODE,%msg)")

		Do %code.WriteLine("		Set tPrevId = """"")
		Do %code.WriteLine("		while(1) {")
		Do %code.WriteLine("			&sql(fetch tHistCurs)")
		Do %code.WriteLine("			Quit:(SQLCODE'=0)")

		Do %code.WriteLine("			if (tPrevId = """") {")
		Do %code.WriteLine("				$$$ThrowOnError(..AddFirstHistRecord(tHistId, .tEntry))")
		Do %code.WriteLine("			} Else {")
		Do %code.WriteLine("				$$$ThrowOnError(..AddHistRecordDelta(tPrevId, tHistId, .tEntry))")
		Do %code.WriteLine("			}")

		Do %code.WriteLine("			Do tJSON.%Push(tEntry)")
		Do %code.WriteLine("			Set tPrevId = tHistId")
		Do %code.WriteLine("		} // while")
		Do %code.WriteLine("		$$$ThrowSQLIfError(SQLCODE,%msg)")

		Do %code.WriteLine("		&sql(close tHistCurs)")
		Do %code.WriteLine("		$$$ThrowSQLIfError(SQLCODE,%msg)")

		Do %code.WriteLine("		If (tPrevId '= """") {")
		Do %code.WriteLine("			$$$ThrowOnError(..AddCurrentRecordDelta(tPrevId, pRecId, .tEntry))")
		Do %code.WriteLine("			Do tJSON.%Push(tEntry)")
		Do %code.WriteLine("		} else {")
		Do %code.WriteLine("			// No history")
		Do %code.WriteLine("			$$$ThrowOnError(..AddCurrentRecord(pRecId, .tEntry))")
		Do %code.WriteLine("			Do tJSON.%Push(tEntry)")
		Do %code.WriteLine("		}")

		// output to stream
		Do %code.WriteLine("		set tResult = ##class(%Stream.TmpCharacter).%New()")
		Do %code.WriteLine("		Do tJSON.%ToJSON(.tResult)")

		Do %code.WriteLine("	} catch ex {")
		Do %code.WriteLine("		Set pSC = ex.AsStatus()")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	Quit tResult")

	} catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod AddFirstHistRecord(
	pRecId As %Integer,
	Output pEntry As %Library.DynamicObject) As %Status [ CodeMode = objectgenerator, GenerateAfter = (SetHasHistoryTable, AddFirstRecord), Private ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	Set tSC = $$$OK
	#dim tCompiledClass As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	try {
		if ('..SetHasHistoryTable()) {
			Set %code = 0
			Return tSC
		}

		Do %code.WriteLine("	Set tSC = $$$OK")
		Do %code.WriteLine("	try {")
		Do %code.WriteLine("		Set pEntry = ##class(%Library.DynamicObject).%New()")
		Do %code.WriteLine("		Set tObj = ##class(" _ %HistoryTableName _ ").%OpenId(pRecId)")
		Do %code.WriteLine("		Set tSC = ..AddFirstRecord(tObj, .pEntry)")
		Do %code.WriteLine("	} catch ex {")
		Do %code.WriteLine("		Set tSC = ex.AsStatus()")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	Quit tSC")
	} catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod AddCurrentRecord(
	pRecId As %Integer,
	Output pEntry As %Library.DynamicObject) As %Status [ CodeMode = objectgenerator, GenerateAfter = (SetHasHistoryTable, AddFirstRecord), Private ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	Set tSC = $$$OK
	#dim tCompiledClass As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	try {
		if ('..SetHasHistoryTable()) {
			Set %code = 0
			Return tSC
		}

		Do %code.WriteLine("	Set tSC = $$$OK")
		Do %code.WriteLine("	try {")
		Do %code.WriteLine("		Set pEntry = ##class(%Library.DynamicObject).%New()")
		Do %code.WriteLine("		Set tObj = ##class(" _ %compiledclass.Name _ ").%OpenId(pRecId)")
 		Do %code.WriteLine("		Set tSC = ..AddFirstRecord(tObj, .pEntry)")
		Do %code.WriteLine("	} catch ex {")
		Do %code.WriteLine("		Set tSC = ex.AsStatus()")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	Quit tSC")
	} catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

ClassMethod AddFirstRecord(
	pObj As %RegisteredObject,
	ByRef pEntry As %Library.DynamicObject) As %Status [ CodeMode = objectgenerator, GenerateAfter = SetHasHistoryTable, Private ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	Set tSC = $$$OK
	#dim tCompiledClass As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	try {
		if ('..SetHasHistoryTable()) {
			Set %code = 0
			Return tSC
		}

		Do %code.WriteLine("	Set tSC = $$$OK")
		Do %code.WriteLine("	try {")
		Do %code.WriteLine("		Do pEntry.%Set(""DateTimeStamp"", pObj.CreateDateTimeStamp)")
		Do %code.WriteLine("		Set tFields = ##class(%Library.DynamicObject).%New()")
		
		$$$ThrowOnError(..TimeLineAddProperties("Do tFields.%Set(""%field"", pObj.%pval)","pObj"))

		Do %code.WriteLine("		Do pEntry.%Set(""Fields"", tFields)")
		Do %code.WriteLine("	} catch ex {")
		Do %code.WriteLine("		Set tSC = ex.AsStatus()")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	Quit tSC")
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod AddHistRecordDelta(
	pPrevId As %Integer,
	pRecId As %Integer,
	Output pEntry As %Library.DynamicObject) As %Status [ CodeMode = objectgenerator, GenerateAfter = (SetHasHistoryTable, AddDelta), Private ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	set tSC = $$$OK
	#dim tCompiledClass As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	try {
		if ('..SetHasHistoryTable()) {
			Set %code = 0
			Return tSC
		}

		Do %code.WriteLine("	Set tSC = $$$OK")
		Do %code.WriteLine("	try {")
		Do %code.WriteLine("		Set pEntry = ##class(%Library.DynamicObject).%New()")
		Do %code.WriteLine("		Set tPrev = ##class(" _ %HistoryTableName _ ").%OpenId(pPrevId)")
		Do %code.WriteLine("		Set tNext = ##class(" _ %HistoryTableName _ ").%OpenId(pRecId)")
		Do %code.WriteLine("		Set tSC = ..AddDelta(tPrev, tNext, .pEntry)")
		Do %code.WriteLine("	} catch ex {")
		Do %code.WriteLine("		Set tSC = ex.AsStatus()")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	Quit tSC")
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod AddCurrentRecordDelta(
	pPrevId As %Integer,
	pRecId As %Integer,
	Output pEntry As %Library.DynamicObject) As %Status [ CodeMode = objectgenerator, GenerateAfter = (SetHasHistoryTable, AddDelta), Private ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	set tSC = $$$OK
	#dim tCompiledClass As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	try {
		if ('..SetHasHistoryTable()) {
			Set %code = 0
			Return tSC
		}
		Do %code.WriteLine("	Set tSC = $$$OK")
		Do %code.WriteLine("	try {")
		Do %code.WriteLine("		Set pEntry = ##class(%Library.DynamicObject).%New()")
		Do %code.WriteLine("		Set tPrev = ##class(" _ %HistoryTableName _ ").%OpenId(pPrevId)")
		Do %code.WriteLine("		Set tNext = ##class(" _ %compiledclass.Name _ ").%OpenId(pRecId)")
		Do %code.WriteLine("		Set tSC = ..AddDelta(tPrev, tNext, .pEntry)")
		Do %code.WriteLine("	}catch ex {")
		Do %code.WriteLine("		Set tSC = ex.AsStatus()")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	Quit tSC")
	}catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod AddDelta(
	pPrev As %RegisteredObject,
	pRec As %RegisteredObject,
	Output pEntry As %Library.DynamicObject) As %Status [ CodeMode = objectgenerator, GenerateAfter = SetHasHistoryTable, Private ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	set tSC = $$$OK
	#dim tCompiledClass As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	try {
		if ('..SetHasHistoryTable()) {
			Set %code = 0
			Return tSC
		}

		Do %code.WriteLine("	Set tSC = $$$OK")
		Do %code.WriteLine("	try {")
		Do %code.WriteLine("		Do pEntry.%Set(""DateTimeStamp"", pRec.UpdateDateTimeStamp)")
		Do %code.WriteLine("		Set tFields = ##class(%Library.DynamicObject).%New()")

		$$$ThrowOnError(..TimeLineAddProperties("Do:(pPrev.%pval'=pRec.%pval) tFields.%Set(""%field"", pRec.%pval)","pRec,pPrev"))

		Do %code.WriteLine("		Do pEntry.%Set(""Fields"", tFields)")
		Do %code.WriteLine("	} catch ex {")
		Do %code.WriteLine("		Set tSC = ex.AsStatus()")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	Quit tSC")

	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Generate the code for property lines of an object.
/// It traverses through serial objects for a complete delta
/// calculation.</br>
/// Line Mask is the line to be added.
/// Put a %pval in the line where the property value will be at
/// Put a %field in the line where the json field name should be
/// path is to be inserted.</br>
/// pIfObjectNames will work with up to a max of two values.
/// This is usually between comparisons. First must be the current
/// and 2nd must be the previous
ClassMethod TimeLineAddProperties(
	pLineMask As %String(MAXLEN=""),
	pIfObjectNames As %String) As %Status
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	Set tSC = $$$OK
	try {
		For i=1:1:%compiledclass.Properties.Count() {
			Set tCompiledProp = %compiledclass.Properties.GetAt(i)
			// Skip ISC properties
			If ($FIND(tCompiledProp.Name, "%") '= 0) {
				Continue
			}
			// skip collections
			If (tCompiledProp.Collection '= "") {
				Continue
			}
			$$$ThrowOnError(..TimeLineAddProperty(tCompiledProp, pLineMask, pIfObjectNames, ""))
		} // end for non-collection property assignment
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Add the line of a property
ClassMethod TimeLineAddProperty(
	pProperty As %Dictionary.CompiledProperty,
	pLineMask As %String(MAXLEN=""),
	pIfObjectNames As %String,
	pFieldPrefix As %String(MAXLEN=""),
	pElseLines As %Boolean = 0,
	pTabLevel As %Integer = 2) As %Status
{
	Set tSC = $$$OK
	try {
		Set:(pFieldPrefix'="") tPropStr = pFieldPrefix _ "_" _ pProperty.Name
		Set:(pFieldPrefix="") tPropStr = pProperty.Name
		Set tPropValStr = ""
		// Create prop based on "type"
		Set tPropertyClass = ##class(%Dictionary.CompiledClass).%OpenId(pProperty.Type,0)
		Set tAssignDirect = 0
		If (tPropertyClass.ClassType = "datatype") {
			Set tAssignDirect = 1
		}
		Set tAssignSerial = 0
		Set:(tPropertyClass.ClassType = "serial") tAssignSerial = 1
		If (tAssignDirect) {
			Set:(pFieldPrefix'="") tPropValStr = $REPLACE(pFieldPrefix,"_",".") _ "." _ pProperty.Name
			Set:(pFieldPrefix="") tPropValStr = pProperty.Name
		} ElseIf (tAssignSerial) {
			$$$ThrowOnError(..TimeLineAddSerialProperty(pProperty, pLineMask, pIfObjectNames, tPropStr, pElseLines, pTabLevel))
		} Else {
			Set:(pFieldPrefix'="") tPropValStr = pFieldPrefix _ "." _ pProperty.Name _ "GetObjectId()"
			Set:(pFieldPrefix="") tPropValStr = pProperty.Name _ "GetObjectId()"
		}
		If (tPropValStr'="") {
			Set tLine = $REPLACE(pLineMask,"%pval",tPropValStr)
			Set tLine = $$$LeftPad("",pTabLevel,$c(9)) _ $REPLACE(tLine,"%field",tPropStr)
			Do %code.WriteLine(tLine)
		}
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Process a property that is of type serial
ClassMethod TimeLineAddSerialProperty(
	pProperty As %Dictionary.CompiledProperty,
	pLineMask As %String(MAXLEN=""),
	pIfObjectNames As %String,
	pFieldPrefix As %String(MAXLEN=""),
	pElseLines As %Boolean,
	pTabLevel As %Integer) As %Status
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}
	Set tSC = $$$OK
	try {
		Set tIfObjs = $LISTFROMSTRING(pIfObjectNames)
		Set tTabs = pTabLevel
		Set tIfLine = $$$LeftPad("",tTabs,$char(9))
		Set tCloseLine = $$$LeftPad("",tTabs,$char(9))
		Set tIfLine = tIfLine _ "If ("
		Set tCloseLine = tCloseLine _ "}"
		Set tPropertyClass = ##class(%Dictionary.CompiledClass).%OpenId(pProperty.Type,0)
		
		If ('pElseLines) {
			For i=1:1:$ll(tIfObjs) {
				Set tObjName = $lg(tIfObjs,i)
				If (i = 1) {
					Set tIfLine = tIfLine _ "(" _ tObjName _ "." _ $REPLACE(pFieldPrefix,"_",".") _ " '= $$$NULLOREF)"
				} Else {
					Set tIfLine = tIfLine _ " && (" _ tObjName _ "." _ $REPLACE(pFieldPrefix,"_",".") _ " '= $$$NULLOREF)"
				}
			} ; for ObjNames

			Set tIfLine = tIfLine _ ") {"
			Do %code.WriteLine(tIfLine)

			Set tTabs = tTabs + 1
			For i=1:1:tPropertyClass.Properties.Count() {
				Set tCompiledProp = tPropertyClass.Properties.GetAt(i)

				// Skip ISC properties
				If ($FIND(tCompiledProp.Name, "%") '= 0) {
					Continue
				}
				// skip collections
				If (tCompiledProp.Collection '= "") {
					Continue
				}
				
				$$$ThrowOnError(..TimeLineAddProperty(tCompiledProp, pLineMask, pIfObjectNames, pFieldPrefix,0,tTabs))
			} ; Serial Object properties for
		
			Do %code.WriteLine(tCloseLine _ " Else {")
		} ; ElseLines

		// Second Part
		// Covers two objects compared
		// in the case where one or the other is null
		// if the first is null, then all the new values can be loaded
		// If it is the second, the values changed to a null from a non-null value.
		// Also handle for when the object is null if only a single
		Set tSavTabs = tTabs
		For i=1:1:$ll(tIfObjs) {
			Set tTabs = tSavTabs
			Set tObjName = $lg(tIfObjs,i)

			If (($ll(tIfObjs) > 1) && ('pElseLines)) {
				Do %code.WriteLine($$$LeftPad("",pTabLevel+1,$char(9)) _ "If (" _ tObjName _ " '= $$$NULLOREF) {")
				Set tTabs = tTabs + 1
			} ElseIf ('pElseLines) {
				;Set tTabs = tTabs - 1
			}
			If (($ll(tIfObjs) > 1) && (i = 1)) {
				// Else of if with two object not null checks
				// so each object checks separately.
				// This is the current rec where the previous was null values
				Set tLineMask = "Do tFields.%Set(""%field"", " _ tObjName _ ".%pval)"
			}
			If ((i=1) && ($ll(tIfObjs)=1)) {
				// else part of single object as with "first records"
				Set tLineMask = "Do tFields.%Set(""%field"", """")"
			}
			If (i > 1) {
				// the second prev was not null, and current is, so set values to null.
				Set tLineMask = "Do tFields.%Set(""%field"", """")"
			}
			
			

			Set tInElse = 1
			;set:(('pElseLines) && ($ll(tIfObjs)=1)) tTabs = tTabs - 1
			
			For j=1:1:tPropertyClass.Properties.Count() {
				Set tCompiledProp = tPropertyClass.Properties.GetAt(j)
				// Skip ISC properties
				If ($FIND(tCompiledProp.Name, "%") '= 0) {
					Continue
				}
				// skip collections
				If (tCompiledProp.Collection '= "") {
					Continue
				}
				$$$ThrowOnError(..TimeLineAddProperty(tCompiledProp, tLineMask, tObjName, pFieldPrefix, tInElse, tTabs))
			}
			Do:(($ll(tIfObjs)>1)&&('pElseLines)) %code.WriteLine($$$LeftPad("",pTabLevel+1,$char(9)) _ "}")
		} ; for ObjNames
		Set tTabs = tSavTabs

		Do:('pElseLines) %code.WriteLine(tCloseLine)
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

}
