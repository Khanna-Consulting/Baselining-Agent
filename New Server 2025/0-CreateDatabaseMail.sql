/*==========================================================================
-- Purpose: 	Used to create Database Mail in SQL Server 2005

-- Author:	Carolyn Richardson
-- Date:	24/09/2007

-- ***Important***
--	Alter the ServerName to make it clear re which server is sending the mail
==========================================================================*/
-- Replace "ReplaceThisWithServerInstanceNameToken@vita" with "Server name" and the "VITA" with The "Agency Initials".
--Reconfigure the server to allow email
use master
go
sp_configure 'show advanced options',1
go
reconfigure with override
go
sp_configure 'Database Mail XPs',1

reconfigure
go
--This part added by Chris Stamey due to error encountered when trying to run this script.
ALTER DATABASE MSDB
SET single_user WITH ROLLBACK IMMEDIATE
GO --So you can run both statements at the same time.
ALTER DATABASE MSDB
SET multi_user WITH ROLLBACK IMMEDIATE
Go
ALTER DATABASE msdb SET ENABLE_BROKER

/*Add Service Account Permission
As an extra security feature SQL Server 2005 uses a role with specific permissions in the MSDB database, not even system administrators can use the mail feature without being a member of this role.  So you need to either add the specific account that runs SQL Server to this role, or add all administers:-
*/

EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'SMTPMailAccount',
    @description = 'ReplaceThisWithServerInstanceNameToken',
    @email_address = 'ReplaceThisWithServerInstanceNameToken@cov.Virginia.gov',--ALTER HERE
    @display_name = 'ReplaceThisWithServerInstanceNameToken SQLServer', --Alter Here.
    @use_default_credentials = 0,
    @mailserver_name = 'csmtp.cov.virginia.gov' --ALTER HERE

/*
If you look at the propertities you may want to altert the anonymous login to SQL Server authentication.
Create Mail Profile

The next  component of the configuration requires the creation of a Mail profile.

We are going to create "ServernamMailProfile" using the sysmail_add_profile procedure to create a Database Mail profile.

For help on options use sp_helptext sysmail_add_profile_sp
*/

EXECUTE msdb.dbo.sysmail_add_profile_sp
       @profile_name = 'Default',
       @description = 'Profile used for database mail'

/*
Add Account Profile

Now execute the sysmail_add_profileaccount procedure, to add the Database Mail account usding the Database Mail profile you created in last step

For help on options use sp_helptext sysmail_add_profileaccount_sp
*/
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'Default',
    @account_name = 'SMTPMailAccount',
    @sequence_number = 1

/*Set default Profile
Use the sysmail_add_principalprofile procedure to grant the Database Mail profile access to the msdb public database role and to make the profile the default Database Mail profile.

For help on options use sysmail_add_principalprofile_sp
*/
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'Default',
    @principal_name = 'public',
    @is_default = 1 ;

--Set SQL Agent options for mail.
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1
GO
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail', N'REG_DWORD', 1

/*To send a test email from SQL Server. Execute the statement below.*/

declare @body1 varchar(100)
set @body1 = 'Server: '+@@servername+ ' My First Database Email '
EXEC msdb.dbo.sp_send_dbmail @recipients='CESC-DBA@vita.virginia.gov', --ALTER HERE
    @subject = 'SQL Server Mail Test',
    @body = @body1,
	@body_format = 'HTML' ;
--CESC-DBA@vita.virginia.gov

USE [msdb]
GO
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', N'Default'
GO
USE [msdb]
GO
EXEC master.dbo.sp_MSsetalertinfo @failsafeoperator=N'CESC-DBA',
		@notificationmethod=1
GO
