-- ============================================================================
-- Commuter Reservation System (CRS)
-- Waitlist Promotion Trigger
-- Date: November 2025
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Trigger (If Re-running)
-- ============================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_promote_waitlist';
    DBMS_OUTPUT.PUT_LINE('Dropped existing trigger');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('No existing trigger found');
END;
/
 
-- ============================================================================
-- Create Waitlist Promotion Trigger
-- Automatically promotes the first waitlisted passenger when a confirmed
-- booking is cancelled.
-- Waitlist positions: 41-45 (5 positions)
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_promote_waitlist
AFTER UPDATE OF seat_status ON CRS_RESERVATION
FOR EACH ROW
WHEN (
    OLD.seat_status = 'CONFIRMED'
    AND NEW.seat_status = 'CANCELLED'
)
DECLARE
    v_next_waitlist_booking_id   NUMBER;
    v_current_waitlist_position  NUMBER;
BEGIN
    BEGIN
        -- Fetch the first waitlisted passenger
        SELECT booking_id, waitlist_position
        INTO v_next_waitlist_booking_id, v_current_waitlist_position
        FROM (
            SELECT booking_id, waitlist_position
            FROM CRS_RESERVATION
            WHERE train_id     = :NEW.train_id
              AND travel_date  = :NEW.travel_date
              AND seat_class   = :NEW.seat_class
              AND seat_status  = 'WAITLISTED'
            ORDER BY waitlist_position ASC
        )
        WHERE ROWNUM = 1;
        
        -- Promote the passenger to confirmed
        UPDATE CRS_RESERVATION
        SET seat_status = 'CONFIRMED',
            waitlist_position = NULL
        WHERE booking_id = v_next_waitlist_booking_id;
        
        DBMS_OUTPUT.PUT_LINE(
            'Promoted booking ' || v_next_waitlist_booking_id ||
            ' from waitlist position ' || v_current_waitlist_position
        );

        -- Decrement waitlist positions for remaining passengers
        UPDATE CRS_RESERVATION
        SET waitlist_position = waitlist_position - 1
        WHERE train_id     = :NEW.train_id
          AND travel_date  = :NEW.travel_date
          AND seat_class   = :NEW.seat_class
          AND seat_status  = 'WAITLISTED'
          AND waitlist_position > v_current_waitlist_position;

        DBMS_OUTPUT.PUT_LINE('Updated remaining waitlist positions');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No waitlisted passengers to promote');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(
                -20030,
                'Error during waitlist promotion: ' || SQLERRM
            );
    END;
END;
/
 
-- ============================================================================
-- Verification
-- ============================================================================
SELECT trigger_name, status, trigger_type, triggering_event
FROM user_triggers
WHERE trigger_name = 'TRG_PROMOTE_WAITLIST';

COMMIT;

PROMPT Waitlist promotion trigger created successfully.
PROMPT Next: Run 09_grant_permissions.sql

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================