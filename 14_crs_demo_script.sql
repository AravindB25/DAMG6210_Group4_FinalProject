-- ============================================================================
-- COMMUTER RESERVATION SYSTEM (CRS) - LIVE DEMO SCRIPT
-- DAMG 6210 - Group_Lab_Team_22
-- Run as: CRS_ADMIN_USER or CRS_DATA_USER
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
SET PAGESIZE 100;

PROMPT ========================================================================
PROMPT                    CRS LIVE DEMONSTRATION
PROMPT ========================================================================
PROMPT

-- ============================================================================
-- PART 1: SHOW DATABASE STRUCTURE
-- ============================================================================

PROMPT [DEMO 1] Showing all CRS tables created...
PROMPT --------------------------------------------------------
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name LIKE 'CRS%' 
ORDER BY table_name;

PROMPT
PROMPT [DEMO 2] Showing all constraints (PK, FK, CHECK)...
PROMPT --------------------------------------------------------
SELECT constraint_name, constraint_type, table_name, status
FROM user_constraints 
WHERE table_name LIKE 'CRS%'
ORDER BY table_name, constraint_type;

PROMPT
PROMPT [DEMO 3] Showing all indexes for performance...
PROMPT --------------------------------------------------------
SELECT index_name, table_name, uniqueness
FROM user_indexes
WHERE table_name LIKE 'CRS%'
ORDER BY table_name;

PROMPT
PROMPT [DEMO 4] Showing sequences for auto-generated IDs...
PROMPT --------------------------------------------------------
SELECT sequence_name, last_number 
FROM user_sequences 
WHERE sequence_name LIKE 'CRS%';

PROMPT
PROMPT [DEMO 5] Showing PL/SQL packages created...
PROMPT --------------------------------------------------------
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'VIEW')
ORDER BY object_type, object_name;

-- ============================================================================
-- PART 2: SHOW MASTER DATA
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT                    MASTER DATA OVERVIEW
PROMPT ========================================================================

PROMPT
PROMPT [DEMO 6] Day Schedule (7 days with weekend flag)...
PROMPT --------------------------------------------------------
SELECT * FROM CRS_DAY_SCHEDULE ORDER BY sch_id;

PROMPT
PROMPT [DEMO 7] Train Information...
PROMPT --------------------------------------------------------
SELECT train_id, train_number, source_station, dest_station, 
       total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare
FROM CRS_TRAIN_INFO ORDER BY train_id;

PROMPT
PROMPT [DEMO 8] Train Schedule (which trains run on which days)...
PROMPT --------------------------------------------------------
SELECT t.train_number, 
       LISTAGG(d.day_of_week, ', ') WITHIN GROUP (ORDER BY d.sch_id) AS operating_days
FROM CRS_TRAIN_INFO t
JOIN CRS_TRAIN_SCHEDULE ts ON t.train_id = ts.train_id
JOIN CRS_DAY_SCHEDULE d ON ts.sch_id = d.sch_id
WHERE ts.is_in_service = 'Y'
GROUP BY t.train_number
ORDER BY t.train_number;

PROMPT
PROMPT [DEMO 9] Sample Passengers (first 5)...
PROMPT --------------------------------------------------------
SELECT passenger_id, first_name || ' ' || last_name AS name, email, phone
FROM CRS_PASSENGER
WHERE ROWNUM <= 5
ORDER BY passenger_id;

-- ============================================================================
-- PART 3: LIVE BOOKING DEMONSTRATION
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT              LIVE BOOKING DEMONSTRATION
PROMPT ========================================================================

-- Demo: Add a new passenger
PROMPT
PROMPT [DEMO 10] Adding a NEW PASSENGER...
PROMPT --------------------------------------------------------
DECLARE
    v_passenger_id NUMBER;
BEGIN
    CRS_PASSENGER_PKG.add_passenger(
        p_first_name => 'Demo',
        p_middle_name => 'Live',
        p_last_name => 'Presentation',
        p_dob => TO_DATE('1995-05-15', 'YYYY-MM-DD'),
        p_address_line1 => '360 Huntington Ave',
        p_city => 'Boston',
        p_state => 'MA',
        p_zip => '02115',
        p_email => 'demo.presentation@northeastern.edu',
        p_phone => '617-373-0001',
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('SUCCESS: New passenger created with ID: ' || v_passenger_id);
END;
/

-- Verify passenger was added
PROMPT
PROMPT Verifying new passenger...
SELECT passenger_id, first_name || ' ' || last_name AS name, email
FROM CRS_PASSENGER
WHERE email = 'demo.presentation@northeastern.edu';

-- Demo: Book a ticket
PROMPT
PROMPT [DEMO 11] Booking a FIRST CLASS ticket...
PROMPT --------------------------------------------------------
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
    v_passenger_id NUMBER;
BEGIN
    -- Get the demo passenger ID
    SELECT passenger_id INTO v_passenger_id
    FROM CRS_PASSENGER
    WHERE email = 'demo.presentation@northeastern.edu';
    
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => v_passenger_id,
        p_train_number => 'TR-201',  -- Boston to Washington DC
        p_travel_date => TRUNC(SYSDATE) + 2,
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Booking ID: ' || v_booking_id || ', Status: ' || v_status);
END;
/

-- Show booking details
PROMPT
PROMPT [DEMO 12] Viewing booking details...
PROMPT --------------------------------------------------------
SELECT r.booking_id, 
       p.first_name || ' ' || p.last_name AS passenger,
       t.train_number,
       t.source_station || ' -> ' || t.dest_station AS route,
       TO_CHAR(r.travel_date, 'DD-MON-YYYY') AS travel_date,
       r.seat_class,
       r.seat_status
FROM CRS_RESERVATION r
JOIN CRS_PASSENGER p ON r.passenger_id = p.passenger_id
JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
WHERE p.email = 'demo.presentation@northeastern.edu';

-- ============================================================================
-- PART 4: BUSINESS RULES VALIDATION
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT           BUSINESS RULES VALIDATION (NEGATIVE TESTS)
PROMPT ========================================================================

-- Test: Duplicate email rejection
PROMPT
PROMPT [DEMO 13] Testing DUPLICATE EMAIL rejection...
PROMPT --------------------------------------------------------
DECLARE
    v_passenger_id NUMBER;
BEGIN
    CRS_PASSENGER_PKG.add_passenger(
        p_first_name => 'Duplicate',
        p_middle_name => NULL,
        p_last_name => 'Test',
        p_dob => TO_DATE('1990-01-01', 'YYYY-MM-DD'),
        p_address_line1 => '123 Test St',
        p_city => 'Boston',
        p_state => 'MA',
        p_zip => '02101',
        p_email => 'john.smith@email.com',  -- Already exists!
        p_phone => '617-999-9999',
        p_passenger_id => v_passenger_id
    );
    DBMS_OUTPUT.PUT_LINE('FAIL: Should have rejected duplicate email');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Duplicate email rejected!');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Test: Booking beyond 7 days
PROMPT
PROMPT [DEMO 14] Testing 7-DAY ADVANCE BOOKING limit...
PROMPT --------------------------------------------------------
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 1000,
        p_train_number => 'TR-101',
        p_travel_date => TRUNC(SYSDATE) + 15,  -- 15 days ahead!
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    DBMS_OUTPUT.PUT_LINE('FAIL: Should have rejected advance booking');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Booking beyond 7 days rejected!');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Test: Invalid train number
PROMPT
PROMPT [DEMO 15] Testing INVALID TRAIN NUMBER...
PROMPT --------------------------------------------------------
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 1000,
        p_train_number => 'TR-999',  -- Does not exist!
        p_travel_date => TRUNC(SYSDATE) + 1,
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    DBMS_OUTPUT.PUT_LINE('FAIL: Should have rejected invalid train');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Invalid train number rejected!');
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- ============================================================================
-- PART 5: CAPACITY & WAITLIST DEMONSTRATION
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT            CAPACITY & WAITLIST DEMONSTRATION
PROMPT ========================================================================

PROMPT
PROMPT [DEMO 16] Checking seat availability using function...
PROMPT --------------------------------------------------------
DECLARE
    v_available NUMBER;
BEGIN
    v_available := CRS_BOOKING_PKG.check_availability('TR-101', TRUNC(SYSDATE) + 3, 'FC');
    DBMS_OUTPUT.PUT_LINE('Available FC seats on TR-101 for ' || 
                         TO_CHAR(TRUNC(SYSDATE) + 3, 'DD-MON-YYYY') || ': ' || v_available);
    
    v_available := CRS_BOOKING_PKG.check_availability('TR-101', TRUNC(SYSDATE) + 3, 'ECON');
    DBMS_OUTPUT.PUT_LINE('Available ECON seats on TR-101 for ' || 
                         TO_CHAR(TRUNC(SYSDATE) + 3, 'DD-MON-YYYY') || ': ' || v_available);
END;
/

-- ============================================================================
-- PART 6: CANCELLATION & WAITLIST PROMOTION
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT         CANCELLATION & WAITLIST PROMOTION (TRIGGER DEMO)
PROMPT ========================================================================

PROMPT
PROMPT [DEMO 17] Current bookings status...
PROMPT --------------------------------------------------------
SELECT seat_status, COUNT(*) AS count
FROM CRS_RESERVATION
GROUP BY seat_status
ORDER BY seat_status;

-- ============================================================================
-- PART 7: REPORTING VIEWS
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT                    MANAGEMENT REPORTS
PROMPT ========================================================================

PROMPT
PROMPT [DEMO 18] Booking Report View (sample)...
PROMPT --------------------------------------------------------
SELECT booking_id, passenger_name, train_number, route, 
       TO_CHAR(travel_date, 'DD-MON') AS travel, seat_class, seat_status
FROM BOOKING_REPORT_VIEW
WHERE ROWNUM <= 10
ORDER BY booking_id DESC;

PROMPT
PROMPT [DEMO 19] Revenue Analysis View...
PROMPT --------------------------------------------------------
SELECT train_number, route, seat_class, 
       confirmed_bookings, total_revenue, capacity_utilization || '%' AS utilization
FROM REVENUE_VIEW
WHERE confirmed_bookings > 0
ORDER BY total_revenue DESC;

-- ============================================================================
-- PART 8: CLEANUP (Optional - Run after demo)
-- ============================================================================

PROMPT
PROMPT ========================================================================
PROMPT                    DEMO COMPLETE!
PROMPT ========================================================================
PROMPT
PROMPT To cleanup demo data, run:
PROMPT   DELETE FROM CRS_RESERVATION WHERE passenger_id = (SELECT passenger_id FROM CRS_PASSENGER WHERE email = 'demo.presentation@northeastern.edu');
PROMPT   DELETE FROM CRS_PASSENGER WHERE email = 'demo.presentation@northeastern.edu';
PROMPT   COMMIT;
PROMPT
PROMPT ========================================================================
