-- ============================================================================
-- Commuter Reservation System (CRS)
-- Passenger Management Package
-- Date: November 2025
-- Note: Run as CRS_ADMIN_USER
-- ============================================================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- ============================================================================
-- Package Specification
-- ============================================================================
CREATE OR REPLACE PACKAGE CRS_PASSENGER_PKG AS
    
    -- Add a new passenger
    PROCEDURE add_passenger(
        p_first_name IN VARCHAR2,
        p_middle_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_dob IN DATE,
        p_address_line1 IN VARCHAR2,
        p_city IN VARCHAR2,
        p_state IN VARCHAR2,
        p_zip IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_passenger_id OUT NUMBER
    );
    
    -- Update passenger information
    PROCEDURE update_passenger(
        p_passenger_id IN NUMBER,
        p_address_line1 IN VARCHAR2 DEFAULT NULL,
        p_city IN VARCHAR2 DEFAULT NULL,
        p_state IN VARCHAR2 DEFAULT NULL,
        p_zip IN VARCHAR2 DEFAULT NULL,
        p_email IN VARCHAR2 DEFAULT NULL,
        p_phone IN VARCHAR2 DEFAULT NULL
    );
    
    -- Get passenger details
    FUNCTION get_passenger_info(p_passenger_id IN NUMBER)
    RETURN VARCHAR2;
    
END CRS_PASSENGER_PKG;
/

-- ============================================================================
-- Package Body
-- ============================================================================
CREATE OR REPLACE PACKAGE BODY CRS_PASSENGER_PKG AS
    
    PROCEDURE add_passenger(
        p_first_name IN VARCHAR2,
        p_middle_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_dob IN DATE,
        p_address_line1 IN VARCHAR2,
        p_city IN VARCHAR2,
        p_state IN VARCHAR2,
        p_zip IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_passenger_id OUT NUMBER
    ) IS
        v_email_count NUMBER;
        v_phone_count NUMBER;
    BEGIN
        -- Check if email already exists
        SELECT COUNT(*) INTO v_email_count
        FROM CRS_PASSENGER
        WHERE email = p_email;
        
        IF v_email_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email already exists in the system');
        END IF;
        
        -- Check if phone already exists
        SELECT COUNT(*) INTO v_phone_count
        FROM CRS_PASSENGER
        WHERE phone = p_phone;
        
        IF v_phone_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Phone number already exists in the system');
        END IF;
        
        -- Validate DOB
        IF p_dob >= SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20003, 'Date of birth must be in the past');
        END IF;
        
        -- Insert new passenger
        INSERT INTO CRS_PASSENGER (
            passenger_id, first_name, middle_name, last_name, date_of_birth,
            address_line1, address_city, address_state, address_zip,
            email, phone
        ) VALUES (
            crs_passenger_seq.NEXTVAL, p_first_name, p_middle_name, p_last_name, p_dob,
            p_address_line1, p_city, p_state, p_zip,
            p_email, p_phone
        ) RETURNING passenger_id INTO p_passenger_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Passenger added successfully. ID: ' || p_passenger_id);
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error adding passenger: ' || SQLERRM);
            RAISE;
    END add_passenger;
    
    PROCEDURE update_passenger(
        p_passenger_id IN NUMBER,
        p_address_line1 IN VARCHAR2 DEFAULT NULL,
        p_city IN VARCHAR2 DEFAULT NULL,
        p_state IN VARCHAR2 DEFAULT NULL,
        p_zip IN VARCHAR2 DEFAULT NULL,
        p_email IN VARCHAR2 DEFAULT NULL,
        p_phone IN VARCHAR2 DEFAULT NULL
    ) IS
        v_count NUMBER;
        v_email_count NUMBER;
        v_phone_count NUMBER;
    BEGIN
        -- Check if passenger exists
        SELECT COUNT(*) INTO v_count
        FROM CRS_PASSENGER
        WHERE passenger_id = p_passenger_id;
        
        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Passenger ID not found');
        END IF;
        
        -- Check email uniqueness if provided
        IF p_email IS NOT NULL THEN
            SELECT COUNT(*) INTO v_email_count
            FROM CRS_PASSENGER
            WHERE email = p_email AND passenger_id != p_passenger_id;
            
            IF v_email_count > 0 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Email already exists');
            END IF;
        END IF;
        
        -- Check phone uniqueness if provided
        IF p_phone IS NOT NULL THEN
            SELECT COUNT(*) INTO v_phone_count
            FROM CRS_PASSENGER
            WHERE phone = p_phone AND passenger_id != p_passenger_id;
            
            IF v_phone_count > 0 THEN
                RAISE_APPLICATION_ERROR(-20002, 'Phone number already exists');
            END IF;
        END IF;
        
        -- Update only provided fields
        UPDATE CRS_PASSENGER
        SET address_line1 = NVL(p_address_line1, address_line1),
            address_city = NVL(p_city, address_city),
            address_state = NVL(p_state, address_state),
            address_zip = NVL(p_zip, address_zip),
            email = NVL(p_email, email),
            phone = NVL(p_phone, phone)
        WHERE passenger_id = p_passenger_id;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Passenger updated successfully');
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            DBMS_OUTPUT.PUT_LINE('Error updating passenger: ' || SQLERRM);
            RAISE;
    END update_passenger;
    
    FUNCTION get_passenger_info(p_passenger_id IN NUMBER)
    RETURN VARCHAR2 IS
        v_info VARCHAR2(500);
    BEGIN
        SELECT first_name || ' ' || NVL(middle_name || ' ', '') || last_name || 
               ' (Email: ' || email || ', Phone: ' || phone || ')'
        INTO v_info
        FROM CRS_PASSENGER
        WHERE passenger_id = p_passenger_id;
        
        RETURN v_info;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Passenger not found';
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END get_passenger_info;
    
END CRS_PASSENGER_PKG;
/

-- ============================================================================
-- Grant Execute Privileges to Application User
-- ============================================================================
GRANT EXECUTE ON CRS_PASSENGER_PKG TO CRS_DATA_USER;

COMMIT;

PROMPT Passenger package created successfully
PROMPT Execute privileges granted to CRS_DATA_USER
PROMPT Next: Run 07_create_booking_package.sql

-- ============================================================================
-- END OF PASSENGER PACKAGE SCRIPT
-- ============================================================================