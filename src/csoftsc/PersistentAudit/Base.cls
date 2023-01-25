Include (%occErrors, csoftsc.PersistentAudit.Defines)

IncludeGenerator %occErrors

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

Property CreateDateTimeStamp As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)}, ReadOnly ];

/// Last Updated date and time
Property UpdateDateTimeStamp As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)}, SqlComputeCode = { Set {*} = $ZDATETIME($HOROLOG,3)}, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by Job ID
Property CreateJob As %Integer [ InitialExpression = {$JOB}, ReadOnly ];

/// Last Updated by Job Id
Property UpdateJob As %Integer [ InitialExpression = {$JOB}, SqlComputeCode = { Set {*} = $JOB }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by System User
Property CreateSystemUser As %String(MAXLEN = 100) [ InitialExpression = {$USERNAME}, ReadOnly ];

/// Last Updated by System User
Property UpdateSystemUser As %String(MAXLEN = 100) [ InitialExpression = {$USERNAME}, SqlComputeCode = { Set {*} = $USERNAME}, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by Interoperability Host (if applicable)
Property CreateBusinessHost As %String(MAXLEN = "") [ InitialExpression = {$s($GET(%Ensemble("ConfigName"),"Ens.Actor")'="Ens.Actor":%Ensemble("ConfigName"),1:$GET(%Ensemble("Process"),""))}, ReadOnly ];

/// Last Updated by Interoperability Host (if applicable)
Property UpdateBusinessHost As %String(MAXLEN = "") [ InitialExpression = {$s($GET(%Ensemble("ConfigName"),"Ens.Actor")'="Ens.Actor":%Ensemble("ConfigName"),1:$GET(%Ensemble("Process"),""))}, SqlComputeCode = { Set {*} = $s($GET(%Ensemble("ConfigName"),"Ens.Actor")'="Ens.Actor":%Ensemble("ConfigName"),1:$GET(%Ensemble("Process"),"")) }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by Client IP (if applicable)
Property CreateClientIP As %String(MAXLEN = "") [ InitialExpression = {$SYSTEM.Process.ClientIPAddress()}, ReadOnly ];

/// Last Updated by Client IP (if applicable)
Property UpdateClientIP As %String(MAXLEN = "") [ InitialExpression = {$SYSTEM.Process.ClientIPAddress()}, SqlComputeCode = { Set {*} = $SYSTEM.Process.ClientIPAddress() }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by CSP Session ID (if applicable)
Property CreateCSPSessionID As %String(MAXLEN = "") [ InitialExpression = {$SYSTEM.Process.CSPSessionID()'=""}, ReadOnly ];

/// Last Updated by CSP Session ID (if applicable)
Property UpdateCSPSessionID As %String(MAXLEN = "") [ InitialExpression = {$SYSTEM.Process.CSPSessionID()}, SqlComputeCode = { Set {*} = $SYSTEM.Process.CSPSessionID() }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Created by Routine
Property CreateRoutine As %String(MAXLEN = "") [ InitialExpression = {$SELECT($SYSTEM.Process.CallingRoutine()'="":$SYSTEM.Process.CallingRoutine(),1:$SYSTEM.Process.Routine())}, ReadOnly ];

/// Last Updated by Routine
Property UpdateRoutine As %String(MAXLEN = "") [ InitialExpression = {$SELECT($SYSTEM.Process.CallingRoutine()'="":$SYSTEM.Process.CallingRoutine(),1:$SYSTEM.Process.Routine())}, SqlComputeCode = { Set {*} = $SELECT($SYSTEM.Process.CallingRoutine()'="":$SYSTEM.Process.CallingRoutine(),1:$SYSTEM.Process.Routine()) }, SqlComputed, SqlComputeOnChange = %%UPDATE ];

/// Generates the code to insert a history record
/// entry for the compiled class</br>
/// To disable the auto historizing of records for a Persistent Class,
/// set the ^PersistentAuditOff(&quot;MyPackage.ClassName&quot;) to 1</br>
/// To keep only a specific number of history record,
/// set the ^PersistentAuditAutoPurge(&quot;MyPackage.ClassName&quot;) to the number of history records to keep</br>
/// If not set, or less than or equal to 0, auto archiving will not be done</br>
/// e.g. ^PersistentAuditAutoPurge(&quot;csoftsc.Demo.Customer&quot;) = 2
ClassMethod GenerateHistorizeCode(
	pTrigger As %Boolean,
	pTriggerName As %String = "") As %Status [ ServerOnly = 1 ]
{
	#dim tHistTable As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	#dim tHistProp As %Dictionary.CompiledProperty

	Set tSC = $$$OK
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
			Return tSC
		}
		// Calculate sql table name
		Set tSQLTableName =  $TRANSLATE($PIECE(%compiledclass.Name, ".", 1, *-1) , ".", "_") _ "." _ $PIECE(%compiledclass.Name, ".", *)
		
		// Create method code
		If (pTrigger = 1) {
			Do %code.WriteLine("	new tHistDisabled")
		} Else {
			Do %code.WriteLine("	set tSC = $$$OK")
		}
		Do %code.WriteLine("	set tHistDisabled = $get(^PersistentAuditOff("""_%compiledclass.Name_"""),0)")
		Do %code.WriteLine("	if (tHistDisabled = 0) {")
		If (pTrigger = 1) {
			Do %code.WriteLine("		new tId,tSC,tCtr,tHistObj,SQLCODE")
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
		Do %code.WriteLine("		set tSC = tHistObj.%Save(0)")
		Do %code.WriteLine("")

		If (pTrigger = 1) {
			Do %code.WriteLine("		NEW tKeepNum,tLimitHistId")
		}
		Set tHistSQLTableName = $TRANSLATE($PIECE(tHistoryTableName, ".", 1, *-1) , ".", "_") _ "." _ $PIECE(tHistoryTableName, ".", *)
		Do %code.WriteLine("		set tKeepNum = $GET(^PersistentAuditAutoPurge(""" _ %compiledclass.Name _ """),0)")
		Do %code.WriteLine("		set:(tKeepNum<0) tKeepNum = 0")
		Do %code.WriteLine("		if (tKeepNum > 0) {")
		Do %code.WriteLine("			&sql(select min(ID)")
		Do %code.WriteLine("				into :tLimitHistId")
		Do %code.WriteLine("				from (")
		Do %code.WriteLine("					select top :tKeepNum ID")
		Do %code.WriteLine("					from " _ tHistSQLTableName)
		Do %code.WriteLine("					where CurrentRecordId = :tId")
		Do %code.WriteLine("					order by ID desc")
		Do %code.WriteLine("				)")
		Do %code.WriteLine("			)")
		Do %code.WriteLine("			Set:(SQLCODE'=0) tLimitHistId = 0")
		Do %code.WriteLine("			If (tLimitHistId > 0) {")
		Do %code.WriteLine("				&sql(delete from " _ tHistSQLTableName)
		Do %code.WriteLine("					where CurrentRecordId = :tId")
		Do %code.WriteLine("					and ID < :tLimitHistId)")
		Do %code.WriteLine("			}")
		Do %code.WriteLine("		}")

		If (pTrigger = 1) {
			Do %code.WriteLine("		if ($$$ISERR(tSC)) {")
			Do %code.WriteLine("			set %ok = 0")
			Do %code.WriteLine("			set %msg = $System.Status.GetErrorText(tSC)")
			Do %code.WriteLine("		}")
			Do %code.WriteLine("	}")
		} Else {
			Do %code.WriteLine("	}")
			Do %code.WriteLine("	quit tSC")
		}
	} Catch ex {
		Set tSC = ex.AsStatus()
		Write !,"COMPILE ERROR: ",ex.DisplayString()
	}
	Quit tSC
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
		Set tSC = ##class(csoftsc.PersistentAudit.Base).GenerateHistorizeCode(1, "BU")
	}
	Quit tSC
}

/// Automtically inserts the table endtry when it is deleted via SQL or ObjectScript
/// Compile-time generated code method in subclasses
Trigger ArchiveRecordOnDelete [ CodeMode = objectgenerator, Event = DELETE, Foreach = row/object, Order = 10 ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	} Else {
		Set tSC = ##class(csoftsc.PersistentAudit.Base).GenerateHistorizeCode(1, "BD")
	}
	Quit tSC
}

/// Restores a record to a specific version.</br>
/// Returns 1 on success and 0 on failure.
ClassMethod RestoreVersion(
	pCurrentRecordId As %String,
	pVersion As %Integer) As %Boolean [ CodeMode = objectgenerator, SqlProc ]
{
	#dim tHistTable As %Dictionary.CompiledClass
	#dim tCompiledProp As %Dictionary.CompiledProperty
	#dim tHistProp As %Dictionary.CompiledProperty

	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}

	Set tSC = $$$OK
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
		Set tVersionProperty = ""
		For i=1:1:%compiledclass.Parameters.Count()
		{
			Set tParam = %compiledclass.Parameters.GetAt(i)
			If ($FIND(tParam.Name, "VERSIONPROPERTY") '= 0) {
				Set tVersionProperty = tParam.Default
				Quit
			}
		}
		Set tHistTableDef = ##class(%Dictionary.CompiledClass).%OpenId(tHistoryTableName,0)
		If (tHistTableDef = "") {
			//set %code = 0
			Do %code.WriteLine("	// No history table")
			Return tSC
		}
		// Create method code
		Do %code.WriteLine("	set tHistObj = ##class(" _ tHistoryTableName _ ").CurrentRecordIdVersionIndexOpen(pCurrentRecordId,pVersion)")
		Do %code.WriteLine("	If (tHistObj = """") {")
		Do %code.WriteLine("		Return 0")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	set tCurObj = ##class(" _ %compiledclass.Name _ ").%OpenId(pCurrentRecordId)")
		Do %code.WriteLine("	If (tHistObj = """") {")
		Do %code.WriteLine("		Return 0")
		Do %code.WriteLine("	}")
		// If this object is already open in the process, this references the existing process object.
		// this causes version clashes. Reload to make sure it is the latest.
		Do %code.WriteLine("	Do tCurObj.%Reload()")
		
		// Process Properties
		For i=1:1:%compiledclass.Properties.Count() {
			Set tCompiledProp = %compiledclass.Properties.GetAt(i)
			// Skip ISC properties
			If ($FIND(tCompiledProp.Name, "%") '= 0) {
				Continue
			}
			If (tCompiledProp.Name = tVersionProperty) {
				Continue
			}
			If (tCompiledProp.Transient = 1) {
				Continue
			}
			If (tCompiledProp.ReadOnly = 1) {
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
			Do %code.WriteLine("	set tCurObj." _ tCompiledProp.Name _ "= tHistObj." _ tCompiledProp.Name)
		}
		Do %code.WriteLine("	set tSC = tCurObj.%Save(0)")
		Do %code.WriteLine("	set tResult = $s($$$ISERR(tSC):0,1:1)")
		Do %code.WriteLine("")
		Do %code.WriteLine("	quit tResult")
	} catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

/// Restores the previous version of a record
ClassMethod RestorePreviousVersion(pCurrentRecordId As %String) As %Boolean [ CodeMode = objectgenerator, GenerateAfter = RestoreRecordVersion, SqlProc ]
{
	If (%compiledclass.Name = "csoftsc.PersistentAudit.Base") {
		Set %code = 0
		Return $$$OK
	}

	Set tSC = $$$OK
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

		// Calculate sql table name
		Set tHistSQLTableName =  $TRANSLATE($PIECE(tHistoryTableName, ".", 1, *-1) , ".", "_") _ "." _ $PIECE(tHistoryTableName, ".", *)
		// Create method code
		Do %code.WriteLine("	&sql(select top 1 Version")
		Do %code.WriteLine("		into :tHistVersion")
		Do %code.WriteLine("		from " _ tHistSQLTableName)
		Do %code.WriteLine("		where CurrentRecordId = :pCurrentRecordId")
		Do %code.WriteLine("		order by ID desc)")
		Do %code.WriteLine("	Set:(SQLCODE'=0) tHistVersion = """"")
		Do %code.WriteLine("	If (tHistVersion = """") {")
		Do %code.WriteLine("		Return 0")
		Do %code.WriteLine("	}")
		Do %code.WriteLine("	quit ..RestoreVersion(pCurrentRecordId,tHistVersion)")
	} catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}
