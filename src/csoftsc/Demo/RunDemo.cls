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

		Set tCust = ##class(csoftsc.Demo.Customer).%New()
		Set tAddr = ##class(csoftsc.Demo.Address).%New()

		Set tCust.Name = "Susan"
		Set tCust.Surname = "Smith"
		Set tCust.MobileNumber = "+27123456789"
		Set tAddr.StreetNumber = "2a"
		Set tAddr.StreetName = "Virtual Street"
		Set tAddr.Suburb = "Cyber Space"
		Set tAddr.City = "Void"
		Set tAddr.ZipCode = "1"
		Set tCust.ReseidentialAddress = tAddr
		
		Do tCust.%NormalizeObject()
		$$$ThrowOnError(tCust.%Save())

		Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),0,.tSC)
		$$$ThrowOnError(tSC)
		Do tDataStream.Rewind()
		w !,"JSON Data:",!,tDataStream.Read()
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Update 1"
		Set tCust.MobileNumber = "+27987654321"
		Set tCust.Email = "susan@cyber.space"
		Do tCust.%NormalizeObject()
		$$$ThrowOnError(tCust.%Save())

		Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),0,.tSC)
		$$$ThrowOnError(tSC)
		Do tDataStream.Rewind()
		w !,"JSON Data:",!,tDataStream.Read()
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Update 2"
		Set tCust.ReseidentialAddress.StreetNumber = "555"
		Set tCust.ReseidentialAddress.StreetName = "std:cout Street"
		Set tCust.ReseidentialAddress.Suburb = "Void Space"
		Set tCust.ReseidentialAddress.City = "dev/null"
		Set tCust.ReseidentialAddress.ZipCode = "2"
		Do tCust.%NormalizeObject()
		$$$ThrowOnError(tCust.%Save())

		Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),0,.tSC)
		$$$ThrowOnError(tSC)
		Do tDataStream.Rewind()
		w !,"JSON Data:",!,tDataStream.Read()
		r !,"Press ENTER to continue",tDummy
		w !

		Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),1,.tSC)
		$$$ThrowOnError(tSC)
		Do tDataStream.Rewind()
		w !,"JSON Data with Logical Values:",!,tDataStream.Read()
		r !,"Press ENTER to continue",tDummy

		w !!,"JSON Data using Dynamic SQL",!
		Set tSQLStr = ""
		Set tSQLStr($i(tSQLStr)) = "select csoftsc_Demo.Customer_GetTimeLineDeltaJSON(id)"
		Set tSQLStr($i(tSQLStr)) = "from csoftsc_Demo.Customer"
		Set tSQLStr($i(tSQLStr)) = "where Name = 'Susan'"
		Set tSQL = ##class(%SQL.Statement).%New(1)
		w tSQL.%Prepare(.tSQLStr)
		s tResult = tSQL.%Execute()
		If (tResult.%Next()) {
			w !,tResult.%GetData(1).Read()
		}
		r !,"Press ENTER to continue",tDummy
		w !

		W !!,"Update 3 using SQL"
		&sql(update csoftsc_Demo.Customer
	   		set Name = 'Sue' where Name = 'Susan')
		w !,"SQLCDOE: ",SQLCODE		Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),0,.tSC)
		$$$ThrowOnError(tSC)
		Do tDataStream.Rewind()
		w !,"JSON Data:",!,tDataStream.Read()

		w !!,"In SMP you can run the following queries to inspect the data"
		w !,"select * from csoftsc_Demo.Customer"
		w !,"select * from csoftsc_Demo.CustomerHistory where CurrentRecordId = 1"
		r !!,"Press ENTER to continue",tDummy
		w !

	} catch ex {
		write !,"ERROR: ",ex.DisplayString()
	}
}

}
