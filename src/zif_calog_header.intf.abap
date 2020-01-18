interface ZIF_CALOG_HEADER
public .

  constants CO_DEFAULT_LOG_OBJECT type BALOBJ_D value 'ZCALOGDEF' ##NO_TEXT.
  constants CO_EXCEPTION_SUB_OBJECT type BALSUBOBJ value 'ZCALOGDEF' ##NO_TEXT.

  methods ADD_TEXT
    importing
      !iv_log_text type CLIKE
      !iv_msgty type SYMSGTY default 'E'
      !iv_ctx_struct_name type TABNAME optional
      !iv_ctx_value type ANY optional
    exporting
      !ev_bal_msg_hndl type BALMSGHNDL
    returning
      value(rv_log_header) type ref to ZIF_CALOG_HEADER .

  methods ADD_MESSAGE
    importing
      !iv_msgty type SYMSGTY default SY-MSGTY
      !iv_msgid type SYMSGID default SY-MSGID
      !iv_msgno type SYMSGNO default SY-MSGNO
      !iv_msgv1 type SYMSGV default SY-MSGV1
      !iv_msgv2 type SYMSGV default SY-MSGV2
      !iv_msgv3 type SYMSGV default SY-MSGV3
      !iv_msgv4 type SYMSGV default SY-MSGV4
      !iv_ctx_struct_name type TABNAME optional
      !iv_ctx_value type ANY optional
    exporting
      !ev_bal_msg_hndl type BALMSGHNDL
    returning
      value(rv_log_header) type ref to ZIF_CALOG_HEADER .

  methods ADD_EXCEPTION
    importing
      !iv_exception_ref type ref to CX_ROOT
    exporting
      !ev_bal_msg_hndl type BALMSGHNDL
    returning
      value(rv_log_header) type ref to ZIF_CALOG_HEADER .

  methods PERSIST
    importing
      !iv_save_immediately type ABAP_BOOL default ABAP_TRUE
      !iv_with_callstack type ABAP_BOOL default ABAP_TRUE
    exporting
      !ev_lognumber type BAL_S_LGNM .

  methods UPDATE_STACKTRACE .

  methods GET_HEADER_LOG_HANDLE
    returning
      value(rv_bal_hdr_handle) type BALLOGHNDL .
endinterface.
