--IMPORT FGL ws_customer
--IMPORT FGL ws_job
--IMPORT FGL ws_product
IMPORT util

SCHEMA pool_doctors

TYPE job_list_type RECORD
    cm_rep_list LIKE customer.cm_rep,
    jh_code_list LIKE job_header.jh_code,
    cm_name_list LIKE customer.cm_name
END RECORD

DEFINE m_job_list_rec job_list_type
DEFINE m_job_list_arr DYNAMIC ARRAY OF job_list_type

DEFINE m_job_detail_rec RECORD LIKE job_detail.*
DEFINE m_job_detail_arr DYNAMIC ARRAY OF RECORD LIKE job_detail.*

DEFINE m_job_note_rec RECORD LIKE job_note.*
DEFINE m_job_note_arr DYNAMIC ARRAY OF RECORD LIKE job_note.*

DEFINE m_job_photo_rec RECORD LIKE job_photo.*
DEFINE m_job_photo_arr DYNAMIC ARRAY OF RECORD LIKE job_photo.*

DEFINE m_job_timesheet_rec RECORD LIKE job_timesheet.*
DEFINE m_job_timesheet_arr DYNAMIC ARRAY OF RECORD LIKE job_timesheet.*

MAIN
    DEFINE l_exit BOOLEAN

    DEFER INTERRUPT
    DEFER QUIT
    OPTIONS FIELD ORDER FORM
    OPTIONS INPUT WRAP

    CALL ui.Interface.loadStyles("pool_doctors_enquiry.4st")
    CLOSE WINDOW screen

    CONNECT TO "pool_doctors"

    OPEN WINDOW w WITH FORM "pool_doctors_enquiry"

    LET l_exit = FALSE

    WHILE NOT l_exit

        DECLARE job_list_curs CURSOR FOR
            SELECT cm_rep, jh_code, cm_name FROM job_header, customer WHERE jh_customer = cm_code ORDER BY cm_rep, jh_code

        CALL m_job_list_arr.clear()
        FOREACH job_list_curs INTO m_job_list_rec.*
            LET m_job_list_arr[m_job_list_arr.getLength() + 1].* = m_job_list_rec.*
        END FOREACH

        DIALOG ATTRIBUTES(UNBUFFERED)
            DISPLAY ARRAY m_job_list_arr TO job_list.*
                BEFORE ROW
                    CALL refresh_job(m_job_list_arr[arr_curr()].jh_code_list)
                    CALL show_photo(m_job_photo_arr[1].jp_code, m_job_photo_arr[1].jp_idx)
                ON DELETE
                    CALL delete_job(m_job_list_arr[arr_curr()].jh_code_list)
            END DISPLAY
            DISPLAY ARRAY m_job_detail_arr TO job_detail.*
            END DISPLAY
            DISPLAY ARRAY m_job_note_arr TO job_note.*
            END DISPLAY
            DISPLAY ARRAY m_job_photo_arr TO job_photo.*
                BEFORE ROW
                    CALL show_photo(m_job_photo_arr[arr_curr()].jp_code, m_job_photo_arr[arr_curr()].jp_idx)
            END DISPLAY
            DISPLAY ARRAY m_job_timesheet_arr TO job_timesheet.*
            END DISPLAY

            ON ACTION refresh ATTRIBUTES(TEXT = "Refresh")
                EXIT DIALOG

            ON ACTION web_services ATTRIBUTES(TEXT = "Web Services")
                RUN "fglrun pool_doctors_server_test" 
--                MENU "" ATTRIBUTES(STYLE = "dialog", COMMENT = "Enter Web Service to test")
--                    ON ACTION random ATTRIBUTES(TEXT = "Create Random Job")
--                        CALL create_random_job()
--                    ON ACTION customer_list ATTRIBUTES(TEXT = "Customer List")
--                        CALL customer_list()
--                    ON ACTION product_list ATTRIBUTES(TEXT = "Product List")
--                        CALL product_list()
--
--                    ON ACTION cancel
--                        EXIT MENU
--                    ON ACTION close
--                        EXIT MENU
--                END MENU

            ON ACTION close
                LET l_exit = TRUE
                EXIT DIALOG
        END DIALOG
    END WHILE
END MAIN

FUNCTION refresh_job(l_job_code)
    DEFINE l_job_code LIKE job_header.jh_code
    DEFINE l_job_header RECORD LIKE job_header.*
    DEFINE l_customer RECORD LIKE customer.*

    CALL m_job_detail_arr.clear()
    CALL m_job_note_arr.clear()
    CALL m_job_photo_arr.clear()
    CALL m_job_timesheet_arr.clear()

    -- Job Header
    SELECT job_header.*, cm_name INTO l_job_header.*, l_customer.cm_name FROM job_header, customer
        WHERE jh_customer = cm_code AND jh_code = l_job_code

    DISPLAY BY NAME l_job_header.*
    DISPLAY BY NAME l_customer.cm_name

    -- Job Detail
    DECLARE job_detail_curs CURSOR FOR SELECT * FROM job_detail WHERE jd_code = l_job_code ORDER BY jd_code, jd_line

    FOREACH job_detail_curs INTO m_job_detail_rec.*
        LET m_job_detail_arr[m_job_detail_arr.getLength() + 1].* = m_job_detail_rec.*
    END FOREACH

    -- Job Note
    DECLARE job_note_curs CURSOR FOR SELECT * FROM job_note WHERE jn_code = l_job_code ORDER BY jn_code, jn_idx

    FOREACH job_note_curs INTO m_job_note_rec.*
        LET m_job_note_arr[m_job_note_arr.getLength() + 1].* = m_job_note_rec.*
    END FOREACH

    -- Job Photo
    DECLARE job_photo_curs CURSOR FOR SELECT * FROM job_photo WHERE jp_code = l_job_code ORDER BY jp_code, jp_idx

    FOREACH job_photo_curs INTO m_job_photo_rec.*
        LET m_job_photo_arr[m_job_photo_arr.getLength() + 1].* = m_job_photo_rec.*
    END FOREACH

    -- Job Timesheet
    DECLARE job_timesheet_curs CURSOR FOR SELECT * FROM job_timesheet WHERE jt_code = l_job_code ORDER BY jt_code, jt_idx

    FOREACH job_timesheet_curs INTO m_job_timesheet_rec.*
        LET m_job_timesheet_arr[m_job_timesheet_arr.getLength() + 1].* = m_job_timesheet_rec.*
    END FOREACH
END FUNCTION

FUNCTION show_photo(l_jp_code, l_jp_idx)
    DEFINE l_jp_code LIKE job_photo.jp_code
    DEFINE l_jp_idx LIKE job_photo.jp_idx
    DEFINE l_jp_photo LIKE job_photo.jp_photo
    
    SELECT jp_photo INTO l_jp_photo FROM job_photo WHERE jp_code = l_jp_code AND jp_idx = l_jp_idx

    IF status = NOTFOUND THEN
        CLEAR show_photo
    ELSE
        DISPLAY l_jp_photo TO show_photo
    END IF
END FUNCTION

FUNCTION delete_job(l_jh_code)
    DEFINE l_jh_code LIKE job_header.jh_code

    BEGIN WORK
    DELETE FROM job_detail WHERE jd_code = l_jh_code
    DELETE FROM job_note WHERE jn_code = l_jh_code
    DELETE FROM job_photo WHERE jp_code = l_jh_code
    DELETE FROM job_timesheet WHERE jt_code = l_jh_code

    DELETE FROM job_header WHERE jh_code = l_jh_code
    COMMIT WORK
END FUNCTION

{
FUNCTION create_random_job()
    DEFINE l_cm_rep LIKE customer.cm_rep
    DEFINE l_jh_code LIKE job_header.jh_code

    DEFINE wsstatus INTEGER

    PROMPT "Enter rep (default=01)" FOR l_cm_rep
    LET l_cm_rep = NVL(l_cm_rep, "01")
    CALL ws_job.createRandomJob(l_cm_rep) RETURNING wsstatus, l_jh_code
    # error handling
END FUNCTION

FUNCTION customer_list()
    DEFINE l_customer_list ws_customer.listResponseBodyType
    DEFINE wsstatus INTEGER
    CALL ws_customer.list() RETURNING wsstatus, l_customer_list.*
    IF wsstatus = ws_customer.C_SUCCESS THEN
        CALL fgl_winmessage("Customer List", util.JSON.stringify(l_customer_list), "info")
    END IF
END FUNCTION

FUNCTION product_list()
    DEFINE l_product_list ws_product.listResponseBodyType
    DEFINE wsstatus INTEGER
    CALL ws_product.list() RETURNING wsstatus, l_product_list.*
    IF wsstatus = ws_product.C_SUCCESS THEN
        CALL fgl_winmessage("Product List", util.JSON.stringify(l_product_list), "info")
    END IF
END FUNCTION
}
