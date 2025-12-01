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
  - Only **two classes** – *Business* and *Economy*
  - Each class has **40 seats** + **5 waitlist slots**
  - Unique passenger **email** and **phone**

---

## 2. Data Model / ERD

The core entities:

- `TRAIN`
- `TRAIN_STATUS`
- `PASSENGER`
- `TICKET`

### 2.1 ERD (Text Diagram)

```text
+------------------+          +----------------------+
|      TRAIN       | 1      M |    TRAIN_STATUS      |
+------------------+----------+----------------------+
| PK Train_ID      |          | PK Status_ID         |
|    Train_Number  |          | FK Train_ID          |
|    Train_Name    |          |    Travel_Date       |
|    Source_Stn    |          |    Class             |
|    Dest_Stn      |          |    Total_Seats       |
|    Days_In_Serv  |          |    Seats_Booked      |
+------------------+          |    Seats_Available   |
                              +----------------------+

+------------------+          +----------------------+
|    PASSENGER     | 1      M |        TICKET        |
+------------------+----------+----------------------+
| PK Passenger_ID  |          | PK Ticket_ID         |
|    First_Name    |          | FK Passenger_ID      |
|    Middle_Name   |          | FK Train_ID          |
|    Last_Name     |          | FK Status_ID         |
|    DOB           |          |    Booking_Date      |
|    Email (UQ)    |          |    Travel_Date       |
|    Phone (UQ)    |          |    Class             |
|    Address       |          |    Ticket_Status     |
+------------------+          |    Seat_No           |
                              |    Waitlist_Pos      |
                              +----------------------+
