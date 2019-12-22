class ZCL_CALOG_HEADER definition
  public
  final
  create private
  global friends ZCL_CALOG_FACTORY .

public section.
  interfaces ZIF_CALOG_HEADER .

  PROTECTED SECTION.

  private section.
  data MS_LOG_HEADER type BAL_S_LOG .
  data MV_HEADER_LOG_HNDL type BALLOGHNDL .
  data MT_CALL_STACK type ABAP_CALLSTACK .

  "! Initialisierung des Log Headers
  "! @parameter iv_log_object           | BAL log object
  "! @parameter iv_log_subobj           | BAL log subobject
  "! @parameter iv_ctx_struct_name      | name of context structure
  "! @parameter iv_ctx_value            | value of context structure
  "! @parameter iv_progname             | program name
  "! @parameter iv_callstack            | Callstack
  methods INITIALIZE
    importing
      !PI_LOG_OBJECT type BALOBJ_D
      !PI_LOG_SUBOBJ type BALSUBOBJ
      !PI_CTX_STRUCT_NAME type BALTABNAME
      !PI_CTX_VALUE type BALCVAL
      !PI_PROGNAME type SYREPID
      !PI_CALLSTACK type ABAP_CALLSTACK optional .
ENDCLASS.



CLASS ZCL_CALOG_HEADER IMPLEMENTATION.


  METHOD initialize.
    " ms_log_header-extnumber = ''. " 0   Anwendungs-Log: Externe Identifikation
    ms_log_header-object        = pi_log_object. " 0  Anwendungs-Log: Objektname (Applikationskürzel)
    ms_log_header-subobject     = pi_log_subobj . " 0   Anwendungs-Log: Unterobjekt
    ms_log_header-aldate        = sy-datum. " 0  Anwendungs-Log: Datum
    ms_log_header-altime        = sy-uzeit. " 0  Anwendungs-Log: Uhrzeit
    ms_log_header-aluser        = sy-uname. " 0  Anwendungs-Log: Benutzername
    ms_log_header-altcode       = sy-tcode. " 0 Anwendungs-Log: Transaktionscode
    ms_log_header-alprog        = pi_progname. " 0  Anwendungs-Log: Programmname
    ms_log_header-almode        = COND #( WHEN sy-batch = 'X' THEN 'B' WHEN sy-binpt = 'X' THEN 'I' ELSE 'D'). " 0  Anwendungs-Log: Betriebsmodus (Batch,Batch-Input,Dialog)
    ms_log_header-alchdate      = sy-datum. " 0    Anwendungs-Log: Datum der letzten Änderung
    ms_log_header-alchtime      = sy-uzeit. " 0    Anwendungs-Log: Uhrzeit der letzten Änderung
    ms_log_header-alchuser      = sy-uname. " 0    Anwendungs-Log: Benutzer, der das Protokoll geändert hat
    " ms_log_header-aldate_del = ''. " 0  Anwendungs-Log: Verfalldatum
    " ms_log_header-del_before = ''. " 0  Anwendungs-Log: Protokoll ist bis zum Verfalldatum zu halten
    " ms_log_header-alstate = ''. " 0 Anwendungs-Log: Bearbeitungsstatus

    IF pi_ctx_struct_name IS NOT INITIAL.
      ms_log_header-context = VALUE #( tabname = pi_ctx_struct_name value = pi_ctx_value ). " 0 Anwendungs-Log: Kontext
    ENDIF.

    " ms_log_header-params = ''. " 0  Anwendungs-Log: Parameter

    IF NOT pi_callstack IS SUPPLIED.
      zif_calog_header~update_stacktrace( ).
    ELSE.
      mt_call_stack = pi_callstack.
    ENDIF.

    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log      = ms_log_header   " Log header data
      IMPORTING
        e_log_handle = mv_header_log_hndl    " Log handle
*      EXCEPTIONS
*       log_header_inconsistent = 1
*       others       = 2
      .
  ENDMETHOD.


  METHOD ZIF_CALOG_HEADER~ADD_EXCEPTION.
    CHECK mv_header_log_hndl IS NOT INITIAL.
    CHECK iv_exception_ref IS NOT INITIAL.

    DATA:
      ls_bal_exception TYPE bal_s_exc,
      lv_timestamp     TYPE baltimstmp.

    GET TIME.
    GET TIME STAMP FIELD lv_timestamp.

    ls_bal_exception-msgty          = 'E'.              " Nachrichtentyp
    ls_bal_exception-exception      = iv_exception_ref. " Abstrakte Oberklasse aller globalen Exceptions
    ls_bal_exception-detlevel       = '1'.              " Anwendungs-Log: Detaillierungsgrad
    ls_bal_exception-probclass      = '1'.              " Anwendungs-Log: Problemklasse einer Meldung
    ls_bal_exception-alsort         = 'EXC'.            " Anwendungs-Log: Sortierkriterium/Gruppierung
    ls_bal_exception-time_stmp      = lv_timestamp.     " Anwendungs-Log: Zeitstempel einer Meldung
    ls_bal_exception-msg_count      = '1'.              " Anwendungs-Log: Anzahl der kumulierten Meldungen

    CALL FUNCTION 'BAL_LOG_EXCEPTION_ADD'
      EXPORTING
        i_log_handle = mv_header_log_hndl    " Log handle
        i_s_exc      = ls_bal_exception    " Exception data
*      IMPORTING
*       e_s_msg_handle      =     " Message handle
*       e_msg_was_logged    =     " Message collected
*       e_msg_was_displayed =     " Message output
*      EXCEPTIONS
*       log_not_found       = 1
*       msg_inconsistent    = 2
*       log_is_full  = 3
*       others       = 4
      .
    rv_log_header = me.
  ENDMETHOD.


  METHOD zif_calog_header~add_message.
    CHECK mv_header_log_hndl IS NOT INITIAL.

    DATA:
      ls_bal_msg       TYPE bal_s_msg,
      lv_timestampl    TYPE timestampl,
      lv_struct_legnth TYPE i.

    GET TIME.
    GET TIME STAMP FIELD lv_timestampl.
    DESCRIBE FIELD iv_ctx_value LENGTH lv_struct_legnth IN CHARACTER MODE.

    ls_bal_msg-msgty =            iv_msgty. " Nachrichtentyp
    ls_bal_msg-msgid =            iv_msgid. " 0  Nachrichtenklasse
    ls_bal_msg-msgno =            iv_msgno. " 0  Nachrichtennummer
    ls_bal_msg-msgv1 =            iv_msgv1. " 0  Nachrichtenvariable
    ls_bal_msg-msgv2 =            iv_msgv2. " 0  Nachrichtenvariable
    ls_bal_msg-msgv3 =            iv_msgv3. " 0  Nachrichtenvariable
    ls_bal_msg-msgv4 =            iv_msgv4. " 0  Nachrichtenvariable
*    ls_bal_msg-msgv1_src = ''. " 0  Anwendungs-Log: Herkunft einer Message-Variablen
*    ls_bal_msg-msgv2_src = ''. " 0  Anwendungs-Log: Herkunft einer Message-Variablen
*    ls_bal_msg-msgv3_src = ''. " 0  Anwendungs-Log: Herkunft einer Message-Variablen
*    ls_bal_msg-msgv4_src = ''. " 0  Anwendungs-Log: Herkunft einer Message-Variablen
    ls_bal_msg-detlevel =         '1'. " 0   Anwendungs-Log: Detaillierungsgrad
    ls_bal_msg-probclass =        '1'. " 0  Anwendungs-Log: Problemklasse einer Meldung
    ls_bal_msg-alsort =           'EXC'. " 0 Anwendungs-Log: Sortierkriterium/Gruppierung
    ls_bal_msg-time_stmp =        lv_timestampl. " 7  Anwendungs-Log: Zeitstempel einer Meldung
    ls_bal_msg-msg_count =        '1'. " 0  Anwendungs-Log: Anzahl der kumulierten Meldungen

    IF iv_ctx_struct_name IS NOT INITIAL AND lv_struct_legnth < 256.
      ls_bal_msg-context = VALUE #( tabname = iv_ctx_struct_name value = iv_ctx_value ). " 0    Anwendungs-Log: Kontext
    ENDIF.

    " ls_bal_msg-params = ''. " 0 Anwendungs-Log: Parameter

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle   = mv_header_log_hndl " Protokollhandle
        i_s_msg        = ls_bal_msg  " Meldungsdaten
      IMPORTING
        e_s_msg_handle = ev_bal_msg_hndl    " Meldungshandle
*       e_msg_was_logged    =     " Meldung wurde gesammelt
*       e_msg_was_displayed =     " Meldung wurde ausgegeben
*  EXCEPTIONS
*       log_not_found  = 1
*       msg_inconsistent    = 2
*       log_is_full    = 3
*       others         = 4
      .

    rv_log_header = me.
  ENDMETHOD.


  METHOD ZIF_CALOG_HEADER~ADD_TEXT.
    data:
          lv_text type c length 200,
          lv_struct_length type i.

    CHECK mv_header_log_hndl IS NOT INITIAL.

    lv_text = iv_log_text.

    DESCRIBE FIELD iv_ctx_value length lv_struct_length in CHARACTER MODE.

    IF iv_ctx_struct_name IS INITIAL OR lv_struct_length > 255.
      CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
        EXPORTING
          i_log_handle = mv_header_log_hndl    " Protokollhandle
          i_msgty      = iv_msgty  " Meldungs-Typ (A, E, W, I, S)
          i_probclass  = '1'    " Problemklasse (1, 2, 3, 4)
          i_text       = lv_text    " Meldungsdaten
*         i_s_context  =     " Kontextinformationen zur Freitextmeldung
*         i_s_params   =     " Parametersatz zur Freitextmeldung
      IMPORTING
         e_s_msg_handle      = ev_bal_msg_hndl    " Meldungshandle
*         e_msg_was_logged    =     " Meldung wurde gesammelt
*         e_msg_was_displayed =     " Meldung wurde ausgegeben
*      EXCEPTIONS
*         log_not_found       = 1
*         msg_inconsistent    = 2
*         log_is_full  = 3
*         others       = 4
        .
    else.
    CALL FUNCTION 'BAL_LOG_MSG_ADD_FREE_TEXT'
    EXPORTING
      i_log_handle = mv_header_log_hndl    " Protokollhandle
      i_msgty      = iv_msgty  " Meldungs-Typ (A, E, W, I, S)
      i_probclass  = '1'    " Problemklasse (1, 2, 3, 4)
      i_text       = lv_text    " Meldungsdaten
      i_s_context  = VALUE BAL_S_CONT( tabname = iv_ctx_struct_name value = iv_ctx_value )    " Kontextinformationen zur Freitextmeldung
*         i_s_params   =     " Parametersatz zur Freitextmeldung
      IMPORTING
         e_s_msg_handle      = ev_bal_msg_hndl    " Meldungshandle
*         e_msg_was_logged    =     " Meldung wurde gesammelt
*         e_msg_was_displayed =     " Meldung wurde ausgegeben
*      EXCEPTIONS
*         log_not_found       = 1
*         msg_inconsistent    = 2
*         log_is_full  = 3
*         others       = 4
      .
    ENDIF.

    rv_log_header = me.
  ENDMETHOD.


  METHOD zif_calog_header~get_header_log_handle.
    rv_bal_hdr_handle = mv_header_log_hndl.
  ENDMETHOD.


  METHOD zif_calog_header~persist.
    CONSTANTS:
      co_bal_disp_detail_callback  TYPE funcname VALUE 'Z_CALOG_STACKTRACE_CALLB',
      co_bal_disp_callback_type_fm TYPE baluet VALUE 'F'.

    DATA:
      lv_2nd_connection  TYPE abap_bool,
      lv_2nd_commit      TYPE abap_bool,
      lt_new_log_numbers TYPE bal_t_lgnm,
      ls_new_log_number  TYPE bal_s_lgnm,
      lv_new_log_number  TYPE balognr,
      ls_bal_log         TYPE bal_s_log,
      ls_bal_param       TYPE bal_s_parm,
      lv_log_number      TYPE balognr.

    IF iv_save_immediately = abap_true.
      lv_2nd_connection = abap_true.
      lv_2nd_commit     = abap_true.
    ENDIF.

    IF iv_with_callstack EQ abap_true.
      CALL FUNCTION 'BAL_LOG_READ'
        EXPORTING
          i_log_handle = mv_header_log_hndl    " Anwendungs-Log: Handle eines Protokolls
        IMPORTING
          es_log       = ls_bal_log.    " Anwendungs-Log: Daten des Protokollkopfes

      ls_bal_param-callback-userexitf = co_bal_disp_detail_callback.
      ls_bal_param-callback-userexitt = co_bal_disp_callback_type_fm.

      ls_bal_log-params = ls_bal_param.

      CALL FUNCTION 'BAL_LOG_HDR_CHANGE'
        EXPORTING
          i_log_handle = mv_header_log_hndl " Protokollhandle
          i_s_log      = ls_bal_log. " Daten des Protokollkopfes
    ENDIF.

    IF iv_save_immediately EQ abap_true.
      CALL FUNCTION 'BAL_DB_SAVE'
        EXPORTING
          i_t_log_handle       = VALUE bal_t_logh( ( mv_header_log_hndl ) )    " Tabelle der Protokoll-Handles
          i_2th_connection     = lv_2nd_connection    " FALSE: keine Sekundärverbindung
          i_2th_connect_commit = lv_2nd_commit    " FALSE: kein COMMIT im Baustein
        IMPORTING
          e_new_lognumbers     = lt_new_log_numbers.    " Tabelle mit den neuen Protokollnummern

      READ TABLE lt_new_log_numbers INTO ls_new_log_number
        WITH KEY log_handle = mv_header_log_hndl.
      lv_log_number = ls_new_log_number-lognumber.
      ev_lognumber = ls_new_log_number.
    ELSE.
      CALL FUNCTION 'BAL_DB_SAVE'
        EXPORTING
          i_t_log_handle   = VALUE bal_t_logh( ( mv_header_log_hndl ) )    " Tabelle der Protokoll-Handles
        IMPORTING
          e_new_lognumbers = lt_new_log_numbers.    " Tabelle mit den neuen Protokollnummern
      READ TABLE lt_new_log_numbers INTO ls_new_log_number
        WITH KEY log_handle = mv_header_log_hndl.
      ev_lognumber = ls_new_log_number.

      CALL FUNCTION 'BAL_LOG_HDR_READ'
        EXPORTING
          i_log_handle = mv_header_log_hndl   " Protokollhandle
        IMPORTING
          e_lognumber  = lv_log_number.    " Interne Nummer des Protokolls
    ENDIF.

    IF iv_with_callstack EQ abap_true AND lv_log_number IS NOT INITIAL.
      IF iv_save_immediately EQ abap_true.
        CALL FUNCTION 'Z_CALOG_STORE_CALL_STACK'
          EXPORTING
            iv_log_number         = lv_log_number    " Anwendungs-Log: Protokollnummer
            it_call_stack        = mt_call_stack        " ABAP-Aufrufstack
            iv_use_2nd_connection = abap_true.

        CALL FUNCTION 'BAL_DB_COMMIT_2ND_CONNECTION'.
      ELSE.
        " in der selben LUW
        CALL FUNCTION 'Z_CALOG_STORE_CALL_STACK'
          EXPORTING
            iv_log_number  = lv_log_number    " Anwendungs-Log: Protokollnummer
            it_call_stack = mt_call_stack.        " ABAP-Aufrufstack
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD zif_calog_header~update_stacktrace.
    CALL FUNCTION 'SYSTEM_CALLSTACK'
*        EXPORTING
*          max_level    = 0    " max. Anzahl anzuzeigender Aufrufer
      IMPORTING
        callstack = mt_call_stack    " ABAP-Aufrufstack
*       et_callstack =     " System Callstack Tabelle
      .
  ENDMETHOD.
ENDCLASS.
