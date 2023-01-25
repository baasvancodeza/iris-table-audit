/// The base class to extend history tables from. 
/// It contains all the properties for auditing purposes
Class csoftsc.PersistentAudit.HistoryBase Extends (%Persistent, %XML.Adaptor, %Populate, %JSON.Adaptor) [ Abstract, NoExtent ]
{

Index CurrentRecordIdIndex On CurrentRecordId;

Index CreateDateTimeStampIndex On CreateDateTimeStamp;

Index UpdateDateTimeStampIndex On UpdateDateTimeStamp;

Index CurrentRecordIdVersionIndex On (CurrentRecordId, Version) [ Unique ];

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

/// Interoperability host that inserted this entry (if applicable)
Property HistorizeBusinessHost As %String(MAXLEN = "") [ InitialExpression = {$GET(%Ensemble("ConfigName"),"")}, ReadOnly ];

/// Created by Client IP (if applicable)
Property CreateClientIP As %String(MAXLEN = "");

/// Last Updated by Client IP (if applicable)
Property UpdateClientIP As %String(MAXLEN = "");

/// Client IP that caused this record to be inserted
Property HistorizeClientIP As %String(MAXLEN = "") [ InitialExpression = {$SYSTEM.Process.ClientIPAddress()}, ReadOnly ];

/// Created by CSP Session ID (if applicable)
Property CreateCSPSessionID As %String(MAXLEN = "");

/// Last Updated by CSP Session ID (if applicable)
Property UpdateCSPSessionID As %String(MAXLEN = "");

/// CSP Session ID that caused this record to be inserted
Property HistorizeCSPSessionID As %String(MAXLEN = "") [ InitialExpression = {$SYSTEM.Process.CSPSessionID()}, ReadOnly ];

/// Created by Routine
Property CreateRoutine As %String(MAXLEN = "");

/// Last Updated by Routine
Property UpdateRoutine As %String(MAXLEN = "");

/// Routine from where this record was inserted
Property HistorizeRoutine As %String(MAXLEN = "") [ InitialExpression = {$SELECT($SYSTEM.Process.CallingRoutine()'="":$SYSTEM.Process.CallingRoutine(),1:$SYSTEM.Process.Routine())}, ReadOnly ];

}
