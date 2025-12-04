# DAMG6210_Group4_FinalProject

## Commuter Reservation System (CRS)

This project implements a simplified **Train Reservation System** in **Oracle Database** using:
- Normalized relational data model
- Tables with constraints (PK, FK, CHECK, UNIQUE)
- PL/SQL packages, procedures, and functions
- Test cases to validate **business rules** and **error handling**

The system focuses on **reservations, passengers, trains, and daily train status**.
Payment details are explicitly **out of scope** as per the assignment.

---

## 1. Problem Statement

The client's current train ticket booking process is manual and lacks proper data management capabilities, causing inconsistent data, overbooking issues, and operational inefficiencies. A centralized database system is required to:

- Manage trains, schedules, passengers, and reservations effectively
- Enforce business rules at the database level (1-week advance booking, seat capacity limits, waitlist management)
- Ensure data accuracy through proper constraints and automated validation
- Support efficient querying for seat availability and booking status in real-time
- Provide transaction integrity for booking and cancellation operations
- Enable waitlist promotion upon cancellations with clear audit trails

---

## 2. Key Features

- Real-time seat availability tracking (40 confirmed + 5 waitlist per class)
- Automated waitlist promotion upon cancellations
- 1-week advance booking validation
- Unique passenger identification (email/phone)
- Role-based access control (Admin, Data User, Report User)
- Comprehensive audit trail for all transactions

---

## 3. Team - Group 4

| Name | Responsibility |
|------|----------------|
| Aravind Balaji | Schema Design, Tables, Constraints, Sequences, Indexes, Documentation |
| Akshay Dnyaneshwar Govind | Master Data, Seed Data, Test Cases, Permissions, Audit Log |
| Pranav Narendrabhai Patel | PL/SQL Packages, Stored Procedures, Functions, Triggers, Reports |

---

## 4. Database Schema

### Tables

| Table | Description |
|-------|-------------|
| CRS_TRAIN_INFO | Train master data (routes, capacity, fares) |
| CRS_DAY_SCHEDULE | Days of week reference (7 rows) |
| CRS_TRAIN_SCHEDULE | Bridge table for train-day relationships |
| CRS_PASSENGER | Passenger information |
| CRS_RESERVATION | Booking records with status tracking |
| CRS_AUDIT_LOG | Transaction audit trail |

### Entity Relationship

```
CRS_TRAIN_INFO ----< CRS_TRAIN_SCHEDULE >---- CRS_DAY_SCHEDULE
      |
      |  1:M
      v
CRS_RESERVATION
      |
      |  M:1
      v
CRS_PASSENGER
```

---

###  ERD (Text Diagram)
```text
+--------------------+          +----------------------+
|   CRS_TRAIN_INFO   | 1      M |  CRS_TRAIN_SCHEDULE  |
+--------------------+----------+----------------------+
| PK train_id        |          | PK tsch_id           |
|    train_number    |          | FK train_id          |
|    source_station  |          | FK sch_id            |
|    dest_station    |          |    is_in_service     |
|    total_fc_seats  |          +----------------------+
|    total_econ_seats|                    |
|    fc_seat_fare    |                    | M
|    econ_seat_fare  |                    |
+--------------------+                    1
                                +----------------------+
                                |   CRS_DAY_SCHEDULE   |
                                +----------------------+
                                | PK sch_id            |
                                |    day_of_week       |
                                |    is_week_end       |
                                +----------------------+

+--------------------+          +----------------------+
|   CRS_PASSENGER    | 1      M |   CRS_RESERVATION    |
+--------------------+----------+----------------------+
| PK passenger_id    |          | PK booking_id        |
|    first_name      |          | FK passenger_id      |
|    middle_name     |          | FK train_id          |
|    last_name       |          |    travel_date       |
|    date_of_birth   |          |    booking_date      |
|    address_line1   |          |    seat_class        |
|    address_city    |          |    seat_status       |
|    address_state   |          |    waitlist_position |
|    address_zip     |          +----------------------+
|    email (UNIQUE)  |
|    phone (UNIQUE)  |
+--------------------+
```

## 5. Project Structure

```
DAMG6210_Group4_FinalProject/
├── README.md
├── docs/
│   └── CRS_Group 4_Final Project_DAMG 6210.pdf
├── 01_create_users_and_schemas.sql
├── 02_create_sequences.sql
├── 03_create_tables.sql
├── 04_create_indexes.sql
├── 05_insert_master_data.sql
├── 06_create_passenger_package.sql
├── 07_create_booking_package.sql
├── 08_create_cancellation_trigger.sql
├── 09_grant_permissions.sql
├── 10_insert_seed_data.sql
├── 11_test_positive_cases.sql
├── 12_test_negative_cases.sql
├── 13_management_reports.sql
└── 14_create_audit_log.sql
```

### File Descriptions

| File | Type | Description | Run As |
|------|------|-------------|--------|
| 01_create_users_and_schemas.sql | DDL | Creates CRS_ADMIN_USER, CRS_DATA_USER, CRS_REPORT_USER | SYSTEM/DBA |
| 02_create_sequences.sql | DDL | Creates sequences for auto-generated primary keys | CRS_ADMIN_USER |
| 03_create_tables.sql | DDL | Creates 5 tables with PK, FK, UNIQUE, CHECK constraints | CRS_ADMIN_USER |
| 04_create_indexes.sql | DDL | Creates performance indexes on foreign keys | CRS_ADMIN_USER |
| 05_insert_master_data.sql | DML | Inserts trains, day schedules, train schedules | CRS_ADMIN_USER |
| 06_create_passenger_package.sql | Stored Proc | Creates CRS_PASSENGER_PKG (add, update, get passenger) | CRS_ADMIN_USER |
| 07_create_booking_package.sql | Stored Proc | Creates CRS_BOOKING_PKG (book, cancel, check availability) | CRS_ADMIN_USER |
| 08_create_cancellation_trigger.sql | Trigger | Creates waitlist promotion trigger | CRS_ADMIN_USER |
| 09_grant_permissions.sql | DCL | Grants EXECUTE permissions to CRS_DATA_USER | CRS_ADMIN_USER |
| 10_insert_seed_data.sql | DML | Inserts sample passengers and bookings | CRS_ADMIN_USER |
| 11_test_positive_cases.sql | Test | Validates business rules (5 test cases) | CRS_DATA_USER |
| 12_test_negative_cases.sql | Test | Validates exception handling (10 test cases) | CRS_DATA_USER |
| 13_management_reports.sql | Views | Creates BOOKING_REPORT_VIEW, OCCUPANCY_VIEW, REVENUE_VIEW | CRS_ADMIN_USER |
| 14_create_audit_log.sql | DDL/Trigger | Creates audit log table and triggers | CRS_ADMIN_USER |

---

## 6. Installation & Execution Instructions

### Prerequisites

- Oracle Database 19c or higher
- SQL*Plus or Oracle SQL Developer
- DBA/SYSTEM privileges for initial setup (Script 01 only)

### Security Note: Execution Permissions

**Important: Application code is NOT executed as SYSTEM/DBA**

| Script | Run As | Why |
|--------|--------|-----|
| 01_create_users_and_schemas.sql | SYSTEM/DBA | **Only script requiring DBA** - creates application users |
| 02-10, 13-14 (DDL, DML, Procedures, Triggers, Views) | CRS_ADMIN_USER | Application owner with **limited permissions only** |
| 11, 12 (Test scripts) | CRS_DATA_USER | Tests execute via procedures only - **no direct table access** |

**Principle of Least Privilege Applied:**
- **CRS_ADMIN_USER** has only: CREATE TABLE, VIEW, SEQUENCE, PROCEDURE, TRIGGER (No DBA, No SYSDBA)
- **CRS_DATA_USER** has only: EXECUTE on packages (No direct INSERT/UPDATE/DELETE on tables)
- **CRS_REPORT_USER** has only: SELECT on views (Read-only access)

### Step-by-Step Execution Order

| Step | File | Run As | Type | Description |
|------|------|--------|------|-------------|
| 1 | 01_create_users_and_schemas.sql | SYSTEM/DBA | DDL | Creates database users (only DBA script) |
| 2 | 02_create_sequences.sql | CRS_ADMIN_USER | DDL | Creates sequences |
| 3 | 03_create_tables.sql | CRS_ADMIN_USER | DDL | Creates tables with constraints |
| 4 | 04_create_indexes.sql | CRS_ADMIN_USER | DDL | Creates indexes |
| 5 | 05_insert_master_data.sql | CRS_ADMIN_USER | DML | Inserts master data |
| 6 | 06_create_passenger_package.sql | CRS_ADMIN_USER | Stored Proc | Creates passenger package |
| 7 | 07_create_booking_package.sql | CRS_ADMIN_USER | Stored Proc | Creates booking package |
| 8 | 08_create_cancellation_trigger.sql | CRS_ADMIN_USER | Trigger | Creates waitlist trigger |
| 9 | 09_grant_permissions.sql | CRS_ADMIN_USER | DCL | Grants permissions |
| 10 | 10_insert_seed_data.sql | CRS_ADMIN_USER | DML | Inserts sample data |
| 11 | 11_test_positive_cases.sql | CRS_DATA_USER | Test | Runs positive tests |
| 12 | 12_test_negative_cases.sql | CRS_DATA_USER | Test | Runs negative tests |
| 13 | 13_management_reports.sql | CRS_ADMIN_USER | Views | Creates report views |
| 14 | 14_create_audit_log.sql | CRS_ADMIN_USER | DDL/Trigger | Creates audit log |

### Detailed Execution Commands

#### Step 1: Connect as SYSTEM and Create Users (Only DBA Script)

```sql
-- Connect as SYSTEM/DBA (ONLY for user creation)
sqlplus system/your_password@your_database

-- Run user creation script
@01_create_users_and_schemas.sql

-- IMPORTANT: Disconnect from SYSTEM immediately after
DISCONNECT
```

#### Step 2: Connect as CRS_ADMIN_USER and Run DDL Scripts

```sql
-- Connect as application owner (NOT as SYSTEM/DBA)
CONNECT CRS_ADMIN_USER/Admin123@your_database

-- Enable output
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Run DDL scripts in order
@02_create_sequences.sql
@03_create_tables.sql
@04_create_indexes.sql
```

#### Step 3: Insert Master Data

```sql
-- Still as CRS_ADMIN_USER (NOT as SYSTEM/DBA)
@05_insert_master_data.sql
```

#### Step 4: Create Stored Procedures & Packages

```sql
-- Still as CRS_ADMIN_USER (NOT as SYSTEM/DBA)
@06_create_passenger_package.sql
@07_create_booking_package.sql
```

#### Step 5: Create Trigger

```sql
-- Still as CRS_ADMIN_USER (NOT as SYSTEM/DBA)
@08_create_cancellation_trigger.sql
```

#### Step 6: Grant Permissions

```sql
-- Still as CRS_ADMIN_USER (NOT as SYSTEM/DBA)
@09_grant_permissions.sql
```

#### Step 7: Insert Seed Data

```sql
-- Still as CRS_ADMIN_USER (NOT as SYSTEM/DBA)
@10_insert_seed_data.sql
```

#### Step 8: Run Test Cases

```sql
-- Connect as CRS_DATA_USER (NOT as SYSTEM/DBA, NOT as CRS_ADMIN_USER)
-- This proves data access works only through procedures
CONNECT CRS_DATA_USER/Data123@your_database

SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Run positive tests (uses EXECUTE permission on packages)
@11_test_positive_cases.sql

-- Run negative tests (validates error handling)
@12_test_negative_cases.sql
```

#### Step 9: Create Views & Audit Log

```sql
-- Connect back as CRS_ADMIN_USER (NOT as SYSTEM/DBA)
CONNECT CRS_ADMIN_USER/Admin123@your_database

@13_management_reports.sql
@14_create_audit_log.sql
```

### Quick Start (All-in-One)

```sql
-- ============================================
-- STEP 1: As SYSTEM/DBA (ONLY for user creation)
-- ============================================
sqlplus system/your_password@your_database
@01_create_users_and_schemas.sql
DISCONNECT

-- ============================================
-- STEP 2: As CRS_ADMIN_USER (Application Owner)
-- All DDL, DML, Stored Procedures, Triggers, Views
-- ============================================
CONNECT CRS_ADMIN_USER/Admin123
SET SERVEROUTPUT ON SIZE UNLIMITED;

@02_create_sequences.sql
@03_create_tables.sql
@04_create_indexes.sql
@05_insert_master_data.sql
@06_create_passenger_package.sql
@07_create_booking_package.sql
@08_create_cancellation_trigger.sql
@09_grant_permissions.sql
@10_insert_seed_data.sql
@13_management_reports.sql
@14_create_audit_log.sql

-- ============================================
-- STEP 3: As CRS_DATA_USER (Test with limited permissions)
-- ============================================
CONNECT CRS_DATA_USER/Data123
SET SERVEROUTPUT ON SIZE UNLIMITED;

@11_test_positive_cases.sql
@12_test_negative_cases.sql
```

### Verification Commands

After running all scripts, verify the setup:

```sql
-- Connect as CRS_ADMIN_USER (NOT as SYSTEM)
CONNECT CRS_ADMIN_USER/Admin123

-- Check all tables created
SELECT table_name FROM user_tables WHERE table_name LIKE 'CRS%';

-- Check all packages created
SELECT object_name, object_type, status 
FROM user_objects 
WHERE object_type IN ('PACKAGE', 'PACKAGE BODY');

-- Check all triggers created
SELECT trigger_name, status FROM user_triggers;

-- Check all views created
SELECT view_name FROM user_views;

-- Check row counts
SELECT 'CRS_TRAIN_INFO' AS table_name, COUNT(*) AS rows FROM CRS_TRAIN_INFO
UNION ALL
SELECT 'CRS_DAY_SCHEDULE', COUNT(*) FROM CRS_DAY_SCHEDULE
UNION ALL
SELECT 'CRS_PASSENGER', COUNT(*) FROM CRS_PASSENGER
UNION ALL
SELECT 'CRS_RESERVATION', COUNT(*) FROM CRS_RESERVATION;
```

### Verify CRS_DATA_USER Cannot Access Tables Directly

```sql
-- Connect as CRS_DATA_USER
CONNECT CRS_DATA_USER/Data123

-- This should FAIL (no direct table access)
SELECT * FROM CRS_ADMIN_USER.CRS_PASSENGER;
-- Expected Error: ORA-00942: table or view does not exist

-- This should SUCCEED (access via procedure)
DECLARE
    v_info VARCHAR2(500);
BEGIN
    v_info := CRS_ADMIN_USER.CRS_PASSENGER_PKG.get_passenger_info(1000);
    DBMS_OUTPUT.PUT_LINE(v_info);
END;
/
```

---

## 7. Usage Examples

### Add a Passenger

```sql
DECLARE
    v_id NUMBER;
BEGIN
    CRS_PASSENGER_PKG.add_passenger(
        p_first_name => 'John',
        p_middle_name => 'A',
        p_last_name => 'Doe',
        p_dob => TO_DATE('1990-01-15', 'YYYY-MM-DD'),
        p_address_line1 => '123 Main St',
        p_city => 'Boston',
        p_state => 'MA',
        p_zip => '02101',
        p_email => 'john.doe@email.com',
        p_phone => '617-555-1234',
        p_passenger_id => v_id
    );
    DBMS_OUTPUT.PUT_LINE('Passenger ID: ' || v_id);
END;
/
```

### Book a Ticket

```sql
DECLARE
    v_booking_id NUMBER;
    v_status VARCHAR2(20);
BEGIN
    CRS_BOOKING_PKG.book_ticket(
        p_passenger_id => 1000,
        p_train_number => 'TR-101',
        p_travel_date => TRUNC(SYSDATE) + 2,
        p_seat_class => 'FC',
        p_booking_id => v_booking_id,
        p_status => v_status
    );
    DBMS_OUTPUT.PUT_LINE('Booking ID: ' || v_booking_id || ', Status: ' || v_status);
END;
/
```

### Check Availability

```sql
SELECT CRS_BOOKING_PKG.check_availability('TR-101', TRUNC(SYSDATE)+1, 'FC') AS available_seats FROM DUAL;
```

### Cancel a Ticket

```sql
BEGIN
    CRS_BOOKING_PKG.cancel_ticket(p_booking_id => 5000);
END;
/
```

### View Booking Details

```sql
SELECT CRS_BOOKING_PKG.get_booking_details(5000) AS booking_info FROM DUAL;
```

---

## 8. Security Model

### User Roles and Permissions

| User | Permissions | Direct Table Access | Purpose |
|------|-------------|---------------------|---------|
| SYSTEM/DBA(ADB) | Full database privileges | Yes | **Used ONLY for creating users (Script 01)** |
| CRS_ADMIN_USER | CREATE TABLE, VIEW, SEQUENCE, PROCEDURE, TRIGGER | Yes (owner) | Application schema owner |
| CRS_DATA_USER | EXECUTE on CRS_PASSENGER_PKG, CRS_BOOKING_PKG | **No** | Data operations via procedures |
| CRS_REPORT_USER | SELECT on reporting views only | **No** | Read-only reporting |

### Principle of Least Privilege

- **CRS_ADMIN_USER** does NOT have DBA or SYSDBA privileges
- **CRS_DATA_USER** cannot INSERT/UPDATE/DELETE tables directly - must use procedures
- **CRS_REPORT_USER** cannot modify any data - read-only access to views
- All business logic is encapsulated in packages, ensuring validation rules are always enforced

---

## 9. Business Rules Implemented

| Rule | Description | Enforcement |
|------|-------------|-------------|
| Unique Email | Each passenger must have unique email | UNIQUE constraint + procedure validation |
| Unique Phone | Each passenger must have unique phone | UNIQUE constraint + procedure validation |
| Seat Capacity | 40 confirmed seats per class (FC/ECON) | Procedure logic |
| Waitlist Capacity | 5 waitlist slots per class (positions 41-45) | Procedure logic + CHECK constraint |
| Advance Booking | Maximum 1-week advance booking | CHECK constraint + procedure validation |
| Waitlist Promotion | Auto-promote first waitlisted on cancellation | Trigger |
| Schedule Validation | Train must run on travel day | Procedure validation |
| Past Date Prevention | Cannot book for past dates | Procedure validation |
| Valid Seat Class | Only FC or ECON allowed | CHECK constraint |
| Valid Status | Only CONFIRMED, WAITLISTED, CANCELLED | CHECK constraint |

---

## 10. Test Cases

### Positive Tests (5 cases) - File: 11_test_positive_cases.sql

| # | Test Case | Expected Result |
|---|-----------|-----------------|
| 1 | Book 40 FC seats | All CONFIRMED |
| 2 | Book 5 more FC seats | All WAITLISTED (positions 41-45) |
| 3 | Book 46th FC seat | Rejected with error -20016 |
| 4 | Cancel confirmed booking | Waitlisted passenger promoted |
| 5 | Book on non-operating day | Rejected with error -20015 |

### Negative Tests (10 cases) - File: 12_test_negative_cases.sql

| # | Scenario | Error Code |
|---|----------|------------|
| 1 | Duplicate Email | -20001 |
| 2 | Duplicate Phone | -20002 |
| 3 | Future Date of Birth | -20003 |
| 4 | Invalid Passenger ID | -20010 |
| 5 | Invalid Train Number | -20011 |
| 6 | Invalid Seat Class | -20012 |
| 7 | Booking Beyond 7 Days | -20013 |
| 8 | Past Date Booking | -20014 |
| 9 | Cancel Non-existent Booking | -20020 |
| 10 | Double Cancellation | -20021 |

---

## 11. Reporting Views

| View | Purpose |
|------|---------|
| BOOKING_REPORT_VIEW | Comprehensive booking details with passenger and train info |
| OCCUPANCY_VIEW | Train capacity utilization by date and class |
| REVENUE_VIEW | Revenue analysis by train and class |
| AUDIT_REPORT_VIEW | Transaction audit trail |

---

## 12. Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| ORA-01017: invalid username/password | Wrong credentials | Check password in 01_create_users_and_schemas.sql |
| ORA-00942: table or view does not exist | Scripts run out of order OR wrong user | Run scripts in sequence; check "Run As" column |
| ORA-04021: timeout occurred | Object locked | Wait or restart session |
| ORA-00955: name is already used | Re-running scripts | Scripts handle DROP IF EXISTS, safe to re-run |
| PLS-00201: identifier must be declared | Package not compiled | Recompile: `ALTER PACKAGE pkg_name COMPILE;` |
| ORA-01031: insufficient privileges | Wrong user connected | Check "Run As" column - don't use SYSTEM for scripts 02-14 |

---

## 13. Documentation

See [CRS_Group 4_Final Project_DAMG 6210.pdf](docs/CRS_Group%204_Final%20Project_DAMG%206210.pdf) for:
- ER Diagram
- Normalization Analysis (1NF, 2NF, 3NF)
- Security Design
- Workflow Diagrams

---

## 14. Course Information

- **Course:** DAMG 6210 - Data Management and Database Design
- **Term:** Fall 2025
- **University:** Northeastern University



