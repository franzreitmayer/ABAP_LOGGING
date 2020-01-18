*----------------------------------------------------------------------*
***INCLUDE LZCALOGP01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Class (Implementation) lcl_dialog_close_handler
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
CLASS lcl_dialogcont_close_handler IMPLEMENTATION.

  METHOD constructor.

    mv_dialogbox_container_ref = pi_dialogbox_container_ref.

  ENDMETHOD.



  METHOD handle_close_event.

    CHECK mv_dialogbox_container_ref IS BOUND.

    SET HANDLER me->handle_close_event

      FOR mv_dialogbox_container_ref ACTIVATION space.

    mv_dialogbox_container_ref->free( ).

  ENDMETHOD.

ENDCLASS.               "lcl_dialogcont_close_handler
