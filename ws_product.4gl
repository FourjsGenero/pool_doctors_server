#+
#+ Generated from ws_product
#+
IMPORT com
IMPORT xml
IMPORT util
IMPORT os

#+
#+ Global Endpoint user-defined type definition
#+
TYPE tGlobalEndpointType RECORD # Rest Endpoint
    Address RECORD # Address
        Uri STRING # URI
    END RECORD,
    Binding RECORD # Binding
        Version STRING, # HTTP Version (1.0 or 1.1)
        ConnectionTimeout INTEGER, # Connection timeout
        ReadWriteTimeout INTEGER, # Read write timeout
        CompressRequest STRING # Compression (gzip or deflate)
    END RECORD
END RECORD

PUBLIC DEFINE Endpoint
    tGlobalEndpointType
    = (Address:(Uri: "http://localhost:8093/ws/r/product"))

# Error codes
PUBLIC CONSTANT C_SUCCESS = 0
PUBLIC CONSTANT C_WS_ERROR = 1001

# generated listResponseBodyType
PUBLIC TYPE listResponseBodyType RECORD
    rows DYNAMIC ARRAY OF RECORD
        pr_code STRING,
        pr_desc STRING,
        pr_barcode STRING
    END RECORD
END RECORD

# generated getResponseBodyType
PUBLIC TYPE getResponseBodyType RECORD
    pr_code STRING,
    pr_desc STRING,
    pr_barcode STRING
END RECORD

# generated ws_errorErrorType
PUBLIC TYPE ws_errorErrorType RECORD
    message STRING
END RECORD

PUBLIC # error
    DEFINE ws_error ws_errorErrorType

################################################################################
# Operation /list
#
# VERB: GET
# ID:          list
#
PUBLIC FUNCTION list() RETURNS(INTEGER, listResponseBodyType)
    DEFINE fullpath base.StringBuffer
    DEFINE contentType STRING
    DEFINE req com.HTTPRequest
    DEFINE resp com.HTTPResponse
    DEFINE resp_body listResponseBodyType
    DEFINE json_body STRING
    DEFINE txt STRING

    TRY

        # Prepare request path
        LET fullpath = base.StringBuffer.Create()
        CALL fullpath.append("/list")

        # Create request and configure it
        LET req =
            com.HTTPRequest.Create(
                SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
        IF Endpoint.Binding.Version IS NOT NULL THEN
            CALL req.setVersion(Endpoint.Binding.Version)
        END IF
        IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
            CALL req.setConnectionTimeout(Endpoint.Binding.ConnectionTimeout)
        END IF
        IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
            CALL req.setTimeout(Endpoint.Binding.ReadWriteTimeout)
        END IF
        IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
            CALL req.setHeader(
                "Content-Encoding", Endpoint.Binding.CompressRequest)
        END IF

        # Perform request
        CALL req.setMethod("GET")
        CALL req.setHeader("Accept", "application/json")
        CALL req.DoRequest()

        # Retrieve response
        LET resp = req.getResponse()
        # Process response
        INITIALIZE resp_body TO NULL
        LET contentType = resp.getHeader("Content-Type")
        CASE resp.getStatusCode()

            WHEN 200 #Success
                IF contentType MATCHES "*application/json*" THEN
                    # Parse JSON response
                    LET json_body = resp.getTextResponse()
                    CALL util.JSON.parse(json_body, resp_body)
                    RETURN C_SUCCESS, resp_body.*
                END IF
                RETURN -1, resp_body.*

            OTHERWISE
                RETURN resp.getStatusCode(), resp_body.*
        END CASE
    CATCH
        RETURN -1, resp_body.*
    END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /get/{l_pr_code}
#
# VERB: GET
# ID:          get
#
PUBLIC FUNCTION get(p_l_pr_code STRING) RETURNS(INTEGER, getResponseBodyType)
    DEFINE fullpath base.StringBuffer
    DEFINE contentType STRING
    DEFINE req com.HTTPRequest
    DEFINE resp com.HTTPResponse
    DEFINE resp_body getResponseBodyType
    DEFINE xml_ws_error RECORD ATTRIBUTE(XMLName = 'ws_error')
        message STRING
    END RECORD
    DEFINE xml_body xml.DomDocument
    DEFINE xml_node xml.DomNode
    DEFINE json_body STRING
    DEFINE txt STRING

    TRY

        # Prepare request path
        LET fullpath = base.StringBuffer.Create()
        CALL fullpath.append("/get/{l_pr_code}")
        CALL fullpath.replace("{l_pr_code}", p_l_pr_code, 1)

        # Create request and configure it
        LET req =
            com.HTTPRequest.Create(
                SFMT("%1%2", Endpoint.Address.Uri, fullpath.toString()))
        IF Endpoint.Binding.Version IS NOT NULL THEN
            CALL req.setVersion(Endpoint.Binding.Version)
        END IF
        IF Endpoint.Binding.ConnectionTimeout <> 0 THEN
            CALL req.setConnectionTimeout(Endpoint.Binding.ConnectionTimeout)
        END IF
        IF Endpoint.Binding.ReadWriteTimeout <> 0 THEN
            CALL req.setTimeout(Endpoint.Binding.ReadWriteTimeout)
        END IF
        IF Endpoint.Binding.CompressRequest IS NOT NULL THEN
            CALL req.setHeader(
                "Content-Encoding", Endpoint.Binding.CompressRequest)
        END IF

        # Perform request
        CALL req.setMethod("GET")
        CALL req.setHeader("Accept", "application/json, application/xml")
        CALL req.DoRequest()

        # Retrieve response
        LET resp = req.getResponse()
        # Process response
        INITIALIZE resp_body TO NULL
        LET contentType = resp.getHeader("Content-Type")
        CASE resp.getStatusCode()

            WHEN 200 #Success
                IF contentType MATCHES "*application/json*" THEN
                    # Parse JSON response
                    LET json_body = resp.getTextResponse()
                    CALL util.JSON.parse(json_body, resp_body)
                    RETURN C_SUCCESS, resp_body.*
                END IF
                RETURN -1, resp_body.*

            WHEN 400 #error
                IF contentType MATCHES "*application/json*" THEN
                    # Parse JSON response
                    LET json_body = resp.getTextResponse()
                    CALL util.JSON.parse(json_body, ws_error)
                    RETURN C_WS_ERROR, resp_body.*
                END IF
                IF contentType MATCHES "*application/xml*" THEN
                    # Parse XML response
                    LET xml_body = resp.getXmlResponse()
                    LET xml_node = xml_body.getDocumentElement()
                    CALL xml.serializer.DomToVariable(xml_node, xml_ws_error)
                    LET ws_error.* = xml_ws_error.*
                    RETURN C_WS_ERROR, resp_body.*
                END IF
                RETURN -1, resp_body.*

            OTHERWISE
                RETURN resp.getStatusCode(), resp_body.*
        END CASE
    CATCH
        RETURN -1, resp_body.*
    END TRY
END FUNCTION
################################################################################
