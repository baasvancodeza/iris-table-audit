/// <example>
/// Do ##class(csoftsc.Demo.RunDemo).Run()
/// </example>
Class csoftsc.Demo.RunDemo [ CompileAfter = Customer ]
{

ClassMethod Run()
{
	Try {
		kill ^csoftsc.Demo.CustomerHistoryI
		kill ^csoftsc.Demo.CustomerHistoryD
		kill ^csoftsc.Demo.CustomerHistoryS
		kill ^csoftsc.Demo.CustomerI
		kill ^csoftsc.Demo.CustomerD
		kill ^csoftsc.Demo.CustomerS
		kill ^PersistentAudit("csoftsc.Demo.Customer")
		kill ^PersistentAuditAutoPurge("csoftsc.Demo.Customer")

		Set tCust = ##class(csoftsc.Demo.Customer).%New()
		Set tAddr = ##class(csoftsc.Demo.Address).%New()

		Set tCust.Name = "Susan"
		Set tCust.Surname = "Smith"
		Set tCust.MobileNumber = "+27123456789"
		Set tAddr.StreetNumber = "2a"
		Set tAddr.StreetName = "Virtual Street"
		Set tAddr.Suburb = "Cyber Space"
		Set tAddr.City = "Void"
		Set tAddr.ZipCode = "0001"
		Set tCust.ReseidentialAddress = tAddr
		Do tCust.%NormalizeObject()
		$$$ThrowOnError(tCust.%Save())
		w !,"Check on SMP for the records if you'd like to."
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Update 1",!
		Set tCust.MobileNumber = "+27987654321"
		Set tCust.Email = "susan@cyber.space"
		Do tCust.%NormalizeObject()
		$$$ThrowOnError(tCust.%Save())

		Set tSQLStmnt = ##class(%SQL.Statement).%New(2)
		Set tSQL = ""
		Set tSQLArgs = ""
		Set tSQL($i(tSQL)) = "select 'hstr'||to_char(ID) as ""recid"", Version As ""Ver"", MobileNumber, ReseidentialAddress_ZipCode As ""ZipCode"" , Name, UpdateDateTimeStamp As ""UpdateDTS"", HistorizeDateTimeStamp As ""HistorizeDTS"""
		Set tSQL($i(tSQL)) = "from csoftsc_Demo.CustomerHistory"
		Set tSQL($i(tSQL)) = "where CurrentRecordId = ?"
		Set tSQL($i(tSQL)) = "UNION ALL"
		Set tSQL($i(tSQL)) = "select 'main'||to_char(ID) as ""recid"", Version As ""Ver"", MobileNumber, ReseidentialAddress_ZipCode As ""ZipCode"" , Name, UpdateDateTimeStamp As ""UpdateDTS"", '-----' As ""HistorizeDTS"""
		Set tSQL($i(tSQL)) = "from csoftsc_Demo.Customer"
		Set tSQL($i(tSQL)) = "where ID = ?"
		Set tSQL($i(tSQL)) = "order by 1"
		Set tSQLArgs($i(tSQLArgs)) = tCust.%Id()
		Set tSQLArgs($i(tSQLArgs)) = tCust.%Id()
		Do tSQLStmnt.%Prepare(.tSQL)
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy


		W !!,"Update 2",!
		Set tCust.ReseidentialAddress.StreetNumber = "555"
		Set tCust.ReseidentialAddress.StreetName = "std:cout Street"
		Set tCust.ReseidentialAddress.Suburb = "Void Space"
		Set tCust.ReseidentialAddress.City = "dev/null"
		Set tCust.ReseidentialAddress.ZipCode = "0020"
		Do tCust.%NormalizeObject()
		$$$ThrowOnError(tCust.%Save())
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy
		w !

		
		W !!,"Switching Off Historization"
		Set ^PersistentAuditOff("csoftsc.Demo.Customer") = 1
		w !,"Update 3 using SQL."
		&sql(update csoftsc_Demo.Customer
	   		set Name = 'Sue' where Name = 'Susan')
		w !,"SQLCDOE: ",SQLCODE,!
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Switching Historization back on"
		Set ^PersistentAuditOff("csoftsc.Demo.Customer") = 0
		w !,"Update 4 using SQL."
		&sql(update csoftsc_Demo.Customer
	   		set Name = 'Kelly' where Name = 'Sue')
		w !,"SQLCDOE: ",SQLCODE,!
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Setting Auto-purge to 2"
		Set ^PersistentAuditAutoPurge("csoftsc.Demo.Customer") = 2
		w !,"Update 4 using SQL."
		&sql(update csoftsc_Demo.Customer
	   		set Name = 'Mary' where Name = 'Kelly')
		w !,"SQLCDOE: ",SQLCODE,!
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Switching Auto-purge off"
		Set ^PersistentAuditAutoPurge("csoftsc.Demo.Customer") = 0
		w !,"Update 4 using SQL."
		&sql(update csoftsc_Demo.Customer
	   		set Name = 'Susan' where Name = 'Mary')
		w !,"SQLCDOE: ",SQLCODE,!
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Restoring Version 4 with ObjectScript"
		Set tSuccess = ##class(csoftsc.Demo.Customer).RestoreVersion(tCust.%Id(),4)
		w !,"Success: ",tSuccess,!
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy
		w !
		
		W !!,"Restoring Previous Version using SQL"
		Set tId = tCust.%Id()
		&sql(:tSuccess = call csoftsc_Demo.Customer_RestorePreviousVersion(:tId))
		w !,"SQLCDOE: ",SQLCODE,!,"Success: ",tSuccess
		set tResultSet = tSQLStmnt.%Execute(tSQLArgs...)
		do tResultSet.%Display()
		r !,"Press ENTER to continue",tDummy
		w !
		

	} catch ex {
		write !,"ERROR: ",ex.DisplayString()
	}
}

}
