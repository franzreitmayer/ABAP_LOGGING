*----------------------------------------------------------------------*
***INCLUDE LZCALOGD01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class lcl_dialog_close_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_dialogcont_close_handler DEFINITION.

  PUBLIC SECTION.

    METHODS:

      constructor IMPORTING pi_dialogbox_container_ref TYPE REF TO cl_gui_dialogbox_container,

      handle_close_event FOR EVENT close OF cl_gui_dialogbox_container.

  PRIVATE SECTION.

    DATA:

          mv_dialogbox_container_ref TYPE REF TO cl_gui_dialogbox_container.

ENDCLASS.
