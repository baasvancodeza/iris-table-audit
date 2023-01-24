# InterSystem IRIS Table Audit
Bbse classes to use on Persistent (table) classes for InterSystems IRIS to keep record history  
These classes enable the historizing of persistent class records into another persistent class when touched.  
This provides for a full history of any record.  
It allows for record rollback to a specific version.  
It can automatically purge old history records.

# Installation
zpm "install csoftsc-persistent-audit"  
The usage sample is available in the GitHub repo  
```
git clone https://github.com/csoft-sc/iris-table-audit.git
```

## Using the Demo
- Clone the repo
- Import the includes and classes and compile
- Open a terminal
  - Change to the namespace where you have installed the package and imported the Demo srouce
  - Run the following  
    ``Do ##class(csoftsc.Demo.RunDemo).Run()``

# Package Structure
| Path | Purpose |
| --- | --- |
| /src/csoftsc/PersistentAudit | Source to use and include in your deployment |
| /src/csoftsc/Demo | A demonstration of usage |

# Usage
## Implementation
- Create a class and extend from csoftsc.PersistentAudit.Base
  - Add all the properties to the class
- Create a second class and extend from csoftsc.PersistentAudit.HistoryBase
  - Add the same properties as you have in the first class.  
  They must align.
  It is recommended to NOT add validation parameters, like MINVAL, or make properties required on the history table. MAXLEN should not be omitted from the history table.  
  It is also not recommended to have Foreign Keys in the hisory table.
- Override the HISTORYTABLECLASS parameter of the first class, and set its value to the name of the second class.
- Compile the second(history) class always prior to the first(main) class.  

### Controlling Historization
To disable the auto historizing of records for a Persistent Class, set the ^PersistentAuditOff("MyPackage.ClassName") to 1  
e.g. ^PersistentAuditOff("csoftsc.Demo.Customer") = 1  
To keep only a specific number of history record, set the ^PersistentAuditAutoPurge("MyPackage.ClassName") to the number of history records to keep  
If not set, or less than or equal to 0, auto archiving will not be done  
e.g. ^PersistentAuditAutoPurge("csoftsc.Demo.Customer") = 2

# Contributors
Stefan Cronje: @Stefan.Cronje1399
