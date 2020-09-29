IMPORT util
IMPORT com

SCHEMA pool_doctors

TYPE customerRecType RECORD LIKE customer.*
TYPE customerListType RECORD
    rows DYNAMIC ARRAY OF customerRecType
END RECORD

PUBLIC DEFINE ws_error RECORD ATTRIBUTES(WSError = "error")
    message STRING
END RECORD

FUNCTION get(l_cm_code LIKE customer.cm_code ATTRIBUTES(WSParam))
    ATTRIBUTES(WSGet, WSPath = "/get/{l_cm_code}", WSThrows = "400:@ws_error")
    RETURNS customerRecType ATTRIBUTES(WSName = "customer", WSMedia = "application/json")

    DEFINE l_cust customerRecType

    SELECT * INTO l_cust.* FROM customer WHERE cm_code = l_cm_code
    IF status = NOTFOUND THEN
        LET ws_error.message = "Invalid Customer Code"
        CALL com.WebServiceEngine.SetRestError(400, ws_error)
    END IF
    RETURN l_cust.*
END FUNCTION

FUNCTION list() ATTRIBUTES(wsget, WSPath = "/list")
    RETURNS customerListType ATTRIBUTES(WSName = "customers", WSMedia = "application/json")

    DEFINE l_cust customerRecType
    DEFINE l_arr customerListType
    DEFINE l_sql STRING

    LET l_sql = "select * from customer order by cm_code "
    DECLARE customers_curs CURSOR FROM l_sql
    FOREACH customers_curs INTO l_cust.*
        LET l_arr.rows[l_arr.rows.getLength() + 1].* = l_cust.*
    END FOREACH
    RETURN l_arr.*
END FUNCTION
