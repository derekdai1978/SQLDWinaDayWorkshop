---''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
---  SQL SCRIPT: 03_DataLoadingAsAdminUser.sql
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
--Execute the following TSQLs as the Admin user. 


--While the query above is running, Open another Query windows as admin user and execute

--   Part 1 - Delimited Text 

SELECT s.* 
FROM 
sys.dm_pdw_exec_requests r 
JOIN
Sys.dm_pdw_request_steps s
ON r.request_id = s.request_id
WHERE r.[label] = 'STG_text_load'


--We can see more detailed information about what is happening in this step with the following. 


SELECT ew.* 
FROM[sys].[dm_pdw_dms_external_work] ew 
JOIN sys.dm_pdw_exec_requests r 
ON r.request_id = ew.request_id
JOIN Sys.dm_pdw_request_steps s
ON r.request_id = s.request_id
WHERE r.[label] = 'STG_text_load'
ORDER BY input_name, read_location


--==============================================================
--  Part 2 - Now run as the Parquet files
--==============================================================

--  DROP EXTERNAL FILE FORMAT [Parquet] 

CREATE EXTERNAL FILE FORMAT [Parquet] WITH (FORMAT_TYPE = PARQUET)
GO

-- DROP EXTERNAL TABLE [staging].[STG_factWeatherMeasurements_parquet]

CREATE EXTERNAL TABLE [staging].[STG_factWeatherMeasurements_parquet]
(
	[SiteName] [varchar](52) NOT NULL,
	[ReadinType] [varchar](52) NOT NULL,
	[ReadingTypeID] [real] NOT NULL,
	[ReadingValue] [real] NOT NULL,
	[ReadingTimestamp] [datetime2](7) NOT NULL,
	[ReadingUnit] [varchar](52) NOT NULL,
	[fpscode] [int] NOT NULL
)
WITH (
DATA_SOURCE = AzureBlobStore,
LOCATION = N'/Parquet_files/',
FILE_FORMAT = [Parquet],
REJECT_TYPE = VALUE,
REJECT_VALUE = 0)
GO


--  After running the CREATE TABLE [staging].[STG_parquet_load] in the usgsLoader
-- run these two commands to compare the loading of a text file vs a Parquet file


--We can see more detailed information about what is happening in this step with the following. 


SELECT ew.* 
FROM[sys].[dm_pdw_dms_external_work] ew 
JOIN sys.dm_pdw_exec_requests r 
ON r.request_id = ew.request_id
JOIN Sys.dm_pdw_request_steps s
ON r.request_id = s.request_id
WHERE r.[label] = 'STG_text_load'
ORDER BY input_name, read_location

SELECT DISTINCT ew.* 
FROM[sys].[dm_pdw_dms_external_work] ew 
JOIN sys.dm_pdw_exec_requests r 
ON r.request_id = ew.request_id
JOIN Sys.dm_pdw_request_steps s
ON r.request_id = s.request_id
WHERE r.[label] = 'STG_parquet_load'
ORDER BY  start_time ASC, dms_step_index


--==============================================================
-- Part 3 - GZIP Compressed Delimited Text
--==============================================================

--   Again, let’s go ahead and execute the following statements before discussing 
--    As admin user:


CREATE EXTERNAL FILE FORMAT compressed_TextFileFormat_Ready 
WITH 
(   
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS
    (   
        FIELD_TERMINATOR = '|'
    ), DATA_COMPRESSION = N'org.apache.hadoop.io.compress.GzipCodec'
)
GO

CREATE EXTERNAL TABLE [staging].[STG_factWeatherMeasurements_CompressedText]
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
DATA_SOURCE = AzureBlobStore,
LOCATION = N'/Compressed_Text_files',
FILE_FORMAT = [compressed_TextFileFormat_Ready],
REJECT_TYPE = VALUE,
REJECT_VALUE = 0
)
GO



-- Let’s take a moment and compare performance of the three file formats that we used. 
-- (NOTE: Wait until the CTAS is completed before you execute the statement below)

SELECT AVG(total_elapsed_time) AS [avg_loadTime_ms], [label]
FROM sys.dm_pdw_exec_requests 
WHERE [label] IS NOT NULL 
AND [label] <> 'System' 
AND Status = 'Completed'
GROUP BY [label]



--==============================================================
-- Part 4  Impact of Single File Compression
--==============================================================


-- Let’s take the same data and try to load it from a single compressed Gzip file. 
--  As admin user (sqladmin)
CREATE EXTERNAL TABLE [staging].[STG_factWeatherMeasurements_CompressedText_single_file]
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
DATA_SOURCE = AzureBlobStore,
LOCATION = N'singlefile/Compressed_Text_files',
FILE_FORMAT = [compressed_TextFileFormat_Ready],
REJECT_TYPE = VALUE,
REJECT_VALUE = 0)
GO

As loading user (usgsloader)
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

-- Rerun this command when the Loader query is complete

SELECT AVG(total_elapsed_time) AS [avg_loadTime_ms], [label]
FROM sys.dm_pdw_exec_requests 
WHERE [label] IS NOT NULL 
AND [label] <> 'System' 
AND Status = 'Completed'
GROUP BY [label]



--==============================================================
-- Part 5  - Impact of Table Distribution on loading 
--==============================================================


While this is running, run the following in another query window as admin user (sqldmin):
Select * 
FROM sys.dm_pdw_dms_workers dw
JOIN sys.dm_pdw_exec_requests r 
ON r.request_id = dw.request_id
WHERE r.[label] = 'STG_Hash_ReadingUnit'


-- Once the load is complete
--Execute the following query as admin user (wait until the previous load is completed):
Select avg(total_elapsed_time) as [avg_loadTime_ms], [label]
FROM sys.dm_pdw_exec_requests 
where [label] is not null 
and [label] <> 'System' 
and Status = 'Completed'
GROUP BY [label] order by 1 desc


--==============================================================
-- Part 6 - Impact of CTAS vs Insert into Select 
--==============================================================

-- While loading run Part 6 from the Admin User
-- Wait until the above inserts are completed and execute the following query as admin user:


SELECT avg(total_elapsed_time) as [avg_loadTime_ms], [label]
FROM sys.dm_pdw_exec_requests 
WHERE [label] is not null 
and [label] <> 'System' 
and Status = 'Completed'
GROUP BY [label] ORDER BY 1 DESC
