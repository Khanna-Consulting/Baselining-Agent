-- ============================================================================
-- COV SQL SERVER BASELINE COMPLIANCE AUDIT
-- Covers all 38 controls from the COV 2019/2022/2025 baseline
-- Run this after deployment to verify scripts ran AND controls pass.
--
-- Output:
--   PART 1: Deployment Verification (did scripts 0-8 apply correctly?)
--   PART 2: Baseline Control Audit (do all 38 controls pass?)
-- ============================================================================

USE [master]
GO

PRINT ''
PRINT '================================================================'
PRINT '  COV SQL SERVER BASELINE COMPLIANCE AUDIT'
PRINT '  Run Date: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '  Server:   ' + @@SERVERNAME
PRINT '  Version:  ' + CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)
PRINT '  Edition:  ' + CAST(SERVERPROPERTY('Edition') AS VARCHAR)
PRINT '================================================================'
PRINT ''
GO

-- ============================================================================
-- PART 1: DEPLOYMENT SCRIPT VERIFICATION
-- Confirms that scripts 0-8 ran successfully by checking their artifacts
-- ============================================================================

PRINT '================================================================'
PRINT '  PART 1: DEPLOYMENT SCRIPT VERIFICATION'
PRINT '================================================================'
PRINT ''
GO

-- Script 0: CreateDatabaseMail
PRINT '--- Script 0: Database Mail ---'
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = 'SMTPMailAccount')
    PRINT 'PASS: Database Mail account exists'
ELSE
    PRINT 'FAIL: Database Mail account "SMTPMailAccount" not found'

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = 'Default')
    PRINT 'PASS: Default mail profile exists'
ELSE
    PRINT 'FAIL: Default mail profile not found'
PRINT ''
GO

-- Script 1: GeneralAlerts
PRINT '--- Script 1: General Alerts ---'
DECLARE @ExpectedAlerts TABLE (AlertName SYSNAME)
INSERT @ExpectedAlerts VALUES
('825Error-TransientCorruption'),('Sev17Alert'),('Sev19Alert'),
('Sev20Alert'),('Sev21Alert'),('Sev22Alert'),('Sev23Alert'),
('Sev24Alert'),('Sev25Alert'),('SQLMemPageOut'),('SlowIORequests'),
('Insufficent Permissions')

DECLARE @MissingAlerts INT
SELECT @MissingAlerts = COUNT(*) FROM @ExpectedAlerts ea
WHERE NOT EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = ea.AlertName)

IF @MissingAlerts = 0
    PRINT 'PASS: All 12 expected alerts exist'
ELSE
    PRINT 'FAIL: ' + CAST(@MissingAlerts AS VARCHAR) + ' alert(s) missing'
PRINT ''
GO

-- Script 2: Operator
PRINT '--- Script 2: DBA Operator ---'
IF EXISTS (SELECT * FROM msdb.dbo.sysoperators WHERE name = 'CESC-DBA')
    PRINT 'PASS: CESC-DBA operator exists'
ELSE
    PRINT 'FAIL: CESC-DBA operator not found'
PRINT ''
GO

-- Script 3: Server Hardening
PRINT '--- Script 3: Server Hardening (sp_configure) ---'
DECLARE @HardeningFails INT = 0
SELECT @HardeningFails = COUNT(*) FROM sys.configurations
WHERE (name = 'Ad Hoc Distributed Queries' AND CAST(value_in_use AS int) <> 0)
   OR (name = 'clr enabled' AND CAST(value_in_use AS int) <> 0)
   OR (name = 'cross db ownership chaining' AND CAST(value_in_use AS int) <> 0)
   OR (name = 'Ole Automation Procedures' AND CAST(value_in_use AS int) <> 0)
   OR (name = 'remote admin connections' AND CAST(value_in_use AS int) <> 0)
   OR (name = 'scan for startup procs' AND CAST(value_in_use AS int) <> 0)
   OR (name = 'xp_cmdshell' AND CAST(value_in_use AS int) <> 0)
   OR (name = 'default trace enabled' AND CAST(value_in_use AS int) <> 1)
   OR (name = 'backup compression default' AND CAST(value_in_use AS int) <> 1)

IF @HardeningFails = 0
    PRINT 'PASS: All sp_configure hardening settings applied'
ELSE
    PRINT 'FAIL: ' + CAST(@HardeningFails AS VARCHAR) + ' sp_configure setting(s) not correct'

-- Check Hide Instance
DECLARE @HideCheck INT
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib',
    N'HideInstance', @HideCheck OUTPUT
IF @HideCheck = 1
    PRINT 'PASS: Hide Instance enabled'
ELSE
    PRINT 'FAIL: Hide Instance not enabled'

-- Check xp revocations (test xp_dirtree)
IF NOT EXISTS (SELECT * FROM sys.database_permissions WHERE
    major_id = OBJECT_ID('xp_dirtree') AND grantee_principal_id = 0 AND state_desc = 'GRANT')
    PRINT 'PASS: xp_dirtree revoked from PUBLIC'
ELSE
    PRINT 'FAIL: xp_dirtree still granted to PUBLIC'
PRINT ''
GO

-- Script 4: Cycle Error Log
PRINT '--- Script 4: Cycle Error Log Job ---'
IF EXISTS (SELECT * FROM msdb.dbo.sysjobs WHERE name = 'CycleErrorlog')
    PRINT 'PASS: CycleErrorlog job exists'
ELSE
    PRINT 'FAIL: CycleErrorlog job not found'

DECLARE @NumLogsCheck INT
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', @NumLogsCheck OUTPUT
IF @NumLogsCheck >= 12
    PRINT 'PASS: NumErrorLogs = ' + CAST(@NumLogsCheck AS VARCHAR) + ' (>= 12)'
ELSE
    PRINT 'FAIL: NumErrorLogs = ' + ISNULL(CAST(@NumLogsCheck AS VARCHAR),'NULL') + ' (requires >= 12)'
PRINT ''
GO

-- Script 5: Extended Attributes
PRINT '--- Script 5: MSDB Extended Properties ---'
USE [msdb]
IF EXISTS (SELECT * FROM fn_listextendedproperty(default, default, default, default, default, default, default))
    PRINT 'PASS: Extended properties exist on MSDB'
ELSE
    PRINT 'FAIL: No extended properties found on MSDB'
USE [master]
PRINT ''
GO

-- Script 6: Backup Compression + CPU Poller
PRINT '--- Script 6: Backup Compression ---'
IF EXISTS (SELECT * FROM sys.configurations WHERE name = 'backup compression default' AND CAST(value_in_use AS int) = 1)
    PRINT 'PASS: Backup compression default enabled'
ELSE
    PRINT 'FAIL: Backup compression default not enabled'
PRINT ''
GO

-- Script 7: Registry/TLS (limited check from SQL - full verify requires OS)
PRINT '--- Script 7: Registry Updates (partial - full check requires OS) ---'
DECLARE @AuditLevel INT
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer', N'AuditLevel', @AuditLevel OUTPUT
IF @AuditLevel >= 2
    PRINT 'PASS: AuditLevel = ' + CAST(@AuditLevel AS VARCHAR) + ' (failed logins captured)'
ELSE
    PRINT 'FAIL: AuditLevel = ' + ISNULL(CAST(@AuditLevel AS VARCHAR),'NULL')
PRINT 'NOTE: TLS 1.0/1.1 disabled and TLS 1.3 enabled must be verified at OS level (regedit or PowerShell)'
PRINT ''
GO

-- Script 8: SSL Check
PRINT '--- Script 8: Network Encryption ---'
IF EXISTS (SELECT * FROM sys.dm_exec_connections WHERE encrypt_option = 'FALSE')
    PRINT 'FAIL: Unencrypted connections detected'
ELSE
    PRINT 'PASS: All active connections encrypted'
PRINT ''
GO

PRINT '================================================================'
PRINT '  END PART 1: DEPLOYMENT VERIFICATION'
PRINT '================================================================'
PRINT ''
PRINT ''
GO

-- ============================================================================
-- PART 2: BASELINE CONTROL AUDIT (38 controls)
-- ============================================================================

PRINT '================================================================'
PRINT '  PART 2: BASELINE CONTROL AUDIT (38 Controls)'
PRINT '================================================================'
PRINT ''
GO

-- ============================================================================
-- SECTION 1: Installation, Updates and Patches
-- ============================================================================

PRINT '--- 1.1: SQL Server Version and Patch Level ---'
SELECT SERVERPROPERTY('ProductVersion') AS [Version],
       SERVERPROPERTY('ProductLevel') AS [PatchLevel],
       SERVERPROPERTY('ProductUpdateLevel') AS [CU_Level],
       SERVERPROPERTY('Edition') AS [Edition]
PRINT ''
GO

PRINT '--- 1.2: Single-Function Server (manual check) ---'
PRINT 'VERIFY: Confirm no other application roles are installed on this server.'
PRINT ''
GO

-- ============================================================================
-- SECTION 2: Surface Area Reduction
-- ============================================================================

PRINT '--- 2.1-2.8, 2.15: sp_configure Settings ---'
SELECT name AS [Control],
       CAST(value_in_use AS int) AS [CurrentValue],
       CASE
           WHEN name = 'Ad Hoc Distributed Queries' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'clr enabled' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'cross db ownership chaining' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'Database Mail XPs' THEN CASE WHEN CAST(value_in_use AS int) = 1 THEN 'EXCEPTION (DBA team uses DB Mail)' ELSE 'PASS' END
           WHEN name = 'Ole Automation Procedures' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'remote access' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'remote admin connections' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'scan for startup procs' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'xp_cmdshell' THEN CASE WHEN CAST(value_in_use AS int) = 0 THEN 'PASS' ELSE 'FAIL' END
           WHEN name = 'default trace enabled' THEN CASE WHEN CAST(value_in_use AS int) = 1 THEN 'PASS' ELSE 'FAIL' END
       END AS [Status]
FROM sys.configurations
WHERE name IN (
    'Ad Hoc Distributed Queries', 'clr enabled', 'cross db ownership chaining',
    'Database Mail XPs', 'Ole Automation Procedures', 'remote access',
    'remote admin connections', 'scan for startup procs', 'xp_cmdshell',
    'default trace enabled'
)
ORDER BY name
PRINT ''
GO

PRINT '--- 2.9: Trustworthy Database Property ---'
IF EXISTS (SELECT name FROM sys.databases WHERE is_trustworthy_on = 1 AND name NOT IN ('msdb'))
    SELECT name AS [Database], 'FAIL' AS [Status] FROM sys.databases WHERE is_trustworthy_on = 1 AND name NOT IN ('msdb')
ELSE
    PRINT 'PASS: No user databases with Trustworthy ON'
PRINT ''
GO

PRINT '--- 2.10: Unnecessary Protocols (informational) ---'
BEGIN TRY
    SELECT value_name, value_data
    FROM sys.dm_server_registry
    WHERE registry_key LIKE '%SuperSocketNetLib%'
    AND value_name IN ('Enabled')
END TRY
BEGIN CATCH
    PRINT 'INFO: Check SQL Server Configuration Manager manually for protocol status'
END CATCH
PRINT ''
GO

PRINT '--- 2.11: Non-Standard Ports ---'
BEGIN TRY
    DECLARE @PortCount INT
    SELECT @PortCount = COUNT(*)
    FROM sys.dm_server_registry
    WHERE value_name LIKE '%TcpPort%' AND value_data = '1433'
    IF @PortCount > 0
        PRINT 'EXCEPTION: Using default port 1433 (accepted per baseline)'
    ELSE
        PRINT 'PASS: Not using default port 1433'
END TRY
BEGIN CATCH
    PRINT 'INFO: Check port configuration in SQL Server Configuration Manager'
END CATCH
PRINT ''
GO

PRINT '--- 2.12: Hide Instance ---'
DECLARE @HideInstance INT
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib',
    N'HideInstance', @HideInstance OUTPUT
SELECT @HideInstance AS [HideInstance],
       CASE WHEN @HideInstance = 1 THEN 'PASS' ELSE 'FAIL' END AS [Status]
PRINT ''
GO

PRINT '--- 2.13: sa Account Disabled ---'
SELECT name, is_disabled,
       CASE WHEN is_disabled = 1 THEN 'PASS' ELSE 'FAIL' END AS [Status]
FROM sys.server_principals
WHERE sid = 0x01
PRINT ''
GO

PRINT '--- 2.14: sa Account Renamed ---'
SELECT name,
       CASE WHEN name <> 'sa' THEN 'PASS (renamed to: ' + name + ')' ELSE 'FAIL (still named sa)' END AS [Status]
FROM sys.server_principals
WHERE sid = 0x01
PRINT ''
GO

PRINT '--- 2.15: xp_cmdshell (covered in 2.1-2.8 query above) ---'
PRINT ''
GO

PRINT '--- 2.16: AUTO_CLOSE Off ---'
IF EXISTS (SELECT name FROM sys.databases WHERE is_auto_close_on = 1)
    SELECT name AS [Database], 'FAIL' AS [Status] FROM sys.databases WHERE is_auto_close_on = 1
ELSE
    PRINT 'PASS: No databases with AUTO_CLOSE ON'
PRINT ''
GO

PRINT '--- 2.17: No Login Named sa ---'
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'sa')
    PRINT 'FAIL: A login named "sa" still exists'
ELSE
    PRINT 'PASS: No login named "sa" exists'
PRINT ''
GO

-- ============================================================================
-- SECTION 3: Authentication and Authorization
-- ============================================================================

PRINT '--- 3.1: Windows Authentication Mode ---'
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly') AS [WindowsAuthOnly],
       CASE WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 1
            THEN 'PASS'
            ELSE 'INFO: Mixed Mode (verify if required by applications)'
       END AS [Status]
PRINT ''
GO

PRINT '--- 3.2: Guest CONNECT Revoked ---'
CREATE TABLE #GuestConnect (DatabaseName SYSNAME, UserName SYSNAME, PermName SYSNAME, StateDesc SYSNAME)
EXEC sp_MSforeachdb '
USE [?];
IF DB_NAME() NOT IN (''master'',''msdb'',''tempdb'')
INSERT INTO #GuestConnect
SELECT DB_NAME(), dp.name, p.permission_name, p.state_desc
FROM sys.database_permissions p
JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE dp.name = ''guest'' AND p.permission_name = ''CONNECT'' AND p.state_desc = ''GRANT'''

IF EXISTS (SELECT * FROM #GuestConnect)
    SELECT *, 'FAIL' AS [Status] FROM #GuestConnect
ELSE
    PRINT 'PASS: Guest CONNECT revoked in all user databases'
DROP TABLE #GuestConnect
PRINT ''
GO

PRINT '--- 3.3: Orphaned Users ---'
CREATE TABLE #OrphanedUsers (DatabaseName SYSNAME, UserName SYSNAME, UserSID VARBINARY(85))
EXEC sp_MSforeachdb '
USE [?];
IF DB_NAME() NOT IN (''master'',''msdb'',''tempdb'',''model'')
INSERT INTO #OrphanedUsers
SELECT DB_NAME(), dp.name, dp.sid
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.type IN (''S'',''U'') AND dp.name NOT IN (''dbo'',''guest'',''INFORMATION_SCHEMA'',''sys'')
AND sp.sid IS NULL AND dp.authentication_type_desc = ''INSTANCE'''

IF EXISTS (SELECT * FROM #OrphanedUsers)
    SELECT *, 'FAIL' AS [Status] FROM #OrphanedUsers
ELSE
    PRINT 'PASS: No orphaned users found'
DROP TABLE #OrphanedUsers
PRINT ''
GO

PRINT '--- 3.4: SQL Auth in Contained Databases ---'
IF EXISTS (SELECT * FROM sys.databases WHERE containment <> 0)
BEGIN
    PRINT 'INFO: Contained databases exist - check for SQL authenticated users'
    SELECT name, containment_desc FROM sys.databases WHERE containment <> 0
END
ELSE
    PRINT 'PASS: No contained databases (or EXCEPTION if app requires SQL auth)'
PRINT ''
GO

PRINT '--- 3.5-3.7: Service Account Configuration ---'
SELECT servicename, service_account, status_desc,
       CASE WHEN service_account LIKE '%LocalSystem%' THEN 'REVIEW'
            ELSE 'PASS' END AS [Status]
FROM sys.dm_server_services
PRINT ''
GO

PRINT '--- 3.8: Public Server Role Permissions ---'
DECLARE @ExtraPerms INT
SELECT @ExtraPerms = COUNT(*)
FROM sys.server_permissions
WHERE grantee_principal_id = 2
AND NOT (permission_name = 'VIEW ANY DATABASE' AND state_desc = 'GRANT')
AND NOT (permission_name = 'CONNECT' AND class_desc = 'ENDPOINT')
IF @ExtraPerms > 0
BEGIN
    SELECT class_desc, permission_name, state_desc, 'FAIL' AS [Status]
    FROM sys.server_permissions
    WHERE grantee_principal_id = 2
    AND NOT (permission_name = 'VIEW ANY DATABASE' AND state_desc = 'GRANT')
    AND NOT (permission_name = 'CONNECT' AND class_desc = 'ENDPOINT')
END
ELSE
    PRINT 'PASS: Only default permissions on public server role'
PRINT ''
GO

PRINT '--- 3.9: BUILTIN Group SQL Logins ---'
IF EXISTS (SELECT * FROM sys.server_principals WHERE name LIKE 'BUILTIN%')
    SELECT name, type_desc, 'FAIL' AS [Status] FROM sys.server_principals WHERE name LIKE 'BUILTIN%'
ELSE
    PRINT 'PASS: No BUILTIN group logins'
PRINT ''
GO

PRINT '--- 3.10: Windows Local Group SQL Logins ---'
IF EXISTS (SELECT * FROM sys.server_principals WHERE type_desc = 'WINDOWS_GROUP'
           AND name LIKE CAST(SERVERPROPERTY('MachineName') AS VARCHAR) + '%')
    SELECT name, 'FAIL' AS [Status] FROM sys.server_principals WHERE type_desc = 'WINDOWS_GROUP'
           AND name LIKE CAST(SERVERPROPERTY('MachineName') AS VARCHAR) + '%'
ELSE
    PRINT 'PASS: No local group logins'
PRINT ''
GO

PRINT '--- 3.11: Public Role Proxy Access (msdb) ---'
USE [msdb]
IF EXISTS (SELECT * FROM dbo.sysproxylogin WHERE sid = 0x00)
    SELECT sp.name AS [ProxyName], 'FAIL' AS [Status]
    FROM dbo.sysproxylogin spl JOIN dbo.sysproxies sp ON spl.proxy_id = sp.proxy_id
    WHERE spl.sid = 0x00
ELSE
    PRINT 'PASS: Public role has no proxy access'
USE [master]
PRINT ''
GO

-- ============================================================================
-- SECTION 4: Password Policies
-- ============================================================================

PRINT '--- 4.1/4.2/4.3: Password Policy Settings ---'
SELECT name AS [Login],
       is_policy_checked AS [CHECK_POLICY],
       is_expiration_checked AS [CHECK_EXPIRATION],
       CASE WHEN is_policy_checked = 1 THEN 'PASS' ELSE 'FAIL' END AS [4.3_Status],
       CASE WHEN is_expiration_checked = 1 THEN 'PASS'
            WHEN IS_SRVROLEMEMBER('sysadmin', name) = 0 THEN 'N/A (not sysadmin)'
            ELSE 'FAIL' END AS [4.2_Status]
FROM sys.sql_logins
WHERE is_disabled = 0
AND name NOT LIKE '##%'
ORDER BY name
PRINT ''
GO

-- ============================================================================
-- SECTION 5: Auditing and Logging
-- ============================================================================

PRINT '--- 5.1: Number of Error Log Files ---'
DECLARE @NumLogs INT
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE',
    N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', @NumLogs OUTPUT
SELECT @NumLogs AS [NumErrorLogs],
       CASE WHEN @NumLogs >= 12 THEN 'PASS' ELSE 'FAIL (requires >= 12)' END AS [Status]
PRINT ''
GO

PRINT '--- 5.2: Default Trace Enabled (covered in 2.1-2.8 query above) ---'
PRINT ''
GO

PRINT '--- 5.3: Login Auditing Level ---'
EXEC xp_loginconfig 'audit level'
PRINT ''
GO

PRINT '--- 5.4: SQL Server Audit ---'
IF EXISTS (SELECT * FROM sys.server_audits)
BEGIN
    SELECT name, status_desc, type_desc, 'EXISTS' AS [Status] FROM sys.server_audits
    SELECT sas.name AS [SpecName], sas.is_state_enabled,
           CASE WHEN sas.is_state_enabled = 1 THEN 'PASS' ELSE 'FAIL (not enabled)' END AS [Status]
    FROM sys.server_audit_specifications sas
END
ELSE
    PRINT 'FAIL: No SQL Server Audit configured'
PRINT ''
GO

-- ============================================================================
-- SECTION 6: Application Development
-- ============================================================================

PRINT '--- 6.1: Input Sanitization (manual/process check) ---'
PRINT 'VERIFY: Confirm applications use parameterized queries or stored procedures.'
PRINT ''
GO

PRINT '--- 6.2: CLR Assembly Permission Sets ---'
CREATE TABLE #CLRCheck (DBName SYSNAME, AssemblyName SYSNAME, PermSet NVARCHAR(60))
EXEC sp_MSforeachdb '
USE [?];
IF DB_ID() > 4
INSERT INTO #CLRCheck
SELECT DB_NAME(), name, permission_set_desc
FROM sys.assemblies
WHERE is_user_defined = 1 AND permission_set_desc <> ''SAFE_ACCESS'''

IF EXISTS (SELECT * FROM #CLRCheck)
    SELECT *, 'REVIEW (exception for Microsoft assemblies)' AS [Status] FROM #CLRCheck
ELSE
    PRINT 'PASS: All CLR assemblies use SAFE_ACCESS (or none exist)'
DROP TABLE #CLRCheck
PRINT ''
GO

-- ============================================================================
-- SECTION 7: Encryption
-- ============================================================================

PRINT '--- 7.1: Symmetric Key Algorithms ---'
CREATE TABLE #SymKeys (DBName SYSNAME, KeyName SYSNAME, Algorithm NVARCHAR(60))
EXEC sp_MSforeachdb '
USE [?];
IF DB_ID() > 4
INSERT INTO #SymKeys
SELECT DB_NAME(), name, algorithm_desc
FROM sys.symmetric_keys
WHERE algorithm_desc NOT IN (''AES_128'',''AES_192'',''AES_256'')
AND name <> ''##MS_DatabaseMasterKey##'''

IF EXISTS (SELECT * FROM #SymKeys)
    SELECT *, 'FAIL' AS [Status] FROM #SymKeys
ELSE
    PRINT 'PASS: All symmetric keys use AES_128 or higher'
DROP TABLE #SymKeys
PRINT ''
GO

PRINT '--- 7.2: Asymmetric Key Size ---'
CREATE TABLE #AsymKeys (DBName SYSNAME, KeyName SYSNAME, KeyLen INT, Algorithm NVARCHAR(60))
EXEC sp_MSforeachdb '
USE [?];
IF DB_ID() > 4
INSERT INTO #AsymKeys
SELECT DB_NAME(), name, key_length, algorithm_desc
FROM sys.asymmetric_keys
WHERE key_length < 2048'

IF EXISTS (SELECT * FROM #AsymKeys)
    SELECT *, 'FAIL' AS [Status] FROM #AsymKeys
ELSE
    PRINT 'PASS: All asymmetric keys >= 2048 bits (or none exist)'
DROP TABLE #AsymKeys
PRINT ''
GO

PRINT '--- 7.3: Backup Encryption ---'
SELECT TOP 5 database_name, key_algorithm, encryptor_type, backup_finish_date,
       CASE WHEN key_algorithm IS NOT NULL THEN 'ENCRYPTED'
            ELSE 'EXCEPTION (encrypted at storage level)' END AS [Status]
FROM msdb.dbo.backupset
WHERE backup_finish_date > DATEADD(day, -7, GETDATE()) AND type = 'D'
ORDER BY backup_finish_date DESC
PRINT ''
GO

PRINT '--- 7.4: Network Encryption ---'
IF EXISTS (SELECT * FROM sys.dm_exec_connections WHERE encrypt_option = 'FALSE')
BEGIN
    SELECT session_id, encrypt_option, client_net_address, auth_scheme, 'FAIL' AS [Status]
    FROM sys.dm_exec_connections WHERE encrypt_option = 'FALSE'
END
ELSE
    PRINT 'PASS: All active connections are encrypted'
PRINT ''
GO

PRINT '--- 7.5: TDE Status ---'
SELECT name,
       CASE WHEN is_encrypted = 1 THEN 'PASS'
            ELSE 'EXCEPTION (not all DBs contain sensitive data)' END AS [Status]
FROM sys.databases
WHERE database_id > 4
ORDER BY name
PRINT ''
GO

-- ============================================================================
-- SECTION 8: Appendix
-- ============================================================================

PRINT '--- 8.1: SQL Server Browser Service ---'
PRINT 'VERIFY: Check via services.msc - should be Disabled unless named instances exist.'
PRINT ''
GO

-- ============================================================================
-- SUMMARY
-- ============================================================================

PRINT '================================================================'
PRINT '  AUDIT COMPLETE - ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '  Review results above for any FAIL items.'
PRINT '  EXCEPTION items have documented differential reasoning.'
PRINT '================================================================'
GO
