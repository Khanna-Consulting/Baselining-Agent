-- Script generated on 12-6-2004 3:22 PM
-- By: Chris Stamey
-- CHANGE: NumErrorLogs updated from 07 to 30 (baseline control 5.1 requires >= 12)

BEGIN TRANSACTION
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'Database Maintenance') < 1
  EXECUTE msdb.dbo.sp_add_category @name = N'Database Maintenance'

  -- Delete the job with the same name (if it exists)
  SELECT @JobID = job_id
  FROM   msdb.dbo.sysjobs
  WHERE (name = N'CycleErrorlog')
  IF (@JobID IS NOT NULL)
  BEGIN
  -- Check if the job is a multi-server job
  IF (EXISTS (SELECT  *
              FROM    msdb.dbo.sysjobservers
              WHERE   (job_id = @JobID) AND (server_id <> 0)))
  BEGIN
    -- There is, so abort the script
    RAISERROR (N'Unable to import job ''CycleErrorlog'' since there is already a multi-server job with this name.', 16, 1)
    GOTO QuitWithRollback
  END
  ELSE
    -- Delete the [local] job
    EXECUTE msdb.dbo.sp_delete_job @job_name = N'CycleErrorlog'
    SELECT @JobID = NULL
  END

BEGIN

  -- Add the job
  EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'CycleErrorlog', @owner_login_name = N'sa', @description = N'Cycle the Errorlog.  Keeps the Errorlog from getting to large to review.', @category_name = N'Database Maintenance', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 2, @notify_level_eventlog = 2, @delete_level= 0
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

  -- Add the job steps
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'CycleErrorlog', @command = N'sp_cycle_errorlog', @database_name = N'master', @server = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
  EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1

  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

  -- Add the job schedules
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID,
  @name = N'Sunday0001',
  @enabled = 1,
  @freq_type = 8,
  @active_start_date = 20110101,
  @active_start_time = 000100,
  @freq_interval = 1,
  @freq_subday_type = 1,
  @freq_subday_interval = 0,
  @freq_relative_interval = 1,
  @freq_recurrence_factor = 1,
  @active_end_date = 99991231,
  @active_end_time = 235959
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
  -- Add the Target Servers
  EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)'
  IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END
COMMIT TRANSACTION
GOTO   EndSave
QuitWithRollback:
  IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
USE [master]
GO
-- CHANGED: Was 07, now 30 to satisfy baseline control 5.1 (requires >= 12)
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 30
GO
