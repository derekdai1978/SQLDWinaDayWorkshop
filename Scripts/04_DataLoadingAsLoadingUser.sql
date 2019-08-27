---''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
---  SQL SCRIPT: 04_DataLoadingAsLoadingUser.sql
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
--     References
--================================================================

/*
This script is given "As Is" with no warranties and plenty of caveats. Use at your own risk!

*/
-----------------------------------------------------------------------
-- User-defined variables
-----------------------------------------------------------------------

--Select New Query and verify that AdventureWorksDW is the selected database.
--Execute the following TSQLs as the USGSLOADER user.  Remember to change the 
-- SSMS connection default database to AdventureWorksDW

CREATE TABLE [staging].[STG_text_load]
WITH
(
DISTRIBUTION = ROUND_ROBIN,
HEAP
)
AS 
SELECT * FROM [staging].[STG_factWeatherMeasurements_text] option(label = 'STG_text_load')



--While the query above is running, Open another Query windows as admin user and execute

SELECT s.* 
FROM 
sys.dm_pdw_exec_requests r 
JOIN
Sys.dm_pdw_request_steps s
ON r.request_id = s.request_id
WHERE r.[label] = 'STG_text_load'
