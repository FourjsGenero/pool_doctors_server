IMPORT util
IMPORT com
IMPORT FGL customer
IMPORT FGL product

MAIN
    DEFINE result INTEGER

    DEFER INTERRUPT

    # seed the random number generator or getRandomJob always end up with same customer.
    CALL util.math.srand()

    CONNECT TO "pool_doctors"
    CALL com.WebServiceEngine.RegisterRestService("customer", "customer")
    CALL com.WebServiceEngine.RegisterRestService("product", "product")
    CALL com.WebServiceEngine.RegisterRestService("job", "job")
    CALL com.WebServiceEngine.Start()

    WHILE TRUE
        LET result = com.WebServiceEngine.ProcessServices(-1)
        CASE result
            WHEN 0
                DISPLAY "Request processed."
            WHEN -1
                DISPLAY "Timeout reached."
            WHEN -2
                DISPLAY "Disconnected from application server."
                EXIT PROGRAM # The Application server has closed the connection
            WHEN -3
                DISPLAY "Client Connection lost."
            WHEN -4
                DISPLAY "Server interrupted with Ctrl-C."
            WHEN -9
                DISPLAY "Unsupported operation."
            WHEN -10
                DISPLAY "Internal server error."
            WHEN -23
                DISPLAY "Deserialization error."
            WHEN -35
                DISPLAY "No such REST operation found."
            WHEN -36
                DISPLAY "Missing REST parameter."
            OTHERWISE
                DISPLAY "Unexpected server error " || result || "."
                EXIT WHILE
        END CASE
        IF int_flag <> 0 THEN
            LET int_flag = 0
            EXIT WHILE
        END IF
    END WHILE
END MAIN

{
function process_http_request(request)
define request com.HttpServiceRequest
define url string

define ok smallint
define str string
define desc string

define method string
define dummy string

    let url = request.getUrl()

    connect to "pool_doctors"
    # turn the url into the address, method, and a list of arguments
    #call split_url(url) returning address, method, arglist
    call WSHelper.SplitURL(url) returning dummy, dummy, dummy, method, dummy

    case method
        when "getCustomers"
            let ok = true
            call getCustomers() returning ok, str

        when "getProducts"
            call getProducts() returning ok, str

        when "createRandomJob"
            call createRandomJob(request.readTextRequest()) returning ok, str

        when "getJobsForRep"
            call getJobsForRep(request.readTextRequest()) returning ok, str

        when "putJob"
            call putJob(request.readTextRequest()) returning ok, str

        when "favicon.ico"
            # ignore this method, called if enter url in a browser
            let ok = true
            let str = null
            let desc = ""

        otherwise
            # return some error if any other method is called
            let ok = false
            let str = null
            let desc =  "unspecified method"
    end case

    disconnect "pool_doctors"
    return ok, str, desc
end function








{
FUNCTION split_url(url)
DEFINE url, address, method, arglist STRING
DEFINE argpos, i INTEGER

   # The argument list is what appears after the ?
   LET argpos = url.getIndexOf("?",1)
   IF argpos > 0 THEN
      LET arglist = url.SubString(argpos+1, url.getLength())
   ELSE
      LET argpos = url.getLength() + 1
      LET arglist = ""
   END IF

   # Before the argument list, the address and method are seperated
   # by the last /
   LET i = argpos
   WHILE i > 0
      LET i = i - 1
	  IF url.getCharAt(i) = "/" THEN
	     LET address = url.SubString(1, i-1)
		 LET method = url.SubString(i+1, argpos-1)
		 EXIT WHILE
      END IF
   END WHILE
   IF i <= 0 THEN
      LET address = url.SubString(1, argpos-1)
	  LET method = ""
   END IF
   RETURN address, method, arglist
END FUNCTION
}
{

IMPORT com
IMPORT FGL crud

MAIN
DEFINE result INTEGER

    CALL crud.init()

    CALL com.WebServiceEngine.RegisterRestService("crud","CRUD")
    CALL com.WebServiceEngine.Start()

    WHILE TRUE
        LET result = com.WebServiceEngine.ProcessServices(-1)
    END WHILE

END MAIN
}
