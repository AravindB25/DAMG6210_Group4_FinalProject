-- ============================================================================
-- Commuter Reservation System (CRS) Group 4
-- Negative Test Cases - Exception Handling Validation
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;

-- ============================================================================
-- Test 1: Duplicate Email (Error -20001)
-- ============================================================================

DECLARE
    v_passenger_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 1: Duplicate Email Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_PASSENGER_PKG.add_passenger(
        p_first_name => 'Duplicate', 
        p_middle_name => NULL, 
        p_last_name => 'EmailTest',
        p_dob => TO_DATE('1990-01-01', 'YYYY-MM-DD'),
        p_address_line1 => '999 Test Street', 
        p_city => 'Boston',
        p_state => 'MA', 
        p_zip => '02101',
        p_email => 'john.smith@email.com',
        p_phone => '617-555-9001',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised duplicate email error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20001 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected duplicate email');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 2: Duplicate Phone (Error -20002)
-- ============================================================================

DECLARE
    v_passenger_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 2: Duplicate Phone Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_PASSENGER_PKG.add_passenger(
        p_first_name => 'Duplicate', 
        p_middle_name => NULL, 
        p_last_name => 'PhoneTest',
        p_dob => TO_DATE('1990-01-01', 'YYYY-MM-DD'),
        p_address_line1 => '999 Test Street', 
        p_city => 'Boston',
        p_state => 'MA', 
        p_zip => '02101',
        p_email => 'unique.email@test.com',
        p_phone => '617-555-0001',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised duplicate phone error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20002 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected duplicate phone');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 3: Future Date of Birth (Error -20003)
-- ============================================================================

DECLARE
    v_passenger_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 3: Future Date of Birth Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_PASSENGER_PKG.add_passenger(
        p_first_name => 'Future', 
        p_middle_name => NULL, 
        p_last_name => 'Baby',
        p_dob => TO_DATE('2030-12-31', 'YYYY-MM-DD'),
        p_address_line1 => '999 Test Street', 
        p_city => 'Boston',
        p_state => 'MA', 
        p_zip => '02101',
        p_email => 'future.baby@test.com',
        p_phone => '617-555-8001',
        p_passenger_id => v_passenger_id
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised future DOB error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20003 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected future date of birth');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 4: Invalid Passenger ID (Error -20010)
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 4: Non-existent Passenger ID Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 99999,
        p_train_number => 'TR-101',
        p_travel_date => TRUNC(SYSDATE) + 3,
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised invalid passenger error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20010 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected invalid passenger ID');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 5: Invalid Train Number (Error -20011)
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 5: Non-existent Train Number Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 1000,
        p_train_number => 'TR-999',
        p_travel_date => TRUNC(SYSDATE) + 3,
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised invalid train error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20011 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected invalid train number');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 6: Invalid Seat Class (Error -20012)
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 6: Invalid Seat Class Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 1000,
        p_train_number => 'TR-101',
        p_travel_date => TRUNC(SYSDATE) + 3,
        p_seat_class => 'BUSINESS',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised invalid seat class error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20012 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected invalid seat class');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 7: Booking Beyond 7-Day Window (Error -20013)
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 7: Advance Booking Limit Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 1000,
        p_train_number => 'TR-101',
        p_travel_date => TRUNC(SYSDATE) + 10,
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised advance booking limit error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20013 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected booking beyond 7 days');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 8: Past Date Booking (Error -20014)
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 8: Past Date Booking Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 1000,
        p_train_number => 'TR-101',
        p_travel_date => TRUNC(SYSDATE) - 1,
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised past date error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20014 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected past date booking');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 9: Cancel Non-existent Booking (Error -20020)
-- ============================================================================

DECLARE
    v_booking_id NUMBER := 99999;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 9: Non-existent Booking Cancellation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    CRS_BOOKING_PKG.cancel_ticket(v_booking_id);
    
    DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised booking not found error');
    DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -20020 THEN
            DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected non-existent booking');
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Test 10: Cancel Already Cancelled Booking (Error -20021)
-- ============================================================================

DECLARE
    v_booking_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 10: Double Cancellation Validation');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    BEGIN
        SELECT booking_id INTO v_booking_id
        FROM CRS_RESERVATION
        WHERE seat_status = 'CONFIRMED'
        AND ROWNUM = 1;

        DBMS_OUTPUT.PUT_LINE('Cancelling booking: ' || v_booking_id);
        
        CRS_BOOKING_PKG.cancel_ticket(v_booking_id);
        DBMS_OUTPUT.PUT_LINE('First cancellation successful');

        CRS_BOOKING_PKG.cancel_ticket(v_booking_id);

        DBMS_OUTPUT.PUT_LINE('FAILED: Should have raised already cancelled error');
        DBMS_OUTPUT.PUT_LINE('');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20021 THEN
                DBMS_OUTPUT.PUT_LINE('PASSED: Correctly rejected double cancellation');
                DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('FAILED: Wrong error code - ' || SQLCODE);
            END IF;
            DBMS_OUTPUT.PUT_LINE('');
    END;
END;
/

-- ============================================================================
-- Test 11: Age Category - Non-existent Passenger
-- ============================================================================

DECLARE
    v_category VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST 11: Age Category - Non-existent Passenger');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    
    v_category := get_passenger_category(99999);
    
    IF v_category = 'PASSENGER NOT FOUND' THEN
        DBMS_OUTPUT.PUT_LINE('PASSED: Correctly handled non-existent passenger');
        DBMS_OUTPUT.PUT_LINE('Result: ' || v_category);
    ELSE
        DBMS_OUTPUT.PUT_LINE('FAILED: Expected PASSENGER NOT FOUND, got ' || v_category);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- ============================================================================
-- Summary
-- ============================================================================

BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('NEGATIVE TEST EXECUTION SUMMARY');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('Test 1:  Duplicate Email (-20001)           - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 2:  Duplicate Phone (-20002)           - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 3:  Future DOB (-20003)                - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 4:  Invalid Passenger ID (-20010)      - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 5:  Invalid Train Number (-20011)      - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 6:  Invalid Seat Class (-20012)        - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 7:  Beyond 7-Day Limit (-20013)        - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 8:  Past Date Booking (-20014)         - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 9:  Non-existent Booking (-20020)      - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 10: Double Cancellation (-20021)       - Executed');
    DBMS_OUTPUT.PUT_LINE('Test 11: Age Category Invalid Passenger     - Executed');
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('All tests validate proper exception handling');
    DBMS_OUTPUT.PUT_LINE('============================================================');
END;
/