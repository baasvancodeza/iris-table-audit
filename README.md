# InterSystem IRIS Table Audit
Persistent Bbse classes for InterSystems IRIS to keep record history  
These classes enable the historizing of persistent class records into another persistent class when touched.  
This provides for a full history of any record.

# Installation
zpm "install csoftsc-persistent-audit"  
The usage sample is available on the GitHub repo  
```
git clone https://github.com/csoft-sc/iris-table-audit.git
```

## Using the Demo
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
- Override the HISTORYTABLECLASS parameter of the first class, and set its value to the name of the second class.
- Compile the second(history) class always prior to the first(main) class.
 
## Getting the record history
- Get the ID value of the record you want the history for.
- In terminal or code  
  ``Set tDataStream = ##class(My.FirstClass).GetTimeLineDeltaJSON({ID VALUE},.tSC)``  
  ``Do tDataStream.Rewind()``  
  ``w tDataStream.Read()``

# Contributors
Stefan Cronje: @Stefan.Cronje1399
