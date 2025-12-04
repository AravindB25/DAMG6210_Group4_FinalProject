-- ============================================================================
-- Commuter Reservation System (CRS)Group 4
-- Waitlist Promotion Trigger
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Trigger
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
-- Create Waitlist Promotion Trigger (Compound Trigger)
-- Fixes mutating table error by using AFTER STATEMENT timing
-- Automatically promotes the first waitlisted passenger when a confirmed
-- booking is cancelled.
-- Waitlist positions: 41-45 (5 positions)
-- ============================================================================
CREATE OR REPLACE TRIGGER trg_promote_waitlist
FOR UPDATE OF seat_status ON CRS_RESERVATION
COMPOUND TRIGGER

    -- Collection to store cancelled booking info
    TYPE t_cancelled_booking IS RECORD (
        train_id       NUMBER,
        travel_date    DATE,
        seat_class     VARCHAR2(10)
    );
    
    TYPE t_cancelled_list IS TABLE OF t_cancelled_booking INDEX BY PLS_INTEGER;
    g_cancelled t_cancelled_list;
    g_count     PLS_INTEGER := 0;

    -- ========================================================================
    -- AFTER EACH ROW: Capture cancelled booking details
    -- ========================================================================
    AFTER EACH ROW IS
    BEGIN
        IF :OLD.seat_status = 'CONFIRMED' AND :NEW.seat_status = 'CANCELLED' THEN
            g_count := g_count + 1;
            g_cancelled(g_count).train_id := :NEW.train_id;
            g_cancelled(g_count).travel_date := :NEW.travel_date;
            g_cancelled(g_count).seat_class := :NEW.seat_class;
        END IF;
    END AFTER EACH ROW;

    -- ========================================================================
    -- AFTER STATEMENT: Process waitlist promotions
    -- ========================================================================
    AFTER STATEMENT IS
        v_next_booking_id   NUMBER;
        v_waitlist_pos      NUMBER;
    BEGIN
        FOR i IN 1..g_count LOOP
            BEGIN
                -- Find first waitlisted passenger
                SELECT booking_id, waitlist_position
                INTO v_next_booking_id, v_waitlist_pos
                FROM (
                    SELECT booking_id, waitlist_position
                    FROM CRS_RESERVATION
                    WHERE train_id = g_cancelled(i).train_id
                      AND travel_date = g_cancelled(i).travel_date
                      AND seat_class = g_cancelled(i).seat_class
                      AND seat_status = 'WAITLISTED'
                    ORDER BY waitlist_position ASC
                )
                WHERE ROWNUM = 1;

                -- Promote to confirmed
                UPDATE CRS_RESERVATION
                SET seat_status = 'CONFIRMED',
                    waitlist_position = NULL
                WHERE booking_id = v_next_booking_id;

                -- Decrement remaining waitlist positions
                UPDATE CRS_RESERVATION
                SET waitlist_position = waitlist_position - 1
                WHERE train_id = g_cancelled(i).train_id
                  AND travel_date = g_cancelled(i).travel_date
                  AND seat_class = g_cancelled(i).seat_class
                  AND seat_status = 'WAITLISTED'
                  AND waitlist_position > v_waitlist_pos;

                DBMS_OUTPUT.PUT_LINE('Promoted booking ' || v_next_booking_id || 
                                     ' from waitlist position ' || v_waitlist_pos);

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No waitlisted passengers to promote');
            END;
        END LOOP;
        
        -- Reset counter
        g_count := 0;
    END AFTER STATEMENT;

END trg_promote_waitlist;
/

-- ============================================================================
-- Verification
-- ============================================================================
SELECT trigger_name, status, trigger_type, triggering_event
FROM user_triggers
WHERE trigger_name = 'TRG_PROMOTE_WAITLIST';

COMMIT;

PROMPT ============================================================
PROMPT Waitlist promotion trigger (compound) created successfully.
PROMPT ============================================================