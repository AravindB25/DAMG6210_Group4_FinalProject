-- ============================================================================
-- Commuter Reservation System (CRS) Group 4
-- Booking Management Package
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Package Specification
-- ============================================================================
CREATE OR REPLACE PACKAGE CRS_BOOKING_PKG AS
    -- Book a ticket
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_train_number IN VARCHAR2,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2,
        p_booking_id OUT NUMBER,
        p_status OUT VARCHAR2
    );

    -- Cancel a ticket
    PROCEDURE cancel_ticket(
        p_booking_id IN NUMBER
    );

    -- Check seat availability
    FUNCTION check_availability(
        p_train_number IN VARCHAR2,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER;

    -- Get booking details
    FUNCTION get_booking_details(
        p_booking_id IN NUMBER
    ) RETURN VARCHAR2;
    
    -- ADDED: Get waitlist position for a booking
    FUNCTION get_waitlist_position(
        p_booking_id IN NUMBER
    ) RETURN NUMBER;
    
END CRS_BOOKING_PKG;
/

-- ============================================================================
-- Package Body
-- ============================================================================
CREATE OR REPLACE PACKAGE BODY CRS_BOOKING_PKG AS

    -- ========================================================================
    -- PROCEDURE: book_ticket
    -- Books a ticket with full validation of business rules
    -- ========================================================================
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_train_number IN VARCHAR2,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2,
        p_booking_id OUT NUMBER,
        p_status OUT VARCHAR2
    ) IS
        v_train_id NUMBER;
        v_passenger_count NUMBER;
        v_booked_count NUMBER;
        v_total_seats NUMBER;
        v_day_name VARCHAR2(20);
        v_train_runs NUMBER;
        v_waitlist_pos NUMBER := NULL;
        v_max_waitlist CONSTANT NUMBER := 5;  -- Configurable waitlist size per class
    BEGIN
        -- Validation 1: Check if passenger exists
        SELECT COUNT(*) INTO v_passenger_count
        FROM CRS_PASSENGER
        WHERE passenger_id = p_passenger_id;

        IF v_passenger_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Passenger ID does not exist');
        END IF;

        -- Validation 2: Check if train exists
        BEGIN
            SELECT train_id INTO v_train_id
            FROM CRS_TRAIN_INFO
            WHERE train_number = p_train_number;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20011, 'Invalid train number: ' || p_train_number);
        END;

        -- Validation 3: Check seat class
        IF UPPER(p_seat_class) NOT IN ('FC', 'ECON') THEN
            RAISE_APPLICATION_ERROR(-20012, 'Invalid seat class. Use FC or ECON');
        END IF;

        -- Validation 4: Check advance booking limit (max 7 days)
        IF p_travel_date > TRUNC(SYSDATE) + 7 THEN
            RAISE_APPLICATION_ERROR(-20013, 'Cannot book more than 1 week in advance. Max date: ' || TO_CHAR(TRUNC(SYSDATE) + 7, 'DD-MON-YYYY'));
        END IF;

        -- Validation 5: Check for past date
        IF p_travel_date < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20014, 'Cannot book for past dates');
        END IF;

        -- FIXED: Get day name with explicit NLS setting for consistency
        v_day_name := TRIM(TO_CHAR(p_travel_date, 'Day', 'NLS_DATE_LANGUAGE=ENGLISH'));
        v_day_name := INITCAP(v_day_name);

        -- Validation 6: Check if train runs on the travel date
        SELECT COUNT(*) INTO v_train_runs
        FROM CRS_TRAIN_SCHEDULE ts
        JOIN CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id
        WHERE ts.train_id = v_train_id
          AND ds.day_of_week = v_day_name
          AND ts.is_in_service = 'Y';

        IF v_train_runs = 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'Train ' || p_train_number || ' does not run on ' || v_day_name);
        END IF;

        -- Get total seats for the class
        IF UPPER(p_seat_class) = 'FC' THEN
            SELECT total_fc_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        ELSE
            SELECT total_econ_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        END IF;

        -- Count current bookings (CONFIRMED + WAITLISTED)
        SELECT COUNT(*) INTO v_booked_count
        FROM CRS_RESERVATION
        WHERE train_id = v_train_id
          AND travel_date = p_travel_date
          AND seat_class = UPPER(p_seat_class)
          AND seat_status IN ('CONFIRMED', 'WAITLISTED');

        -- Determine booking status
        IF v_booked_count < v_total_seats THEN
            -- Seats available - CONFIRMED
            p_status := 'CONFIRMED';
            v_waitlist_pos := NULL;
        ELSIF v_booked_count < v_total_seats + v_max_waitlist THEN
            -- No seats but waitlist available - WAITLISTED
            p_status := 'WAITLISTED';
            v_waitlist_pos := v_total_seats + 1 + (v_booked_count - v_total_seats);  -- Position 41-45
        ELSE
            -- No seats and waitlist full
            RAISE_APPLICATION_ERROR(-20016, 'No seats available. Train is fully booked (' || v_total_seats || ' confirmed + ' || v_max_waitlist || ' waitlist)');
        END IF;

        -- Insert the reservation
        INSERT INTO CRS_RESERVATION (
            booking_id, passenger_id, train_id, travel_date,
            booking_date, seat_class, seat_status, waitlist_position
        ) VALUES (
            crs_booking_seq.NEXTVAL, p_passenger_id, v_train_id, p_travel_date,
            SYSDATE, UPPER(p_seat_class), p_status, v_waitlist_pos
        ) RETURNING booking_id INTO p_booking_id;

        COMMIT;

        -- Output confirmation message
        IF p_status = 'CONFIRMED' THEN
            DBMS_OUTPUT.PUT_LINE('Booking confirmed! Booking ID: ' || p_booking_id);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Booking waitlisted. Booking ID: ' || p_booking_id ||
                                 ', Waitlist Position: ' || v_waitlist_pos);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Booking failed: ' || SQLERRM);
            RAISE;
    END book_ticket;

    -- ========================================================================
    -- PROCEDURE: cancel_ticket
    -- Cancels a booking (trigger handles waitlist promotion)
    -- ========================================================================
    PROCEDURE cancel_ticket(p_booking_id IN NUMBER) IS
        v_count NUMBER;
        v_current_status VARCHAR2(20);
        v_train_number VARCHAR2(20);
        v_travel_date DATE;
    BEGIN
        -- Check if booking exists and get current status
        SELECT COUNT(*), MAX(seat_status)
        INTO v_count, v_current_status
        FROM CRS_RESERVATION
        WHERE booking_id = p_booking_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Booking ID ' || p_booking_id || ' not found');
        END IF;

        IF v_current_status = 'CANCELLED' THEN
            RAISE_APPLICATION_ERROR(-20021, 'Booking ' || p_booking_id || ' is already cancelled');
        END IF;

        -- Get booking details for confirmation message
        SELECT t.train_number, r.travel_date
        INTO v_train_number, v_travel_date
        FROM CRS_RESERVATION r
        JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
        WHERE r.booking_id = p_booking_id;

        -- Update status to CANCELLED
        UPDATE CRS_RESERVATION
        SET seat_status = 'CANCELLED',
            waitlist_position = NULL
        WHERE booking_id = p_booking_id;

        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Booking cancelled successfully.');
        DBMS_OUTPUT.PUT_LINE('  Booking ID: ' || p_booking_id);
        DBMS_OUTPUT.PUT_LINE('  Train: ' || v_train_number);
        DBMS_OUTPUT.PUT_LINE('  Travel Date: ' || TO_CHAR(v_travel_date, 'DD-MON-YYYY'));

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Cancellation failed: ' || SQLERRM);
            RAISE;
    END cancel_ticket;

    -- ========================================================================
    -- FUNCTION: check_availability
    -- Returns number of available seats for a train/date/class
    -- ========================================================================
    FUNCTION check_availability(
        p_train_number IN VARCHAR2,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER IS
        v_train_id NUMBER;
        v_total_seats NUMBER;
        v_booked_count NUMBER;
        v_available NUMBER;
    BEGIN
        -- Get train ID
        SELECT train_id INTO v_train_id
        FROM CRS_TRAIN_INFO
        WHERE train_number = p_train_number;

        -- Get total seats for class
        IF UPPER(p_seat_class) = 'FC' THEN
            SELECT total_fc_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        ELSE
            SELECT total_econ_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        END IF;

        -- Count confirmed bookings only
        SELECT COUNT(*) INTO v_booked_count
        FROM CRS_RESERVATION
        WHERE train_id = v_train_id
          AND travel_date = p_travel_date
          AND seat_class = UPPER(p_seat_class)
          AND seat_status = 'CONFIRMED';

        v_available := v_total_seats - v_booked_count;
        RETURN v_available;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;  -- Invalid train number
        WHEN OTHERS THEN
            RETURN -1;
    END check_availability;

    -- ========================================================================
    -- FUNCTION: get_booking_details
    -- Returns formatted string with booking information
    -- ========================================================================
    FUNCTION get_booking_details(p_booking_id IN NUMBER)
    RETURN VARCHAR2 IS
        v_details VARCHAR2(1000);
    BEGIN
        SELECT 'Booking ID: ' || r.booking_id ||
               CHR(10) || 'Passenger: ' || p.first_name || ' ' || p.last_name ||
               CHR(10) || 'Train: ' || t.train_number ||
               CHR(10) || 'Route: ' || t.source_station || ' to ' || t.dest_station ||
               CHR(10) || 'Travel Date: ' || TO_CHAR(r.travel_date, 'DD-MON-YYYY') ||
               CHR(10) || 'Booking Date: ' || TO_CHAR(r.booking_date, 'DD-MON-YYYY') ||
               CHR(10) || 'Class: ' || DECODE(r.seat_class, 'FC', 'First Class', 'ECON', 'Economy') ||
               CHR(10) || 'Status: ' || r.seat_status ||
               CASE WHEN r.waitlist_position IS NOT NULL
                    THEN CHR(10) || 'Waitlist Position: ' || r.waitlist_position
                    ELSE '' END
        INTO v_details
        FROM CRS_RESERVATION r
        JOIN CRS_PASSENGER p ON r.passenger_id = p.passenger_id
        JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
        WHERE r.booking_id = p_booking_id;

        RETURN v_details;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Booking ID ' || p_booking_id || ' not found';
        WHEN OTHERS THEN
            RETURN 'Error retrieving booking: ' || SQLERRM;
    END get_booking_details;

    -- ========================================================================
    -- FUNCTION: get_waitlist_position (ADDED)
    -- Returns current waitlist position or NULL if confirmed/cancelled
    -- ========================================================================
    FUNCTION get_waitlist_position(p_booking_id IN NUMBER)
    RETURN NUMBER IS
        v_position NUMBER;
    BEGIN
        SELECT waitlist_position INTO v_position
        FROM CRS_RESERVATION
        WHERE booking_id = p_booking_id;
        
        RETURN v_position;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
        WHEN OTHERS THEN
            RETURN NULL;
    END get_waitlist_position;

END CRS_BOOKING_PKG;
/

-- ============================================================================
-- Grants
-- ============================================================================
GRANT EXECUTE ON CRS_BOOKING_PKG TO CRS_DATA_USER;
COMMIT;

PROMPT ============================================================
PROMPT Booking package created successfully
PROMPT Execute privileges granted to CRS_DATA_USER
PROMPT ============================================================
PROMPT Next: Run 08_create_cancellation_trigger.sql

-- ============================================================================
-- END OF BOOKING PACKAGE SCRIPT
-- ============================================================================