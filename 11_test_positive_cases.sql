-- ============================================================================
-- Commuter Reservation System (CRS)
-- Positive Test Cases - Business Rules Validation
-- Date: November 2025
-- Note: Run as CRS_DATA_USER
-- Prerequisites: Seed Data (File 10) must already be loaded
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

-- ============================================================================
-- TEST CASE 1: Capacity Enforcement
-- Book 40 FC seats -> Should be CONFIRMED
-- Next 5 bookings -> Should be WAITLISTED (positions 41-45)
-- 46th booking -> Should be rejected with -20016
-- ============================================================================

DECLARE
    v_booking_id        NUMBER;
    v_status            VARCHAR2(20);
    v_test_date         DATE := TRUNC(SYSDATE) + 5;
    v_confirmed_count   NUMBER := 0;
    v_waitlist_count    NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 1: Capacity Enforcement (40 Confirmed + 5 Waitlist)');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    -- Book the 40 confirmed seats
    FOR i IN 1..40 LOOP
        CRS_ADMIN_USER.CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000 + MOD(i - 1, 20),
            p_train_number => 'TR-101',
            p_travel_date  => v_test_date,
            p_seat_class   => 'FC',
            p_booking_id   => v_booking_id,
            p_status       => v_status
        );

        IF v_status = 'CONFIRMED' THEN
            v_confirmed_count := v_confirmed_count + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Booked 40 seats: ' || v_confirmed_count || ' confirmed.');

    -- Book 5 waitlist seats (41-45)
    FOR i IN 1..5 LOOP
        CRS_ADMIN_USER.CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000 + MOD(i - 1, 20),
            p_train_number => 'TR-101',
            p_travel_date  => v_test_date,
            p_seat_class   => 'FC',
            p_booking_id   => v_booking_id,
            p_status       => v_status
        );

        IF v_status = 'WAITLISTED' THEN
            v_waitlist_count := v_waitlist_count + 1;

            DECLARE
                v_pos NUMBER;
            BEGIN
                SELECT waitlist_position
                INTO v_pos
                FROM CRS_ADMIN_USER.CRS_RESERVATION
                WHERE booking_id = v_booking_id;

                DBMS_OUTPUT.PUT_LINE('Waitlist booking ' || i || ': Position = ' || v_pos);

                IF v_pos NOT BETWEEN 41 AND 45 THEN
                    DBMS_OUTPUT.PUT_LINE('ERROR: Invalid waitlist position = ' || v_pos);
                END IF;
            END;
        END IF;
    END LOOP;

    IF v_waitlist_count = 5 THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: 5 waitlist bookings created (41-45)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Expected 5 waitlist bookings, got ' || v_waitlist_count);
    END IF;

    -- 46th booking must be rejected
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Attempting 46th booking (should be rejected)...');

    BEGIN
        CRS_ADMIN_USER.CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000,
            p_train_number => 'TR-101',
            p_travel_date  => v_test_date,
            p_seat_class   => 'FC',
            p_booking_id   => v_booking_id,
            p_status       => v_status
        );

        DBMS_OUTPUT.PUT_LINE('TEST FAILED: 46th booking should have been rejected.');

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20016 THEN
                DBMS_OUTPUT.PUT_LINE('TEST PASSED: 46th booking correctly rejected.');
                DBMS_OUTPUT.PUT_LINE('Error message: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('TEST FAILED: Wrong error code: ' || SQLCODE);
            END IF;
    END;

    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- TEST CASE 2: Waitlist Promotion
-- Cancel a CONFIRMED booking -> first waitlisted passenger should be promoted
-- ============================================================================

DECLARE
    v_confirmed_booking_id      NUMBER;
    v_waitlist_booking_id       NUMBER;
    v_original_waitlist_pos     NUMBER;
    v_new_status                VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 2: Waitlist Promotion on Cancellation');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    SELECT booking_id
    INTO v_confirmed_booking_id
    FROM CRS_ADMIN_USER.CRS_RESERVATION
    WHERE seat_status = 'CONFIRMED'
      AND train_id = (SELECT train_id FROM CRS_ADMIN_USER.CRS_TRAIN_INFO WHERE train_number = 'TR-101')
      AND travel_date = TRUNC(SYSDATE) + 5
      AND seat_class = 'FC'
      AND ROWNUM = 1;

    SELECT booking_id, waitlist_position
    INTO v_waitlist_booking_id, v_original_waitlist_pos
    FROM CRS_ADMIN_USER.CRS_RESERVATION
    WHERE seat_status = 'WAITLISTED'
      AND train_id = (SELECT train_id FROM CRS_ADMIN_USER.CRS_TRAIN_INFO WHERE train_number = 'TR-101')
      AND travel_date = TRUNC(SYSDATE) + 5
      AND seat_class = 'FC'
    ORDER BY waitlist_position
    FETCH FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE('Confirmed booking to cancel: ' || v_confirmed_booking_id);
    DBMS_OUTPUT.PUT_LINE('Waitlisted booking to promote: ' || v_waitlist_booking_id ||
                         ' (Position ' || v_original_waitlist_pos || ')');

    CRS_ADMIN_USER.CRS_BOOKING_PKG.cancel_ticket(v_confirmed_booking_id);

    SELECT seat_status, waitlist_position
    INTO v_new_status, v_original_waitlist_pos
    FROM CRS_ADMIN_USER.CRS_RESERVATION
    WHERE booking_id = v_waitlist_booking_id;

    IF v_new_status = 'CONFIRMED' AND v_original_waitlist_pos IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: Waitlisted passenger promoted to CONFIRMED.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: New status = ' || v_new_status ||
                             ', Waitlist Pos = ' || NVL(TO_CHAR(v_original_waitlist_pos), 'NULL'));
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- TEST CASE 3: Advance Booking Validation
-- Booking travel_date > SYSDATE + 7 should fail with -20013
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
    v_status     VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 3: 7-Day Advance Booking Limit');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    BEGIN
        CRS_ADMIN_USER.CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000,
            p_train_number => 'TR-201',
            p_travel_date  => TRUNC(SYSDATE) + 8,
            p_seat_class   => 'ECON',
            p_booking_id   => v_booking_id,
            p_status       => v_status
        );

        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Booking should have been rejected.');

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20013 THEN
                DBMS_OUTPUT.PUT_LINE('TEST PASSED: Booking correctly rejected beyond 7-day limit.');
                DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('TEST FAILED: Wrong error code: ' || SQLCODE);
            END IF;
    END;

    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- TEST CASE 4: Duplicate Email Prevention
-- Should fail with error -20001
-- ============================================================================

DECLARE
    v_passenger_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 4: Duplicate Email Prevention');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    BEGIN
        CRS_ADMIN_USER.CRS_PASSENGER_PKG.add_passenger(
            p_first_name     => 'Duplicate',
            p_middle_name    => NULL,
            p_last_name      => 'Test',
            p_dob            => TO_DATE('1990-01-01', 'YYYY-MM-DD'),
            p_address_line1  => '999 Test St',
            p_city           => 'Boston',
            p_state          => 'MA',
            p_zip            => '02101',
            p_email          => 'john.smith@email.com',
            p_phone          => '617-555-9999',
            p_passenger_id   => v_passenger_id
        );

        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Duplicate email should have been rejected.');

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN
                DBMS_OUTPUT.PUT_LINE('TEST PASSED: Duplicate email correctly rejected.');
                DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('TEST FAILED: Wrong error code: ' || SQLCODE);
            END IF;
    END;

    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- TEST CASE 5: Schedule Availability
-- TR-101 runs only on weekdays -> booking on Saturday should fail (-20015)
-- ============================================================================

DECLARE
    v_booking_id  NUMBER;
    v_status      VARCHAR2(20);
    v_saturday    DATE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 5: Train Schedule Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    SELECT NEXT_DAY(TRUNC(SYSDATE), 'SATURDAY')
    INTO v_saturday FROM DUAL;

    IF v_saturday > TRUNC(SYSDATE) + 7 THEN
        v_saturday := v_saturday - 7;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Testing TR-101 on Saturday: ' ||
                         TO_CHAR(v_saturday, 'Day DD-MON-YYYY'));

    BEGIN
        CRS_ADMIN_USER.CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000,
            p_train_number => 'TR-101',
            p_travel_date  => v_saturday,
            p_seat_class   => 'FC',
            p_booking_id   => v_booking_id,
            p_status       => v_status
        );

        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Weekend booking should have been rejected.');

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20015 THEN
                DBMS_OUTPUT.PUT_LINE('TEST PASSED: Weekend booking correctly rejected.');
                DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('TEST FAILED: Wrong error code: ' || SQLCODE);
            END IF;
    END;

    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- TEST CASE 6: Age Category Feature
-- Test Minor/Adult/Senior Citizen classification based on DOB
-- ============================================================================

DECLARE
    v_category VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 6: Age Category Feature (Minor/Adult/Senior)');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    -- Test for ADULT (existing passenger born 1985)
    v_category := CRS_ADMIN_USER.get_passenger_category(1000);
    DBMS_OUTPUT.PUT_LINE('Passenger 1000 (DOB: 1985): ' || v_category);
    IF v_category = 'ADULT' THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: Correctly identified as ADULT');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Expected ADULT, got ' || v_category);
    END IF;
    
    -- Test for MINOR (Tommy Young - 15 years old)
    v_category := CRS_ADMIN_USER.get_passenger_category(1020);
    DBMS_OUTPUT.PUT_LINE('Passenger 1020 (Age: 15): ' || v_category);
    IF v_category = 'MINOR' THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: Correctly identified as MINOR');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Expected MINOR, got ' || v_category);
    END IF;
    
    -- Test for SENIOR CITIZEN (Margaret Elder - 65 years old)
    v_category := CRS_ADMIN_USER.get_passenger_category(1021);
    DBMS_OUTPUT.PUT_LINE('Passenger 1021 (Age: 65): ' || v_category);
    IF v_category = 'SENIOR CITIZEN' THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: Correctly identified as SENIOR CITIZEN');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Expected SENIOR CITIZEN, got ' || v_category);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- SUMMARY REPORT
-- ============================================================================

DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('POSITIVE TEST EXECUTION SUMMARY');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('Test Case 1: Capacity Enforcement (40+5)    - Executed');
    DBMS_OUTPUT.PUT_LINE('Test Case 2: Waitlist Promotion             - Executed');
    DBMS_OUTPUT.PUT_LINE('Test Case 3: 7-Day Advance Booking          - Executed');
    DBMS_OUTPUT.PUT_LINE('Test Case 4: Duplicate Email Prevention     - Executed');
    DBMS_OUTPUT.PUT_LINE('Test Case 5: Train Schedule Validation      - Executed');
    DBMS_OUTPUT.PUT_LINE('Test Case 6: Age Category Feature           - Executed');
    DBMS_OUTPUT.PUT_LINE('============================================================');
END;
/

SELECT 
    COUNT(*) AS total_passengers,
    (SELECT COUNT(*) FROM CRS_ADMIN_USER.CRS_RESERVATION WHERE seat_status = 'CONFIRMED')   AS confirmed_bookings,
    (SELECT COUNT(*) FROM CRS_ADMIN_USER.CRS_RESERVATION WHERE seat_status = 'WAITLISTED')  AS waitlisted_bookings,
    (SELECT COUNT(*) FROM CRS_ADMIN_USER.CRS_RESERVATION WHERE seat_status = 'CANCELLED')   AS cancelled_bookings
FROM CRS_ADMIN_USER.CRS_PASSENGER;

-- Age Category Summary
SELECT category, COUNT(*) AS count
FROM CRS_ADMIN_USER.PASSENGER_AGE_VIEW
GROUP BY category
ORDER BY category;

-- ============================================================================
-- END OF POSITIVE TEST CASES
-- Next: Run 12_test_negative_cases.sql
-- ============================================================================