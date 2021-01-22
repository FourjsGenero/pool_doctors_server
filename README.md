# pool_doctors_server
This project contains the back end applications to be used in conjunction with the Pool Doctors demo application for Genero Mobile.

NOTE: This is in a state of flux 30/9/2020 as I perform final testing, please ignore this program for a day or two

This project consists of a a number of applications.

The applications are ...

## pool_doctors_server

This is the application that contains the web services that are used by the mobile application to interface with the back end database.

## pool_doctors_enquiry

This is an applicaton that allows you to view the data in back end database.  The left hand side consists of a list of jobs in the database.  

![Screen Shot 2021-01-22 at 15 08 31](https://user-images.githubusercontent.com/13615993/105436305-deb95c80-5cc3-11eb-97af-022202b7b82e.png)

The right hand side consists of a number of collapsible group boxes that allow you to view the dataa in the child tables for each job.  To view the data for that job, expand the appropriate group box

![Screen Shot 2021-01-22 at 15 08 51](https://user-images.githubusercontent.com/13615993/105436316-e24ce380-5cc3-11eb-8ded-b68dbdadae7a.png)

There are 3 actions

Refresh - Redo the selects from the database
Web Services - This will run the pool_doctors_service_test application that you can use to test the various Web Services
Delete - Delete the data for the currently selected job

## pool_doctors_service_test

Allows you to do rudimentary tests of the various web services from the back end.  It will display any results to stdout so is intended to be run from Geneor Studio so that output appears in the output panel.  Similarly some of the input parameters are hard-coded e.g. customer_get() is hard-coded to AKL028, product_get is hard-coded to "WIDESKIM"

## pool_doctors_service_test_create

Tests the generation of the 4gl client code that is used to call the web services

## pool_doctors_create_db

Creates the back end database and populates some data into the customer and product tables

## Usage

The intended usage is that you will 

1. Run pool_doctors_create_db to create the database on your backend
2. Start pool_doctors_server to start the back end web services exposing the data in this database
3. Start pool_doctors_enquiry to view the data in the back end database
4. From pool_doctos_enquiry you can click Web Services button to execute a web service and click Refresh button to update your view of the database.  A good test as part of this is to i) click Web Services->Create Random Job ii) click Refresh and observe that the number of jobs in the list on the left will grow by one




