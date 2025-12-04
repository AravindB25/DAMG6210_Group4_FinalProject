-- ============================================================================
-- Commuter Reservation System (CRS)- Group 4
-- Master Data Insertion Script
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Clear Existing Data (If Re-running)
-- ============================================================================
DELETE FROM CRS_TRAIN_SCHEDULE;
DELETE FROM CRS_RESERVATION;
DELETE FROM CRS_PASSENGER;
DELETE FROM CRS_TRAIN_INFO;
DELETE FROM CRS_DAY_SCHEDULE;
COMMIT;

-- ============================================================================
-- Insert Day Schedule (7 static rows with explicit IDs)
-- ============================================================================
INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end) 
VALUES (1, 'Monday', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end) 
VALUES (2, 'Tuesday', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end) 
VALUES (3, 'Wednesday', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end) 
VALUES (4, 'Thursday', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end) 
VALUES (5, 'Friday', 'N');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end) 
VALUES (6, 'Saturday', 'Y');

INSERT INTO CRS_DAY_SCHEDULE (sch_id, day_of_week, is_week_end) 
VALUES (7, 'Sunday', 'Y');

COMMIT;

-- ============================================================================
-- Insert Train Information (6 sample trains)
-- ============================================================================
INSERT INTO CRS_TRAIN_INFO 
(train_id, train_number, source_station, dest_station, 
 total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES 
(crs_train_seq.NEXTVAL, 'TR-101', 'Boston', 'New York', 
 40, 40, 150.00, 75.00);

INSERT INTO CRS_TRAIN_INFO 
(train_id, train_number, source_station, dest_station, 
 total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES 
(crs_train_seq.NEXTVAL, 'TR-102', 'New York', 'Boston', 
 40, 40, 150.00, 75.00);

INSERT INTO CRS_TRAIN_INFO 
(train_id, train_number, source_station, dest_station, 
 total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES 
(crs_train_seq.NEXTVAL, 'TR-201', 'Boston', 'Washington DC', 
 40, 40, 250.00, 125.00);

INSERT INTO CRS_TRAIN_INFO 
(train_id, train_number, source_station, dest_station, 
 total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES 
(crs_train_seq.NEXTVAL, 'TR-301', 'Philadelphia', 'Boston', 
 40, 40, 180.00, 90.00);

INSERT INTO CRS_TRAIN_INFO 
(train_id, train_number, source_station, dest_station, 
 total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES 
(crs_train_seq.NEXTVAL, 'TR-401', 'New York', 'Philadelphia', 
 40, 40, 100.00, 50.00);

INSERT INTO CRS_TRAIN_INFO 
(train_id, train_number, source_station, dest_station, 
 total_fc_seats, total_econ_seats, fc_seat_fare, econ_seat_fare)
VALUES 
(crs_train_seq.NEXTVAL, 'TR-501', 'Washington DC', 'New York', 
 40, 40, 200.00, 100.00);

COMMIT;

-- ============================================================================
-- Insert Train Schedules (Which trains run on which days)
-- ============================================================================

-- Weekday trains: TR-101, TR-102, TR-501
INSERT INTO CRS_TRAIN_SCHEDULE (tsch_id, sch_id, train_id, is_in_service)
SELECT crs_train_schedule_seq.NEXTVAL, s.sch_id, t.train_id, 'Y'
FROM CRS_DAY_SCHEDULE s, CRS_TRAIN_INFO t
WHERE s.day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
AND t.train_number IN ('TR-101', 'TR-102', 'TR-501');

-- All-day trains: TR-201, TR-301
INSERT INTO CRS_TRAIN_SCHEDULE (tsch_id, sch_id, train_id, is_in_service)
SELECT crs_train_schedule_seq.NEXTVAL, s.sch_id, t.train_id, 'Y'
FROM CRS_DAY_SCHEDULE s, CRS_TRAIN_INFO t
WHERE t.train_number IN ('TR-201', 'TR-301');

-- Weekend train: TR-401
INSERT INTO CRS_TRAIN_SCHEDULE (tsch_id, sch_id, train_id, is_in_service)
SELECT crs_train_schedule_seq.NEXTVAL, s.sch_id, t.train_id, 'Y'
FROM CRS_DAY_SCHEDULE s, CRS_TRAIN_INFO t
WHERE s.day_of_week IN ('Saturday', 'Sunday')
AND t.train_number = 'TR-401';

COMMIT;

-- ============================================================================
-- Verification
-- ============================================================================

-- Day Schedule
SELECT sch_id, day_of_week, is_week_end 
FROM CRS_DAY_SCHEDULE 
ORDER BY sch_id;

-- Train Information
SELECT train_id, train_number, source_station, dest_station
FROM CRS_TRAIN_INFO
ORDER BY train_id;

-- Train Schedule Summary
SELECT t.train_number, 
       COUNT(*) as days_in_service,
       LISTAGG(d.day_of_week, ', ') WITHIN GROUP (ORDER BY d.sch_id) as operating_days
FROM CRS_TRAIN_INFO t
JOIN CRS_TRAIN_SCHEDULE ts ON t.train_id = ts.train_id
JOIN CRS_DAY_SCHEDULE d ON ts.sch_id = d.sch_id
WHERE ts.is_in_service = 'Y'
GROUP BY t.train_number
ORDER BY t.train_number;

-- ============================================================================
-- END OF MASTER DATA INSERTION SCRIPT
-- Next: Run 06_create_passenger_package.sql
-- ============================================================================