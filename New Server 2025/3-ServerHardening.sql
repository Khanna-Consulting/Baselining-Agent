-- ============================================================================
-- SERVER HARDENING CONFIGURATION
-- Extracted from 3-MaintenanceSolution-2012-2022.sql (end section)
-- Updated for SQL Server 2025 compatibility
--
-- CHANGES FROM ORIGINAL:
-- 1. Added missing sp_configure: cross db ownership chaining, remote access,
--    remote admin connections, xp_cmdshell (controls 2.3, 2.6, 2.7, 2.15)
-- 2. Wrapped 'remote access' in TRY/CATCH for SQL 2025 (option removed)
-- 3. Uncommented Hide Instance registry write (control 2.12)
-- 4. NumErrorLogs set to 30 (matches CycleErrorLog, satisfies control 5.1)
--
-- NOTE: Run the Ola Hallengren MaintenanceSolution separately.
--       Download the LATEST version from https://ola.hallengren.com
--       The 2020-11-01 version is outdated for SQL 2025.
-- ============================================================================

USE [master]
GO

-- Enable advanced options for sp_configure changes
EXECUTE sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

-- Control 2.1: Ad Hoc Distributed Queries = 0
EXECUTE sp_configure 'Ad Hoc Distributed Queries', 0;
GO

-- Control 2.2: CLR Enabled = 0
EXECUTE sp_configure 'clr enabled', 0;
GO

-- Control 2.3: Cross DB Ownership Chaining = 0 (ADDED - was missing)
EXECUTE sp_configure 'cross db ownership chaining', 0;
GO

-- Control 2.5: Ole Automation Procedures = 0
EXECUTE sp_configure 'Ole Automation Procedures', 0;
GO

-- Control 2.6: Remote Access = 0 (ADDED - was missing)
-- Wrapped in TRY/CATCH because this option is REMOVED in SQL Server 2025
BEGIN TRY
    EXECUTE sp_configure 'remote access', 0;
END TRY
BEGIN CATCH
    PRINT 'Note: remote access option not available (expected on SQL Server 2025+)';
END CATCH
GO

-- Control 2.7: Remote Admin Connections = 0 (ADDED - was missing)
-- NOTE: On clustered instances, leave this at 1
EXECUTE sp_configure 'remote admin connections', 0;
GO

-- Control 2.8: Scan For Startup Procs = 0
EXECUTE sp_configure 'scan for startup procs', 0;
GO

-- Control 2.15: xp_cmdshell = 0 (ADDED - was missing)
EXECUTE sp_configure 'xp_cmdshell', 0;
GO

-- Control 5.2: Default Trace Enabled = 1
EXECUTE sp_configure 'default trace enabled', 1;
GO

-- Backup compression default (from script 6)
EXECUTE sys.sp_configure N'backup compression default', N'1';
GO

RECONFIGURE WITH OVERRIDE
GO

EXECUTE sp_configure 'show advanced options', 0;
RECONFIGURE WITH OVERRIDE
GO

-- ============================================================================
-- EXTENDED STORED PROCEDURE REVOCATIONS
-- ============================================================================

USE [master]
GO
REVOKE EXECUTE ON xp_dirtree TO PUBLIC;
GO
REVOKE EXECUTE ON xp_fixeddrives TO PUBLIC;
GO
REVOKE EXECUTE ON xp_regread TO PUBLIC;
GO

-- ============================================================================
-- REGISTRY SETTINGS
-- ============================================================================

-- Control 5.3: Audit Level (2 = failed logins only per baseline)
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'AuditLevel', REG_DWORD, 2
GO

-- Control 5.1: NumErrorLogs = 30 (baseline requires >= 12)
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'NumErrorLogs', REG_DWORD, 30
GO

-- Control 2.12: Hide Instance = Yes (UNCOMMENTED - was commented out)
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib', N'HideInstance', REG_DWORD, 1
GO

-- ============================================================================
-- SYSTEM DATABASE FILE GROWTH
-- ============================================================================

USE [master]
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'master', FILEGROWTH = 8192KB )
GO
ALTER DATABASE [master] MODIFY FILE ( NAME = N'mastlog', FILEGROWTH = 8192KB )
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBData', FILEGROWTH = 8192KB )
GO
ALTER DATABASE [msdb] MODIFY FILE ( NAME = N'MSDBLog', FILEGROWTH = 8192KB )
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', FILEGROWTH = 8192KB )
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modellog', FILEGROWTH = 8192KB )
GO
