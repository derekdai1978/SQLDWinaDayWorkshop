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

CREATE DATABASE SCOPED CREDENTIAL DWINADAY
WITH IDENTITY = 'mas',
--SECRET = ‘<Access key for your storage account>’
SECRET = '9kOe50/BBz/JY4jqPe75rgVutUo8h6KFSUbI83mHfJoV7sBYzlp9+CTXv7fchuLldY08edW6deoWkNU7G6e8oA=='
GO

--DROP EXTERNAL DATA SOURCE Ready_store

CREATE EXTERNAL DATA SOURCE Ready_store
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
DATA_SOURCE = [Ready_store],
LOCATION = N'/usgsdata/weatherdata/factWeatherMeasurements/',
FILE_FORMAT = [TextFileFormat_Ready],
REJECT_TYPE = VALUE,
REJECT_VALUE = 0)

Select count(*) from [staging].[STG_factWeatherMeasurements_text]



--===============================
Testing
--===============================

IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'AzureBlobStore')
DROP EXTERNAL DATA SOURCE AzureBlobStore;  
 
go


DROP DATABASE SCOPED CREDENTIAL BLOBCredentialDEV;  

CREATE DATABASE SCOPED CREDENTIAL BLOBCredentialDEV
WITH
    IDENTITY = 'myuser',
    SECRET = 'dRIZB1nQbsIa2pi+o45h1pFRbrNiiAbjMoT3WVlskJf7e9nCwgP9imVFwXm8oG7YYHZyTvWkCZQ/Qxj7UzsdbA=='
;


CREATE EXTERNAL DATA SOURCE USGSWeatherEvents with (  
      TYPE = HADOOP,
      LOCATION ='wasbs://usgsdata@dwdatdstorage.blob.core.windows.net',  
      CREDENTIAL = BLOBCredentialDEV  
);
 

Drop External Table [EXT].[factWeatherMeasurements]
go
DROP EXTERNAL FILE FORMAT TextFileFormat  

CREATE EXTERNAL FILE FORMAT TextFileFormat  
WITH 
(   
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS
    (   
        FIELD_TERMINATOR = '|'
    )
)
GO

CREATE EXTERNAL FILE FORMAT TextFileFormat  
WITH 
(   
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS
    (   
        FIELD_TERMINATOR = '|',
		DATE_FORMAT = 'yyyy-MM-dd',
		USE_TYPE_DEFAULT =  TRUE,
		Encoding = 'UTF8'
    )
)
GO

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
	DATA_SOURCE = USGSWeatherEvents, 
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
	DATA_SOURCE = USGSWeatherEvents, 
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
	DATA_SOURCE = USGSWeatherEvents, 
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
	DATA_SOURCE = USGSWeatherEvents, 
	LOCATION = '/usgsdata/weatherdata/dimWeatherObservationSites/', 
	FILE_FORMAT = TextFileFormat 
); 
 
 select count(*) from [EXT].[dimWeatherObservationSites] 



