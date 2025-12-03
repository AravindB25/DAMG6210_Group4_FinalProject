-- ============================================================================
-- Commuter Reservation System (CRS)
-- Booking Management Package
-- Date: November 2025
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Package Specification
-- ============================================================================
CREATE OR REPLACE PACKAGE CRS_BOOKING_PKG AS
    PROCEDURE book_ticket(
        p_passenger_id IN NUMBER,
        p_train_number IN VARCHAR2,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2,
        p_booking_id OUT NUMBER,
        p_status OUT VARCHAR2
    );

    PROCEDURE cancel_ticket(
        p_booking_id IN NUMBER
    );

    FUNCTION check_availability(
        p_train_number IN VARCHAR2,
        p_travel_date IN DATE,
        p_seat_class IN VARCHAR2
    ) RETURN NUMBER;

    FUNCTION get_booking_details(
        p_booking_id IN NUMBER
    ) RETURN VARCHAR2;
END CRS_BOOKING_PKG;
/

-- ============================================================================
-- Package Body
-- ============================================================================
CREATE OR REPLACE PACKAGE BODY CRS_BOOKING_PKG AS

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
        v_day_name VARCHAR2(10);
        v_train_runs NUMBER;
        v_waitlist_pos NUMBER := NULL;
    BEGIN
        SELECT COUNT(*) INTO v_passenger_count
        FROM CRS_PASSENGER
        WHERE passenger_id = p_passenger_id;

        IF v_passenger_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Passenger ID does not exist');
        END IF;

        BEGIN
            SELECT train_id INTO v_train_id
            FROM CRS_TRAIN_INFO
            WHERE train_number = p_train_number;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20011, 'Invalid train number');
        END;

        IF p_seat_class NOT IN ('FC', 'ECON') THEN
            RAISE_APPLICATION_ERROR(-20012, 'Invalid seat class. Use FC or ECON');
        END IF;

        IF p_travel_date > TRUNC(SYSDATE) + 7 THEN
            RAISE_APPLICATION_ERROR(-20013, 'Cannot book more than 1 week in advance');
        END IF;

        IF p_travel_date < TRUNC(SYSDATE) THEN
            RAISE_APPLICATION_ERROR(-20014, 'Cannot book for past dates');
        END IF;

        v_day_name := TRIM(TO_CHAR(p_travel_date, 'Day'));
        v_day_name := UPPER(SUBSTR(v_day_name, 1, 1)) || LOWER(SUBSTR(v_day_name, 2));

        SELECT COUNT(*) INTO v_train_runs
        FROM CRS_TRAIN_SCHEDULE ts
        JOIN CRS_DAY_SCHEDULE ds ON ts.sch_id = ds.sch_id
        WHERE ts.train_id = v_train_id
          AND ds.day_of_week = v_day_name
          AND ts.is_in_service = 'Y';

        IF v_train_runs = 0 THEN
            RAISE_APPLICATION_ERROR(-20015, 'Train does not run on ' || v_day_name);
        END IF;

        IF p_seat_class = 'FC' THEN
            SELECT total_fc_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        ELSE
            SELECT total_econ_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        END IF;

        SELECT COUNT(*) INTO v_booked_count
        FROM CRS_RESERVATION
        WHERE train_id = v_train_id
          AND travel_date = p_travel_date
          AND seat_class = p_seat_class
          AND seat_status IN ('CONFIRMED', 'WAITLISTED');

        IF v_booked_count < v_total_seats THEN
            p_status := 'CONFIRMED';
            v_waitlist_pos := NULL;
        ELSIF v_booked_count < v_total_seats + 5 THEN
            p_status := 'WAITLISTED';
            v_waitlist_pos := v_booked_count + 1;
        ELSE
            RAISE_APPLICATION_ERROR(-20016, 'No seats available. Train is fully booked (40 confirmed + 5 waitlist)');
        END IF;

        INSERT INTO CRS_RESERVATION (
            booking_id, passenger_id, train_id, travel_date,
            booking_date, seat_class, seat_status, waitlist_position
        ) VALUES (
            crs_booking_seq.NEXTVAL, p_passenger_id, v_train_id, p_travel_date,
            SYSDATE, p_seat_class, p_status, v_waitlist_pos
        ) RETURNING booking_id INTO p_booking_id;

        COMMIT;

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

    PROCEDURE cancel_ticket(p_booking_id IN NUMBER) IS
        v_count NUMBER;
        v_current_status VARCHAR2(20);
    BEGIN
        SELECT COUNT(*), MAX(seat_status)
        INTO v_count, v_current_status
        FROM CRS_RESERVATION
        WHERE booking_id = p_booking_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Booking ID not found');
        END IF;

        IF v_current_status = 'CANCELLED' THEN
            RAISE_APPLICATION_ERROR(-20021, 'Booking is already cancelled');
        END IF;

        UPDATE CRS_RESERVATION
        SET seat_status = 'CANCELLED',
            waitlist_position = NULL
        WHERE booking_id = p_booking_id;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Booking cancelled successfully. ID: ' || p_booking_id);

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Cancellation failed: ' || SQLERRM);
            RAISE;
    END cancel_ticket;

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
        SELECT train_id INTO v_train_id
        FROM CRS_TRAIN_INFO
        WHERE train_number = p_train_number;

        IF p_seat_class = 'FC' THEN
            SELECT total_fc_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        ELSE
            SELECT total_econ_seats INTO v_total_seats
            FROM CRS_TRAIN_INFO
            WHERE train_id = v_train_id;
        END IF;

        SELECT COUNT(*) INTO v_booked_count
        FROM CRS_RESERVATION
        WHERE train_id = v_train_id
          AND travel_date = p_travel_date
          AND seat_class = p_seat_class
          AND seat_status = 'CONFIRMED';

        v_available := v_total_seats - v_booked_count;
        RETURN v_available;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1;
        WHEN OTHERS THEN
            RETURN -1;
    END check_availability;

    FUNCTION get_booking_details(p_booking_id IN NUMBER)
    RETURN VARCHAR2 IS
        v_details VARCHAR2(1000);
    BEGIN
        SELECT 'Booking ID: ' || r.booking_id ||
               ', Passenger: ' || p.first_name || ' ' || p.last_name ||
               ', Train: ' || t.train_number ||
               ', Route: ' || t.source_station || ' to ' || t.dest_station ||
               ', Travel Date: ' || TO_CHAR(r.travel_date, 'DD-MON-YYYY') ||
               ', Class: ' || r.seat_class ||
               ', Status: ' || r.seat_status ||
               CASE WHEN r.waitlist_position IS NOT NULL
                    THEN ', Waitlist: ' || r.waitlist_position
                    ELSE '' END
        INTO v_details
        FROM CRS_RESERVATION r
        JOIN CRS_PASSENGER p ON r.passenger_id = p.passenger_id
        JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id
        WHERE r.booking_id = p_booking_id;

        RETURN v_details;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Booking not found';
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END get_booking_details;

END CRS_BOOKING_PKG;
/

-- ============================================================================
-- Grants
-- ============================================================================
GRANT EXECUTE ON CRS_BOOKING_PKG TO CRS_DATA_USER;
COMMIT;

PROMPT Booking package created successfully
PROMPT Execute privileges granted to CRS_DATA_USER
PROMPT Next: Run 08_create_cancellation_trigger.sql

-- ============================================================================
-- END OF BOOKING PACKAGE SCRIPT
-- ============================================================================
