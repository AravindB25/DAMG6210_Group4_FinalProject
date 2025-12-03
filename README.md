# DAMG6210_Group4_FinalProject

## Train Reservation System (Commuter Reservation System)

This project implements a simplified **Train Reservation System** in **Oracle Database** using:
- Normalized relational data model
- Tables with constraints (PK, FK, CHECK, UNIQUE)
- PL/SQL packages, procedures, and functions
- Test cases to validate **business rules** and **error handling**

The system focuses on **reservations, passengers, trains, and daily train status**.
Payment details are explicitly **out of scope** as per the assignment.

---

## 1. Problem Description

The goal is to design and implement a **Commuter Reservation System (CRS)** that allows:

- Maintaining master data for **trains** and **passengers**
- Managing **daily status** of trains (per train, per travel date, per class)
- Booking tickets **only when seats are available**, with **waitlist support**
- Cancelling tickets and **promoting waitlisted passengers** when seats free up
- Enforcing key business rules such as:
  - Only **one week** advance booking allowed
  - Only **two classes** – *First Class (FC)* and *Economy (ECON)*
  - Each class has **40 seats** + **5 waitlist slots**
  - Unique passenger **email** and **phone**

---

## 2. Data Model / ERD

### 2.1 Core Entities

| Table | Description |
|-------|-------------|
| CRS_TRAIN_INFO | Train master data (routes, capacity, fares) |
| CRS_DAY_SCHEDULE | Days of week reference (7 rows) |
| CRS_TRAIN_SCHEDULE | Bridge table for train-day relationships |
| CRS_PASSENGER | Passenger information |
| CRS_RESERVATION | Booking records with status tracking |
| CRS_AUDIT_LOG | Transaction audit trail |

### 2.2 ERD (Text Diagram)
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

### 2.3 Entity Relationships
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

## 3. Key Features

- Real-time seat availability tracking (40 confirmed + 5 waitlist per class)
- Automated waitlist promotion upon cancellations
- 1-week advance booking validation
- Unique passenger identification (email/phone)
- Role-based access control (Admin, Data User, Report User)
- Comprehensive audit trail for all transactions

---

## 4. Team - Group 4

| Name | Responsibility |
|------|----------------|
| Aravind Balaji | Schema Design, Tables, Constraints, Sequences, Indexes, Documentation |
| Pranav Narendrabhai Patel | PL/SQL Packages, Stored Procedures, Functions, Triggers, Reports |
| Akshay Dnyaneshwar Govind | Master Data, Seed Data, Test Cases, Permissions, Audit Log |

---

## 5. Installation

### Prerequisites

- Oracle Database 19c or higher
- SQL*Plus or Oracle SQL Developer
- DBA privileges for initial setup

### Run Scripts in Order
```sql
-- Step 1: As SYSTEM/DBA user
@01_create_users_and_schemas.sql

-- Step 2: Connect as CRS_ADMIN_USER
CONNECT CRS_ADMIN_USER/Admin123

-- Step 3: Run remaining scripts in sequence
@02_create_sequences.sql
@03_create_tables.sql
@04_create_indexes.sql
@05_insert_master_data.sql
@06_create_passenger_package.sql
@07_create_booking_package.sql
@08_create_cancellation_trigger.sql
@09_grant_permissions.sql
@10_insert_seed_data.sql
@11_test_positive_cases.sql
@12_test_negative_cases.sql
@13_management_reports.sql
@14_create_audit_log.sql
```

---

## 6. Project Structure
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

---

## 8. Security Model

| Role | Access Level |
|------|--------------|
| CRS_ADMIN_USER | Full DDL/DML access, schema owner |
| CRS_DATA_USER | Execute procedures only |
| CRS_REPORT_USER | SELECT on views only |

---

## 9. Business Rules Implemented

| Rule | Description |
|------|-------------|
| Unique Email | Each passenger must have unique email |
| Unique Phone | Each passenger must have unique phone |
| Seat Capacity | 40 confirmed seats per class (FC/ECON) |
| Waitlist Capacity | 5 waitlist slots per class |
| Advance Booking | Maximum 1-week advance booking |
| Waitlist Promotion | Auto-promote on cancellation |
| Schedule Validation | Train must run on travel day |
| Past Date Prevention | Cannot book for past dates |

---

## 10. Test Cases

| Type | Count | File | Purpose |
|------|-------|------|---------|
| Positive Tests | 5 | 11_test_positive_cases.sql | Validate business rules work correctly |
| Negative Tests | 10 | 12_test_negative_cases.sql | Validate error handling for invalid data |

### Negative Test Scenarios

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
| BOOKING_REPORT_VIEW | Comprehensive booking details |
| OCCUPANCY_VIEW | Train capacity utilization |
| REVENUE_VIEW | Revenue analysis by train/class |
| AUDIT_REPORT_VIEW | Transaction audit trail |

---

## 12. Documentation

See [CRS_Group 4_Final Project_DAMG 6210.pdf](docs/CRS_Group%204_Final%20Project_DAMG%206210.pdf) for:
- ER Diagram
- Normalization Analysis (1NF, 2NF, 3NF)
- Security Design
- Workflow Diagrams

---

## 13. Course Information

- **Course:** DAMG 6210 - Data Management and Database Design
- **Term:** Fall 2025
- **University:** Northeastern University
