--Open SQL Server Management Studio on your laptop and connect to your SQLDW 
-- instance using the credentials provided during the sign-up.

-- Open a new query window connected to ‘Master’ database (right-click on Master and click ‘New Query’) 
-- and execute the following command:
Create Login usgsloader with PASSWORD = 'Password!1234'

-- Open another query window connected to ‘AdventureWorksDW’ 
-- and execute the following commands:
Create user usgsloader from login usgsloader
EXEC sp_addrolemember 'staticrc60', 'usgsloader'
EXEC sp_addrolemember 'db_ddladmin', 'usgsloader'
EXEC sp_addrolemember 'db_datawriter', 'usgsloader'
EXEC sp_addrolemember 'db_datareader', 'usgsloader'
