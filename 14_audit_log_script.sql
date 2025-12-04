-- ============================================================================
-- Commuter Reservation System (CRS)
-- Audit Log Table and Triggers
-- Date: November 2025
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Objects (If Re-running)
-- ============================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_audit_passenger';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_audit_reservation';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_audit_train_info';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE crs_audit_seq';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CRS_AUDIT_LOG CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ============================================================================
-- Create Audit Sequence
-- ============================================================================
CREATE SEQUENCE crs_audit_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================================================
-- Create Audit Log Table
-- ============================================================================
CREATE TABLE CRS_AUDIT_LOG (
    log_id          NUMBER PRIMARY KEY,
    table_name      VARCHAR2(50) NOT NULL,
    operation       VARCHAR2(10) NOT NULL,
    record_id       NUMBER,
    old_values      CLOB,
    new_values      CLOB,
    changed_by      VARCHAR2(50) DEFAULT USER NOT NULL,
    changed_at      TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    client_ip       VARCHAR2(50),
    session_id      NUMBER,
    CONSTRAINT chk_audit_operation CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- Create index for faster queries
CREATE INDEX idx_audit_table ON CRS_AUDIT_LOG(table_name);
CREATE INDEX idx_audit_timestamp ON CRS_AUDIT_LOG(changed_at);
CREATE INDEX idx_audit_record ON CRS_AUDIT_LOG(table_name, record_id);

PROMPT Audit log table created successfully.

-- ============================================================================
-- Trigger: Audit CRS_PASSENGER Table
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_audit_passenger
AFTER INSERT OR UPDATE OR DELETE ON CRS_PASSENGER
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.passenger_id;
        v_old_values := NULL;
        v_new_values := 'passenger_id=' || :NEW.passenger_id ||
                        ', name=' || :NEW.first_name || ' ' || :NEW.last_name ||
                        ', email=' || :NEW.email ||
                        ', phone=' || :NEW.phone;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.passenger_id;
        v_old_values := 'passenger_id=' || :OLD.passenger_id ||
                        ', name=' || :OLD.first_name || ' ' || :OLD.last_name ||
                        ', email=' || :OLD.email ||
                        ', phone=' || :OLD.phone;
        v_new_values := 'passenger_id=' || :NEW.passenger_id ||
                        ', name=' || :NEW.first_name || ' ' || :NEW.last_name ||
                        ', email=' || :NEW.email ||
                        ', phone=' || :NEW.phone;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.passenger_id;
        v_old_values := 'passenger_id=' || :OLD.passenger_id ||
                        ', name=' || :OLD.first_name || ' ' || :OLD.last_name ||
                        ', email=' || :OLD.email ||
                        ', phone=' || :OLD.phone;
        v_new_values := NULL;
    END IF;

    -- Insert audit record
    INSERT INTO CRS_AUDIT_LOG (
        log_id, table_name, operation, record_id,
        old_values, new_values, changed_by, changed_at,
        client_ip, session_id
    ) VALUES (
        crs_audit_seq.NEXTVAL, 'CRS_PASSENGER', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );
END;
/

PROMPT Passenger audit trigger created.

-- ============================================================================
-- Trigger: Audit CRS_RESERVATION Table
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_audit_reservation
AFTER INSERT OR UPDATE OR DELETE ON CRS_RESERVATION
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.booking_id;
        v_old_values := NULL;
        v_new_values := 'booking_id=' || :NEW.booking_id ||
                        ', passenger_id=' || :NEW.passenger_id ||
                        ', train_id=' || :NEW.train_id ||
                        ', travel_date=' || TO_CHAR(:NEW.travel_date, 'YYYY-MM-DD') ||
                        ', seat_class=' || :NEW.seat_class ||
                        ', seat_status=' || :NEW.seat_status ||
                        ', waitlist_pos=' || NVL(TO_CHAR(:NEW.waitlist_position), 'NULL');
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.booking_id;
        v_old_values := 'booking_id=' || :OLD.booking_id ||
                        ', passenger_id=' || :OLD.passenger_id ||
                        ', train_id=' || :OLD.train_id ||
                        ', travel_date=' || TO_CHAR(:OLD.travel_date, 'YYYY-MM-DD') ||
                        ', seat_class=' || :OLD.seat_class ||
                        ', seat_status=' || :OLD.seat_status ||
                        ', waitlist_pos=' || NVL(TO_CHAR(:OLD.waitlist_position), 'NULL');
        v_new_values := 'booking_id=' || :NEW.booking_id ||
                        ', passenger_id=' || :NEW.passenger_id ||
                        ', train_id=' || :NEW.train_id ||
                        ', travel_date=' || TO_CHAR(:NEW.travel_date, 'YYYY-MM-DD') ||
                        ', seat_class=' || :NEW.seat_class ||
                        ', seat_status=' || :NEW.seat_status ||
                        ', waitlist_pos=' || NVL(TO_CHAR(:NEW.waitlist_position), 'NULL');
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.booking_id;
        v_old_values := 'booking_id=' || :OLD.booking_id ||
                        ', passenger_id=' || :OLD.passenger_id ||
                        ', train_id=' || :OLD.train_id ||
                        ', travel_date=' || TO_CHAR(:OLD.travel_date, 'YYYY-MM-DD') ||
                        ', seat_class=' || :OLD.seat_class ||
                        ', seat_status=' || :OLD.seat_status ||
                        ', waitlist_pos=' || NVL(TO_CHAR(:OLD.waitlist_position), 'NULL');
        v_new_values := NULL;
    END IF;

    -- Insert audit record
    INSERT INTO CRS_AUDIT_LOG (
        log_id, table_name, operation, record_id,
        old_values, new_values, changed_by, changed_at,
        client_ip, session_id
    ) VALUES (
        crs_audit_seq.NEXTVAL, 'CRS_RESERVATION', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );
END;
/

PROMPT Reservation audit trigger created.

-- ============================================================================
-- Trigger: Audit CRS_TRAIN_INFO Table
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_audit_train_info
AFTER INSERT OR UPDATE OR DELETE ON CRS_TRAIN_INFO
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.train_id;
        v_old_values := NULL;
        v_new_values := 'train_id=' || :NEW.train_id ||
                        ', train_number=' || :NEW.train_number ||
                        ', route=' || :NEW.source_station || '->' || :NEW.dest_station ||
                        ', fc_seats=' || :NEW.total_fc_seats ||
                        ', econ_seats=' || :NEW.total_econ_seats;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.train_id;
        v_old_values := 'train_id=' || :OLD.train_id ||
                        ', train_number=' || :OLD.train_number ||
                        ', route=' || :OLD.source_station || '->' || :OLD.dest_station ||
                        ', fc_seats=' || :OLD.total_fc_seats ||
                        ', econ_seats=' || :OLD.total_econ_seats;
        v_new_values := 'train_id=' || :NEW.train_id ||
                        ', train_number=' || :NEW.train_number ||
                        ', route=' || :NEW.source_station || '->' || :NEW.dest_station ||
                        ', fc_seats=' || :NEW.total_fc_seats ||
                        ', econ_seats=' || :NEW.total_econ_seats;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.train_id;
        v_old_values := 'train_id=' || :OLD.train_id ||
                        ', train_number=' || :OLD.train_number ||
                        ', route=' || :OLD.source_station || '->' || :OLD.dest_station ||
                        ', fc_seats=' || :OLD.total_fc_seats ||
                        ', econ_seats=' || :OLD.total_econ_seats;
        v_new_values := NULL;
    END IF;

    INSERT INTO CRS_AUDIT_LOG (
        log_id, table_name, operation, record_id,
        old_values, new_values, changed_by, changed_at,
        client_ip, session_id
    ) VALUES (
        crs_audit_seq.NEXTVAL, 'CRS_TRAIN_INFO', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYSTIMESTAMP,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS'),
        SYS_CONTEXT('USERENV', 'SESSIONID')
    );
END;
/

PROMPT Train info audit trigger created.

-- ============================================================================
-- Create Audit Report View
-- ============================================================================
CREATE OR REPLACE VIEW AUDIT_REPORT_VIEW AS
SELECT 
    log_id,
    table_name,
    operation,
    record_id,
    SUBSTR(old_values, 1, 100) AS old_values_preview,
    SUBSTR(new_values, 1, 100) AS new_values_preview,
    changed_by,
    TO_CHAR(changed_at, 'YYYY-MM-DD HH24:MI:SS') AS changed_at,
    client_ip
FROM CRS_AUDIT_LOG
ORDER BY changed_at DESC;

-- Grant SELECT to report user
GRANT SELECT ON AUDIT_REPORT_VIEW TO CRS_REPORT_USER;
GRANT SELECT ON CRS_AUDIT_LOG TO CRS_REPORT_USER;

PROMPT Audit report view created.

-- ============================================================================
-- Verification
-- ============================================================================
PROMPT
PROMPT ============================================================
PROMPT AUDIT LOG VERIFICATION
PROMPT ============================================================

SELECT trigger_name, table_name, status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_AUDIT%'
ORDER BY trigger_name;

SELECT table_name, column_name, data_type
FROM user_tab_columns
WHERE table_name = 'CRS_AUDIT_LOG'
ORDER BY column_id;

COMMIT;

PROMPT
PROMPT ============================================================
PROMPT AUDIT LOG SETUP COMPLETE!
PROMPT ============================================================
PROMPT
PROMPT Audit triggers created for:
PROMPT   - CRS_PASSENGER (INSERT/UPDATE/DELETE)
PROMPT   - CRS_RESERVATION (INSERT/UPDATE/DELETE)
PROMPT   - CRS_TRAIN_INFO (INSERT/UPDATE/DELETE)
PROMPT
PROMPT To view audit logs:
PROMPT   SELECT * FROM AUDIT_REPORT_VIEW;
PROMPT
PROMPT ============================================================

-- ============================================================================
-- END OF AUDIT LOG SCRIPT
-- ============================================================================
