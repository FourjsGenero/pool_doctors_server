IMPORT com
IMPORT util
IMPORT os

SCHEMA pool_doctors

TYPE job_header_RecType RECORD LIKE job_header.*
TYPE job_header_ListType RECORD
    rows DYNAMIC ARRAY OF job_header_RecType
END RECORD
TYPE job_header_job_code_Type LIKE job_header.jh_code

TYPE job_Type RECORD
    job_header RECORD LIKE job_header.*,
    job_detail DYNAMIC ARRAY OF RECORD LIKE job_detail.*,
    job_note DYNAMIC ARRAY OF RECORD LIKE job_note.*,
    job_timesheet DYNAMIC ARRAY OF RECORD LIKE job_timesheet.*,
    job_photo DYNAMIC ARRAY OF RECORD LIKE job_photo.*
END RECORD

PUBLIC DEFINE ws_error RECORD ATTRIBUTES(WSError = "error")
    message STRING
END RECORD

FUNCTION createRandomJob(l_cm_rep LIKE customer.cm_rep ATTRIBUTES(WSParam))
    ATTRIBUTES(WSGet, WSPath = "/createRandomJob/{l_cm_rep}", WSThrows = "400:@ws_error")
    RETURNS job_header_job_code_Type ATTRIBUTES(WSName = "job_code", WSMedia = "application/json")

    DEFINE l_job_header RECORD LIKE job_header.*
    DEFINE l_customer RECORD LIKE customer.*

    DEFINE l_rand INTEGER
    DEFINE l_customer_count INTEGER

    DEFINE l_sql STRING
    DEFINE l_last_job LIKE job_header.jh_code
    DEFINE l_last_job_int INTEGER

    SELECT COUNT(*) INTO l_customer_count FROM customer WHERE cm_rep = l_cm_rep

    IF l_customer_count = 0 THEN
        LET ws_error.message = "No customers for rep"
        CALL com.WebServiceEngine.setRestError(400, ws_error)
    END IF

    LET l_rand = util.Math.rand(l_customer_count)

    -- get random customer
    CASE fgl_db_driver_type()
        WHEN "SQT" -- SQLite
            LET l_sql = "select * from customer limit 1 offset ", l_rand
            DECLARE customer_sqt_curs CURSOR FROM l_sql
            OPEN customer_sqt_curs
            FETCH customer_sqt_curs INTO l_customer.*
            -- may need to add other database types here
        OTHERWISE
            LET l_sql = "select * from customer"
            DECLARE customer_ifx_curs SCROLL CURSOR FROM l_sql
            OPEN customer_ifx_curs
            LET l_rand = l_rand + 1
            FETCH ABSOLUTE l_rand customer_ifx_curs INTO l_customer.*
    END CASE

    -- get maxmimum job code and add 1 to 1
    LET l_sql =
        "select jh_code ", "from job_header, customer ", "where jh_customer = cm_code ", "and cm_rep = ? ", "order by jh_code desc"
    DECLARE last_job_curs CURSOR FROM l_sql
    OPEN last_job_curs USING l_cm_rep
    FETCH last_job_curs INTO l_last_job

    IF status = NOTFOUND THEN
        LET l_last_job_int = 1
    ELSE
        LET l_last_job_int = 1 + l_last_job[3, 10]
    END IF

    LET l_job_header.jh_code = SFMT("%1%2", l_cm_rep, l_last_job_int USING "&&&&&&&&")
    LET l_job_header.jh_customer = l_customer.cm_code
    LET l_job_header.jh_date_created = CURRENT YEAR TO SECOND
    LET l_job_header.jh_status = 'O'
    LET l_job_header.jh_address1 = l_customer.cm_addr1
    LET l_job_header.jh_address2 = l_customer.cm_addr2
    LET l_job_header.jh_address3 = l_customer.cm_addr3
    LET l_job_header.jh_address4 = l_customer.cm_addr4
    LET l_job_header.jh_phone = l_customer.cm_phone
    LET l_job_header.jh_task_notes = "Created By random test mechanism"

    INSERT INTO job_header VALUES(l_job_header.*)

    RETURN l_job_header.jh_code
END FUNCTION

FUNCTION getJobsForRep(l_cm_rep LIKE customer.cm_rep ATTRIBUTES(WSParam)) ATTRIBUTES(WSGet, WSPath = "/getJobsForRep/{l_cm_rep}")
    RETURNS job_header_ListType ATTRIBUTES(WSName = "job_header", WSMedia = "application/json")

    DEFINE l_job_header job_header_RecType
    DEFINE l_arr job_header_ListType

    DEFINE l_sql STRING

    LET l_sql =
        "select * ", "from job_header, customer ", "where jh_customer = cm_code ", "and cm_rep = ? ",
        #"and (jh_status = 'O' or jh_status = 'I' or (jh_status = 'X' and jh_date_signed >= date( julianday(date('now'))-7))) ",
        "and (jh_status = 'O' or jh_status = 'I' or (jh_status = 'X' and jh_date_signed >= (today-7))) ", "order by jh_code "

    DECLARE job_header_curs CURSOR FROM l_sql
    FOREACH job_header_curs USING l_cm_rep INTO l_job_header.*
        LET l_arr.rows[l_arr.rows.getLength() + 1].* = l_job_header.*
        DISPLAY l_job_header.*
    END FOREACH
    DISPLAY util.JSON.stringify(l_arr)

    RETURN l_arr.*
END FUNCTION

FUNCTION uploadJob(l_job job_Type ATTRIBUTES(WSName = "job")) ATTRIBUTES(WSPut, WSPath = "/put")

    DEFINE i INTEGER

    BEGIN WORK

    DELETE FROM job_detail WHERE jd_code = l_job.job_header.jh_code
    DELETE FROM job_note WHERE jn_code = l_job.job_header.jh_code
    DELETE FROM job_photo WHERE jp_code = l_job.job_header.jh_code
    DELETE FROM job_timesheet WHERE jt_code = l_job.job_header.jh_code

    -- update what has changed
    UPDATE job_header
        SET jh_date_signed = l_job.job_header.jh_date_signed, jh_name_signed = l_job.job_header.jh_name_signed,
            jh_signature = l_job.job_header.jh_signature, jh_status = l_job.job_header.jh_status
        WHERE jh_code = l_job.job_header.jh_code

    FOR i = 1 TO l_job.job_detail.getLength()
        INSERT INTO job_detail VALUES l_job.job_detail[i].*
    END FOR

    FOR i = 1 TO l_job.job_note.getLength()
        INSERT INTO job_note VALUES l_job.job_note[i].*
    END FOR

    FOR i = 1 TO l_job.job_photo.getLength()
        INSERT INTO job_photo VALUES l_job.job_photo[i].*
    END FOR

    FOR i = 1 TO l_job.job_timesheet.getLength()
        INSERT INTO job_timesheet VALUES l_job.job_timesheet[i].*
    END FOR
    COMMIT WORK

    RETURN TRUE, ""
END FUNCTION

PUBLIC FUNCTION uploadJobPhoto(
    l_jp_code LIKE job_photo.jp_code ATTRIBUTES(WSParam), l_jp_idx LIKE job_photo.jp_idx ATTRIBUTE(WSParam),
    l_device_filename STRING ATTRIBUTES(WSAttachment, WSMedia = "image/*"))
    ATTRIBUTES(WSPost, WSPath = "/put_photo/{l_jp_code}/{l_jp_idx}")

    DEFINE l_server_filename STRING
    DEFINE ok INTEGER
    LET l_server_filename =
        SFMT("%1%2%3_%4_%5",
            os.Path.pwd(), os.Path.separator(), l_jp_code CLIPPED, l_jp_idx USING "&&", os.Path.basename(l_device_filename))
    LET ok = os.Path.copy(l_device_filename, l_server_filename)
    DISPLAY l_device_filename, l_server_filename
    BEGIN WORK
    UPDATE job_photo SET jp_photo = l_server_filename WHERE jp_code = l_jp_code AND jp_idx = l_jp_idx
    COMMIT WORK

    RETURN TRUE, ""
END FUNCTION
