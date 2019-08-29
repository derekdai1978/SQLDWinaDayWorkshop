---''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
---  SQL SCRIPT: 03_DataLoadingScenarios.sql
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
-- Grant limited access to Azure Storage resources using shared access signatures (SAS)
-- https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview
-- CREATE DATABASE SCOPED CREDENTIAL (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-database-scoped-credential-transact-sql?view=sql-server-2017
-- Create Database Scoped Credential: 
-- https://msdn.microsoft.com/library/mt270260.aspx
-- Shared Access Signatures cannot be used with Polybase
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-database-scoped-credential-transact-sql?view=sql-server-2017 
-- Manage anonymous read access to containers and blobs
-- https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources
-- Use PolyBase to read Blob Storage in Azure SQL DW
-- https://microsoft-bitools.blogspot.com/2017/08/use-polybase-to-read-blob-storage-in.html
/*
This script is given "As Is" with no warranties and plenty of caveats. Use at your own risk!

*/
-----------------------------------------------------------------------
-- User-defined variables
-----------------------------------------------------------------------

--Select New Query and verify that AdventureWorksDW is the selected database.
--Execute the following TSQLs as admin user (sqladmin)
CREATE MASTER KEY
GO

--DROP DATABASE SCOPED CREDENTIAL DWINADAY; 

--If you have already created an external data source, you cannot drop or re-create
-- a credential that is in use, so you have to drop the data source first.

IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'AzureBlobStore')
DROP EXTERNAL DATA SOURCE AzureBlobStore;  
 
go

-- DROP DATABASE SCOPED CREDENTIAL DWINADAY;  

CREATE DATABASE SCOPED CREDENTIAL DWINADAY
WITH
    IDENTITY = 'myuser',
	--SECRET = ‘<Access key for your storage account>’
    SECRET = '9kOe50/BBz/JY4jqPe75rgVutUo8h6KFSUbI83mHfJoV7sBYzlp9+CTXv7fchuLldY08edW6deoWkNU7G6e8oA=='
;


CREATE EXTERNAL DATA SOURCE AzureBlobStore
WITH 
(
TYPE = HADOOP, 
--LOCATION = N'wasbs://usgs@<your storage account name>.blob.core.windows.net/', 
LOCATION = N'wasbs://usgsdata@dwlabwalkthorugh.blob.core.windows.net/', 
CREDENTIAL = DWINADAY
)
GO

--Create an external TextFileFormat

-- DROP EXTERNAL FILE FORMAT TextFileFormat_Ready 

CREATE EXTERNAL FILE FORMAT TextFileFormat_Ready 
WITH 
(   
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS
    (   
        FIELD_TERMINATOR = '|'
    )
)
GO


-- The next thing that we need to do is create an external table over the files 
--  so that we can access the data from SQL DW


CREATE SCHEMA staging;
GO

CREATE EXTERNAL TABLE [staging].[STG_factWeatherMeasurements_text]
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
LOCATION = N'/usgsdata/weatherdata/factWeatherMeasurements/',
FILE_FORMAT = [TextFileFormat_Ready],
REJECT_TYPE = VALUE,
REJECT_VALUE = 0)

-- By running this command, all the files are used to create the external table
-- The location is a wild card, so all files and directories are used
-- Make sure that you only have the files in the specified directory

Select count(*) from [staging].[STG_factWeatherMeasurements_text]
--Result should be the number of records, around 134333511 if all worked well
--If one file is bad, the Select Count() will fail.



--  Extra Credit

--===============================
-- As an extra, running the rest of the script will create the Fact Measurements External Tables
--===============================


-- Create schema for external tables over Azure Data Lake Store Gen2
CREATE SCHEMA [EXT]

-- Create schema for staging tables after loading
CREATE SCHEMA [STG]

-- Create schema for cleaned production tables
CREATE SCHEMA [PROD]


/*  Clean UP   


Drop External Table [EXT].[factWeatherMeasurements] 
go
Drop External Table [EXT].[dimWeatherObservationSites]
go
Drop External Table [EXT].[dimWeatherObservationTypes]
go
Drop External Table [EXT].[dimUSFIPSCodes] 
go
*/






CREATE EXTERNAL TABLE [EXT].[factWeatherMeasurements] 
( 
	[StationId] [nvarchar](12) NOT NULL, 
	[ObservationTypeCode] [nvarchar](4) NOT NULL, 
	[ObservationValueCorrected] [real] NOT NULL, 
	[ObservationValue] [real] NOT NULL, 
	[ObservationDate] [date] NOT NULL, 
	[ObservationSourceFlag] [nvarchar](2) NULL, 
	[fipscountycode] [varchar](5) NULL 
) 
WITH 
( 
	DATA_SOURCE = AzureBlobStore, 
	LOCATION = '/usgsdata/weatherdata/factWeatherMeasurements/', 
	FILE_FORMAT = TextFileFormat 
); 

select count(*) from [EXT].[factWeatherMeasurements] 



--dimWeatherObservationTypes 
CREATE EXTERNAL TABLE [EXT].[dimWeatherObservationTypes] 
( 
	[ObservationTypeCode] [nvarchar](5) NOT NULL, 
	[ObservationTypeName] [nvarchar](100) NOT NULL, 
	[ObservationUnits] [nvarchar](5) NULL 
) 
WITH 
( 
	DATA_SOURCE = AzureBlobStore, 
	LOCATION = '/usgsdata/weatherdata/dimWeatherObservationTypes/', 
	FILE_FORMAT = TextFileFormat 
); 

select count(*) from [EXT].[dimWeatherObservationTypes] 

 
--dimUSFIPSCodes 
CREATE EXTERNAL TABLE [EXT].[dimUSFIPSCodes] 
( 
	[FIPSCode] [varchar](5) NOT NULL, 
	[StateFIPSCode] [smallint] NOT NULL, 
	[CountyFIPSCode] [smallint] NOT NULL, 
	[StatePostalCode] [varchar](2) NOT NULL, 
	[CountyName] [varchar](35) NOT NULL, 
	[StateName] [varchar](30) NOT NULL 
) 
WITH 
( 
	DATA_SOURCE = AzureBlobStore, 
	LOCATION = '/usgsdata/weatherdata/dimUSFIPSCodes/', 
	FILE_FORMAT = TextFileFormat 
); 
 

 select count(*) from [EXT].[dimUSFIPSCodes] 

--dimWeatherObservationSites 
CREATE EXTERNAL TABLE [EXT].[dimWeatherObservationSites] 
( 
	[StationId] [nvarchar](20) NOT NULL, 
	[SourceAgency] [nvarchar](10) NOT NULL, 
	[StationName] [nvarchar](150) NULL, 
	[CountryCode] [varchar](2) NULL, 
	[CountryName] [nvarchar](150) NULL, 
	[StatePostalCode] [varchar](3) NULL, 
	[FIPSCountyCode] [varchar](5) NULL, 
	[StationLatitude] [decimal](11, 8) NULL, 
	[StationLongitude] [decimal](11, 8) NULL, 
	[NWSRegion] [nvarchar](30) NULL, 
	[NWSWeatherForecastOffice] [nvarchar](20) NULL, 
	[GroundElevation_Ft] [real] NULL, 
	[UTCOffset] [nvarchar](10) NULL 
	) 
WITH 
( 
	DATA_SOURCE = AzureBlobStore, 
	LOCATION = '/usgsdata/weatherdata/dimWeatherObservationSites/', 
	FILE_FORMAT = TextFileFormat 
); 
 
 select count(*) from [EXT].[dimWeatherObservationSites] 






 /*-- CTAS External Tables into Staging Tables --*/

 
--Weather Data
--factWeatherMeasurements
CREATE TABLE [STG].[factWeatherMeasurements]
WITH
(
	CLUSTERED COLUMNSTORE INDEX,
	DISTRIBUTION = ROUND_ROBIN
)
AS SELECT * FROM [EXT].[factWeatherMeasurements] OPTION(label = 'load_weatherfact');

--dimWeatherObservationTypes
CREATE TABLE [STG].[dimWeatherObservationTypes]
WITH
(
	CLUSTERED COLUMNSTORE INDEX,
	DISTRIBUTION = ROUND_ROBIN
)
AS SELECT * FROM [EXT].[dimWeatherObservationTypes] OPTION(label = 'load_weatherobservationtypes');

--dimUSFIPSCodes
CREATE TABLE [STG].[dimUSFIPSCodes]
WITH
(
	CLUSTERED COLUMNSTORE INDEX,
	DISTRIBUTION = ROUND_ROBIN
)
AS SELECT * FROM [EXT].[dimUSFIPSCodes] OPTION(label = 'load_fips');

--dimWeatherObservationSites
CREATE TABLE [STG].[dimWeatherObservationSites]
WITH
(
	CLUSTERED COLUMNSTORE INDEX,
	DISTRIBUTION = ROUND_ROBIN
)
AS SELECT * FROM [EXT].[dimWeatherObservationSites] OPTION(label = 'load_weatherobservationsites');

