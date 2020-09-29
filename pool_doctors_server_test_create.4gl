MAIN
    RUN "fglrestful -o ws_job.4gl http://localhost:8093/ws/r/job?openapi.json"
    RUN "fglrestful -o ws_customer.4gl http://localhost:8093/ws/r/ws_customer?openapi.json"
    RUN "fglrestful -o ws_product.4gl http://localhost:8093/ws/r/ws_product?openapi.json"
END MAIN