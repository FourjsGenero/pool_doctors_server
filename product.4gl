IMPORT util
IMPORT com

SCHEMA pool_doctors

TYPE productRecType RECORD LIKE product.*
TYPE productListType RECORD
    rows DYNAMIC ARRAY OF productRecType
END RECORD

PUBLIC DEFINE ws_error RECORD ATTRIBUTES(WSError = "error")
    message STRING
END RECORD

FUNCTION get(l_pr_code LIKE product.pr_code ATTRIBUTES(WSParam))
    ATTRIBUTES(WSGet, WSPath = "/get/{l_pr_code}", WSThrows = "400:@ws_error")
    RETURNS productRecType ATTRIBUTES(WSName = "product", WSMedia = "application/json")

    DEFINE l_prod productRecType

    SELECT * INTO l_prod.* FROM product WHERE pr_code = l_pr_code
    IF status = NOTFOUND THEN
        LET ws_error.message = "Invalid Product Code"
        CALL com.WebServiceEngine.SetRestError(400, ws_error)
    END IF
    RETURN l_prod.*
END FUNCTION

FUNCTION list() ATTRIBUTES(wsget, WSPath = "/list")
    RETURNS productListType ATTRIBUTES(WSName = "products", WSMedia = "application/json")

    DEFINE l_prod productRecType
    DEFINE l_arr productListType
    DEFINE l_sql STRING

    LET l_sql = "select * from product order by pr_code "
    DECLARE product_curs CURSOR FROM l_sql
    FOREACH product_curs INTO l_prod.*
        LET l_arr.rows[l_arr.rows.getLength() + 1].* = l_prod.*
    END FOREACH
    RETURN l_arr.*
END FUNCTION
