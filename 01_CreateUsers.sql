---''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
---  SQL SCRIPT: 01_CreateUsers.sql
---
--- Description: Create Loading Users
---		 
---
--- Parameters :   
---
---
--- Date               Developer            Action
--- ---------------------------------------------------------------------
--- Aug 10, 2019       Steve Young          Writing And Development
---
---
---
/*

*/

--================================================================
--     Clean up and start fresh
--================================================================


/*
This script is given "As Is" with no warranties and plenty of caveats. Use at your own risk!

*/
-----------------------------------------------------------------------
-- User-defined variables
-----------------------------------------------------------------------

--Open SQL Server Management Studio on your laptop and connect to your SQLDW instance using the credentials provided during the sign-up.

--Open a new query window connected to ‘Master’ database (right-click on Master and click ‘New Query’) 
--and execute the following command:

Create Login usgsloader with PASSWORD = 'Password!1234'

--Open another query window connected to ‘AdventureWorksDW’ and execute the following commands:

Create user usgsloader from login usgsloader
EXEC sp_addrolemember 'staticrc60', 'usgsloader'
EXEC sp_addrolemember 'db_ddladmin', 'usgsloader'
EXEC sp_addrolemember 'db_datawriter', 'usgsloader'
EXEC sp_addrolemember 'db_datareader', 'usgsloader'

EXEC sp_addrolememter 'db_owner', 'usgsloader'

ALTER ROLE dbmanager ADD MEMBER 'usgsloader'; 

ALTER ROLE db_owner ADD MEMBER 'usgsloader'; ;

GRANT CONTROL ON DATABASE::[RebeccaDW]to usgsloader;
EXEC sp_addrolemember 'staticrc60', 'LoaderRC60';

GRANT CONTROL ON DATABASE::[RebeccaDW]  to usgsloader;
GRANT CONTROL ON DATABASE::[RebeccaDW]  to LabAdministrator;



Create user LabAdministrator from login LabAdministrator
EXEC sp_addrolemember 'staticrc60', 'LabAdministrator'
EXEC sp_addrolemember 'db_ddladmin', 'LabAdministrator'
EXEC sp_addrolemember 'db_datawriter', 'LabAdministrator'
EXEC sp_addrolemember 'db_datareader', 'LabAdministrator'
