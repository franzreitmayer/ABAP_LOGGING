"! Speichert den &uuml;bergebenen Call Stack im Tabellen Cluster bal_indx f&uuml;r fie
"! Verwendung im Business Application Log ab. Die Verwendung eines Remotef&auml;higen
"! Bausteins ist hier notwendig um das Abspeichern in die DB in einer eigenen LUW
"! zu gew&auml;hrleisten.
"! Bausteins ist hier notwendig um das Abspeichern in die DB in einer eigenen LUW
"! zu gew&auml;hrleisten.
"! zu gew&auml;hrleisten.

FUNCTION Z_CALOG_STORE_CALL_STACK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LOG_NUMBER) TYPE  BALOGNR
*"     REFERENCE(IT_CALL_STACK) TYPE  ABAP_CALLSTACK
*"     REFERENCE(IV_USE_2ND_CONNECTION) TYPE  FLAG DEFAULT ABAP_FALSE
*"----------------------------------------------------------------------
  DATA:
    line_count     TYPE i,
    log_cstack TYPE TABLE OF zcalog_cstack,
    current_date   TYPE d.

  CLEAR:
    line_count,
    log_cstack.
    current_date = sy-datum.

  LOOP AT it_call_stack REFERENCE INTO data(call_stack_line_ref).
    APPEND INITIAL LINE TO log_cstack ASSIGNING FIELD-SYMBOL(<log_cstack>).
    line_count = line_count + 1.

    MOVE-CORRESPONDING call_stack_line_ref->* TO <log_cstack>.
    <log_cstack>-stacktr_line_nr     = line_count.
    <log_cstack>-xdate             = current_date.
    <log_cstack>-lognumber         = iv_log_number.
  ENDLOOP.

  IF iv_use_2nd_connection EQ abap_true.
    INSERT zcalog_cstack CONNECTION (const_bal_2th_connection) FROM TABLE log_cstack.
  ELSE.
    INSERT zcalog_cstack FROM TABLE log_cstack.
  ENDIF.
ENDFUNCTION.
