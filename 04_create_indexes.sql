-- ============================================================================
-- Commuter Reservation System (CRS) - Group 4
-- Indexes Creation Script
-- Date: November 2025
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Indexes (If Re-running)
-- ============================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_train_schedule_day';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_train_schedule_train';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_booking_passenger';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_booking_train';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_booking_travel_date';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP INDEX idx_booking_status';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ============================================================================
-- Create Indexes - Performance Optimization
-- ============================================================================

-- Indexes on CRS_TRAIN_SCHEDULE foreign keys
CREATE INDEX idx_train_schedule_day ON CRS_TRAIN_SCHEDULE(sch_id);
CREATE INDEX idx_train_schedule_train ON CRS_TRAIN_SCHEDULE(train_id);

-- Indexes on CRS_RESERVATION foreign keys
CREATE INDEX idx_booking_passenger ON CRS_RESERVATION(passenger_id);
CREATE INDEX idx_booking_train ON CRS_RESERVATION(train_id);

-- Indexes on frequently queried columns
CREATE INDEX idx_booking_travel_date ON CRS_RESERVATION(travel_date);
CREATE INDEX idx_booking_status ON CRS_RESERVATION(seat_status);

-- ============================================================================
-- Commit Changes
-- ============================================================================
COMMIT;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT index_name, table_name, uniqueness
FROM user_indexes
WHERE table_name LIKE 'CRS%'
ORDER BY table_name, index_name;

-- ============================================================================
-- END OF INDEX CREATION SCRIPT
-- Next: Run 05_insert_master_data.sql
-- ============================================================================