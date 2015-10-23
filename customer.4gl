import util

schema pool_doctors

function getCustomers()

define j_resp record
    count float,
    results dynamic array of record
        cm_addr1 string,
        cm_addr2 string,
        cm_addr3 string,
        cm_addr4 string,
        cm_code string,
        cm_email string,
        cm_lat float,
        cm_lon float,
        cm_name string,
        cm_phone string,
        cm_postcode string,
        cm_rep string
    end record
end record

define l_cust record like customer.*
define i integer
define l_sql string

define l_json_string string

    let l_sql = "select * from customer order by cm_code "
    declare customers_curs cursor from l_sql 
    let i = 0
    foreach customers_curs into l_cust.*
        let i = i + 1
        let j_resp.results[i].cm_addr1 = l_cust.cm_addr1
        let j_resp.results[i].cm_addr2 = l_cust.cm_addr2
        let j_resp.results[i].cm_addr3 = l_cust.cm_addr3
        let j_resp.results[i].cm_addr4 = l_cust.cm_addr4
        let j_resp.results[i].cm_code = l_cust.cm_code
        let j_resp.results[i].cm_email = l_cust.cm_email
        let j_resp.results[i].cm_lat = l_cust.cm_lat
        let j_resp.results[i].cm_lon = l_cust.cm_lon
        let j_resp.results[i].cm_name = l_cust.cm_name
        let j_resp.results[i].cm_phone = l_cust.cm_phone
        let j_resp.results[i].cm_postcode = l_cust.cm_postcode
        let j_resp.results[i].cm_rep = l_cust.cm_rep
    end foreach
    let j_resp.count = i

    let l_json_string = util.JSON.stringify(j_resp)
    return true, l_json_string
end function