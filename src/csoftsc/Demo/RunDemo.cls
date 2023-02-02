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

		w !,"You can use the following SQLs on SMP to see more record details:"
		w !,"select *"
		w !,"from csoftsc_Demo.CustomerHistory"
		w !,"where CurrentRecordId = 1"
		w !
		w !,"select *"
		w !,"from csoftsc_Demo.Customer"
		w !,"where ID = 1"
		r !,"Press ENTER to Start the Demo",tDummy
		w !!

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
		w !,"Main Testing Record Added"
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Update 1",!
		Set tCust.MobileNumber = "+27987654321"
		Set tCust.Email = "susan@cyber.space"
		Do tCust.%NormalizeObject()
		$$$ThrowOnError(tCust.%Save())
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

		w !,"Bulk Insert 10 000 recirds",!,"Start: ",$zdt($h,3)
		Do ##class(csoftsc.Demo.Customer).Populate(10000)
		w !,"Done: ",$zdt($h,3)
		
		&sql(select count(*)
			into :tMainCount
			from csoftsc_Demo.Customer)
		&sql(select count(*)
			into :tHistCount
			from csoftsc_Demo.CustomerHistory)
		w !,"Main #: ",tMainCount
		w !,"History #: ",tHistCount

		w !!,"Updating 10 000 Records",!,"Start: ",$zdt($h,3)
		&sql(update csoftsc_Demo.Customer
			set ReseidentialAddress_ZipCode = csoftsc_Demo.SQLUtil_RandomZip(),
				MobileNumber = csoftsc_Demo.SQLUtil_RandomPhone(),
				Name = csoftsc_Demo.SQLUtil_RandomName()
			where ID > 1)
		w:(SQLCODE'=0) !!,"SQL ERROR: ",SQLCODE," - ",$g(%msg)
		w !,"Done: ",$zdt($h,3)

		&sql(select count(*)
			into :tMainCount
			from csoftsc_Demo.Customer)
		&sql(select count(*)
			into :tHistCount
			from csoftsc_Demo.CustomerHistory)
		w !,"Main #: ",tMainCount
		w !,"History #: ",tHistCount		

	} catch ex {
		write !,"ERROR: ",ex.DisplayString()
	}
}

}
