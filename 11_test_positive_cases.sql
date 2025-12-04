-- ============================================================================
-- Commuter Reservation System (CRS)Group 4
-- Positive Test Cases - Business Rules Validation
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

-- ============================================================================
-- TEST CASE 1: Capacity Enforcement
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

    FOR i IN 1..40 LOOP
        CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000 + MOD(i - 1, 20),
            p_train_number => 'TR-102',
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

    FOR i IN 1..5 LOOP
        CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000 + MOD(i - 1, 20),
            p_train_number => 'TR-102',
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
                FROM CRS_RESERVATION
                WHERE booking_id = v_booking_id;

                DBMS_OUTPUT.PUT_LINE('Waitlist booking ' || v_waitlist_count || ': Position = ' || v_pos);
            END;
        END IF;
    END LOOP;

    IF v_waitlist_count = 5 THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: 5 waitlist bookings created (41-45)');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Expected 5 waitlist bookings, got ' || v_waitlist_count);
    END IF;

    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Attempting 46th booking (should be rejected)...');

    BEGIN
        CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000,
            p_train_number => 'TR-102',
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
-- ============================================================================

DECLARE
    v_confirmed_id NUMBER;
    v_waitlist_id NUMBER;
    v_old_pos NUMBER;
    v_new_status VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 2: Waitlist Promotion on Cancellation');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    SELECT booking_id INTO v_confirmed_id
    FROM CRS_RESERVATION
    WHERE seat_status = 'CONFIRMED'
      AND train_id = (SELECT train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TR-102')
      AND ROWNUM = 1;

    SELECT booking_id, waitlist_position INTO v_waitlist_id, v_old_pos
    FROM CRS_RESERVATION
    WHERE seat_status = 'WAITLISTED'
      AND train_id = (SELECT train_id FROM CRS_TRAIN_INFO WHERE train_number = 'TR-102')
    ORDER BY waitlist_position
    FETCH FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE('Confirmed booking to cancel: ' || v_confirmed_id);
    DBMS_OUTPUT.PUT_LINE('Waitlisted booking to promote: ' || v_waitlist_id || ' (Position ' || v_old_pos || ')');

    CRS_BOOKING_PKG.cancel_ticket(v_confirmed_id);

    SELECT seat_status INTO v_new_status
    FROM CRS_RESERVATION 
    WHERE booking_id = v_waitlist_id;

    IF v_new_status = 'CONFIRMED' THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: Waitlisted passenger promoted to CONFIRMED');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Status is ' || v_new_status);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- TEST CASE 3: Advance Booking Validation
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
    v_status     VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 3: 7-Day Advance Booking Limit');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    BEGIN
        CRS_BOOKING_PKG.book_ticket(
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
-- ============================================================================

DECLARE
    v_passenger_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 4: Duplicate Email Prevention');
    DBMS_OUTPUT.PUT_LINE('============================================================');

    BEGIN
        CRS_PASSENGER_PKG.add_passenger(
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
        CRS_BOOKING_PKG.book_ticket(
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
-- ============================================================================

DECLARE
    v_category VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('TEST CASE 6: Age Category Feature (Minor/Adult/Senior)');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    v_category := get_passenger_category(1000);
    DBMS_OUTPUT.PUT_LINE('Passenger 1000 (DOB: 1985): ' || v_category);
    IF v_category = 'ADULT' THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: Correctly identified as ADULT');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Expected ADULT, got ' || v_category);
    END IF;
    
    v_category := get_passenger_category(1020);
    DBMS_OUTPUT.PUT_LINE('Passenger 1020 (Age: 15): ' || v_category);
    IF v_category = 'MINOR' THEN
        DBMS_OUTPUT.PUT_LINE('TEST PASSED: Correctly identified as MINOR');
    ELSE
        DBMS_OUTPUT.PUT_LINE('TEST FAILED: Expected MINOR, got ' || v_category);
    END IF;
    
    v_category := get_passenger_category(1021);
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

-- ============================================================================
-- FINAL VERIFICATION
-- ============================================================================

SELECT seat_status, COUNT(*) AS count 
FROM CRS_RESERVATION 
GROUP BY seat_status 
ORDER BY seat_status;

SELECT category, COUNT(*) AS count
FROM PASSENGER_AGE_VIEW
GROUP BY category
ORDER BY category;