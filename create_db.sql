-- Use the pool_doctors_create_db application to create the database instead of this SQL

CREATE TABLE customer (
cm_code CHAR(10) NOT NULL,
cm_name LVARCHAR(255) NOT NULL,
cm_email LVARCHAR(30),
cm_phone LVARCHAR(20),
cm_addr1 LVARCHAR(40),
cm_addr2 LVARCHAR(40),
cm_addr3 LVARCHAR(40),
cm_addr4 LVARCHAR(40),
cm_lat DECIMAL(11,5),
cm_lon DECIMAL(11,5),
cm_postcode CHAR(10),
cm_rep CHAR(2));

CREATE TABLE job_detail (
jd_code CHAR(10) NOT NULL,
jd_line INTEGER NOT NULL,
jd_product CHAR(10),
jd_qty DECIMAL(11,2),
jd_status CHAR(1));

CREATE TABLE job_header (
jh_code CHAR(10) NOT NULL,
jh_customer CHAR(10),
jh_date_created DATETIME YEAR TO FRACTION(3),
jh_status CHAR(1),
jh_address1 LVARCHAR(40),
jh_address2 LVARCHAR(40),
jh_address3 LVARCHAR(40),
jh_address4 LVARCHAR(40),
jh_contact LVARCHAR(40),
jh_phone LVARCHAR(20),
jh_task_notes LVARCHAR(200),
jh_signature LVARCHAR(10000),
jh_date_signed DATETIME YEAR TO FRACTION(3),
jh_name_signed LVARCHAR(40));

CREATE TABLE job_note (
jn_code CHAR(10),
jn_idx INTEGER,
jn_note LVARCHAR(10000),
jn_when DATETIME YEAR TO FRACTION(3));

CREATE TABLE job_photo (
jp_code CHAR(10) NOT NULL,
jp_idx INTEGER NOT NULL,
jp_photo LVARCHAR(80),
jp_when DATETIME YEAR TO FRACTION(3),
jp_lat DECIMAL(11,5),
jp_lon DECIMAL(11,5),
jp_text LVARCHAR(10000));

CREATE TABLE job_timesheet (
jt_code CHAR(10) NOT NULL,
jt_idx INTEGER NOT NULL,
jt_start DATETIME YEAR TO FRACTION(3),
jt_finish DATETIME YEAR TO FRACTION(3),
jt_charge_code_id CHAR(2),
jt_text LVARCHAR(10000));

CREATE TABLE product (
pr_code CHAR(10) NOT NULL,
pr_desc LVARCHAR(255) NOT NULL,
pr_barcode LVARCHAR(30));
