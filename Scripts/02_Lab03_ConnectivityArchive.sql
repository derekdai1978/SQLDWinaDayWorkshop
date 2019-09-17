---''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
---  SQL SCRIPT: 02_Lab03_ConnectivityArchive.sql
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


-- A: Create a Database Master Key And Certificate
-- Only necessary if one does not already exist.
-- Required to encrypt the credential secret in the next step.
-- 
-- For more information on Master Key: https://msdn.microsoft.com/library/ms174382.aspx?f=255&MSPPError=-2147217396




-- --CREATE MASTER KEY;

-- IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101 ) --name = '##MS_ServiceMasterKey##') 
-- BEGIN
--   PRINT 'Creating Database Master Key'
--   CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PutYourDemoEncryptionPassword@!!'
-- END
-- ELSE
-- BEGIN
--  PRINT 'Database Master Key Alread Exists'
-- END 
-- GO

--   You may get error message that the “key” is already created.  
--   You still need to run the Master Certificate in the Master Database  
--  ===================================================================
--               Master Certificate - Run In Master
--  =================================================================== 
--drop certificate MyDemoDataSecurityCertificate?
--create our certificate.
IF NOT EXISTS(SELECT *
              FROM   sys.certificates
              WHERE  name = 'AzureDemoDataSecurityCertificate')
  BEGIN
      CREATE CERTIFICATE AzureDemoDataSecurityCertificate WITH SUBJECT = 'AZURE DataSecurity Certificate', EXPIRY_DATE = '12/31/2024'

      PRINT 'AzureDemoDataSecurityCertificate Created'
  END
ELSE
  BEGIN
      PRINT 'AzureDemoDataSecurityCertificate Already Exists.'
  END 

--  ===================================================================
--              Database Scoped Credential - Run In AdventureWorksDW
--  =================================================================== 
-- B: Create a database scoped credential
-- IDENTITY: Pass the client id and OAuth 2.0 Token Endpoint taken from your Azure Active Directory Application
-- SECRET: Provide your AAD Application Service Principal key.
-- For more information on Create Database Scoped Credential: https://msdn.microsoft.com/library/mt270260.aspx
IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'USGSWeatherEvents')
DROP EXTERNAL DATA SOURCE USGSWeatherEvents;  
 
go


--DROP DATABASE SCOPED CREDENTIAL USGSWeatherEvents;  

CREATE DATABASE SCOPED CREDENTIAL USGSWeatherEventsCredential
WITH
    IDENTITY = 'myuser',
    SECRET = '<< Put the key WeatherData Text from BlobKey.txt file here >>'
;


--==============================================================================
-- C: Create an external data source
--==============================================================================

-- LOCATION:  Azure account storage account name and blob container name.  
-- CREDENTIAL: The database scoped credential created above.  
CREATE EXTERNAL DATA SOURCE USGSWeatherEvents with (  
      TYPE = HADOOP,
      LOCATION ='wasbs://usgsdata@dwdatdstorage.blob.core.windows.net',  
      CREDENTIAL = USGSWeatherEventsCredential  
);
 


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


-- Create schema for external tables over Azure Data Lake Store Gen2
CREATE SCHEMA [EXT]
GO

-- Create schema for staging tables after loading
CREATE SCHEMA [STG]
GO
-- Create schema for cleaned production tables
CREATE SCHEMA [PROD]
GO

-- Create schema for cleaned production tables
CREATE SCHEMA [staging]
GO


/*  Clean UP   For Demo Reset

Drop External Table [EXT].[dimUSFIPSCodes]
GO
Drop External Table [EXT].[dimWeatherObservationSites]
GO
Drop External Table [EXT].[dimWeatherObservationTypes]
GO
Drop External Table [EXT].[factWeatherMeasurements]
GO
Drop External Table [staging].[STG_factWeatherMeasurements_CompressedText]
GO
Drop External Table [staging].[STG_factWeatherMeasurements_CompressedText_single_file]
GO
Drop External Table [staging].[STG_factWeatherMeasurements_parquet]
GO
Drop External Table [staging].[STG_factWeatherMeasurements_text]
GO
Drop External Table [dbo].[dimWeatherObservationSites_EXT]
GO






*/

-- Create the External Table
CREATE EXTERNAL TABLE [staging].[STG_factWeatherMeasurements_text]
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

select count(*) from [staging].[STG_factWeatherMeasurements_text] 





--====================================================================================
--  End of lab section.
--====================================================================================
--   Running the rest of the script will create the other tables and datawarehouse
--===================================================================================



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

