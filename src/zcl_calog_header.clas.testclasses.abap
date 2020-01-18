*"* use this source file for your ABAP unit test classes
CLASS zcl_tst_log_header DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.

*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>zcl_Tst_Log_Header
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>ZCL_CALOG_HEADER
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE>X
*?</GENERATE_FIXTURE>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION>X
*?</GENERATE_INVOCATION>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>

  PRIVATE SECTION.
    CONSTANTS:
      co_ctx_name_too_long TYPE tabname VALUE 'ZCALOG_TEST_CTX_STRUCT_L_S',
      co_ctx_name_ok       TYPE tabname VALUE 'ZCALOG_TEST_CTX_STRUCT_S'.

    DATA:
      f_cut           TYPE REF TO zif_calog_header,  "class under test
      ms_ctx_too_long TYPE zcalog_test_ctx_struct_l_s,
      ms_ctx_ok       TYPE zcalog_test_ctx_struct_s.

    METHODS: setup.
    METHODS: teardown.
    METHODS: add_exception FOR TESTING.
    METHODS: add_message FOR TESTING.
    METHODS: add_text FOR TESTING.
    METHODS: create FOR TESTING.
    METHODS: persist FOR TESTING.
    METHODS: persist_is_isolated FOR TESTING.
ENDCLASS.       "zcl_Tst_Log_Header

CLASS zcl_tst_log_header IMPLEMENTATION.

  METHOD setup.
    ms_ctx_too_long-component1  = 'zu'.
    ms_ctx_too_long-component2  = 'lange'.
    ms_ctx_ok-component1        = 'das'.
    ms_ctx_ok-component2        = 'ist'.
    ms_ctx_ok-component3        = 'nicht'.
    ms_ctx_ok-component4        = 'zu'.
    ms_ctx_ok-component5        = 'lange'.

    f_cut = zcl_calog_factory=>create_header( ).
  ENDMETHOD.

  METHOD teardown.

  ENDMETHOD.

  METHOD add_exception.
    DATA pi_exception_ref TYPE REF TO cx_root.
    DATA pe_bal_msg_hndl TYPE balmsghndl.

    TRY.
        DATA(i) = 1 / 0.
      CATCH cx_root INTO pi_exception_ref.

    ENDTRY.

    f_cut->add_exception( EXPORTING iv_exception_ref = pi_exception_ref IMPORTING ev_bal_msg_hndl = pe_bal_msg_hndl )->persist( ).
  ENDMETHOD.

  METHOD add_message.
    DATA pi_msgty TYPE symsgty VALUE'E'.
    DATA pi_msgid TYPE symsgid VALUE 'ZCALOG_TST'.
    DATA pi_msgno TYPE symsgno VALUE '000'.
    DATA pi_msgv1 TYPE symsgv VALUE 'ONE'.
    DATA pi_msgv2 TYPE symsgv VALUE 'TWO'.
    DATA pi_msgv3 TYPE symsgv VALUE 'THREE'.
    DATA pi_msgv4 TYPE symsgv VALUE 'FOUR'.
    DATA pi_ctx_struct_name TYPE tabname.

    " data pi_Ctx_Value type any.
    DATA: pe_bal_msg_hndl TYPE balmsghndl,
          lv_exists_on_db TYPE abap_bool,
          ls_bal_msg      TYPE bal_s_msg,
          ls_ctx_ok_act   TYPE zcalog_test_ctx_struct_s.

    f_cut->add_message(
        EXPORTING
        iv_msgty = pi_msgty
        iv_msgid = pi_msgid
        iv_msgno = pi_msgno
       iv_msgv1 = pi_msgv1
       iv_msgv2 = pi_msgv2
       iv_msgv3 = pi_msgv3
       iv_msgv4 = pi_msgv4
       iv_ctx_struct_name = co_ctx_name_ok
       iv_ctx_value = ms_ctx_ok
      IMPORTING
        ev_bal_msg_hndl = pe_bal_msg_hndl
    ).

    " Weil die Methode persist() noch nicht aufgerufen wurde darf der Eintrag zu diesem Zeitpunkt noch nicht auf der
    " Datenbank stehen
    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = pe_bal_msg_hndl    " Meldungshandle
*       i_langu        = SY-LANGU    " Sprache
      IMPORTING
        e_s_msg        = ls_bal_msg    " Meldungsdaten
        e_exists_on_db = lv_exists_on_db    " Meldungs existiert bereits auf der Datenbank
*       e_txt_msgty    =     " Text zum Fehlertyp
*       e_txt_msgid    =     " Text zum Arbeitsgebiet
*       e_txt_detlevel =     " Text zu Detaillierungsgrad
*       e_txt_probclass          =     " Text zur Problemklasse
*       e_txt_msg      =     " Text der Meldung (aufbereitet)
*       e_warning_text_not_found =     " Mindestens ein Text wurde nicht ermittelt
*    EXCEPTIONS
*       log_not_found  = 1
*       msg_not_found  = 2
*       others         = 3
      .

    cl_aunit_assert=>assert_equals( EXPORTING act = lv_exists_on_db  exp = abap_false
      msg = 'Log entry must not exist on database' ).

    " Log Eintrag speichern (pi_commit_immediately = 'X' <-- Default)
    f_cut->persist( ).

*    " Log Eintrag aus der Datenbank holen
*    CALL FUNCTION 'BAL_DB_LOAD'
*      EXPORTING
**       i_t_log_header =     " Alternative 1:Tabelle mit Protokollköpfen
*        i_t_log_handle = VALUE bal_t_logh( ( pe_bal_msg_hndl-log_handle ) )   " Alternative 2: Tabelle mit Protokollhandles
**       i_t_lognumber  =     " Alternative 3: Tabelle mit Protokollnummern
**       i_client       = SY-MANDT    " Mandant für I_T_LOGNUMBER
**       i_do_not_load_messages        = SPACE    " Nur Protkollkopf laden
**       i_exception_if_already_loaded =     " Ausnahme auslösen, falls Protokoll schon geladen
**       i_lock_handling               = 2    " 0: Sperren ignorieren, 1: gesperrte nicht  lesen, 2: warten
**    IMPORTING
**       e_t_log_handle =     " Tabelle der Handles der gelesenen Protokolle
**       e_t_msg_handle =     " Tabelle der Handles der gelesenen Meldungen
**       e_t_locked     =     " Gesperrte und nicht gelesene Protokolle
**    EXCEPTIONS
**       no_logs_specified             = 1
**       log_not_found  = 2
**       log_already_loaded            = 3
**       others         = 4
*      .
*
*    CALL FUNCTION 'BAL_LOG_MSG_READ'
*      EXPORTING
*        i_s_msg_handle = pe_bal_msg_hndl    " Meldungshandle
**       i_langu        = SY-LANGU    " Sprache
*      IMPORTING
*        e_s_msg        = ls_bal_msg    " Meldungsdaten
*        e_exists_on_db = lv_exists_on_db    " Meldungs existiert bereits auf der Datenbank
**       e_txt_msgty    =     " Text zum Fehlertyp
**       e_txt_msgid    =     " Text zum Arbeitsgebiet
**       e_txt_detlevel =     " Text zu Detaillierungsgrad
**       e_txt_probclass          =     " Text zur Problemklasse
**       e_txt_msg      =     " Text der Meldung (aufbereitet)
**       e_warning_text_not_found =     " Mindestens ein Text wurde nicht ermittelt
**    EXCEPTIONS
**       log_not_found  = 1
**       msg_not_found  = 2
**       others         = 3
*      .

    CALL FUNCTION 'Z_CALOG_TEST_BAL_MSG_ON_DB'
      EXPORTING
        iv_bal_hdr_hndl = f_cut->get_header_log_handle( )    " Anwendungs-Log: Handle eines Protokolls
        iv_bal_msg_hndl = pe_bal_msg_hndl    " Anwendungs-Log: Handle für eine Meldung
      IMPORTING
        ev_exists_on_db = lv_exists_on_db.    " allgemeines flag

    " Weil die Methode persist( ) aufgerufen wurde muss der Eintrag auf der Datenbank existieren
    cl_aunit_assert=>assert_equals( act = lv_exists_on_db exp = abap_true msg = 'Log Entry must exist on DB').

    " Gelesene Daten prüfen
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgid exp = pi_msgid ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgno exp = pi_msgno ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgty exp = pi_msgty ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv1 exp = pi_msgv1 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv2 exp = pi_msgv2 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv3 exp = pi_msgv3 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv4 exp = pi_msgv4 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgid exp = pi_msgid ).

    " Context Informationen prüfen
    ls_ctx_ok_act = ls_bal_msg-context-value.

    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component1 exp = ms_ctx_ok-component1 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component2 exp = ms_ctx_ok-component2 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component3 exp = ms_ctx_ok-component3 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component4 exp = ms_ctx_ok-component4 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component5 exp = ms_ctx_ok-component5 ).

    " zu langer Context darf zu keinem Fehler führen
    f_cut = zcl_calog_factory=>create_header( ).
    f_cut->add_message(
        EXPORTING
        iv_msgty = pi_msgty
        iv_msgid = pi_msgid
        iv_msgno = pi_msgno
       iv_msgv1 = pi_msgv1
       iv_msgv2 = pi_msgv2
       iv_msgv3 = pi_msgv3
       iv_msgv4 = pi_msgv4
       iv_ctx_struct_name = co_ctx_name_too_long
       iv_ctx_value = ms_ctx_too_long
      IMPORTING
        ev_bal_msg_hndl = pe_bal_msg_hndl
    ).

    " Log Eintrag speichern (pi_commit_immediately = 'X' <-- Default)
    f_cut->persist( ).

    " Log Eintrag aus der Datenbank holen
    CALL FUNCTION 'BAL_DB_LOAD'
      EXPORTING
*       i_t_log_header =     " Alternative 1:Tabelle mit Protokollköpfen
        i_t_log_handle = VALUE bal_t_logh( ( pe_bal_msg_hndl-log_handle ) )   " Alternative 2: Tabelle mit Protokollhandles
*       i_t_lognumber  =     " Alternative 3: Tabelle mit Protokollnummern
*       i_client       = SY-MANDT    " Mandant für I_T_LOGNUMBER
*       i_do_not_load_messages        = SPACE    " Nur Protkollkopf laden
*       i_exception_if_already_loaded =     " Ausnahme auslösen, falls Protokoll schon geladen
*       i_lock_handling               = 2    " 0: Sperren ignorieren, 1: gesperrte nicht  lesen, 2: warten
*    IMPORTING
*       e_t_log_handle =     " Tabelle der Handles der gelesenen Protokolle
*       e_t_msg_handle =     " Tabelle der Handles der gelesenen Meldungen
*       e_t_locked     =     " Gesperrte und nicht gelesene Protokolle
*    EXCEPTIONS
*       no_logs_specified             = 1
*       log_not_found  = 2
*       log_already_loaded            = 3
*       others         = 4
      .

    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = pe_bal_msg_hndl    " Meldungshandle
*       i_langu        = SY-LANGU    " Sprache
      IMPORTING
        e_s_msg        = ls_bal_msg    " Meldungsdaten
      " e_exists_on_db = lv_exists_on_db    " Meldungs existiert bereits auf der Datenbank
*       e_txt_msgty    =     " Text zum Fehlertyp
*       e_txt_msgid    =     " Text zum Arbeitsgebiet
*       e_txt_detlevel =     " Text zu Detaillierungsgrad
*       e_txt_probclass          =     " Text zur Problemklasse
*       e_txt_msg      =     " Text der Meldung (aufbereitet)
*       e_warning_text_not_found =     " Mindestens ein Text wurde nicht ermittelt
*    EXCEPTIONS
*       log_not_found  = 1
*       msg_not_found  = 2
*       others         = 3
      .

    " Weil die Methode persist( ) aufgerufen wurde muss der Eintrag auf der Datenbank existieren
    CALL FUNCTION 'Z_CALOG_TEST_BAL_MSG_ON_DB'
      EXPORTING
        iv_bal_hdr_hndl = f_cut->get_header_log_handle( )    " Anwendungs-Log: Handle eines Protokolls
        iv_bal_msg_hndl = pe_bal_msg_hndl    " Anwendungs-Log: Handle für eine Meldung
      IMPORTING
        ev_exists_on_db = lv_exists_on_db.    " allgemeines flag

    cl_aunit_assert=>assert_equals( act = lv_exists_on_db exp = abap_true msg = 'Log Entry must exist on DB').

    " Gelesene Daten prüfen
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgid exp = pi_msgid ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgno exp = pi_msgno ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgty exp = pi_msgty ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv1 exp = pi_msgv1 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv2 exp = pi_msgv2 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv3 exp = pi_msgv3 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv4 exp = pi_msgv4 ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgid exp = pi_msgid ).

    " Context Informationen prüfen
    " Muss hier leer sein
    cl_aunit_assert=>assert_initial( ls_bal_msg-context-value ).
  ENDMETHOD.

  METHOD add_text.
    CONSTANTS:
      co_text_to_log TYPE string VALUE 'test1'.

    DATA: pe_bal_msg_hndl TYPE balmsghndl,
          lv_exists_on_db TYPE abap_bool,
          ls_bal_msg      TYPE bal_s_msg,
          ls_ctx_ok_act   TYPE zcalog_test_ctx_struct_s.

    f_cut->add_text( EXPORTING iv_log_text = co_text_to_log iv_ctx_struct_name = co_ctx_name_ok iv_ctx_value = ms_ctx_ok
      IMPORTING ev_bal_msg_hndl = pe_bal_msg_hndl  )->persist( ).

    " Log Eintrag aus der Datenbank holen
    CALL FUNCTION 'BAL_DB_LOAD'
      EXPORTING
*       i_t_log_header =     " Alternative 1:Tabelle mit Protokollköpfen
        i_t_log_handle = VALUE bal_t_logh( ( pe_bal_msg_hndl-log_handle ) )   " Alternative 2: Tabelle mit Protokollhandles
*       i_t_lognumber  =     " Alternative 3: Tabelle mit Protokollnummern
*       i_client       = SY-MANDT    " Mandant für I_T_LOGNUMBER
*       i_do_not_load_messages        = SPACE    " Nur Protkollkopf laden
*       i_exception_if_already_loaded =     " Ausnahme auslösen, falls Protokoll schon geladen
*       i_lock_handling               = 2    " 0: Sperren ignorieren, 1: gesperrte nicht  lesen, 2: warten
*    IMPORTING
*       e_t_log_handle =     " Tabelle der Handles der gelesenen Protokolle
*       e_t_msg_handle =     " Tabelle der Handles der gelesenen Meldungen
*       e_t_locked     =     " Gesperrte und nicht gelesene Protokolle
*    EXCEPTIONS
*       no_logs_specified             = 1
*       log_not_found  = 2
*       log_already_loaded            = 3
*       others         = 4
      .

    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = pe_bal_msg_hndl    " Meldungshandle
*       i_langu        = SY-LANGU    " Sprache
      IMPORTING
        e_s_msg        = ls_bal_msg    " Meldungsdaten
*       e_exists_on_db = lv_exists_on_db    " Meldungs existiert bereits auf der Datenbank
*       e_txt_msgty    =     " Text zum Fehlertyp
*       e_txt_msgid    =     " Text zum Arbeitsgebiet
*       e_txt_detlevel =     " Text zu Detaillierungsgrad
*       e_txt_probclass          =     " Text zur Problemklasse
*       e_txt_msg      =     " Text der Meldung (aufbereitet)
*       e_warning_text_not_found =     " Mindestens ein Text wurde nicht ermittelt
*    EXCEPTIONS
*       log_not_found  = 1
*       msg_not_found  = 2
*       others         = 3
      .

    CALL FUNCTION 'Z_CALOG_TEST_BAL_MSG_ON_DB'
      EXPORTING
        iv_bal_hdr_hndl = f_cut->get_header_log_handle( )    " Anwendungs-Log: Handle eines Protokolls
        iv_bal_msg_hndl = pe_bal_msg_hndl    " Anwendungs-Log: Handle für eine Meldung
      IMPORTING
        ev_exists_on_db = lv_exists_on_db.    " allgemeines flag

    cl_aunit_assert=>assert_equals( act = lv_exists_on_db exp = abap_true msg = 'Log Entry must exist on DB' ).
    cl_aunit_assert=>assert_equals( act = ls_bal_msg-msgv1 exp = co_text_to_log ).

    " Context Informationen prüfen
    ls_ctx_ok_act = ls_bal_msg-context-value.

    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component1 exp = ms_ctx_ok-component1 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component2 exp = ms_ctx_ok-component2 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component3 exp = ms_ctx_ok-component3 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component4 exp = ms_ctx_ok-component4 ).
    cl_aunit_assert=>assert_equals( act = ls_ctx_ok_act-component5 exp = ms_ctx_ok-component5 ).

    " Zu langer Kontext darf zu keinem Fehler führen...
    f_cut = zcl_calog_factory=>create_header( ).

    f_cut->add_text( EXPORTING iv_log_text = co_text_to_log iv_ctx_struct_name = co_ctx_name_too_long iv_ctx_value = ms_ctx_too_long
      IMPORTING ev_bal_msg_hndl = pe_bal_msg_hndl  )->persist( ).

    " Log Eintrag aus der Datenbank holen
    CALL FUNCTION 'BAL_DB_LOAD'
      EXPORTING
*       i_t_log_header =     " Alternative 1:Tabelle mit Protokollköpfen
        i_t_log_handle = VALUE bal_t_logh( ( pe_bal_msg_hndl-log_handle ) )   " Alternative 2: Tabelle mit Protokollhandles
*       i_t_lognumber  =     " Alternative 3: Tabelle mit Protokollnummern
*       i_client       = SY-MANDT    " Mandant für I_T_LOGNUMBER
*       i_do_not_load_messages        = SPACE    " Nur Protkollkopf laden
*       i_exception_if_already_loaded =     " Ausnahme auslösen, falls Protokoll schon geladen
*       i_lock_handling               = 2    " 0: Sperren ignorieren, 1: gesperrte nicht  lesen, 2: warten
*    IMPORTING
*       e_t_log_handle =     " Tabelle der Handles der gelesenen Protokolle
*       e_t_msg_handle =     " Tabelle der Handles der gelesenen Meldungen
*       e_t_locked     =     " Gesperrte und nicht gelesene Protokolle
*    EXCEPTIONS
*       no_logs_specified             = 1
*       log_not_found  = 2
*       log_already_loaded            = 3
*       others         = 4
      .

    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = pe_bal_msg_hndl    " Meldungshandle
*       i_langu        = SY-LANGU    " Sprache
      IMPORTING
        e_s_msg        = ls_bal_msg    " Meldungsdaten
      " e_exists_on_db = lv_exists_on_db    " Meldungs existiert bereits auf der Datenbank
*       e_txt_msgty    =     " Text zum Fehlertyp
*       e_txt_msgid    =     " Text zum Arbeitsgebiet
*       e_txt_detlevel =     " Text zu Detaillierungsgrad
*       e_txt_probclass          =     " Text zur Problemklasse
*       e_txt_msg      =     " Text der Meldung (aufbereitet)
*       e_warning_text_not_found =     " Mindestens ein Text wurde nicht ermittelt
*    EXCEPTIONS
*       log_not_found  = 1
*       msg_not_found  = 2
*       others         = 3
      .

    " Weil die Methode persist( ) aufgerufen wurde muss der Eintrag auf der Datenbank existieren

    CALL FUNCTION 'Z_CALOG_TEST_BAL_MSG_ON_DB'
      EXPORTING
        iv_bal_hdr_hndl = f_cut->get_header_log_handle( )    " Anwendungs-Log: Handle eines Protokolls
        iv_bal_msg_hndl = pe_bal_msg_hndl    " Anwendungs-Log: Handle für eine Meldung
      IMPORTING
        ev_exists_on_db = lv_exists_on_db.    " allgemeines flag

    cl_aunit_assert=>assert_equals( act = lv_exists_on_db exp = abap_true msg = 'Log Entry must exist on DB').

    " Gelesene Daten prüfen
    ls_ctx_ok_act = ls_bal_msg-context-value.

    " Context Informationen prüfen
    " Muss hier leer sein
    cl_aunit_assert=>assert_initial( ls_bal_msg-context-value ).
  ENDMETHOD.

  METHOD create.
*    data pi_Log_Object type balobj_D.
*    data pi_Log_Subobj type balsubobj.
*    data pi_Ctx_Struct_Name type baltabname.
*    data pi_Ctx_Value type balcval.
*    data pi_Progname type syrepid.
*    data pr_Log_Header_Ref type ref to zif_Ca_Log_Header.
*
*    pr_Log_Header_Ref = zcl_Ca_Logging_Header=>zif_Ca_Log_Header~create(
**       PI_LOG_OBJECT = pi_Log_Object
**       PI_LOG_SUBOBJ = pi_Log_Subobj
**       PI_CTX_STRUCT_NAME = pi_Ctx_Struct_Name
**       PI_CTX_VALUE = pi_Ctx_Value
**       PI_PROGNAME = pi_Progname
*    ).
  ENDMETHOD.

  METHOD persist.
    DATA:
      lv_bal_msg_handle TYPE balmsghndl,
      lv_exists_on_db   TYPE abap_bool,
      ls_bal_msg        TYPE bal_s_msg.

    f_cut->add_text(
      EXPORTING iv_log_text = 'Unit Test ZCL_TST_LOG_HEADER->persist( )'
        IMPORTING ev_bal_msg_hndl = lv_bal_msg_handle )->persist( ).

    " Log Eintrag aus der Datenbank holen
    CALL FUNCTION 'BAL_DB_LOAD'
      EXPORTING
*       i_t_log_header =     " Alternative 1:Tabelle mit Protokollköpfen
        i_t_log_handle = VALUE bal_t_logh( ( lv_bal_msg_handle-log_handle ) )   " Alternative 2: Tabelle mit Protokollhandles
*       i_t_lognumber  =     " Alternative 3: Tabelle mit Protokollnummern
*       i_client       = SY-MANDT    " Mandant für I_T_LOGNUMBER
*       i_do_not_load_messages        = SPACE    " Nur Protkollkopf laden
*       i_exception_if_already_loaded =     " Ausnahme auslösen, falls Protokoll schon geladen
*       i_lock_handling               = 2    " 0: Sperren ignorieren, 1: gesperrte nicht  lesen, 2: warten
*    IMPORTING
*       e_t_log_handle =     " Tabelle der Handles der gelesenen Protokolle
*       e_t_msg_handle =     " Tabelle der Handles der gelesenen Meldungen
*       e_t_locked     =     " Gesperrte und nicht gelesene Protokolle
*    EXCEPTIONS
*       no_logs_specified             = 1
*       log_not_found  = 2
*       log_already_loaded            = 3
*       others         = 4
      .

    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = lv_bal_msg_handle    " Meldungshandle
*       i_langu        = SY-LANGU    " Sprache
      IMPORTING
        e_s_msg        = ls_bal_msg    " Meldungsdaten
        e_exists_on_db = lv_exists_on_db    " Meldungs existiert bereits auf der Datenbank
*       e_txt_msgty    =     " Text zum Fehlertyp
*       e_txt_msgid    =     " Text zum Arbeitsgebiet
*       e_txt_detlevel =     " Text zu Detaillierungsgrad
*       e_txt_probclass          =     " Text zur Problemklasse
*       e_txt_msg      =     " Text der Meldung (aufbereitet)
*       e_warning_text_not_found =     " Mindestens ein Text wurde nicht ermittelt
*    EXCEPTIONS
*       log_not_found  = 1
*       msg_not_found  = 2
*       others         = 3
      .

    CALL FUNCTION 'Z_CALOG_TEST_BAL_MSG_ON_DB'
      EXPORTING
        iv_bal_hdr_hndl = f_cut->get_header_log_handle( )    " Anwendungs-Log: Handle eines Protokolls
        iv_bal_msg_hndl = lv_bal_msg_handle    " Anwendungs-Log: Handle für eine Meldung
      IMPORTING
        ev_exists_on_db = lv_exists_on_db.    " allgemeines flag

    cl_aunit_assert=>assert_equals( act = lv_exists_on_db exp = abap_true msg = 'Log Entry must exist on DB' ).

    f_cut = zcl_calog_factory=>create_header(
*            pi_log_object      = CO_DEFAULT_LOG_OBJECT
*            pi_log_subobj      = CO_EXCEPTION_SUB_OBJECT
*            pi_ctx_struct_name =
*            pi_ctx_value       =
*            pi_progname        = SY-CPROG
*            pit_callstack      =
        ).

    " Aufruf ohne pi_save_immediately. Log Eintrag darf noch nicht auf der Datenbank stehen
    f_cut->add_text(
      EXPORTING iv_log_text = 'Unit Test ZCL_TST_LOG_HEADER->persist( ) not immediately'
        IMPORTING ev_bal_msg_hndl = lv_bal_msg_handle )->persist( iv_save_immediately = abap_false ).

    ROLLBACK WORK.

    CALL FUNCTION 'Z_CALOG_TEST_BAL_MSG_ON_DB'
      EXPORTING
        iv_bal_hdr_hndl = f_cut->get_header_log_handle( )    " Anwendungs-Log: Handle eines Protokolls
        iv_bal_msg_hndl = lv_bal_msg_handle    " Anwendungs-Log: Handle für eine Meldung
      IMPORTING
        ev_exists_on_db = lv_exists_on_db.    " allgemeines flag

    cl_aunit_assert=>assert_equals( act = lv_exists_on_db exp = abap_false msg = 'Log Entry must not exist on DB' ).
  ENDMETHOD.

  METHOD persist_is_isolated.
    " Sicherstellen, dass persit isoliert von der Standard-DB-Verbindung läuft. D.h. eine von aussen begonnene Transaktion
    " darf durch ein persist mit dem Flag commit immediately nicht betroffen sein.
    CONSTANTS:
      co_lognumber TYPE balognr VALUE 'UNITTESTUNITTESTUNITTEST',
      co_nr        TYPE i VALUE 1.

    DATA:
      ls_zcalog_cstack TYPE zcalog_cstack,
      lv_bal_msg_handle TYPE balmsghndl,
      lv_exists_on_db  TYPE abap_bool.

    ls_zcalog_cstack-lognumber = co_lognumber.
    ls_zcalog_cstack-stacktr_line_nr = co_nr.
    ls_zcalog_cstack-xdate = sy-datum.

    INSERT zcalog_cstack FROM ls_zcalog_cstack.
    cl_aunit_assert=>assert_equals( exp = 0 act = sy-subrc ).

    f_cut->add_text( EXPORTING iv_log_text = 'Unit Test persist_is_isolated'

    IMPORTING ev_bal_msg_hndl = lv_bal_msg_handle )->persist( iv_save_immediately = abap_true ).

    ROLLBACK WORK.

    " Header muss auf der DB Vorhanden sein
    CALL FUNCTION 'Z_CALOG_TEST_BAL_MSG_ON_DB'
      EXPORTING
        iv_bal_hdr_hndl = f_cut->get_header_log_handle( )    " Anwendungs-Log: Handle eines Protokolls
        iv_bal_msg_hndl = lv_bal_msg_handle    " Anwendungs-Log: Handle für eine Meldung
      IMPORTING
        ev_exists_on_db = lv_exists_on_db.    " allgemeines flag

    cl_aunit_assert=>assert_equals( exp = abap_true act = lv_exists_on_db msg = 'Log entry must exist on db' ).

    SELECT SINGLE * FROM zcalog_cstack INTO ls_zcalog_cstack WHERE lognumber = co_lognumber AND stacktr_line_nr = co_nr.
    IF sy-subrc <> 4.
      cl_aunit_assert=>fail( msg = 'persist with pi_save_immeditely must be isolated' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
