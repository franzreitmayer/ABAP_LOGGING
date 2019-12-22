# ABAP_LOGGING
Simple Logging Framework for ABAP

## Description
This framework is designed to enable logging with abap on netweaver stack wich support less verbose usage and allows to do business process and logging in different transactions in order separate both concerns.

## Installation
The framework is stored on github with the use of ZABAPGIT (https://github.com/larshp/abapGit/blob/master/src/zabapgit.prog.abap) So you can use it to install the code on your system. As a post installation task you need to create a BAL log object (Transaction SLG0) with the name ZCALOGDEF and a subobject assigned to with the same name ZCALOGDEF. In order to check wether the installation was successful you can run the unit test of class ZCL_CALOG_HEADER.

## Usage
The report ZCALOG_SAMPLE report in package ZCALOG demonstrates how the framework can be used.
