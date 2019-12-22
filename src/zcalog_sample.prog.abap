*&---------------------------------------------------------------------*
*& Report ZCALOG_SAMPLE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCALOG_SAMPLE.



START-OF-SELECTION.

ZCL_CALOG_FACTORY=>CREATE_HEADER( )->ADD_TEXT( 'Simplpe Text added' )->ADD_TEXT( 'Another text' )->PERSIST( ).
