/*Script to add alerts and notifications to DBA User*/
-- If you want to add another operator change these two parameters.
-- SET @OpName = 'CESC-DBA' --ALTER if required.
-- @email_address=N'CESC-DBA@Vita.virginia.gov', --ALTER

/*First add an operator*/
USE [msdb]
GO

DECLARE @OpName VARCHAR (50),
		@OpID INT,
		@Count INT,
		@Recs INT

SET @OpName = 'CESC-DBA' --ALTER if required.

/*Check if operator exists*/
SELECT @Recs = Count(*)
  FROM [msdb].[dbo].[sysoperators]
WHERE [name] = @OpName

IF @Recs = 0
BEGIN
EXEC msdb.dbo.sp_add_operator @name= @OpName,
		@enabled=1,
		@weekday_pager_start_time=90000,
		@weekday_pager_end_time=180000,
		@saturday_pager_start_time=90000,
		@saturday_pager_end_time=180000,
		@sunday_pager_start_time=90000,
		@sunday_pager_end_time=180000,
		@pager_days=0,
		@email_address=N'CESC-DBA@Vita.virginia.gov', --ALTER
		@category_name=N'[Uncategorized]'
END

/*Clear record count*/
SET @Recs = 0

/*Get Operators ID */
SELECT @OpID = ID
FROM sysoperators
WHERE name = @OpName

/*Add Job Alert Notification*/
UPDATE sysjobs
SET [notify_level_email] = 2,
[notify_level_eventlog] = 0,
[notify_email_operator_id] = @OpID

/*Add Alert notification*/
UPDATE sysalerts
SET has_notification = 1

SET @Count = (SELECT MIN(id) FROM sysalerts)

WHILE @Count <= (SELECT MAX(id) FROM sysalerts)
BEGIN
	/*Check Alert exists*/
	SELECT @Recs = Count(*)
	FROM sysnotifications
	WHERE alert_id = @Count

	/*If alert doesn't exist add*/
	IF @Recs = 0
		INSERT INTO [msdb].[dbo].[sysnotifications]
           ([alert_id]
           ,[operator_id]
           ,[notification_method])
		VALUES
           (@Count
           ,@OpID
           ,1)

	SET @Count = @Count +1
END
GO
