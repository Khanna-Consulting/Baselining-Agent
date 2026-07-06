--You must specify operators and the response after runing this script.
--Chris Stamey, 2-27-2009 Replace 'ReplaceThisWithServerInstanceNameToken' With Current SQL Server name
USE [msdb]
GO
/****** Object:  Alert [825Error-TransientCorruption]    Script Date: 02/27/2009 09:51:19 ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'825Error-TransientCorruption')
EXEC msdb.dbo.sp_delete_alert @name=N'825Error-TransientCorruption'
EXEC msdb.dbo.sp_add_alert @name=N'825Error-TransientCorruption',
		@message_id=825,
		@severity=0,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken - This means that an 823, Hard I/O error, or 824, Soft I/O error, has occured but SQL Server was able to retry and read the data. You will want to investigate corruption IMMEDIATELY. Check the MSDB.dbo.suspect_pages table.',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Sev19Alert')
EXEC msdb.dbo.sp_add_alert @name=N'Sev19Alert',
		@message_id=0,
		@severity=19,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'

/****** Object:  Alert [Sev20Alert]    Script Date: 03/04/2009 08:43:24 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Sev20Alert')
EXEC msdb.dbo.sp_add_alert @name=N'Sev20Alert',
		@message_id=0,
		@severity=20,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken Fatal Error in Resourse',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'

/****** Object:  Alert [Sev21Alert]    Script Date: 03/04/2009 08:43:47 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Sev21Alert')
EXEC msdb.dbo.sp_add_alert @name=N'Sev21Alert',
		@message_id=0,
		@severity=21,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken Fatal Error in Database Process',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'

IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Sev22Alert')
EXEC msdb.dbo.sp_add_alert @name=N'Sev22Alert',
		@message_id=0,
		@severity=22,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken Database Table Suspect',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'

/****** Object:  Alert [Sev23Alert]    Script Date: 03/04/2009 08:44:16 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Sev23Alert')
EXEC msdb.dbo.sp_add_alert @name=N'Sev23Alert',
		@message_id=0,
		@severity=23,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken SUSPECT DATABASE',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'

/****** Object:  Alert [Sev24Alert]    Script Date: 03/04/2009 08:44:31 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Sev24Alert')
EXEC msdb.dbo.sp_add_alert @name=N'Sev24Alert',
		@message_id=0,
		@severity=24,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken Fatal Hardware Error',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'

/****** Object:  Alert [Sev25Alert]    Script Date: 03/04/2009 08:44:46 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Sev25Alert')
EXEC msdb.dbo.sp_add_alert @name=N'Sev25Alert',
		@message_id=0,
		@severity=25,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'SQLMemPageOut')
EXEC msdb.dbo.sp_add_alert @name=N'SQLMemPageOut',
		@message_id=0,
		@severity=1,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken',
		@event_description_keyword=N'A significant part of sql server process memory has been paged out',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'SlowIORequests')
EXEC msdb.dbo.sp_add_alert @name=N'SlowIORequests',
		@message_id=0,
		@severity=1,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken',
		@event_description_keyword=N'occurrence(s) of I/O requests taking longer than 15 seconds',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
USE [msdb]
IF NOT EXISTS (SELECT name FROM msdb.dbo.sysalerts WHERE name = N'Insufficent Permissions')
EXEC msdb.dbo.sp_add_alert @name=N'Insufficent Permissions',
		@message_id=0,
		@severity=14,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'ReplaceThisWithServerInstanceNameToken',
		@event_description_keyword=N'Insufficent Permissions',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
/****** Object:  Alert [Sev17Alert]    Script Date: 10/17/2018 7:13:01 AM ******/
EXEC msdb.dbo.sp_add_alert @name=N'Sev17Alert',
		@message_id=0,
		@severity=17,
		@enabled=1,
		@delay_between_responses=600,
		@include_event_description_in=1,
		@notification_message=N'Resource alert check the server logs.',
		@category_name=N'[Uncategorized]',
		@job_id=N'00000000-0000-0000-0000-000000000000'
