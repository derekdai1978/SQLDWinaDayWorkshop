---''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
---  SQL SCRIPT: 03_DataLoadingAsLoadingUser.sql
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

--==============================================================
-- Part 1 - Delimited Text
--==============================================================


CREATE TABLE [staging].[STG_text_load]
WITH
(
DISTRIBUTION = ROUND_ROBIN,
HEAP
)
AS 
SELECT * FROM [staging].[STG_factWeatherMeasurements_text] option(label = 'STG_text_load')


SELECT count(*) FROM [staging].[STG_text_load]

--==============================================================
--  Part 2 - Now run as the Parquet files after the Setup in the Admin user's tab
--==============================================================

CREATE TABLE [staging].[STG_parquet_load]
WITH
(
DISTRIBUTION = ROUND_ROBIN,
HEAP
)
AS
SELECT *  
FROM [staging].[STG_factWeatherMeasurements_parquet]
OPTION (label = 'STG_parquet_load')
GO



--==============================================================
-- Part 3 - GZIP Compressed Delimited Text
--==============================================================
--As load user (usgsLoader)

CREATE TABLE [staging].[STG_compressed_text_load]
WITH
(
DISTRIBUTION = ROUND_ROBIN,
HEAP
)
AS
SELECT *  
FROM [staging].[STG_factWeatherMeasurements_CompressedText]
OPTION (label = 'STG_compressed_text_load')
GO




--==============================================================
-- Part 4  Impact of Single File Compression
--==============================================================
-- Let’s take the same data and try to load it from a single compressed Gzip file. 
--  As admin user (sqladmin)

--  As loading user (usgsloader)


CREATE TABLE [staging].[STG_CompressedText_single_file]
WITH 
(
DISTRIBUTION = ROUND_ROBIN, HEAP
)
AS 
SELECT *
FROM [staging].[STG_factWeatherMeasurements_CompressedText_single_file] 
OPTION(label = 'STG_single_compressed_load')
GO



--==============================================================
-- Part 5  - Impact of Table Distribution on loading 
--==============================================================

CREATE TABLE [staging].[STG_Hash_ReadingUnit]
WITH
(
DISTRIBUTION = HASH(ReadingUnit),
HEAP
)
AS
SELECT *  
FROM [staging].[STG_factWeatherMeasurements_CompressedText]
OPTION (label = 'STG_Hash_ReadingUnit')

--==============================================================
-- Part 6 - Impact of CTAS vs Insert into Select 
--==============================================================

-- After load complete run Part 6 from the Admin User

CREATE TABLE [staging].[STG_factWeatherMeasurements_Insert_Into]
(
	[SiteName] [varchar](52) NOT NULL,
	[ReadinType] [varchar](52) NOT NULL,
	[ReadingTypeID] [real] NOT NULL,
	[ReadingValue] [real] NOT NULL,
	[ReadingTimestamp] [datetime2](7) NOT NULL,
	[ReadingUnit] [varchar](52) NOT NULL,
	[fpscode] [int] NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
GO 

INSERT INTO [staging].[STG_factWeatherMeasurements_Insert_Into] SELECT  * FROM [staging].[STG_factWeatherMeasurements_text] option (label = 'STG_insertInto')
GO

INSERT INTO [staging].[STG_factWeatherMeasurements_Insert_Into] 
	SELECT  * FROM [staging].[STG_factWeatherMeasurements_text] option (label = 'STG_insertInto_two')
GO
