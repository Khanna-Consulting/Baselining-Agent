-- change #14d changed to backup compression for default
USE [master]
GO
EXEC sys.sp_configure N'backup compression default', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @cpu_poller_enabled=1
GO
