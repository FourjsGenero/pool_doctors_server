IMPORT util
IMPORT com

SCHEMA pool_doctors

TYPE customerRecType RECORD LIKE customer.*
TYPE customerListType RECORD
    rows DYNAMIC ARRAY OF customerRecType
END RECORD
TYPE poolDataType RECORD
    temperature DECIMAL(5,1),
    hardness DECIMAL(5,1),
    free_chlorine DECIMAL(5,1),
    total_chroline DECIMAL(5,1),
    total_alkalinity DECIMAL(5,1),
    ph DECIMAL(5,1)
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

FUNCTION pool_data(l_cm_code LIKE customer.cm_code ATTRIBUTES(WSParam))
    ATTRIBUTES(WSGet, WSPath = "/pool_data/{l_cm_code}", WSThrows = "400:@ws_error")
    RETURNS poolDataType ATTRIBUTES(WSName = "pooldata", WSMedia = "application/json")

DEFINE l_pool_data poolDataType

    -- Simulate a call to some real time data sensors
    LET l_pool_data.temperature = 26.0 + (util.Math.rand(20) / 10)
    LET l_pool_data.hardness = 100.0 +  (util.Math.rand(2000) / 10)
    LET l_pool_data.free_chlorine = 0.5 +  (util.Math.rand(30) / 10)
    LET l_pool_data.total_chroline = 0.5 +  (util.Math.rand(30) / 10)
    LET l_pool_data.total_alkalinity = 60.0 +  (util.Math.rand(900) / 10)
    LET l_pool_data.ph = 7 +  (util.Math.rand(10) / 10)
    RETURN l_pool_data.*
END FUNCTION

