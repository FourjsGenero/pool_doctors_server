import util

schema pool_doctors

function getProducts()

define j_resp record
    count float,
    results dynamic array of record
        pr_barcode string,
        pr_code string,
        pr_name string
    end record
end record

define l_product record like product.*
define i integer
define l_sql string

define l_json_string string

    let l_sql = "select * from product order by pr_code "
    declare customers_curs cursor from l_sql 
    let i = 0
    foreach customers_curs into l_product.*
        let i = i + 1
        let j_resp.results[i].pr_barcode = l_product.pr_barcode
        let j_resp.results[i].pr_code = l_product.pr_code
        let j_resp.results[i].pr_name = l_product.pr_desc
    end foreach
    let j_resp.count = i

    let l_json_string = util.JSON.stringify(j_resp)
    return true, l_json_string
end function