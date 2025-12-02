*&---------------------------------------------------------------------*
*& Report ZFARR_FIX_LATEST_FLAG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfarr_fix_latest_flag.

DATA: go_msg_handler    TYPE REF TO cl_farr_message_handler,
      gv_log_handler    TYPE balloghndl,
      gv_msg_str        TYPE string,
      gv_has_input_err  TYPE boolean,
      gv_timestamp      TYPE timestamp,
      gt_defitem_update TYPE farr_tt_defitem_data.

*----------------------------------------------------------------------*
*              Selection Screen                                        *
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE t_data.
  PARAMETERS: p_pob   TYPE farr_pob_id, " POB ID
              p_recon TYPE farr_recon_key,
              p_cond  TYPE kscha.

  PARAMETERS : p_int TYPE arch_processing_options-delete_testmode RADIOBUTTON GROUP a,
               p_clr TYPE arch_processing_options-delete_testmode RADIOBUTTON GROUP a.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK ctrl WITH FRAME TITLE t_ctrl.
  PARAMETERS p_test TYPE arch_processing_options-delete_testmode AS CHECKBOX  DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK ctrl.

SELECTION-SCREEN BEGIN OF BLOCK info WITH FRAME TITLE t_info.
  SELECTION-SCREEN COMMENT /1(79) t_cmt_1. " Max lenght of comment is 79
  SELECTION-SCREEN COMMENT /1(79) t_cmt_2.
  SELECTION-SCREEN COMMENT /1(79) t_cmt_3.
SELECTION-SCREEN END OF BLOCK info.

*----------------------------------------------------------------------*
*              INITIALIZATION                                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  t_data = 'Data Selection'.
  t_ctrl = 'Control'.

  %_p_int_%_app_%-text  = 'Insert'.
  %_p_clr_%_app_%-text  = 'Clear'.
  %_p_test_%_app_%-text  = 'Simulation'.
  %_p_pob_%_app_%-text   = 'Performance Obligation'.
  %_p_recon_%_app_%-text  = 'Recon Key'.
  %_p_cond_%_app_%-text  = 'Condition Type'.
  t_cmt_1 = 'IMPORTANT: THIS REPORT MUST ONLY BE EXECUTED AFTER '.
  t_cmt_2 = '                   ALIGNMENT WITH SAP PRODUCT SUPPORT '.
  t_cmt_3 = '' .


START-OF-SELECTION.
  PERFORM initialize_msg_handler.

  PERFORM check_input.

  PERFORM start_of_work.

*&---------------------------------------------------------------------*
*&      Form  start_of_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM start_of_work.
  DATA: lt_defitem_data     TYPE farr_tt_defitem_data.
  FIELD-SYMBOLS:
        <ls_defitem_data>   TYPE farr_s_defitem_data.

  PERFORM write_run_mode_log.
  IF gv_has_input_err = abap_false.

    CLEAR gt_defitem_update.
    TRY .
        CALL METHOD cl_farr_defitem_db_access=>read_multiple_by_pob_id
          EXPORTING
            iv_pob_id  = p_pob
          IMPORTING
            et_defitem = lt_defitem_data.

        LOOP AT lt_defitem_data ASSIGNING <ls_defitem_data>
          WHERE recon_key = p_recon AND condition_type = p_cond.
          IF p_clr = abap_true .
            CLEAR <ls_defitem_data>-latest_defitem.
            APPEND <ls_defitem_data> TO gt_defitem_update.
          ELSEIF p_int = abap_true.
            <ls_defitem_data>-latest_defitem = 'X'.
            APPEND <ls_defitem_data> TO gt_defitem_update.
          ENDIF.
        ENDLOOP.

        CALL METHOD cl_farr_defitem_db_access=>update_multiple
          EXPORTING
            it_defitem = gt_defitem_update.

        LOOP AT gt_defitem_update ASSIGNING <ls_defitem_data>.

          MESSAGE i000(farr_rai_check)
          WITH 'Deferral item of POB'
          <ls_defitem_data>-pob_id
          'has been fixed on reconciliation key'
          <ls_defitem_data>-recon_key
          INTO gv_msg_str.

          CALL METHOD go_msg_handler->add_symessage
            EXPORTING
              iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
        ENDLOOP.

      CATCH cx_farr_message.

    ENDTRY.

    IF p_test IS INITIAL.
      COMMIT WORK.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

    PERFORM save_and_close_application_log.
    PERFORM display_result.

  ENDIF.

ENDFORM.                    "start_of_work

*&---------------------------------------------------------------------*
*&      Form  SAVE_AND_CLOSE_APPLICATION_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_and_close_application_log .

  TRY.
      gv_log_handler = go_msg_handler->get_log_handler( ).
      CALL METHOD go_msg_handler->save_and_close_app_log( ).

      COMMIT WORK.
    CATCH cx_farr_message.
  ENDTRY.

ENDFORM.                    " SAVE_CLOSE_APPLICATION_LOG
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_result .
  DATA: lt_fieldcat  TYPE slis_t_fieldcat_alv,
        lv_alv_title TYPE lvc_title.
  FIELD-SYMBOLS:
        <ls_fieldcat>         TYPE slis_fieldcat_alv.

  IF sy-batch = abap_false.
    PERFORM show_application_log.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING "         i_program_name         = <program name>
        i_structure_name       = 'FARR_S_DEFITEM_DATA'
        i_bypassing_buffer     = 'X'
      CHANGING
        ct_fieldcat            = lt_fieldcat[]
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    LOOP AT lt_fieldcat ASSIGNING <ls_fieldcat>.
      <ls_fieldcat>-seltext_m = <ls_fieldcat>-fieldname.
      <ls_fieldcat>-seltext_l = <ls_fieldcat>-fieldname.
      <ls_fieldcat>-seltext_s = <ls_fieldcat>-fieldname.
      <ls_fieldcat>-reptext_ddic = <ls_fieldcat>-fieldname.
    ENDLOOP.

    IF p_test IS NOT INITIAL.
      lv_alv_title = 'LATEST_DEFITEM flag Correction for POB(Simulation Run)'.
    ELSE.
      lv_alv_title = 'LATEST_DEFITEM flag Correction for POB(Productive Run)'.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat  = lt_fieldcat
        i_grid_title = lv_alv_title
      TABLES
        t_outtab     = gt_defitem_update.
  ENDIF.

ENDFORM.                    " DISPLAY_RESULT

*&---------------------------------------------------------------------*
*&      Form  write_fix_log_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM write_fix_log_header.
  MESSAGE s000(fb)
     WITH 'Start to fix data...'
     INTO gv_msg_str.

  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  MESSAGE s000(fb)
     WITH gv_timestamp
          'is the timestamp of the fix'
     INTO gv_msg_str.

  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
ENDFORM.                    "write_fix_log_header



*&---------------------------------------------------------------------*
*&      Form  initialize_msg_handler
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM initialize_msg_handler.
  DATA: lx_farr_message TYPE REF TO cx_farr_message.

  CREATE OBJECT go_msg_handler.
  TRY.
      CALL METHOD go_msg_handler->initialize
        EXPORTING
          iv_sub_obj = 'CLEANUP'.
    CATCH cx_farr_message INTO lx_farr_message.
      MESSAGE ID lx_farr_message->mv_msgid
      TYPE lx_farr_message->mv_msgty
      NUMBER lx_farr_message->mv_msgno
      WITH lx_farr_message->mv_msgv1
      lx_farr_message->mv_msgv2
      lx_farr_message->mv_msgv3
      lx_farr_message->mv_msgv4.
  ENDTRY.

ENDFORM.                    "initialize_msg_handler

*&---------------------------------------------------------------------*
*&      Form  check_input
*&---------------------------------------------------------------------*
*       The input parameters must be filled by the user.
*----------------------------------------------------------------------*
FORM check_input.
  CLEAR gv_has_input_err.
  IF sy-batch = abap_false.
* Online run, directly show error on UI
    IF p_pob IS INITIAL.
      MESSAGE i000(farr_rai_check)
         WITH 'No performance obligation is entered!'.

      gv_has_input_err = abap_true.

      RETURN.
    ELSEIF p_recon IS INITIAL.
      MESSAGE i000(farr_rai_check)
         WITH 'No Recon key is entered!'.

      gv_has_input_err = abap_true.
    ENDIF.
  ENDIF.
ENDFORM.                    "check_input

*&---------------------------------------------------------------------*
*&      Form  SHOW_APPLICATION_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_application_log .
  DATA: ls_filter          TYPE bal_s_lfil,
        lrs_log_handler    TYPE bal_s_logh,
        lt_header          TYPE balhdr_t,
        ls_display_profile TYPE bal_s_prof.

  lrs_log_handler-sign  = 'I'.
  lrs_log_handler-option = 'EQ'.
  TRY.
      lrs_log_handler-low =  gv_log_handler.
    CATCH cx_farr_message.
  ENDTRY.
  APPEND lrs_log_handler TO ls_filter-log_handle.

  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
      i_s_log_filter = ls_filter
    IMPORTING
      e_t_log_header = lt_header
    EXCEPTIONS
      OTHERS         = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'BAL_DB_LOAD'
    EXPORTING
      i_t_log_header         = lt_header
      i_do_not_load_messages = abap_false
    EXCEPTIONS
      OTHERS                 = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* get a prepared profile
  CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
    IMPORTING
      e_s_display_profile = ls_display_profile
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ls_display_profile-disvariant-report = sy-repid.
  ls_display_profile-disvariant-handle = 'LOG'.

*  Display without context
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile = ls_display_profile
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID   sy-msgid
    TYPE sy-msgty
    NUMBER sy-msgno
    WITH sy-msgv1
    sy-msgv2
    sy-msgv3
    sy-msgv4.
  ENDIF.
ENDFORM.                    " SHOW_APPLICATION_LOG

*&---------------------------------------------------------------------*
*&      Form  write_run_mode_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM write_run_mode_log.
  IF p_test = abap_true.
    MESSAGE s000(fb)
      WITH '==== Test Run (No DB Update) ===='
      INTO gv_msg_str.
  ELSE.
    MESSAGE s000(fb)
      WITH '==== Production Run (DB will be Updated) ===='
      INTO gv_msg_str.
  ENDIF.

  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
ENDFORM.                    "write_run_mode_log
