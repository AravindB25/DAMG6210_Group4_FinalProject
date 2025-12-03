-- ============================================================================
-- Commuter Reservation System (CRS) - Group 4
-- Sequences Creation Script
-- Date: November 2025
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Sequences (If Re-running)
-- ============================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE crs_train_seq';
    DBMS_OUTPUT.PUT_LINE('Dropped existing crs_train_seq');
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('crs_train_seq does not exist');
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE crs_train_schedule_seq';
    DBMS_OUTPUT.PUT_LINE('Dropped existing crs_train_schedule_seq');
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('crs_train_schedule_seq does not exist');
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE crs_passenger_seq';
    DBMS_OUTPUT.PUT_LINE('Dropped existing crs_passenger_seq');
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('crs_passenger_seq does not exist');
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE crs_booking_seq';
    DBMS_OUTPUT.PUT_LINE('Dropped existing crs_booking_seq');
EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('crs_booking_seq does not exist');
END;
/

-- ============================================================================
-- Create Sequences
-- ============================================================================

-- Train information sequence
CREATE SEQUENCE crs_train_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Train schedule bridge table sequence
CREATE SEQUENCE crs_train_schedule_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Passenger sequence (starts at 1000)
CREATE SEQUENCE crs_passenger_seq
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Booking sequence (starts at 5000)
CREATE SEQUENCE crs_booking_seq
    START WITH 5000
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT sequence_name, min_value, max_value, increment_by, last_number
FROM user_sequences
ORDER BY sequence_name;

COMMIT;

-- ============================================================================
-- END OF SEQUENCE CREATION SCRIPT
-- Next: Run 03_create_tables.sql
-- ============================================================================