-- ============================================================================
-- Commuter Reservation System (CRS)Group 4
-- Seed Data Insertion Script
-- Note: Run as CRS_ADMIN_USER
-- Prerequisites: Master data (trains, schedules) must exist
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Insert Sample Passengers (20 passengers)
-- ============================================================================

-- Passenger 1
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'John', 'A', 'Smith', TO_DATE('1985-03-15', 'YYYY-MM-DD'),
    '123 Main St', 'Boston', 'MA', '02101', 'john.smith@email.com', '617-555-0001');

-- Passenger 2
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Sarah', 'B', 'Johnson', TO_DATE('1990-07-22', 'YYYY-MM-DD'),
    '456 Oak Ave', 'New York', 'NY', '10001', 'sarah.johnson@email.com', '212-555-0002');

-- Passenger 3
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Michael', NULL, 'Williams', TO_DATE('1988-11-30', 'YYYY-MM-DD'),
    '789 Pine Rd', 'Philadelphia', 'PA', '19101', 'michael.williams@email.com', '215-555-0003');

-- Passenger 4
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Emily', 'C', 'Brown', TO_DATE('1992-05-18', 'YYYY-MM-DD'),
    '321 Elm St', 'Washington', 'DC', '20001', 'emily.brown@email.com', '202-555-0004');

-- Passenger 5
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'David', 'D', 'Davis', TO_DATE('1987-09-25', 'YYYY-MM-DD'),
    '654 Maple Dr', 'Boston', 'MA', '02102', 'david.davis@email.com', '617-555-0005');

-- Passenger 6
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Jessica', NULL, 'Miller', TO_DATE('1991-12-10', 'YYYY-MM-DD'),
    '987 Cedar Ln', 'New York', 'NY', '10002', 'jessica.miller@email.com', '212-555-0006');

-- Passenger 7
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Robert', 'E', 'Wilson', TO_DATE('1986-04-08', 'YYYY-MM-DD'),
    '147 Birch Ave', 'Philadelphia', 'PA', '19102', 'robert.wilson@email.com', '215-555-0007');

-- Passenger 8
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Amanda', 'F', 'Moore', TO_DATE('1993-08-14', 'YYYY-MM-DD'),
    '258 Spruce St', 'Washington', 'DC', '20002', 'amanda.moore@email.com', '202-555-0008');

-- Passenger 9
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Christopher', NULL, 'Taylor', TO_DATE('1989-02-20', 'YYYY-MM-DD'),
    '369 Willow Ct', 'Boston', 'MA', '02103', 'christopher.taylor@email.com', '617-555-0009');

-- Passenger 10
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Jennifer', 'G', 'Anderson', TO_DATE('1994-06-12', 'YYYY-MM-DD'),
    '741 Poplar Rd', 'New York', 'NY', '10003', 'jennifer.anderson@email.com', '212-555-0010');

-- Passenger 11
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Matthew', 'H', 'Thomas', TO_DATE('1987-10-05', 'YYYY-MM-DD'),
    '852 Ash Blvd', 'Philadelphia', 'PA', '19103', 'matthew.thomas@email.com', '215-555-0011');

-- Passenger 12
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Ashley', NULL, 'Jackson', TO_DATE('1992-03-28', 'YYYY-MM-DD'),
    '963 Hickory Way', 'Washington', 'DC', '20003', 'ashley.jackson@email.com', '202-555-0012');

-- Passenger 13
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Daniel', 'I', 'White', TO_DATE('1988-07-16', 'YYYY-MM-DD'),
    '159 Magnolia Dr', 'Boston', 'MA', '02104', 'daniel.white@email.com', '617-555-0013');

-- Passenger 14
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Melissa', 'J', 'Harris', TO_DATE('1991-11-22', 'YYYY-MM-DD'),
    '357 Sycamore Ln', 'New York', 'NY', '10004', 'melissa.harris@email.com', '212-555-0014');

-- Passenger 15
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Joshua', NULL, 'Martin', TO_DATE('1986-12-01', 'YYYY-MM-DD'),
    '468 Dogwood St', 'Philadelphia', 'PA', '19104', 'joshua.martin@email.com', '215-555-0015');

-- Passenger 16
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Stephanie', 'K', 'Thompson', TO_DATE('1993-04-09', 'YYYY-MM-DD'),
    '579 Redwood Ave', 'Washington', 'DC', '20004', 'stephanie.thompson@email.com', '202-555-0016');

-- Passenger 17
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Andrew', 'L', 'Garcia', TO_DATE('1989-08-27', 'YYYY-MM-DD'),
    '680 Cypress Ct', 'Boston', 'MA', '02105', 'andrew.garcia@email.com', '617-555-0017');

-- Passenger 18
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Nicole', NULL, 'Martinez', TO_DATE('1990-01-13', 'YYYY-MM-DD'),
    '791 Beech Rd', 'New York', 'NY', '10005', 'nicole.martinez@email.com', '212-555-0018');

-- Passenger 19
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Ryan', 'M', 'Robinson', TO_DATE('1987-05-31', 'YYYY-MM-DD'),
    '802 Fir Dr', 'Philadelphia', 'PA', '19105', 'ryan.robinson@email.com', '215-555-0019');

-- Passenger 20
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Lauren', 'N', 'Clark', TO_DATE('1994-09-19', 'YYYY-MM-DD'),
    '913 Sequoia Blvd', 'Washington', 'DC', '20005', 'lauren.clark@email.com', '202-555-0020');

COMMIT;

-- ============================================================================
-- Age Category Feature (Minor/Adult/Senior Citizen)
-- Based on Date of Birth as per Requirements
-- ============================================================================

-- Function: Get Passenger Age Category
CREATE OR REPLACE FUNCTION get_passenger_category(p_passenger_id IN NUMBER)
RETURN VARCHAR2 IS
    v_dob DATE;
    v_age NUMBER;
    v_category VARCHAR2(20);
BEGIN
    SELECT date_of_birth INTO v_dob
    FROM CRS_PASSENGER
    WHERE passenger_id = p_passenger_id;
    
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, v_dob) / 12);
    
    IF v_age < 18 THEN
        v_category := 'MINOR';
    ELSIF v_age >= 60 THEN
        v_category := 'SENIOR CITIZEN';
    ELSE
        v_category := 'ADULT';
    END IF;
    
    RETURN v_category;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'PASSENGER NOT FOUND';
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END get_passenger_category;
/

GRANT EXECUTE ON get_passenger_category TO CRS_DATA_USER;

-- View: Passenger Age Category View
CREATE OR REPLACE VIEW PASSENGER_AGE_VIEW AS
SELECT 
    passenger_id,
    first_name || ' ' || last_name AS passenger_name,
    date_of_birth,
    TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) AS age,
    CASE 
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) < 18 THEN 'MINOR'
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, date_of_birth) / 12) >= 60 THEN 'SENIOR CITIZEN'
        ELSE 'ADULT'
    END AS category
FROM CRS_PASSENGER;

GRANT SELECT ON PASSENGER_AGE_VIEW TO CRS_REPORT_USER;

-- Insert MINOR (15 years old) for testing
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Tommy', NULL, 'Young', ADD_MONTHS(SYSDATE, -180),
    '100 Youth St', 'Boston', 'MA', '02106', 'tommy.young@email.com', '617-555-0021');

-- Insert SENIOR CITIZEN (65 years old) for testing
INSERT INTO CRS_PASSENGER (passenger_id, first_name, middle_name, last_name, date_of_birth,
    address_line1, address_city, address_state, address_zip, email, phone)
VALUES (crs_passenger_seq.NEXTVAL, 'Margaret', 'S', 'Elder', ADD_MONTHS(SYSDATE, -780),
    '200 Senior Ave', 'New York', 'NY', '10006', 'margaret.elder@email.com', '212-555-0022');

COMMIT;

-- ============================================================================
-- Insert Sample Bookings (45 bookings with varied statuses)
-- ============================================================================

DECLARE
    v_passenger_id NUMBER := 1000;
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    -- Day +1: 15 confirmed FC bookings on TR-101
    FOR i IN 1..15 LOOP
        CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => v_passenger_id,
            p_train_number => 'TR-101',
            p_travel_date => TRUNC(SYSDATE) + 1,
            p_seat_class => 'FC',
            p_booking_id => v_booking_id,
            p_status => v_status
        );
        v_passenger_id := v_passenger_id + 1;
    END LOOP;
    
    -- Day +2: 20 confirmed ECON bookings on TR-201
    FOR i IN 1..20 LOOP
        CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000 + MOD(i, 20),
            p_train_number => 'TR-201',
            p_travel_date => TRUNC(SYSDATE) + 2,
            p_seat_class => 'ECON',
            p_booking_id => v_booking_id,
            p_status => v_status
        );
    END LOOP;
    
    -- Day +3: 10 confirmed FC bookings on TR-301
    FOR i IN 1..10 LOOP
        CRS_BOOKING_PKG.book_ticket(
            p_passenger_id => 1000 + MOD(i, 20),
            p_train_number => 'TR-301',
            p_travel_date => TRUNC(SYSDATE) + 3,
            p_seat_class => 'FC',
            p_booking_id => v_booking_id,
            p_status => v_status
        );
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Sample bookings created successfully');
END;
/

COMMIT;

-- ============================================================================
-- Verification
-- ============================================================================

-- Count passengers
SELECT COUNT(*) AS total_passengers FROM CRS_PASSENGER;

-- Count bookings by status
SELECT seat_status, COUNT(*) AS count
FROM CRS_RESERVATION
GROUP BY seat_status
ORDER BY seat_status;

-- Bookings by train
SELECT t.train_number, COUNT(*) AS bookings
FROM CRS_RESERVATION r
JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
GROUP BY t.train_number
ORDER BY t.train_number;

-- Age Category Summary
SELECT category, COUNT(*) AS count
FROM PASSENGER_AGE_VIEW
GROUP BY category
ORDER BY category;

-- ============================================================================
-- END OF SEED DATA INSERTION SCRIPT
-- Next: Run 11_test_positive_cases.sql
-- ============================================================================