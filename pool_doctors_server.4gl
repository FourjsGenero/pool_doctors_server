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



