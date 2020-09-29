IMPORT os

CONSTANT DATABASE_FILENAME = "pool_doctors.db"
MAIN
DEFINE ch base.Channel

    IF base.Application.getArgument(1) = "--delete" THEN
        IF os.Path.delete(DATABASE_FILENAME) THEN
            DISPLAY "INFO - Existing database file deleted"
        END IF
    END IF

    IF os.Path.exists(DATABASE_FILENAME) THEN
        DISPLAY "ERROR - Database already exists"
        EXIT PROGRAM 1
    END IF
    LET ch = base.Channel.create()
    TRY
        CALL ch.openFile(DATABASE_FILENAME,"w") 
        CALL ch.close()
    CATCH
        DISPLAY "ERROR - Cannot create database file"
        EXIT PROGRAM 2
    END TRY

    TRY
        CONNECT TO "pool_doctors"
    CATCH
        DISPLAY "ERROR - Cannot connect to database"
        EXIT PROGRAM 3
    END TRY
    
    DISPLAY "INFO - Connected to database"

    CREATE TABLE customer (
        cm_code CHAR(10) NOT NULL,
        cm_name VARCHAR(255) NOT NULL,
        cm_email VARCHAR(30),
        cm_phone VARCHAR(20),
        cm_addr1 VARCHAR(40),
        cm_addr2 VARCHAR(40),
        cm_addr3 VARCHAR(40),
        cm_addr4 VARCHAR(40),
        cm_lat DECIMAL(11,5),
        cm_lon DECIMAL(11,5),
        cm_postcode CHAR(10),
        cm_rep CHAR(2))
        
    CREATE TABLE product (
        pr_code CHAR(10) NOT NULL,
        pr_desc VARCHAR(255),
        pr_barcode VARCHAR(30))

    CREATE TABLE job_header (
        jh_code CHAR(10) NOT NULL,
        jh_customer CHAR(10),
        jh_date_created DATETIME YEAR TO FRACTION(3),
        jh_status CHAR(1),
        jh_address1 VARCHAR(40),
        jh_address2 VARCHAR(40),
        jh_address3 VARCHAR(40),
        jh_address4 VARCHAR(40),
        jh_contact VARCHAR(40),
        jh_phone VARCHAR(20),
        jh_task_notes VARCHAR(200),
        jh_signature VARCHAR(10000),
        jh_date_signed DATETIME YEAR TO FRACTION(3),
        jh_name_signed VARCHAR(40))
        
    CREATE TABLE job_timesheet (
        jt_code CHAR(10) NOT NULL,
        jt_idx INTEGER NOT NULL,
        jt_start DATETIME YEAR TO FRACTION(3),
        jt_finish DATETIME YEAR TO FRACTION(3),
        jt_charge_code_id CHAR(2),
        jt_text VARCHAR(10000))
        
    CREATE TABLE job_detail (
        jd_code CHAR(10) NOT NULL,
        jd_line INTEGER NOT NULL,
        jd_product CHAR(10),
        jd_qty DECIMAL(11,2),
        jd_status CHAR(1))
        
    CREATE TABLE job_note (
        jn_code CHAR(10) NOT NULL,
        jn_idx INTEGER NOT NULL,
        jn_note VARCHAR(10000),
        jn_when DATETIME YEAR TO FRACTION(3))
        
    CREATE TABLE job_photo (
        jp_code CHAR(10) NOT NULL,
        jp_idx INTEGER NOT NULL,
        jp_photo VARCHAR(255),
        jp_when DATETIME YEAR TO FRACTION(3),
        jp_lat DECIMAL(11,5),
        jp_lon DECIMAL(11,5),
        jp_text VARCHAR(10000))

    DISPLAY "INFO - Database tables created"

    TRY
        LOAD FROM "customer.unl" INSERT INTO customer
    CATCH
        DISPLAY "ERROR - Cannot populate customer"
    END TRY

    TRY
        LOAD FROM "product.unl" INSERT INTO product
    CATCH
        DISPLAY "ERROR - Cannot populate product"
    END TRY

    DISPLAY "INFO - Database tables populated"
    
END MAIN