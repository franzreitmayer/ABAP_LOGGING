FUNCTION Z_CALOG_TEST_BAL_MSG_ON_DB.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_BAL_HDR_HNDL) TYPE  BALLOGHNDL
*"     VALUE(IV_BAL_MSG_HNDL) TYPE  BALMSGHNDL
*"  EXPORTING
*"     VALUE(EV_EXISTS_ON_DB) TYPE  FLAG
*"----------------------------------------------------------------------
  data:
        lv_exists_on_db type boolean.

  ev_exists_on_db = abap_false.

  CALL FUNCTION 'BAL_DB_LOAD'
    EXPORTING
*     i_t_log_header =     " Alternative 1:Tabelle mit Protokollköpfen
      i_t_log_handle = VALUE bal_t_logh( ( iv_bal_hdr_hndl ) )   " Alternative 2: Tabelle mit Protokollhandles
*     i_t_lognumber  =     " Alternative 3: Tabelle mit Protokollnummer
*     i_client       = SY-MANDT    " Mandant für I_T_LOGNUMBER
*     i_do_not_load_messages        = SPACE    " Nur Protkollkopf laden
*     i_exception_if_already_loaded =     " Ausnahme auslösen, falls Protokoll schon geladen
*     i_lock_handling               = 2    " 0: Sperren ignorieren, 1: gesperrte nicht  lesen, 2: warten
*    IMPORTING
*     e_t_log_handle =     " Tabelle der Handles der gelesenen Protokolle
*     e_t_msg_handle =     " Tabelle der Handles der gelesenen Meldungen
*     e_t_locked     =     " Gesperrte und nicht gelesene Protokolle
    EXCEPTIONS
      log_not_found  = 1
*     no_logs_specified             = 1
*     log_already_loaded            = 3
*     others         = 4
    .

  IF sy-subrc = 1.
    return.
  ENDIF.

  CALL FUNCTION 'BAL_LOG_MSG_READ'
    EXPORTING
      i_s_msg_handle = iv_bal_msg_hndl    " Meldungshandle
*     i_langu        = SY-LANGU    " Sprache
    IMPORTING
*     e_s_msg        =     " Meldungsdaten
      e_exists_on_db = ev_exists_on_db    " Meldungs existiert bereits auf der Datenbank
*     e_txt_msgty    =     " Text zum Fehlertyp
*     e_txt_msgid    =     " Text zum Arbeitsgebiet
*     e_txt_detlevel =     " Text zu Detaillierungsgrad
*     e_txt_probclass          =     " Text zur Problemklasse
*     e_txt_msg      =     " Text der Meldung (aufbereitet)
*     e_warning_text_not_found =     " Mindestens ein Text wurde nicht ermittelt
*    EXCEPTIONS
*     log_not_found  = 1
*     msg_not_found  = 2
*     others         = 3
    .
ENDFUNCTION.
