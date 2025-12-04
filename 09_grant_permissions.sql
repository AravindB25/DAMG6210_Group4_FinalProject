-- ============================================================================
-- Commuter Reservation System (CRS)Group 4
-- Grant Permissions Script
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Grant Execute Permissions to CRS_DATA_USER
-- ============================================================================

-- Grant execute on passenger package
GRANT EXECUTE ON CRS_PASSENGER_PKG TO CRS_DATA_USER;

-- Grant execute on booking package
GRANT EXECUTE ON CRS_BOOKING_PKG TO CRS_DATA_USER;

-- ============================================================================
-- Grant SELECT Permissions to CRS_REPORT_USER (Read-Only Access)
-- ============================================================================

-- Grant SELECT on all CRS tables to report user
GRANT SELECT ON CRS_TRAIN_INFO TO CRS_REPORT_USER;
GRANT SELECT ON CRS_DAY_SCHEDULE TO CRS_REPORT_USER;
GRANT SELECT ON CRS_TRAIN_SCHEDULE TO CRS_REPORT_USER;
GRANT SELECT ON CRS_PASSENGER TO CRS_REPORT_USER;
GRANT SELECT ON CRS_RESERVATION TO CRS_REPORT_USER;

-- ============================================================================
-- Verification
-- ============================================================================

-- Permissions for CRS_DATA_USER
SELECT grantee, table_name, privilege
FROM user_tab_privs
WHERE grantee = 'CRS_DATA_USER'
ORDER BY table_name;

-- Permissions for CRS_REPORT_USER
SELECT grantee, table_name, privilege
FROM user_tab_privs
WHERE grantee = 'CRS_REPORT_USER'
ORDER BY table_name;

COMMIT;

-- ============================================================================
-- END OF GRANT PERMISSIONS SCRIPT
-- Next: Run 10_insert_seed_data.sql
-- ============================================================================