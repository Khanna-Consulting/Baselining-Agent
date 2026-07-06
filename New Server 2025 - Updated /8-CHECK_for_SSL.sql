-- ============================================================================
-- Control 7.4: ENFORCE AND VERIFY Network Encryption
--
-- CHANGES:
-- 1. Sets ForceEncryption = 1 via registry (requires service restart to take effect)
-- 2. Verification query shows any unencrypted connections (should be 0 after restart)
--
-- NOTE: A valid TLS certificate must already be installed and assigned to SQL Server
--       via SQL Server Configuration Manager BEFORE enabling ForceEncryption.
--       If no cert is assigned, SQL will use a self-signed cert (acceptable for
--       internal servers per COV baseline, but not for external-facing).
--
-- IMPORTANT: SQL Server service MUST be restarted after this script runs for
--            ForceEncryption to take effect. New connections after restart will
--            be encrypted; existing connections are not affected until reconnect.
-- ============================================================================

USE [master]
GO

-- Enable Force Encryption via registry
-- This is the same setting as SQL Server Configuration Manager > Protocols > Force Encryption = Yes
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\Microsoft SQL Server\MSSQLServer\SuperSocketNetLib',
    N'ForceEncryption', REG_DWORD, 1;
GO

PRINT 'ForceEncryption registry value set to 1.'
PRINT 'ACTION REQUIRED: Restart SQL Server service for encryption enforcement to take effect.'
PRINT ''
GO

-- Verification: show any current unencrypted connections
-- After service restart, this should return 0 rows
SELECT session_id, encrypt_option, client_net_address, auth_scheme, net_transport
FROM sys.dm_exec_connections
WHERE encrypt_option = 'FALSE';
GO
