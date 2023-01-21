Class csoftsc.Demo.RunDemo [ CompileAfter = Customer ]
{

ClassMethod Run()
{
    Try {
        Set tCust = ##class(csoftsc.Demo.Customer).%New()
        Set tAddr = ##class(csoftsc.Demo.Address).%New()

        Set tCust.Name = "Susan"
        Set tCust.Surname = "Smith"
        Set tCust.MobileNumber = "+27123456789"
        Set tAddr.StreetNumber = "2a"
        Set tAddr.StreetName = "Virtual Street"
        Set tAddr.Suburb = "Cyber Space"
        Set tAddr.City = "Void"
        Set tAddr.ZipCode = "00000"
        Set tCust.ReseidentialAddress = tAddr
        
        Do tCust.%NormalizeObject()
        $$$ThrowOnError(tCust.%Save())

        Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),.tSC)
        $$$ThrowOnError(tSC)
        Do tDataStream.Rewind()
        w !,"JSON Data:",!,tDataStream.Read()

        W !!,"Update 1"
        Set tCust.MobileNumber = "+27987654321"
        Set tCust.Email = "susan@cyber.space"
        Do tCust.%NormalizeObject()
        $$$ThrowOnError(tCust.%Save())

        Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),.tSC)
        $$$ThrowOnError(tSC)
        Do tDataStream.Rewind()
        w !,"JSON Data:",!,tDataStream.Read()

        W !!,"Update 2"
        Set tCust.ReseidentialAddress.StreetNumber = "555"
        Set tCust.ReseidentialAddress.StreetName = "std:cout Street"
        Set tCust.ReseidentialAddress.Suburb = "Void Space"
        Set tCust.ReseidentialAddress.City = "dev/null"
        Set tCust.ReseidentialAddress.ZipCode = "10101"
        Do tCust.%NormalizeObject()
        $$$ThrowOnError(tCust.%Save())

        Set tDataStream = ##class(csoftsc.Demo.Customer).GetTimeLineDeltaJSON(tCust.%Id(),.tSC)
        $$$ThrowOnError(tSC)
        Do tDataStream.Rewind()
        w !,"JSON Data:",!,tDataStream.Read()
    } catch ex {
        write !,"ERROR: ",ex.DisplayString()
    }
}

}
