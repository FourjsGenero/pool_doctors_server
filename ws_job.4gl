#+
#+ Generated from ws_job
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
    = (Address:(Uri: "http://localhost:8093/ws/r/job"))

# Error codes
PUBLIC CONSTANT C_SUCCESS = 0
PUBLIC CONSTANT C_WS_ERROR = 1001

# generated uploadJobRequestBodyType
PUBLIC TYPE uploadJobRequestBodyType RECORD
    job_header RECORD
        jh_code STRING,
        jh_customer STRING,
        jh_date_created DATETIME YEAR TO SECOND,
        jh_status STRING,
        jh_address1 STRING,
        jh_address2 STRING,
        jh_address3 STRING,
        jh_address4 STRING,
        jh_contact STRING,
        jh_phone STRING,
        jh_task_notes STRING,
        jh_signature STRING,
        jh_date_signed DATETIME YEAR TO SECOND,
        jh_name_signed STRING
    END RECORD,
    job_detail DYNAMIC ARRAY OF RECORD
        jd_code STRING,
        jd_line INTEGER,
        jd_product STRING,
        jd_qty FLOAT,
        jd_status STRING
    END RECORD,
    job_note DYNAMIC ARRAY OF RECORD
        jn_code STRING,
        jn_idx INTEGER,
        jn_note STRING,
        jn_when DATETIME YEAR TO SECOND
    END RECORD,
    job_timesheet DYNAMIC ARRAY OF RECORD
        jt_code STRING,
        jt_idx INTEGER,
        jt_start DATETIME YEAR TO SECOND,
        jt_finish DATETIME YEAR TO SECOND,
        jt_charge_code_id STRING,
        jt_text STRING
    END RECORD,
    job_photo DYNAMIC ARRAY OF RECORD
        jp_code STRING,
        jp_idx INTEGER,
        jp_photo STRING,
        jp_when DATETIME YEAR TO SECOND,
        jp_lat FLOAT,
        jp_lon FLOAT,
        jp_text STRING
    END RECORD
END RECORD

# generated getJobsForRepResponseBodyType
PUBLIC TYPE getJobsForRepResponseBodyType RECORD
    rows DYNAMIC ARRAY OF RECORD
        jh_code STRING,
        jh_customer STRING,
        jh_date_created DATETIME YEAR TO SECOND,
        jh_status STRING,
        jh_address1 STRING,
        jh_address2 STRING,
        jh_address3 STRING,
        jh_address4 STRING,
        jh_contact STRING,
        jh_phone STRING,
        jh_task_notes STRING,
        jh_signature STRING,
        jh_date_signed DATETIME YEAR TO SECOND,
        jh_name_signed STRING
    END RECORD
END RECORD

# generated ws_errorErrorType
PUBLIC TYPE ws_errorErrorType RECORD
    message STRING
END RECORD

PUBLIC # error
    DEFINE ws_error ws_errorErrorType

################################################################################
# Operation /put
#
# VERB: PUT
# ID:          uploadJob
#
PUBLIC FUNCTION uploadJob(p_body uploadJobRequestBodyType) RETURNS(INTEGER)
    DEFINE fullpath base.StringBuffer
    DEFINE contentType STRING
    DEFINE req com.HTTPRequest
    DEFINE resp com.HTTPResponse
    DEFINE json_body STRING
    DEFINE txt STRING

    TRY

        # Prepare request path
        LET fullpath = base.StringBuffer.Create()
        CALL fullpath.append("/put")

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
        CALL req.setMethod("PUT")
        # Perform JSON request
        CALL req.setHeader("Content-Type", "application/json")
        LET json_body = util.JSON.stringify(p_body)
        CALL req.DoTextRequest(json_body)

        # Retrieve response
        LET resp = req.getResponse()
        # Process response
        LET contentType = resp.getHeader("Content-Type")
        CASE resp.getStatusCode()

            WHEN 204 #No Content
                RETURN C_SUCCESS

            OTHERWISE
                RETURN resp.getStatusCode()
        END CASE
    CATCH
        RETURN -1
    END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /put_photo/{l_jp_code}/{l_jp_idx}
#
# VERB: POST
# ID:          uploadJobPhoto
#
PUBLIC FUNCTION uploadJobPhoto(
    p_l_jp_code STRING, p_l_jp_idx INTEGER, p_body STRING)
    RETURNS(INTEGER)
    DEFINE fullpath base.StringBuffer
    DEFINE contentType STRING
    DEFINE req com.HTTPRequest
    DEFINE resp com.HTTPResponse
    DEFINE txt STRING

    TRY

        # Prepare request path
        LET fullpath = base.StringBuffer.Create()
        CALL fullpath.append("/put_photo/{l_jp_code}/{l_jp_idx}")
        CALL fullpath.replace("{l_jp_code}", p_l_jp_code, 1)
        CALL fullpath.replace("{l_jp_idx}", p_l_jp_idx, 1)

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
        CALL req.setMethod("POST")
        # Perform FILE request
        CALL req.DoFileRequest(p_body)

        # Retrieve response
        LET resp = req.getResponse()
        # Process response
        LET contentType = resp.getHeader("Content-Type")
        CASE resp.getStatusCode()

            WHEN 204 #No Content
                RETURN C_SUCCESS

            OTHERWISE
                RETURN resp.getStatusCode()
        END CASE
    CATCH
        RETURN -1
    END TRY
END FUNCTION
################################################################################

################################################################################
# Operation /getJobsForRep/{l_cm_rep}
#
# VERB: GET
# ID:          getJobsForRep
#
PUBLIC FUNCTION getJobsForRep(
    p_l_cm_rep STRING)
    RETURNS(INTEGER, getJobsForRepResponseBodyType)
    DEFINE fullpath base.StringBuffer
    DEFINE contentType STRING
    DEFINE req com.HTTPRequest
    DEFINE resp com.HTTPResponse
    DEFINE resp_body getJobsForRepResponseBodyType
    DEFINE json_body STRING
    DEFINE txt STRING

    TRY

        # Prepare request path
        LET fullpath = base.StringBuffer.Create()
        CALL fullpath.append("/getJobsForRep/{l_cm_rep}")
        CALL fullpath.replace("{l_cm_rep}", p_l_cm_rep, 1)

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
# Operation /createRandomJob/{l_cm_rep}
#
# VERB: GET
# ID:          createRandomJob
#
PUBLIC FUNCTION createRandomJob(p_l_cm_rep STRING) RETURNS(INTEGER, STRING)
    DEFINE fullpath base.StringBuffer
    DEFINE contentType STRING
    DEFINE req com.HTTPRequest
    DEFINE resp com.HTTPResponse
    DEFINE resp_body STRING
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
        CALL fullpath.append("/createRandomJob/{l_cm_rep}")
        CALL fullpath.replace("{l_cm_rep}", p_l_cm_rep, 1)

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
                    RETURN C_SUCCESS, resp_body
                END IF
                RETURN -1, resp_body

            WHEN 400 #error
                IF contentType MATCHES "*application/json*" THEN
                    # Parse JSON response
                    LET json_body = resp.getTextResponse()
                    CALL util.JSON.parse(json_body, ws_error)
                    RETURN C_WS_ERROR, resp_body
                END IF
                IF contentType MATCHES "*application/xml*" THEN
                    # Parse XML response
                    LET xml_body = resp.getXmlResponse()
                    LET xml_node = xml_body.getDocumentElement()
                    CALL xml.serializer.DomToVariable(xml_node, xml_ws_error)
                    LET ws_error.* = xml_ws_error.*
                    RETURN C_WS_ERROR, resp_body
                END IF
                RETURN -1, resp_body

            OTHERWISE
                RETURN resp.getStatusCode(), resp_body
        END CASE
    CATCH
        RETURN -1, resp_body
    END TRY
END FUNCTION
################################################################################
