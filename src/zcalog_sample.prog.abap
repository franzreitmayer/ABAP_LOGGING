*&---------------------------------------------------------------------*
*& Report ZCALOG_SAMPLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCALOG_SAMPLE.



START-OF-SELECTION.



" create a log header for default log object and sub object...
data(log_header) = ZCL_CALOG_FACTORY=>CREATE_HEADER( ).

" add a simle text message
log_header->ADD_TEXT( 'This is a test' ).

" persist the logging, with default settings: persist immediately and save
" with stacktrace
log_header->PERSIST( ).


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
log_header->PERSIST( ).

try.
  data(num) = 1 / 0.
catch cx_root into data(exception_ref).
  log_header->ADD_EXCEPTION( exception_ref ).
endtry.
  log_header->persist( ).



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
