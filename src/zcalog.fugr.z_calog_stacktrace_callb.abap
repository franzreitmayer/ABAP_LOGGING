FUNCTION Z_CALOG_STACKTRACE_CALLB.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      I_T_PARAMS STRUCTURE  SPAR
*"----------------------------------------------------------------------
CONSTANTS:
    co_param_lognumber TYPE spo_par VALUE '%LOGNUMBER'.


  DATA:
    callstack                     TYPE abap_callstack,
    bal_lognumber                 TYPE balognr,
    parameter                     TYPE spar,
    gui_dialog_container          TYPE REF TO cl_gui_dialogbox_container,
    alv_table                     TYPE REF TO cl_salv_table,
    close_handler                 TYPE REF TO lcl_dialogcont_close_handler,
    dialog_title                  TYPE c LENGTH 100.


  READ TABLE i_t_params
    INTO parameter WITH KEY param = co_param_lognumber.
  IF sy-subrc = 0.

    bal_lognumber = parameter-value.
    dialog_title = text-001 && bal_lognumber.

    SELECT * FROM zcalog_cstack INTO TABLE @DATA(stacktrace) WHERE lognumber = @bal_lognumber.
    SORT stacktrace BY stacktr_line_nr ASCENDING.

    MOVE-CORRESPONDING stacktrace TO callstack.
    IF lines( callstack ) < 1.
      PERFORM popup_no_stacktrace.
      EXIT.
    ENDIF.

    gui_dialog_container = NEW cl_gui_dialogbox_container(
        parent                      = cl_gui_dialogbox_container=>default_screen
        width                       = 1000
        height                      = 220
        caption                     = dialog_title
    ).

    TRY.
        cl_salv_table=>factory(
          EXPORTING
            r_container    = gui_dialog_container    " Abstracter Container fuer GUI Controls
          IMPORTING
            r_salv_table   = alv_table    " Basisklasse einfache ALV Tabellen
          CHANGING
            t_table        = callstack
        ).
      CATCH cx_salv_msg INTO DATA(salv_msg_exception).    "
        MESSAGE salv_msg_exception->get_text( ) TYPE 'X'.
    ENDTRY.

    close_handler = NEW lcl_dialogcont_close_handler( gui_dialog_container ).
    SET HANDLER close_handler->handle_close_event FOR gui_dialog_container.

    alv_table->display( ).
  ELSE.
    PERFORM popup_no_stacktrace.
  ENDIF.
ENDFUNCTION.
