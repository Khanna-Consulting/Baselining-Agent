# SQL Server 2025 Deployment Scripts

Deployment and hardening scripts for SQL Server 2025 in the COV environment, aligned to the COV Baseline (CIS Benchmark adapted).

## Execution Order

Run scripts 0–8 during initial server deployment. Run script 9 after deployment to produce a compliance log.

| # | File | Purpose |
|---|------|---------|
| 0 | `0-CreateDatabaseMail.sql` | Configure Database Mail account, profile, and SQL Agent mail settings |
| 1 | `1-GeneralAlerts.sql` | Create severity 17–25 alerts, I/O alerts, memory paging alerts |
| 2 | `2-AddOperatorToAlertsAndNotifications.sql` | Create CESC-DBA operator and attach to all alerts/jobs |
| 2a | `2a-AddAgencyOperatorToAlertsAndNotifications.sql` | Template for adding agency-specific operator (edit name/email before running) |
| 3 | `3-ServerHardening.sql` | All sp_configure hardening, registry writes, extended stored proc revocations |
| 4 | `4-CycleErrorLog.sql` | Create weekly error log cycle job |
| 5 | `5-AddextendedAttributesMSDB.sql` | Add documentation metadata (agency, contact, app name) to MSDB |
| 6 | `6-SetIdleCPUConditionAndCompressBackups.sql` | Enable backup compression default and SQL Agent CPU poller |
| 7 | `7-Windows2025_Registry_updates.reg` | OS-level registry settings: TLS, memory, filesystem, NTFS |
| 8 | `8-CHECK_for_SSL.sql` | Verify all connections are encrypted (control 7.4) |
| 9 | `9-BaselineComplianceAudit.sql` | Compliance log — verifies deployment scripts ran AND all 38 baseline controls pass |

## Changes from Previous (2019/2022) Scripts

### `3-ServerHardening.sql` (previously end of `3-MaintenanceSolution-2012-2022.sql`)

- **Added** `sp_configure 'cross db ownership chaining', 0` — control 2.3 was missing
- **Added** `sp_configure 'remote access', 0` wrapped in TRY/CATCH — control 2.6 was missing; TRY/CATCH needed because this option is removed in SQL 2025 and would error without it
- **Added** `sp_configure 'remote admin connections', 0` — control 2.7 was missing
- **Added** `sp_configure 'xp_cmdshell', 0` — control 2.15 was missing
- **Uncommented** Hide Instance registry write — control 2.12 was commented out in the original, meaning it never executed

### `4-CycleErrorLog.sql`

- **Changed** `NumErrorLogs` from `07` to `30` — baseline control 5.1 requires >= 12 error log files; the old value of 7 was non-compliant

### `7-Windows2025_Registry_updates.reg` (previously `7-Windows2022_Registry_updates.reg`)

- **Disabled** TLS 1.0 (Client and Server) — was Enabled in the 2022 version; TLS 1.0 is deprecated and vulnerable
- **Disabled** TLS 1.1 (Client and Server) — was Enabled in the 2022 version; TLS 1.1 is deprecated
- **Added** TLS 1.3 section (Client and Server Enabled) — SQL Server 2025 supports TLS 1.3 natively; this ensures the strongest available protocol is used

### `8-CHECK_for_SSL.sql`

- **Flipped** the query from `WHERE encrypt_option = 'TRUE'` to `WHERE encrypt_option = 'FALSE'` — the old query showed encrypted connections (proves nothing); the new query finds unencrypted connections (which is what indicates a failure of control 7.4)

### `9-BaselineComplianceAudit.sql` (new file)

- **Part 1:** Checks that each deployment script (0–8) ran successfully by verifying their artifacts exist (mail accounts, alerts, operators, sp_configure values, jobs, registry settings, encryption status)
- **Part 2:** Audits all 38 baseline controls individually with PASS/FAIL/EXCEPTION output

## Files With No Changes

- `0-CreateDatabaseMail.sql` — Database Mail is an accepted exception (control 2.4)
- `1-GeneralAlerts.sql` — Alert definitions are correct as-is
- `2-AddOperatorToAlertsAndNotifications.sql` — Operator logic is correct
- `2a-AddAgencyOperatorToAlertsAndNotifications.sql` — Template, edit before use
- `5-AddextendedAttributesMSDB.sql` — Documentation metadata, no security impact
- `6-SetIdleCPUConditionAndCompressBackups.sql` — Compression and CPU poller correct

## Notes

- The Ola Hallengren Maintenance Solution (`DatabaseBackup`, `DatabaseIntegrityCheck`, `IndexOptimize`) should be downloaded separately from https://ola.hallengren.com and run before these scripts. The version bundled in the old `3-MaintenanceSolution-2012-2022.sql` is from 2020 and should be updated for SQL 2025 compatibility.
- Script 7 (`.reg` file) must be run at the OS level (double-click or `regedit /s`), not from within SQL Server.
- Replace all instances of `ReplaceThisWithServerInstanceNameToken` with the actual server name before running.
- If TLS 1.0 is still required by legacy applications, re-enable it in the .reg file and document as a formal exception in the baseline.
