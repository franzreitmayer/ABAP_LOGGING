class ZCL_CALOG_FACTORY definition
  public
  final
  create public .

public section.
  "! default application log object
  constants CO_DEFAULT_LOG_OBJECT type BALOBJ_D value 'ZCALOGDEF' ##NO_TEXT.

  "! default application log object
  constants CO_EXCEPTION_SUB_OBJECT type BALSUBOBJ value 'ZCALOGDEF' ##NO_TEXT.

  "! Erzeugt einen Logging Header
  "!
  "! @parameter iv_log_object      | Business Application Log Object
  "! @parameter iv_log_subobj      | Business Application Log Subobject
  "! @parameter iv_ctx_struct_name | Name of ddic structure
  "! @parameter iv_ctx_value       | context data
  "! @parameter iv_progname        | program name
  "! @parameter rv_log_header_ref  | ZCALOG log header
  class-methods CREATE_HEADER
    importing
      !iv_log_object type BALOBJ_D default CO_DEFAULT_LOG_OBJECT
      !iv_log_subobj type BALSUBOBJ default CO_EXCEPTION_SUB_OBJECT
      !iv_ctx_struct_name type BALTABNAME optional
      !iv_ctx_value type BALCVAL optional
      !iv_progname type SYREPID default SY-CPROG
      !it_callstack type ABAP_CALLSTACK optional
    returning
      value(rv_log_header_ref) type ref to ZIF_CALOG_HEADER .

protected section.

private section.

ENDCLASS.



CLASS ZCL_CALOG_FACTORY IMPLEMENTATION.


  METHOD create_header.
    DATA:
      lv_instance_ref TYPE REF TO zcl_calog_header,
      lt_callstack    TYPE abap_callstack.

    lv_instance_ref = NEW #( ).

    IF it_callstack IS NOT SUPPLIED.
      CALL FUNCTION 'SYSTEM_CALLSTACK'
*        EXPORTING
*          max_level    = 0    " max. Anzahl anzuzeigender Aufrufer
        IMPORTING
          callstack = lt_callstack    " ABAP-Aufrufstack
*         et_callstack =     " System Callstack Tabelle
        .
    ELSE.
      lt_callstack = it_callstack.
    ENDIF.

    lv_instance_ref->initialize(
    pi_log_object           = iv_log_object
    pi_log_subobj           = iv_log_subobj
    pi_ctx_struct_name      = iv_ctx_struct_name
    pi_ctx_value            = iv_ctx_value
    pi_progname             = iv_progname
    pi_callstack            = lt_callstack ).

    rv_log_header_ref = lv_instance_ref.

  ENDMETHOD.
ENDCLASS.
