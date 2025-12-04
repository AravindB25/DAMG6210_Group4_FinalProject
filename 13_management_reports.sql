-- ============================================================================
-- Commuter Reservation System (CRS)Group 4
-- Management Reports and Views
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;

-- ============================================================================
-- Drop Existing Views (If Re-running)
-- ============================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW BOOKING_REPORT_VIEW';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW OCCUPANCY_VIEW';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW REVENUE_VIEW';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ============================================================================
-- View 1: BOOKING_REPORT_VIEW - Comprehensive Booking Details
-- ============================================================================
CREATE OR REPLACE VIEW BOOKING_REPORT_VIEW AS
SELECT 
    r.booking_id,
    r.booking_date,
    r.travel_date,
    TO_CHAR(r.travel_date, 'Day') AS day_of_week,
    p.passenger_id,
    p.first_name || ' ' || p.last_name AS passenger_name,
    p.email,
    p.phone,
    t.train_id,
    t.train_number,
    t.source_station,
    t.dest_station,
    t.source_station || ' to ' || t.dest_station AS route,
    r.seat_class,
    r.seat_status,
    r.waitlist_position,
    CASE 
        WHEN r.seat_class = 'FC' THEN t.fc_seat_fare
        ELSE t.econ_seat_fare
    END AS fare_amount,
    CASE 
        WHEN r.seat_status = 'CONFIRMED' THEN 
            CASE WHEN r.seat_class = 'FC' THEN t.fc_seat_fare ELSE t.econ_seat_fare END
        ELSE 0
    END AS revenue
FROM CRS_RESERVATION r
JOIN CRS_PASSENGER p ON r.passenger_id = p.passenger_id
JOIN CRS_TRAIN_INFO t ON r.train_id = t.train_id;

-- ============================================================================
-- View 2: OCCUPANCY_VIEW - Train Capacity and Utilization
-- ============================================================================
CREATE OR REPLACE VIEW OCCUPANCY_VIEW AS
SELECT 
    t.train_id,
    t.train_number,
    t.source_station,
    t.dest_station,
    r.travel_date,
    r.seat_class,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_seats,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS waitlisted_seats,
    CASE 
        WHEN r.seat_class = 'FC' THEN t.total_fc_seats
        ELSE t.total_econ_seats
    END AS total_capacity,
    CASE 
        WHEN r.seat_class = 'FC' THEN t.total_fc_seats
        ELSE t.total_econ_seats
    END - COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS available_seats,
    ROUND(
        COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0 / 
        CASE WHEN r.seat_class = 'FC' THEN t.total_fc_seats ELSE t.total_econ_seats END, 
        2
    ) AS occupancy_percentage
FROM CRS_TRAIN_INFO t
LEFT JOIN CRS_RESERVATION r ON t.train_id = r.train_id
WHERE r.seat_status IN ('CONFIRMED', 'WAITLISTED') OR r.booking_id IS NULL
GROUP BY 
    t.train_id, t.train_number, t.source_station, t.dest_station,
    r.travel_date, r.seat_class, t.total_fc_seats, t.total_econ_seats;

-- ============================================================================
-- View 3: REVENUE_VIEW - Revenue Analysis by Train and Class
-- ============================================================================
CREATE OR REPLACE VIEW REVENUE_VIEW AS
SELECT 
    t.train_id,
    t.train_number,
    t.source_station || ' to ' || t.dest_station AS route,
    r.seat_class,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN r.seat_status = 'WAITLISTED' THEN 1 END) AS waitlisted_bookings,
    COUNT(CASE WHEN r.seat_status = 'CANCELLED' THEN 1 END) AS cancelled_bookings,
    CASE 
        WHEN r.seat_class = 'FC' THEN t.fc_seat_fare
        ELSE t.econ_seat_fare
    END AS fare_per_seat,
    COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) *
    CASE 
        WHEN r.seat_class = 'FC' THEN t.fc_seat_fare
        ELSE t.econ_seat_fare
    END AS total_revenue,
    CASE 
        WHEN r.seat_class = 'FC' THEN t.total_fc_seats
        ELSE t.total_econ_seats
    END AS total_capacity,
    ROUND(
        COUNT(CASE WHEN r.seat_status = 'CONFIRMED' THEN 1 END) * 100.0 /
        CASE WHEN r.seat_class = 'FC' THEN t.total_fc_seats ELSE t.total_econ_seats END,
        2
    ) AS capacity_utilization
FROM CRS_TRAIN_INFO t
LEFT JOIN CRS_RESERVATION r ON t.train_id = r.train_id
GROUP BY 
    t.train_id, t.train_number, t.source_station, t.dest_station,
    r.seat_class, t.fc_seat_fare, t.econ_seat_fare, t.total_fc_seats, t.total_econ_seats;

-- ============================================================================
-- Grant SELECT Permissions on Views to CRS_REPORT_USER
-- ============================================================================
GRANT SELECT ON BOOKING_REPORT_VIEW TO CRS_REPORT_USER;
GRANT SELECT ON OCCUPANCY_VIEW TO CRS_REPORT_USER;
GRANT SELECT ON REVENUE_VIEW TO CRS_REPORT_USER;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT view_name, text_length 
FROM user_views 
WHERE view_name IN ('BOOKING_REPORT_VIEW', 'OCCUPANCY_VIEW', 'REVENUE_VIEW')
ORDER BY view_name;

COMMIT;

-- ============================================================================
-- END OF VIEWS CREATION SCRIPT
-- Next: Run 10_insert_seed_data.sql
-- ============================================================================