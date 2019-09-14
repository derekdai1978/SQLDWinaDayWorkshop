---''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
---  SQL SCRIPT: 99_Reset_Database.sql
---
--- Description: Admin User to reset main content for labs
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

Drop External Table [EXT].[factWeatherMeasurements] 
GO
Drop External Table [EXT].[dimWeatherObservationSites]
GO
Drop External Table [EXT].[dimWeatherObservationTypes]
GO
Drop External Table [EXT].[factWeatherMeasurements]
GO

Drop  Table   [staging].[STG_compressed_text_load] 
GO


Drop  Table   [staging].[STG_CompressedText_single_file]
GO
Drop  Table   [staging].[STG_CompressedText_single_file]
GO
Drop  Table   [staging].[STG_factWeatherMeasurements_Insert_Into]
GO
Drop  Table   [staging].[STG_Hash_ReadingUnit]
GO
Drop  Table   [staging].[STG_parquet_load]
GO
Drop  Table   [staging].[STG_text_load]
GO
DROP EXTERNAL TABLE [staging].[STG_factWeatherMeasurements_parquet]

Drop  Table [dbo].[dimWeatherObservationSites]  
go

Drop  Table [dbo].[dimWeatherObservationSites_repl] 
go

Drop  Table [dbo].[factWeatherMeasurements] 
go