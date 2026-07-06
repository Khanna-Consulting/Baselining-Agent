/* Add extended Attributes to MSDB Database:
Agency Change: to
Contact Change: to
Note: Change to Change to Description of the application
Application Server:List the servers that connect to the SQL server database
Microsoft SQL Version:
GO

Place holder for more than on database as appropriate: MSDB
*/
Use MSDB
Go

EXEC [MSDB].sys.sp_addextendedproperty @name=N'Agency: ',
@value=N'ReplaceWithAgencyDetails'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Contact: ' , NULL,NULL, NULL,NULL, NULL,NULL))
EXEC [MSDB].sys.sp_addextendedproperty @name=N'Contact:',
@value=N'ReplaceWithContactDetails'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Note: ' , NULL,NULL, NULL,NULL, NULL,NULL))
EXEC [MSDB].sys.sp_addextendedproperty @name=N'Note: ',
@value=N'ReplaceWithAppropriateNotes'
GO
IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Application Server: ' , NULL,NULL, NULL,NULL, NULL,NULL))
EXEC [MSDB].sys.sp_addextendedproperty @name=N'Application Server: ',
@value=N'ReplaceWithApplicationServer'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Application Name: ' , NULL,NULL, NULL,NULL, NULL,NULL))
EXEC [MSDB].sys.sp_addextendedproperty @name=N'Application Name: ',
@value=N'ReplaceWithApplicationName'
GO

IF NOT EXISTS (SELECT * FROM ::fn_listextendedproperty(N'Microsoft_Management_Utility_Version: ' , NULL,NULL, NULL,NULL, NULL,NULL))
EXEC [MSDB].sys.sp_addextendedproperty @name=N'Microsoft SQL Version: ',
@value=N'ReplaceWithSqlVersion'
GO
--- EXECUTE THIS AFTER RUNNING THE ABOVE

USE MSDB;
GO
SELECT name, value
FROM fn_listextendedproperty(default, default, default, default, default, default, default);
GO
