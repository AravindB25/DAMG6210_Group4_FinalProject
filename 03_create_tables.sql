-- ============================================================================
-- Commuter Reservation System (CRS) - Group 4
-- DDL Script - Table Creation
-- Date: November 2025
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Drop Existing Tables (If Re-running)
-- Drop in reverse order of dependencies
-- ============================================================================

DROP TABLE CRS_RESERVATION CASCADE CONSTRAINTS;
DROP TABLE CRS_PASSENGER CASCADE CONSTRAINTS;
DROP TABLE CRS_TRAIN_SCHEDULE CASCADE CONSTRAINTS;
DROP TABLE CRS_DAY_SCHEDULE CASCADE CONSTRAINTS;
DROP TABLE CRS_TRAIN_INFO CASCADE CONSTRAINTS;

-- ============================================================================
-- Independent Entity Tables
-- ============================================================================

-- CRS_TRAIN_INFO Table
CREATE TABLE CRS_TRAIN_INFO (
    train_id         NUMBER PRIMARY KEY,
    train_number     VARCHAR2(20) NOT NULL UNIQUE,
    source_station   VARCHAR2(100) NOT NULL,
    dest_station     VARCHAR2(100) NOT NULL,
    total_fc_seats   NUMBER DEFAULT 40 NOT NULL,
    total_econ_seats NUMBER DEFAULT 40 NOT NULL,
    fc_seat_fare     NUMBER(10,2) NOT NULL,
    econ_seat_fare   NUMBER(10,2) NOT NULL,
    CONSTRAINT chk_train_seats CHECK (total_fc_seats > 0 AND total_econ_seats > 0),
    CONSTRAINT chk_train_fare CHECK (fc_seat_fare > 0 AND econ_seat_fare > 0),
    CONSTRAINT chk_stations CHECK (source_station != dest_station)
);

-- CRS_DAY_SCHEDULE Table
CREATE TABLE CRS_DAY_SCHEDULE (
    sch_id      NUMBER PRIMARY KEY,
    day_of_week VARCHAR2(10) NOT NULL UNIQUE,
    is_week_end CHAR(1) NOT NULL,
    CONSTRAINT chk_weekend CHECK (is_week_end IN ('Y', 'N'))
);

-- CRS_PASSENGER Table
CREATE TABLE CRS_PASSENGER (
    passenger_id   NUMBER PRIMARY KEY,
    first_name     VARCHAR2(50) NOT NULL,
    middle_name    VARCHAR2(50),
    last_name      VARCHAR2(50) NOT NULL,
    date_of_birth  DATE NOT NULL,
    address_line1  VARCHAR2(200) NOT NULL,
    address_city   VARCHAR2(100) NOT NULL,
    address_state  VARCHAR2(50) NOT NULL,
    address_zip    VARCHAR2(10) NOT NULL,
    email          VARCHAR2(100) NOT NULL UNIQUE,
    phone          VARCHAR2(15) NOT NULL UNIQUE,
    CONSTRAINT chk_dob CHECK (date_of_birth < SYSDATE)
);

-- ============================================================================
-- Bridge/Junction Tables
-- ============================================================================

-- CRS_TRAIN_SCHEDULE Table
CREATE TABLE CRS_TRAIN_SCHEDULE (
    tsch_id        NUMBER PRIMARY KEY,
    sch_id         NUMBER NOT NULL,
    train_id       NUMBER NOT NULL,
    is_in_service  CHAR(1) DEFAULT 'Y' NOT NULL,
    CONSTRAINT chk_in_service CHECK (is_in_service IN ('Y', 'N')),
    CONSTRAINT fk_schedule_day FOREIGN KEY (sch_id) REFERENCES CRS_DAY_SCHEDULE(sch_id),
    CONSTRAINT fk_schedule_train FOREIGN KEY (train_id) REFERENCES CRS_TRAIN_INFO(train_id),
    CONSTRAINT uk_train_day UNIQUE (train_id, sch_id)
);

-- ============================================================================
-- Transaction Tables
-- ============================================================================

-- CRS_RESERVATION Table
CREATE TABLE CRS_RESERVATION (
    booking_id        NUMBER PRIMARY KEY,
    passenger_id      NUMBER NOT NULL,
    train_id          NUMBER NOT NULL,
    travel_date       DATE NOT NULL,
    booking_date      DATE DEFAULT SYSDATE NOT NULL,
    seat_class        VARCHAR2(10) NOT NULL,
    seat_status       VARCHAR2(20) DEFAULT 'CONFIRMED' NOT NULL,
    waitlist_position NUMBER,
    CONSTRAINT chk_seat_class CHECK (seat_class IN ('FC', 'ECON')),
    CONSTRAINT chk_seat_status CHECK (seat_status IN ('CONFIRMED', 'WAITLISTED', 'CANCELLED')),
    CONSTRAINT chk_travel_date CHECK (
        travel_date >= TRUNC(booking_date)
        AND travel_date <= TRUNC(booking_date) + 7
    ),
    CONSTRAINT chk_waitlist_logic CHECK (
        (seat_status = 'CONFIRMED' AND waitlist_position IS NULL) OR
        (seat_status = 'WAITLISTED' AND waitlist_position BETWEEN 41 AND 45) OR
        (seat_status = 'CANCELLED')
    ),
    CONSTRAINT fk_booking_passenger FOREIGN KEY (passenger_id) REFERENCES CRS_PASSENGER(passenger_id),
    CONSTRAINT fk_booking_train FOREIGN KEY (train_id) REFERENCES CRS_TRAIN_INFO(train_id)
);

-- ============================================================================
-- Commit Changes
-- ============================================================================
COMMIT;

-- ============================================================================
-- Verification
-- ============================================================================
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name LIKE 'CRS%' 
ORDER BY table_name;

-- ============================================================================
-- END OF TABLE CREATION SCRIPT
-- Next: Run 04_create_indexes.sql
-- ============================================================================
