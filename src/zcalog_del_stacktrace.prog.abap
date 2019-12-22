*&---------------------------------------------------------------------*

*& Report  ZCA_LOG_DEL_STACKTRACE

*&

*&---------------------------------------------------------------------*
*& Löschreport für Tabelle ZCA_LOG_CSTACK
*&
*&---------------------------------------------------------------------*
REPORT zca_log_del_stacktrace MESSAGE-ID zca_logging.

CONSTANTS:
  co_stack_trace_tab_name TYPE tabname VALUE 'ZCA_LOG_CSTACK'.

DATA:
  gs_sel            TYPE          zcalog_cstack,
  gt_zca_log_cstack TYPE TABLE OF zcalog_cstack.



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b11 WITH FRAME TITLE text-003.
SELECT-OPTIONS:
so_balnr FOR gs_sel-lognumber,
so_xdate FOR gs_sel-xdate.
SELECTION-SCREEN END OF BLOCK b11.


SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b12 WITH FRAME TITLE text-002.
PARAMETERS:
  pa_test TYPE flag RADIOBUTTON GROUP g1,
  pa_del  TYPE flag RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b12.

SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.

START-OF-SELECTION.

  SELECT
    *
  FROM
    zcalog_cstack
  INTO TABLE gt_zca_log_cstack
  WHERE
lognumber IN so_balnr AND
xdate IN so_xdate.


END-OF-SELECTION.
  IF pa_test EQ abap_true.
    PERFORM run_test.
  ELSEIF pa_del EQ abap_true.
    PERFORM run_deletion.
  ENDIF.



FORM run_test.

  TRY.
      cl_salv_table=>factory(
*  EXPORTING
*    list_display   = IF_SALV_C_BOOL_SAP=>FALSE    " ALV wird im Listenmodus angezeigt
*    r_container    =     " Abstracter Container fuer GUI Controls
*    container_name =
        IMPORTING
          r_salv_table   =  DATA(lr_salv_table)   " Basisklasse einfache ALV Tabellen
      CHANGING
          t_table        = gt_zca_log_cstack
        ).
    CATCH cx_salv_msg INTO DATA(lcx_salv_msg_ref).    "
      MESSAGE lcx_salv_msg_ref->get_text( ) TYPE 'X'.
  ENDTRY.
  lr_salv_table->display( ).
ENDFORM.


FORM run_deletion.
  DATA:
    lv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = 'Wirklich löschen?'    " Titel des Popup
*     diagnose_object       = SPACE    " Diagnosetext (Pflege über SE61)
      text_question         = 'Wollen Sie die Datensätze gemäß der Auswahl wirklich löschen?'   " Fragetext im Popup
      text_button_1         = 'Ja'(004)    " Text auf der ersten Drucktaste
*     icon_button_1         = SPACE    " Ikone auf der ersten Drucktaste
      text_button_2         = 'Nein'(005)    " Text auf der zweiten Drucktaste
*     icon_button_2         = SPACE    " Ikone auf der zweiten Drucktaste
*     default_button        = '1'    " Cursorposition
      display_cancel_button = space    " Schalter,ob Abbrechen-Drucktaste angezeigt wird
*     userdefined_f1_help   = SPACE    " Benutzerdefinierte F1-Hilfe
*     start_column          =     " Startspalte, in der das POPUP beginnt
*     start_row             =     " Startzeile, in der das POPUP beginnt
*     popup_type            =     " Ikonentyp
*     iv_quickinfo_button_1 = SPACE    " Quickinfo auf der ersten Drucktaste
*     iv_quickinfo_button_2 = SPACE    " Quickinfo auf der zweiten Drucktaste
    IMPORTING
      answer                = lv_answer   " Rückgabewerte: '1', '2', 'A'
*  TABLES
*     parameter             =     " Übergabetabelle für Parameter im Text
*  EXCEPTIONS
*     text_not_found        = 1
*     others                = 2
    .
  IF lv_answer EQ '1'.

    PERFORM delete_selected_logs.
  ENDIF.
ENDFORM.


FORM delete_selected_logs.
  DELETE FROM zcalog_cstack WHERE
    lognumber IN so_balnr AND xdate IN so_xdate.
  IF sy-subrc = 0.
    MESSAGE s001 WITH sy-dbcnt.
  ELSE.
    MESSAGE i002.
  ENDIF.

ENDFORM.
