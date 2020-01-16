# ABAP_LOGGING
Simple Logging Framework for ABAP Netweaver

## Description
This framework is designed to enable fluent, less verbose and isolated logging at ABAP Netweaver stack.

## Installation
The framework is managed on github with the use of ZABAPGIT (https://github.com/larshp/abapGit/blob/master/src/zabapgit.prog.abap) So you can use ZABAPGIT to install the code at your system. As a __post installation task__ you need to __create a BAL log object__ (Transaction SLG0) with the name __ZCALOGDEF__ and a __subobject__ assigned to with the same name __ZCALOGDEF__. In order to check wether the installation was successful you can run the unit test of class ZCL_CALOG_HEADER.

## Usage
The report ZCALOG_SAMPLE report in package ZCALOG demonstrates how the framework can be used.
