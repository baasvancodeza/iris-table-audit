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

## Running the Demo

### Using Docker Compose
- Clone the repo
- Go nto your terminal of choice into the project directory
- Build the container
  ```
  docker-compose build
  ```
- Start the container
  ```
  docker-compose up -d
  ```
- Open an IRIS session on the running container instance
  ```
  docker-compose exec iris iris session iris -U IRISAPP
  ```
- Run the following  
  ```
  Do ##class(csoftsc.Demo.RunDemo).Run()
  ```
- To go tot he Mangement Portal to run SQL queries on the tables go to below. Remember to replace the "hostname-or-ip with your computer's IP or hostname  
  http://hostname-or-ip:9081/csp/sys/UtilHome.csp
  

### From Source

- Clone the repo
- Import the includes and classes and compile
  - csoftsc.PersistentAudit first
  - csoftsc.Demo second
- Open a terminal
  - Change to the namespace where you have imported the package and imported the Demo srouce
  - Run the following  
    ```
    Do ##class(csoftsc.Demo.RunDemo).Run()
    ```

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
    - They must align.
    - It is recommended to NOT do the following in the History class
      - Add validation parameters, like MINVAL, or make properties required. MAXLEN is an exception and should not be omitted from the history table.  
      - Have Foreign Keys in the hisory table. You can have the reference property, but omit the "ForeignKey".
- Override the HISTORYTABLECLASS parameter of the first class, and set its value to the name of the second class.
- Compile the second(history) class always prior to the first(main) class.  

### Trigger Information and Order

The generated triggers are set to run on row/object, which means it applies to Object-level and SQL operations.  
The triggers are orderred at number 10, which means you can still let your own triggers execute before or after the historization triggers.

### Controlling Historization

To disable the auto historizing of records for a Persistent Class, set the __^PersistentAuditOff("MyPackage.ClassName")__ to 1  
e.g. ``^PersistentAuditOff("csoftsc.Demo.Customer") = 1  ``
To keep only a specific number of history records, set the __^PersistentAuditAutoPurge("MyPackage.ClassName")__ to the number of history records to keep  
If not set, or tod less than or equal to 0, auto archiving will not be done.  
e.g. ``^PersistentAuditAutoPurge("csoftsc.Demo.Customer") = 2``

### Record Restore (Rollback)

The class that extends from the base will contain two class methods that are available as Stored Procedures as well.
- RestoreVersion. Example:  
  ``Set tSuccess = ##class(csoftsc.Demo.Customer).RestoreVersion(tCust.%Id(),4)``
- RestorePreviousVersion. Example:  
  ``&sql(:tSuccess = call csoftsc_Demo.Customer_RestorePreviousVersion(:tId))``

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/intersystems/TestCoverage/tags).

## Authors

* **Stefan Cronje** - *Initial implementation* - [cssoft-sc](http://github.com/csoft-sc)  
  InterSystem Communitry: @Stefan.Cronje1399

See also the list of [contributors](https://github.com/csoft-sc/iris-table-audit/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.