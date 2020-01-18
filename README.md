# ABAP_LOGGING
Simple Logging Framework for ABAP Netweaver

## Description
This framework is designed to enable fluent, less verbose and isolated logging at ABAP Netweaver stack. ABAP Netweaver Stack offeres the Busines Application Log to support logging. However the api to use is is still not object oriented and quite verbose. This frameworks offers an object oriented wrapper to support he most common logging operations.

## Installation
The framework is managed on github with the use of ZABAPGIT (https://github.com/larshp/abapGit/blob/master/src/zabapgit.prog.abap) So you can use ZABAPGIT to install the code at your system. As a __post installation task__ you need to __create a BAL log object__ (Transaction SLG0) with the name __ZCALOGDEF__ and a __subobject__ assigned to with the same name __ZCALOGDEF__. In order to check wether the installation was successful you can run the unit test of class ZCL_CALOG_HEADER.

## Usage
The report ZCALOG_SAMPLE report in package ZCALOG demonstrates how the framework can be used.

Use the central class ZCL_CALOG_FACTORY to get a header object to manager further logging:

```abap
" create a log header for default log object and sub object...
data(log_header) = ZCL_CALOG_FACTORY=>CREATE_HEADER( ).
```

Use the header object retrieved to write messages, texts and exceptions

```abap
" add a simle text message
log_header->ADD_TEXT( 'This is a test' ).

" add a message with parameters...
log_header->ADD_MESSAGE(
  exporting
    IV_MSGTY           = conv symsgty( 'E' )
    IV_MSGID           = CONV symsgid( 'ZCALOG_TST')
    IV_MSGNO           = CONV symsgno( 0 )
    IV_MSGV1           = 'Param 1'
    IV_MSGV2           = 'Param 2'
    IV_MSGV3           = 'Param 3'
    IV_MSGV4           = 'Param 4'
).

try.
  data(num) = 1 / 0.
catch cx_root into data(exception_ref).
  log_header->ADD_EXCEPTION( exception_ref ).
endtry.

```

Every method to append the log returns the logheader itself, thus you can chain the appends to keep coding short.

```abap
" use chained method calls to keep code short...
  ZCL_CALOG_FACTORY=>CREATE_HEADER(
  )->add_text( 'This is a test'
  )->ADD_MESSAGE( IV_MSGTY           = conv symsgty( 'E' )
    IV_MSGID           = CONV symsgid( 'ZCALOG_TST')
    IV_MSGNO           = CONV symsgno( 0 )
    IV_MSGV1           = 'Param 1'
    IV_MSGV2           = 'Param 2'
    IV_MSGV3           = 'Param 3'
    IV_MSGV4           = 'Param 4'
  )->ADD_EXCEPTION( EXCEPTION_REF )->PERSIST( ).
```

Call method persist to save the logs to database. the framework support two ways of storing the log (controlled by parameter iv_save_immediately). Please refer to the wikipages for further details:
* Storing in a parallel db connection (no dependency to surrounding TX)
* Storing in same db connection (depends on surrounding TX)

The method persist also has the paramter iv_with_callstack which allows to store the callstack at the BAL logheader.

