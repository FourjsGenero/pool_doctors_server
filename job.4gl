
import util

schema pool_doctors


function createRandomJob(l_cm_rep)
define l_cm_rep like customer.cm_rep
define l_job_header record like job_header.*
define l_customer record like customer.*

define l_rand integer
define l_customer_count integer

define l_sql string
define l_job_count integer
define l_last_job like job_header.jh_code
define l_last_job_int integer

    select count(*)
    into l_customer_count
    from customer
    where cm_rep = l_cm_rep

    let l_rand = util.Math.rand(l_customer_count)

    -- get random customer
    -- SQLite
    #let l_sql = "select * from customer limit 1 offset ", l_rand
    #declare customer_curs cursor from l_sql
    #open customer_curs 
    #fetch customer_curs into l_customer.*

    -- Informix
    let l_sql = "select * from customer"
    declare customer_curs scroll cursor from l_sql
    open customer_curs 
    let l_rand = l_rand + 1
    fetch absolute l_rand customer_curs into l_customer.*


    -- get maxmimum job code and add 1 to 1
    let l_sql= "select jh_code ",
    "from job_header, customer ",
    "where jh_customer = cm_code ",
    "and cm_rep = ? ",
    "order by jh_code desc"
    declare last_job_curs cursor from l_sql
    open last_job_curs using l_cm_rep
    fetch last_job_curs into l_last_job
    if status = notfound then
        let l_last_job_int = 1
    else
        let l_last_job_int = 1 + l_last_job[3,10]
    end if

    let l_job_header.jh_code = sfmt("%1%2", l_cm_rep, l_last_job_int using "<<<<&&&&")
    let l_job_header.jh_customer = l_customer.cm_code
    let l_job_header.jh_date_created = current year to second
    let l_job_header.jh_status = 'O'
    let l_job_header.jh_address1 = l_customer.cm_addr1
    let l_job_header.jh_address2 = l_customer.cm_addr2
    let l_job_header.jh_address3 = l_customer.cm_addr3
    let l_job_header.jh_address4 = l_customer.cm_addr4
    let l_job_header.jh_phone = l_customer.cm_phone
    let l_job_header.jh_task_notes = "Created By random test mechanism"
    
    insert into job_header values(l_job_header.*)

    return true, l_job_header.jh_code
end function



function getJobsForRep(l_cm_rep)
define l_cm_rep like customer.cm_rep

define l_json_string string
define l_job_header record like job_header.*

define j_resp record
    count float,
    results dynamic array of record
        jh_address1 string,
        jh_address2 string,
        jh_address3 string,
        jh_address4 string,
        jh_code string,
        jh_contact string,
        jh_customer string,
        jh_date_created string,
        jh_date_signed string,
        jh_phone string,
        jh_signature string,
        jh_status string,
        jh_task_notes string
    end record
end record

define l_sql string
define i integer

    let l_sql = "select * ",
    "from job_header, customer ",
    "where jh_customer = cm_code ",
    "and cm_rep = ? ",
    #"and (jh_status = 'O' or jh_status = 'I' or (jh_status = 'X' and jh_date_signed >= date( julianday(date('now'))-7))) ",
    "and (jh_status = 'O' or jh_status = 'I' or (jh_status = 'X' and jh_date_signed >= (today-7))) ",
    "order by jh_code " 

    declare job_header_curs cursor from l_sql 
    let i = 0
    foreach job_header_curs using l_cm_rep into l_job_header.*
        let i = i + 1
        let j_resp.results[i].jh_address1 = l_job_header.jh_address1
        let j_resp.results[i].jh_address2 = l_job_header.jh_address2
        let j_resp.results[i].jh_address3 = l_job_header.jh_address3
        let j_resp.results[i].jh_address4 = l_job_header.jh_address4
        let j_resp.results[i].jh_code = l_job_header.jh_code
        let j_resp.results[i].jh_contact = l_job_header.jh_contact
        let j_resp.results[i].jh_customer = l_job_header.jh_customer
        let j_resp.results[i].jh_date_created = l_job_header.jh_date_created
        let j_resp.results[i].jh_date_signed = l_job_header.jh_date_signed
        let j_resp.results[i].jh_phone = l_job_header.jh_phone
        let j_resp.results[i].jh_signature = l_job_header.jh_signature
        let j_resp.results[i].jh_status = l_job_header.jh_status
        let j_resp.results[i].jh_task_notes = l_job_header.jh_task_notes
    end foreach
    let j_resp.count = i

    let l_json_string = util.JSON.stringify(j_resp)
    return true, l_json_string
end function



function putJob(s)
define s string

define j_job record
        Customer string,
        JobLines dynamic array of record
            jd_code string,
            jd_line float,
            jd_product string,
            jd_qty float,
            jd_status string
        end record,
        Notes dynamic array of record
            jn_code string,
            jn_idx float,
            jn_note string,
            jn_when string
        end record,
        Photos dynamic array of record
            jp_code string,
            jp_idx float,
            jp_lat float,
            jp_lon float,
            jp_photo string,
            jp_image byte,
            jp_text string,
            jp_when string
        end record,
        TimeSheets dynamic array of record
            jt_charge_code_id string,
            jt_code string,
            jt_finish string,
            jt_idx float,
            jt_start string,
            jt_text string
        end record,
        cm_rep string,
        jh_address1 string,
        jh_address2 string,
        jh_address3 string,
        jh_address4 string,
        jh_code string,
        jh_contact string,
        jh_customer string,
        jh_date_created string,
        jh_date_signed string,
        jh_name_signed string,
        jh_phone string,
        jh_signature string,
        jh_status string,
        jh_task_notes string
end record

define l_job_header record like job_header.*
define l_job_detail record like job_detail.*
define l_job_timesheet record like job_timesheet.*
define l_job_note record like job_note.*
define l_job_photo record like job_photo.*
define i integer

    #TODO Until util.JSON.parse locate's automatically
    #do this to locate one file to begin with
    locate j_job.Photos[1].jp_image in file "photo.tmp"

    call util.JSON.parse(s, j_job)
    begin work
    let l_job_header.jh_code = j_job.jh_code
    
    delete from job_detail where jd_code = l_job_header.jh_code
    delete from job_note where jn_code = l_job_header.jh_code
    delete from job_photo where jp_code = l_job_header.jh_code
    delete from job_timesheet where jt_code = l_job_header.jh_code

    -- Job
 
    -- update what has changed
    -- what about name captured from signature? TODO
    let l_job_header.jh_date_signed = sfmt("%1:00.000",j_job.jh_date_signed.trim())
    let l_job_header.jh_name_signed = j_job.jh_name_signed
    let l_job_header.jh_signature = j_job.jh_signature
    let l_job_header.jh_status = j_job.jh_status

    update job_header
    set jh_date_signed = l_job_header.jh_date_signed,
        jh_name_signed = l_job_header.jh_name_signed,
        jh_signature = l_job_header.jh_signature,
	jh_status = l_job_header.jh_status
    where jh_code = l_job_header.jh_code

    for i = 1 to j_job.JobLines.getLength()
        initialize l_job_detail.* to null
        let l_job_detail.jd_code = j_job.JobLines[i].jd_code
        let l_job_detail.jd_line = j_job.JobLines[i].jd_line
        let l_job_detail.jd_product = j_job.JobLines[i].jd_product
        let l_job_detail.jd_qty = j_job.JobLines[i].jd_qty
        let l_job_detail.jd_status = j_job.JobLines[i].jd_status

        insert into job_detail values l_job_detail.*
    end for

    for i = 1 to j_job.Notes.getLength()
        initialize l_job_note.* to null
        let l_job_note.jn_code = j_job.Notes[i].jn_code
        let l_job_note.jn_idx = j_job.Notes[i].jn_idx
        let l_job_note.jn_note = j_job.Notes[i].jn_note
        let l_job_note.jn_when = sfmt("%1:00.000",j_job.Notes[i].jn_when.trim())

        insert into job_note values l_job_note.*
    end for

    for i = 1 to j_job.Photos.getLength()
        locate l_job_photo.jp_photo_data in memory
        initialize l_job_photo.* to null
        let l_job_photo.jp_code = j_job.Photos[i].jp_code
        let l_job_photo.jp_idx = j_job.Photos[i].jp_idx
        let l_job_photo.jp_lat = j_job.Photos[i].jp_lat
        let l_job_photo.jp_lon = j_job.Photos[i].jp_lon
        #let l_job_photo.jp_photo_data = j_job.Photos[i].jp_image
	#TODO Note comment up around parse statements
	# this next line will change when locate automatically
	# done by parse
        call l_job_photo.jp_photo_data.readFile("photo.tmp")

        let l_job_photo.jp_when = sfmt("%1:00.000",j_job.Photos[i].jp_when.trim())
        let l_job_photo.jp_text = j_job.Photos[i].jp_text

        insert into job_photo values l_job_photo.*
	free l_job_photo.jp_photo_data
    end for

    for i = 1 to j_job.TimeSheets.getLength()
        initialize l_job_timesheet.* to null
        let l_job_timesheet.jt_code = j_job.TimeSheets[i].jt_code
        let l_job_timesheet.jt_idx = j_job.Timesheets[i].jt_idx
        let l_job_timesheet.jt_charge_code_id = j_job.Timesheets[i].jt_charge_code_id
        let l_job_timesheet.jt_finish = sfmt("%1:00.000",j_job.Timesheets[i].jt_finish.trim())
        let l_job_timesheet.jt_start = sfmt("%1:00.000",j_job.Timesheets[i].jt_start.trim())
        let l_job_timesheet.jt_text = j_job.Timesheets[i].jt_text

        insert into job_timesheet values l_job_timesheet.*
    end for
    commit work
    free j_job.Photos[1].jp_image
    return true, ""
end function
