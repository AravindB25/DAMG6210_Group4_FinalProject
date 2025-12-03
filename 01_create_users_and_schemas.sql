-- ============================================================================
-- Commuter Reservation System (CRS) - Group 4
-- User Creation & Setup Script
-- Date: November 2025
-- Note: Run as SYSTEM/DBA user
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Users (If Re-running)
-- ============================================================================
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM dba_users 
    WHERE username = 'CRS_ADMIN_USER';
    
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER CRS_ADMIN_USER CASCADE';
        DBMS_OUTPUT.PUT_LINE('Dropped existing CRS_ADMIN_USER');
    END IF;
    
    SELECT COUNT(*) INTO v_count 
    FROM dba_users 
    WHERE username = 'CRS_DATA_USER';
    
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER CRS_DATA_USER CASCADE';
        DBMS_OUTPUT.PUT_LINE('Dropped existing CRS_DATA_USER');
    END IF;
    
    SELECT COUNT(*) INTO v_count 
    FROM dba_users 
    WHERE username = 'CRS_REPORT_USER';
    
    IF v_count > 0 THEN
        EXECUTE IMMEDIATE 'DROP USER CRS_REPORT_USER CASCADE';
        DBMS_OUTPUT.PUT_LINE('Dropped existing CRS_REPORT_USER');
    END IF;
END;
/

-- ============================================================================
-- Schema Owner - Full Database Control
-- ============================================================================
CREATE USER CRS_ADMIN_USER 
IDENTIFIED BY NeuBoston2025#
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

GRANT CONNECT TO CRS_ADMIN_USER;
GRANT RESOURCE TO CRS_ADMIN_USER;
GRANT CREATE SESSION TO CRS_ADMIN_USER;
GRANT CREATE TABLE TO CRS_ADMIN_USER;
GRANT CREATE VIEW TO CRS_ADMIN_USER;
GRANT CREATE SEQUENCE TO CRS_ADMIN_USER;
GRANT CREATE PROCEDURE TO CRS_ADMIN_USER;
GRANT CREATE TRIGGER TO CRS_ADMIN_USER;

DBMS_OUTPUT.PUT_LINE('CRS_ADMIN_USER created successfully');

-- ============================================================================
-- Application User - Restricted Access (Execute Procedures Only)
-- ============================================================================
CREATE USER CRS_DATA_USER 
IDENTIFIED BY NeuBoston2025#
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 0 ON USERS;

GRANT CONNECT TO CRS_DATA_USER;
GRANT CREATE SESSION TO CRS_DATA_USER;

DBMS_OUTPUT.PUT_LINE('CRS_DATA_USER created successfully');

-- ============================================================================
-- Report User - Read-Only Access for Analytics
-- ============================================================================
CREATE USER CRS_REPORT_USER 
IDENTIFIED BY NeuBoston2025#
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA 0 ON USERS;

GRANT CONNECT TO CRS_REPORT_USER;
GRANT CREATE SESSION TO CRS_REPORT_USER;

DBMS_OUTPUT.PUT_LINE('CRS_REPORT_USER created successfully');

COMMIT;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT username, account_status, created, default_tablespace
FROM dba_users 
WHERE username IN ('CRS_ADMIN_USER', 'CRS_DATA_USER', 'CRS_REPORT_USER')
ORDER BY username;

-- ============================================================================
-- END OF USER CREATION SCRIPT
-- Next: Connect as CRS_ADMIN_USER and run 02_create_sequences.sql
-- ============================================================================