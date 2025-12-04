-- ============================================================================
-- Commuter Reservation System (CRS) Group 4
-- Indexes Creation Script
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Indexes (If Re-running)
-- ============================================================================
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_train_schedule_day'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_train_schedule_train'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_booking_passenger'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_booking_train'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_booking_travel_date'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_booking_status'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_booking_train_date_class'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- These two lines removed (Oracle auto-created indexes due to constraints)
-- BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_passenger_email'; EXCEPTION WHEN OTHERS THEN NULL; END;
-- /
-- BEGIN EXECUTE IMMEDIATE 'DROP INDEX idx_train_number'; EXCEPTION WHEN OTHERS THEN NULL; END;
-- /

-- ============================================================================
-- Create Indexes - Performance Optimization
-- ============================================================================

-- CRS_TRAIN_SCHEDULE foreign keys
CREATE INDEX idx_train_schedule_day ON CRS_TRAIN_SCHEDULE(sch_id);
CREATE INDEX idx_train_schedule_train ON CRS_TRAIN_SCHEDULE(train_id);

-- CRS_RESERVATION foreign keys
CREATE INDEX idx_booking_passenger ON CRS_RESERVATION(passenger_id);
CREATE INDEX idx_booking_train ON CRS_RESERVATION(train_id);

-- Frequent query columns
CREATE INDEX idx_booking_travel_date ON CRS_RESERVATION(travel_date);
CREATE INDEX idx_booking_status ON CRS_RESERVATION(seat_status);

-- Composite index for availability check
CREATE INDEX idx_booking_train_date_class 
ON CRS_RESERVATION(train_id, travel_date, seat_class, seat_status);

-- Removed (Oracle already created unique index via constraint)
-- CREATE INDEX idx_passenger_email ON CRS_PASSENGER(email);

-- Removed (Oracle already created unique index via constraint)
-- CREATE INDEX idx_train_number ON CRS_TRAIN_INFO(train_number);

-- ============================================================================
-- Commit
-- ============================================================================
COMMIT;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT index_name, table_name, uniqueness
FROM user_indexes
WHERE table_name LIKE 'CRS%'
ORDER BY table_name, index_name;

PROMPT ============================================================
PROMPT Indexes created successfully with performance optimizations
PROMPT ============================================================

-- ============================================================================
-- END OF SCRIPT
-- Next: Run 05_insert_master_data.sql
-- ============================================================================
