-- Replace The user's name and email account with the new information
-- Stephen.Curry@abc.virginia.gov
-- Stephen.Curry'

USE [msdb]
GO
EXEC msdb.dbo.sp_add_operator @name=N'Stephen.Curry',
		@enabled=1,
		@pager_days=0,
		@email_address=N'Stephen.Curry@abc.virginia.gov'
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'825Error-TransientCorruption', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Insufficent Permissions', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Sev19Alert', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Sev20Alert', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Sev21Alert', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Sev22Alert', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Sev23Alert', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Sev24Alert', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'Sev25Alert', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'SlowIORequests', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'SQLMemPageOut', @operator_name=N'Stephen.Curry', @notification_method = 1
GO
