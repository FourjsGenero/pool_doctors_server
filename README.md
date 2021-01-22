# pool_doctors_server
This project contains the back end applications to be used in conjunction with the Pool Doctors demo application for Genero Mobile.

NOTE: This is in a state of flux 30/9/2020 as I perform final testing, please ignore this program for a day or two

This project consists of a a number of applications.

The two main applications are

## pool_doctors_server

This is the application that contains the web services that are used by the mobile application to interface with the back end database.

## pool_doctors_enquiry

This is an applicaton that allows you to view the data in back end database.  The left hand side consists of a list of jobs in the database.  The right hand side consists of a number of collapsible group boxes that allow you to view the dataa in the child tables for each job.  To view the data for that job, expand the appropriate group box

TODO: 2 images from README

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

