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

--Open a new query window connected to �Master� database (right-click on Master and click �New Query�) 
--and execute the following command:

/****** Object:  Login [usgsloader]    Script Date: 8/27/2019 5:21:26 PM ******/
DROP LOGIN [usgsloader]


Create Login usgsloader with PASSWORD = 'Password!1234'

--Open another query window connected to �AdventureWorksDW� and execute the following commands:

Create user usgsloader from login usgsloader
EXEC sp_addrolemember 'staticrc60', 'usgsloader'
EXEC sp_addrolemember 'db_ddladmin', 'usgsloader'
EXEC sp_addrolemember 'db_datawriter', 'usgsloader'
EXEC sp_addrolemember 'db_datareader', 'usgsloader'
