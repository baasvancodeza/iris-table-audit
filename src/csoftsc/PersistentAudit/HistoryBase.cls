/// The base class to extend history tables from. 
/// It contains all the properties for auditing purposes
Class csoftsc.PersistentAudit.HistoryBase Extends (%Persistent, %XML.Adaptor, %Populate, %JSON.Adaptor) [ Abstract, NoExtent ]
{

Index CurrentRecordIdIndex On CurrentRecordId;

Index CreateDateTimeStampIndex On CreateDateTimeStamp;

Index UpdateDateTimeStampIndex On UpdateDateTimeStamp;

/// The Table IdKey of the main record
Property CurrentRecordId As %String [ Required ];

/// The record version. used for internal versio control
Property Version As %Integer;

/// Record creation date and time
Property CreateDateTimeStamp As %TimeStamp;

/// Last Update date and time
Property UpdateDateTimeStamp As %TimeStamp;

/// Date and time this History table entry was created
Property HistorizeDateTimeStamp As %TimeStamp [ InitialExpression = {$ZDATETIME($HOROLOG,3)}, ReadOnly ];

/// Created by Job
Property CreateJob As %Integer;

/// Last Updated by Job
Property UpdateJob As %Integer;

/// Job that created this entry
Property HistorizeJob As %Integer [ InitialExpression = {$JOB}, ReadOnly ];

/// Created by System User
Property CreateSystemUser As %String(MAXLEN = 100);

/// Last Update by System User
Property UpdateSystemUser As %String(MAXLEN = 100);

/// System user that was involved in the logging of this entry
Property HistorizeSystemUser As %String(MAXLEN = 100) [ InitialExpression = {$USERNAME}, ReadOnly ];

/// Created by Interoperability Host (if applicable)
Property CreateBusinessHost As %String(MAXLEN = "");

/// Last Modified by Interoperability Host (if applicable)
Property UpdateBusinessHost As %String(MAXLEN = "");

/// Ensem,ble host that inserted this entry (if applicable)
Property HistorizeBusinessHost As %String(MAXLEN = "") [ InitialExpression = {$GET(%Ensemble("ConfigName"),"")}, ReadOnly ];

}
