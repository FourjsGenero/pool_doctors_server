IMPORT FGL ws_customer
IMPORT FGL ws_product
IMPORT FGL ws_job
IMPORT  util

SCHEMA pool_doctors

MAIN
    MENU ""

        COMMAND "Create Random Job"
            CALL do_create_random_job()

        COMMAND "Get Jobs For Rep"
            CALL do_get_jobs_for_rep()

        COMMAND "Upload jobs"
            CALL do_upload_jobs()

        COMMAND "Customer Get"
            CALL do_customer_get()
            
        COMMAND "Customer List"
            CALL do_customer_list()

        COMMAND "Product Get"
            CALL do_product_get()

        COMMAND "Product List"
            CALL do_product_list()

        ON ACTION close
            EXIT MENU
    END MENU
END MAIN

FUNCTION do_get_jobs_for_rep()
DEFINE wsstatus INTEGER
DEFINE jobs ws_job.getJobsForRepResponseBodyType

    CALL ws_job.getJobsForRep("01") RETURNING wsstatus, jobs.*
    IF wsstatus = ws_job.C_SUCCESS THEN
        DISPLAY util.Json.stringify(jobs)
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_job.ws_error.message=%1",ws_job.ws_error.message)
    END IF        

END FUNCTION

FUNCTION do_create_random_job()
DEFINE wsstatus INTEGER
DEFINE resp  STRING

    CALL ws_job.createRandomJob("01") RETURNING wsstatus, resp
    IF wsstatus = ws_job.C_SUCCESS THEN
        DISPLAY resp
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_job.ws_error.message=%1",ws_job.ws_error.message)
    END IF

END FUNCTION

FUNCTION do_customer_get()
DEFINE l_customer_rec  ws_customer.getResponseBodyType
DEFINE wsstatus INTEGER

    CALL ws_customer.get("AKL028") RETURNING wsstatus, l_customer_rec.*
    IF wsstatus = ws_customer.C_SUCCESS THEN
        DISPLAY util.JSON.stringify(l_customer_rec)
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_customer.ws_error.message=%1",ws_customer.ws_error.message)
    END IF
END FUNCTION

FUNCTION do_customer_list()
DEFINE l_customer_list  ws_customer.listResponseBodyType
DEFINE wsstatus INTEGER

    CALL ws_customer.list() RETURNING wsstatus, l_customer_list.*
    IF wsstatus = ws_customer.C_SUCCESS THEN
        DISPLAY util.JSON.stringify(l_customer_list)
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_customer.ws_error.message=%1",ws_customer.ws_error.message)
    END IF
END FUNCTION

FUNCTION do_product_get()
DEFINE l_product_rec  ws_product.getResponseBodyType
DEFINE wsstatus INTEGER

    CALL ws_product.get("WIDESKIM") RETURNING wsstatus, l_product_rec.*
    IF wsstatus = ws_product.C_SUCCESS THEN
        DISPLAY util.JSON.stringify(l_product_rec)
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_product.ws_error.message=%1",ws_product.ws_error.message)
    END IF
END FUNCTION

FUNCTION do_product_list()
DEFINE l_product_list  ws_product.listResponseBodyType
DEFINE wsstatus INTEGER

    CALL ws_product.list() RETURNING wsstatus, l_product_list.*
    IF wsstatus = ws_product.C_SUCCESS THEN
        DISPLAY util.JSON.stringify(l_product_list)
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_product.ws_error.message=%1",ws_product.ws_error.message)
    END IF
END FUNCTION

FUNCTION do_upload_jobs()
DEFINE wsstatus INTEGER
DEFINE l_product_list  ws_product.listResponseBodyType
DEFINE job ws_job.uploadJobRequestBodyType
DEFINE job_list ws_job.getJobsForRepResponseBodyType
DEFINE job_idx, line_idx INTEGER

    -- Get data we need for this test

    CALL ws_job.getJobsForRep("01") RETURNING wsstatus, job_list.*
    IF wsstatus = ws_job.C_SUCCESS THEN
        # Jobs loaded
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_job.ws_error.message=%1",ws_job.ws_error.message)
    END IF

    CALL ws_product.list() RETURNING wsstatus, l_product_list.*
    IF wsstatus = ws_product.C_SUCCESS THEN
        # Products loaded
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_product.ws_error.message=%1",ws_product.ws_error.message)
    END IF

    FOR job_idx = 1 TO job_list.rows.getLength()
        IF job_list.rows[job_idx].jh_status = "O" THEN
            -- This fiirst job is one we will update
            EXIT FOR
        END IF
    END FOR
    IF job_idx > job_list.rows.getLength() THEN
        DISPLAY " *** No jobs available to update, create a random job *** "
        RETURN
    END IF

    LET job.job_header.* = job_list.rows[job_idx].*
    LET job.job_header.jh_status = "C"
    LET job.job_header.jh_name_signed = "Name on signature"
    LET job.job_header.jh_signature = "Signature"
    LET job.job_header.jh_date_signed = TODAY

    FOR line_idx = (util.Math.rand(5)+1) TO 1 STEP -1
        LET job.job_detail[line_idx].jd_code = job.job_header.jh_code
        LET job.job_detail[line_idx].jd_line = line_idx
        LET job.job_detail[line_idx].jd_product = l_product_list.rows[util.Math.rand(l_product_list.rows.getLength())+1].pr_code
        LET job.job_detail[line_idx].jd_qty = util.Math.rand(10) + 1
        LET job.job_detail[line_idx].jd_status = "X"
    END FOR
    DISPLAY SFMT("Job Detail Count=%1",job.job_detail.getLength())

    FOR line_idx = (util.Math.rand(3)+1) TO 1 STEP -1
        LET job.job_note[line_idx].jn_code = job.job_header.jh_code
        LET job.job_note[line_idx].jn_idx = line_idx
        LET job.job_note[line_idx].jn_note = "Random text"
        LET job.job_note[line_idx].jn_when  = CURRENT
    END FOR
    DISPLAY SFMT("Job Note Count=%1",job.job_note.getLength())

    FOR line_idx = (util.Math.rand(3)+1) TO 1 STEP -1
        LET job.job_timesheet[line_idx].jt_code = job.job_header.jh_code
        LET job.job_timesheet[line_idx].jt_idx = line_idx
        LET job.job_timesheet[line_idx].jt_text = "Random text"
        LET job.job_timesheet[line_idx].jt_start  = CURRENT
        LET job.job_timesheet[line_idx].jt_finish  = CURRENT
        LET job.job_timesheet[line_idx].jt_charge_code_id = "S"
    END FOR
    DISPLAY SFMT("Job Timesheet Count=%1",job.job_timesheet.getLength())

    FOR line_idx = (util.Math.rand(3)+1) TO 1 STEP -1
        LET job.job_photo[line_idx].jp_code = job.job_header.jh_code
        LET job.job_photo[line_idx].jp_idx = line_idx
        LET job.job_photo[line_idx].jp_text = "Random text"
        LET job.job_photo[line_idx].jp_when  = CURRENT
        LET job.job_photo[line_idx].jp_photo  = IIF(line_idx MOD 2 == 0, "smiley.png", "ssmiley.png")
        LET job.job_photo[line_idx].jp_lat = -37
        LET job.job_photo[line_idx].jp_lon = 174
    END FOR
    DISPLAY SFMT("Job Photo Count=%1",job.job_photo.getLength())

    CALL ws_job.uploadJob(job.*) RETURNING wsstatus
    IF wsstatus = ws_job.C_SUCCESS THEN
        DISPLAY SFMT("Job Uploaded = %1", job.job_header.jh_code) 

        -- Now do the individual photo files
        FOR line_idx = 1 TO job.job_photo.getLength()
            CALL ws_job.uploadJobPhoto(job.job_photo[line_idx].jp_code, job.job_photo[line_idx].jp_idx,  job.job_photo[line_idx].jp_photo  )
                RETURNING wsstatus
            IF wsstatus = ws_job.C_SUCCESS THEN
                DISPLAY SFMT("Photo Uploaded %1/%2 %3", job.job_photo[line_idx].jp_code, job.job_photo[line_idx].jp_idx,  job.job_photo[line_idx].jp_photo) 
            ELSE
                DISPLAY SFMT("ws_job.ws_error.message=%1",ws_job.ws_error.message)
            END IF
        END FOR
        
    ELSE
        DISPLAY SFMT("wsstatus=%1", wsstatus)
        DISPLAY SFMT("ws_job.ws_error.message=%1",ws_job.ws_error.message)
    END IF
END FUNCTION 

