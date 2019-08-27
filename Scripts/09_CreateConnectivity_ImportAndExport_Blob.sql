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
--     References
--================================================================
-- Grant limited access to Azure Storage resources using shared access signatures (SAS)
-- https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview
-- CREATE DATABASE SCOPED CREDENTIAL (Transact-SQL)
-- https://docs.microsoft.com/en-us/sql/t-sql/statements/create-database-scoped-credential-transact-sql?view=sql-server-2017
-- Create Database Scoped Credential: 
-- https://msdn.microsoft.com/library/mt270260.aspx
-- Shared Access Signatures cannot be used with Polybase
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


-- A: Create a Database Master Key.
-- Only necessary if one does not already exist.
-- Required to encrypt the credential secret in the next step.
-- For more information on Master Key: https://msdn.microsoft.com/library/ms174382.aspx?f=255&MSPPError=-2147217396

--CREATE MASTER KEY;

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE symmetric_key_id = 101 ) --name = '##MS_ServiceMasterKey##') 
BEGIN
  PRINT 'Creating Database Master Key'
  CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'PutYourDemoEncryptionPassword@!!'
END
ELSE
BEGIN
 PRINT 'Database Master Key Alread Exists'
END 

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


-- B: Create a database scoped credential
-- IDENTITY: Pass the client id and OAuth 2.0 Token Endpoint taken from your Azure Active Directory Application
-- SECRET: Provide your AAD Application Service Principal key.
-- For more information on Create Database Scoped Credential: https://msdn.microsoft.com/library/mt270260.aspx
IF EXISTS (SELECT * FROM sys.external_data_sources WHERE name = 'AzureBlobStore')
DROP EXTERNAL DATA SOURCE AzureBlobStore;  
 
go


DROP DATABASE SCOPED CREDENTIAL BLOBCredentialDEV;  

CREATE DATABASE SCOPED CREDENTIAL BLOBCredentialDEV
WITH
    IDENTITY = 'myuser',
    SECRET = 'dRIZB1nQbsIa2pi+o45h1pFRbrNiiAbjMoT3WVlskJf7e9nCwgP9imVFwXm8oG7YYHZyTvWkCZQ/Qxj7UzsdbA=='
;
--Enter the Authorization endpoint URL. For Azure Active Directory, this URL will be similar to the following URL, 
--where <client_id> is replaced with the client id that identifies your application to the OAuth 2.0 server.
--ttps://login.microsoftonline.com/<client_id>/oauth2/authorize
-- It should look something like this:
--https://login.microsoftonline.com/<client_id>/oauth2/authorize
--client_id  required The Application ID assigned to your app when you registered it with Azure AD. You can find this in the Azure Portal. Click Azure Active Directory in the services sidebar, click App registrations, and choose the application.
--https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-protocols-oauth-code
--CREATE DATABASE SCOPED CREDENTIAL ADLCredential
--WITH
--    IDENTITY = 'myuser',
--    SECRET = 'BjdIlmtKp4Fpyh9hIvr8HJlUida/seM5kQ3EpLAmeDI='
;

-- C: Create an external data source
-- TYPE: HADOOP - PolyBase uses Hadoop APIs to access data in Azure Data Lake Store.
-- LOCATION: Provide Azure Data Lake accountname and URI
-- CREDENTIAL: Provide the credential created in the previous step.


-- Option 7: Azure blob storage (WASB[S])
--sp_configure 'Hadoop connectivity', 7
--Reconfigure

-- LOCATION:  Azure account storage account name and blob container name.  
-- CREDENTIAL: The database scoped credential created above.  
CREATE EXTERNAL DATA SOURCE USGSWeatherEvents with (  
      TYPE = HADOOP,
      LOCATION ='wasbs://usgsdata@dwdatdstorage.blob.core.windows.net',  
      CREDENTIAL = BLOBCredentialDEV  
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

-- Create schema for staging tables after loading
CREATE SCHEMA [STG]

-- Create schema for cleaned production tables
CREATE SCHEMA [PROD]


/*  Clean UP   


Drop External Table [EXT].[factWeatherMeasurements] 
Drop External Table [EXT].[dimWeatherObservationSites]
Drop External Table [EXT].[dimWeatherObservationTypes]
Drop External Table [EXT].[factWeatherMeasurements]
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




--- Create external tables in different formats
https://www.ben-morris.com/polybase-import-and-export-between-azure-sql-data-warehouse-and-blob-storage/

-- Create an external table with location etc


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


CREATE EXTERNAL TABLE [EXT].[factWeatherMeasurements_Exported] 
WITH 
( 
	DATA_SOURCE = USGSWeatherEvents, 
	LOCATION = '/usgsdata/weatherdata/factWeatherMeasurements/Compressed_Text_files', 
	FILE_FORMAT = [compressed_TextFileFormat_Ready]
)
as
Select 
	[StationId], 
	[ObservationTypeCode],
	[ObservationValueCorrected], 
	[ObservationValue],
	[ObservationDate],
	[ObservationSourceFlag],
	[fipscountycode]
	From [STG].[factWeatherMeasurements]



-- As load user (usgsLoader)

CREATE TABLE [STG].[STG_compressed_text_load]
WITH
(
DISTRIBUTION = ROUND_ROBIN,
HEAP
)
AS
SELECT *  
FROM [EXT].[factWeatherMeasurements_Exported] 
OPTION (label = 'STG_compressed_text_load')



CREATE EXTERNAL FILE FORMAT [Parquet] WITH (FORMAT_TYPE = PARQUET)
GO



CREATE EXTERNAL TABLE [EXT].[factWeatherMeasurements_ExportedParquet] 
WITH 
( 
	DATA_SOURCE = USGSWeatherEvents, 
	LOCATION = '/usgsdata/weatherdata/factWeatherMeasurements/Parquet_files', 
	FILE_FORMAT = [Parquet]
)
as
Select 
	[StationId], 
	[ObservationTypeCode],
	[ObservationValueCorrected], 
	[ObservationValue],
	[ObservationDate],
	[ObservationSourceFlag],
	[fipscountycode]
	From [STG].[factWeatherMeasurements]



--Execute the following CTAS as load user (usgsLoader)
-- Reload the table

CREATE TABLE [STG].[STG_parquet_load]
WITH
(
DISTRIBUTION = ROUND_ROBIN,
HEAP
)
AS
SELECT *  
FROM [EXT].[factWeatherMeasurements_ExportedParquet]
OPTION (label = 'STG_parquet_load')
GO


