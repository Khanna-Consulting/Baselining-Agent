-- Control 7.4: Verify Network Encryption is Enforced
-- CHANGED: Was checking encrypt_option = 'TRUE' (shows encrypted connections)
-- Now checks for 'FALSE' (finds UNENCRYPTED connections - which is what matters)
-- If this returns ANY rows, encryption is NOT enforced and control 7.4 FAILS

Use Master
GO
SELECT session_id, encrypt_option, client_net_address, auth_scheme, net_transport
FROM sys.dm_exec_connections
WHERE encrypt_option = 'FALSE';
GO
