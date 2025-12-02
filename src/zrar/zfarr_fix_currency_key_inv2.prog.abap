*&---------------------------------------------------------------------*
*& Report ZFARR_FIX_CURRENCY_KEY_INV2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfarr_fix_currency_key_inv2.
*&---------------------------------------------------------------------*
*& Fix the farr_d_invoice entries with missing currency key
*&
*&---------------------------------------------------------------------*
TABLES: farr_d_pob.

TYPES:
  BEGIN OF ty_s_pob_data,
    pob_id         TYPE farr_pob_id,
    contract_id    TYPE farr_contract_id,
    alloc_amt_curk TYPE waers,
  END OF ty_s_pob_data,

  ty_ts_pob_data TYPE SORTED TABLE OF ty_s_pob_data   WITH UNIQUE KEY  pob_id.

DATA: go_message_handler TYPE REF TO cl_farr_message_handler,
      gv_log_handler     TYPE balloghndl,
      gv_counter         TYPE int4,
      gv_msg_str         TYPE string.

* for data selection
DATA: gt_sel_list       TYPE farr_tt_pob_id,
      gs_sel_list       LIKE LINE OF gt_sel_list,
      gt_pob_id_range   TYPE farr_tt_pob_id_range,
      gt_pob_data       TYPE ty_ts_pob_data,
      gt_invoice_defect TYPE farr_tt_invoice_data.

*----------------------------------------------------------------------*
*              Selection Screen                                        *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE t_data.

  SELECT-OPTIONS:
  s_bukrs FOR farr_d_pob-company_code OBLIGATORY,
  s_con   FOR farr_d_pob-contract_id,
  s_pob   FOR farr_d_pob-pob_id.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK ctrl WITH FRAME TITLE t_ctrl.
  PARAMETERS p_test TYPE arch_processing_options-delete_testmode AS CHECKBOX  DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK ctrl.

*----------------------------------------------------------------------*
*              Global variant identification                           *
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_s_result,
         contract_id TYPE farr_contract_id,
         pob_id      TYPE farr_pob_id,
         fixed       TYPE  char1,
       END OF ty_s_result.

DATA:
  gi_fieldcat_pob  TYPE slis_t_fieldcat_alv,
  gt_pob_corrected TYPE STANDARD TABLE OF ty_s_result.

*----------------------------------------------------------------------*
*              INITIALIZATION                                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  t_data = 'Data selection'.
  t_ctrl = 'Control'.

  %_s_bukrs_%_app_%-text   = 'Company Code'.
  %_s_con_%_app_%-text     = 'Contract'.
  %_s_pob_%_app_%-text     = 'Performance Obligation'.

  %_p_test_%_app_%-text  = 'Simulation'.

START-OF-SELECTION.
  PERFORM initialize_global_parameters.
  PERFORM start_of_work.

*&---------------------------------------------------------------------*
*&      Form  start_of_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM start_of_work.
  PERFORM  sel_invoice_from_db.

  PERFORM set_currency_key.

  IF p_test IS INITIAL.
    PERFORM save_to_db.
  ENDIF.

  PERFORM close_application_log.
  PERFORM display_result.

ENDFORM.                    "start_of_work
*&---------------------------------------------------------------------*
*&      Form  sel_farr_cons_from_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sel_invoice_from_db.

  DATA: ls_sel_pob_id TYPE farr_s_sel_pob_id,
        lt_sel_pob_id TYPE TABLE OF farr_s_sel_pob_id,
        lv_pob_id     TYPE farr_pob_id.

  CLEAR: gt_pob_data,
         gt_invoice_defect.

  SELECT pob_id contract_id alloc_amt_curk INTO  TABLE gt_pob_data
  FROM farr_d_pob
    WHERE pob_id       IN s_pob
    AND   company_code IN s_bukrs
    AND   contract_id  IN s_con.

  LOOP AT gt_pob_data ASSIGNING FIELD-SYMBOL(<ls_pob_data>).
    ls_sel_pob_id-sign   = if_farrc_contr_mgmt=>co_criteria_include_sign.
    ls_sel_pob_id-option = if_farrc_contr_mgmt=>co_criteria_option_equal.
    ls_sel_pob_id-low    = <ls_pob_data>-pob_id.
    APPEND ls_sel_pob_id TO lt_sel_pob_id.
  ENDLOOP.

* read invoice table entries
  SELECT * FROM farr_d_invoice
            INTO CORRESPONDING FIELDS OF TABLE gt_invoice_defect
            WHERE  pob_id IN lt_sel_pob_id
            AND ( waers = space OR waers IS NULL )
            ORDER BY PRIMARY KEY.

  DESCRIBE TABLE gt_invoice_defect LINES gv_counter.

  PERFORM add_select_counter_to_log.

ENDFORM.                    "sel_dupplicate_missing_mapping
*&---------------------------------------------------------------------*
*&      Form  add_select_counter_to_log.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_select_counter_to_log.
  MESSAGE i000(fb)
  WITH 'Number of FARR_D_INVOICE entries without currency key: ' gv_counter
  INTO gv_msg_str.

  CALL METHOD go_message_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
ENDFORM.                    "add_select_counter_to_log

*&---------------------------------------------------------------------*
*&      Form  adjust_rev_quantity_delta
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_currency_key.
  DATA: lt_invoice                 TYPE TABLE OF farr_d_invoice,
        ls_company_code_currencies TYPE farr_s_cocd_local_currency,
        ls_contract                TYPE farr_d_contract.

  DATA: lv_msg                TYPE string ##NEEDED.

  FIELD-SYMBOLS: <ls_pob_data> TYPE ty_s_pob_data,
                 <ls_invoice>  TYPE farr_s_invoice_data.

  LOOP AT gt_invoice_defect ASSIGNING <ls_invoice>.

    IF <ls_invoice>-company_code NE  ls_company_code_currencies-company_code.
      TRY.
          cl_farr_rai_cust=>get_local_currencies( EXPORTING iv_bukrs    = <ls_invoice>-company_code
                                                 IMPORTING es_currencies = ls_company_code_currencies ).
        CATCH  cx_farr_message.
      ENDTRY.
    ENDIF.

    IF <ls_invoice>-waers IS INITIAL.
      READ TABLE gt_pob_data WITH KEY pob_id = <ls_invoice>-pob_id ASSIGNING <ls_pob_data>.
      IF sy-subrc EQ 0.
        IF <ls_pob_data>-alloc_amt_curk IS NOT INITIAL.
          <ls_invoice>-waers =  <ls_pob_data>-alloc_amt_curk.
        ELSE.
          IF <ls_pob_data>-contract_id NE ls_contract-contract_id.
            SELECT SINGLE * FROM farr_d_contract INTO ls_contract WHERE contract_id EQ <ls_pob_data>-contract_id.
          ENDIF.
          <ls_invoice>-waers =  ls_contract-trx_price_curk.
        ENDIF.
      ENDIF.
    ENDIF.

    IF <ls_invoice>-hwaer IS INITIAL AND ls_company_code_currencies-hwaer IS NOT INITIAL.
      <ls_invoice>-hwaer = ls_company_code_currencies-hwaer.
    ENDIF.

    IF <ls_invoice>-hwae2 IS INITIAL AND ls_company_code_currencies-hwae2 IS NOT INITIAL.
      <ls_invoice>-hwae2 = ls_company_code_currencies-hwae2.
    ENDIF.

    IF <ls_invoice>-hwae3 IS INITIAL AND ls_company_code_currencies-hwae3 IS NOT INITIAL.
      <ls_invoice>-hwae3 = ls_company_code_currencies-hwae3.
    ENDIF.

    MESSAGE i119(farr_application) INTO lv_msg
     WITH |{ 'POB ID' } { <ls_invoice>-pob_id } |  ##NEEDED ##MG_MISSING.


    go_message_handler->add_symessage( iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global
                                       iv_probcl   = if_shdb_pfw_logger=>c_probclass_high ).

  ENDLOOP.

ENDFORM.                    "set_currency_key

*&---------------------------------------------------------------------*
*&      Form  close_application_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM close_application_log.
  TRY.
      gv_log_handler = go_message_handler->get_log_handler( ).
      CALL METHOD go_message_handler->save_and_close_app_log( ).

      COMMIT WORK.
    CATCH cx_farr_message.
  ENDTRY.
ENDFORM.                    "close_application_log

*&---------------------------------------------------------------------*
*&      Form  display_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_result.
  DATA: lt_fieldcat  TYPE slis_t_fieldcat_alv,
        ls_fieldcat  TYPE slis_fieldcat_alv,
        lv_alv_title TYPE lvc_title.

  IF sy-batch = abap_false.
    PERFORM show_application_log.

    ls_fieldcat-fieldname = 'GUID'.
    ls_fieldcat-outputlen = 32.
    ls_fieldcat-seltext_m = 'GUID'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'COMPANY_CODE'.
    ls_fieldcat-outputlen = 4.
    ls_fieldcat-seltext_m = 'Company code'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'ACCT_PRINCIPLE'.
    ls_fieldcat-outputlen = 4.
    ls_fieldcat-seltext_m = 'Acc. Princ.'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'POB_ID'.
    ls_fieldcat-outputlen = 14.
    ls_fieldcat-seltext_m = 'POB ID'.
    APPEND ls_fieldcat TO lt_fieldcat.

    IF p_test IS INITIAL.
      ls_fieldcat-fieldname = 'WAERS'.
      ls_fieldcat-outputlen = 5.
      ls_fieldcat-seltext_m = 'Currency Key'.
      APPEND ls_fieldcat TO lt_fieldcat.

      ls_fieldcat-fieldname = 'HWAER'.
      ls_fieldcat-outputlen = 5.
      ls_fieldcat-seltext_m = 'Local currency'.
      APPEND ls_fieldcat TO lt_fieldcat.
    ENDIF.

    IF p_test IS NOT INITIAL.
      lv_alv_title = 'FARR_D_INVOICE entries without currency Key (Simulation Run)'.
    ELSE.
      lv_alv_title = 'FARR_D_INVOICE entries with updated currency Key (Productive Run)'.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat  = lt_fieldcat
        i_grid_title = lv_alv_title
      TABLES
        t_outtab     = gt_invoice_defect.
  ENDIF.
ENDFORM.                    "repair_one_contract

*&---------------------------------------------------------------------*
*&      Form  show_application_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_application_log.
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
ENDFORM.                    "show_application_log

*&---------------------------------------------------------------------*
*&      Form  initialize_global_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM initialize_global_parameters.
  DATA:
        lx_farr_message         TYPE REF TO cx_farr_message.

  CREATE OBJECT go_message_handler.
  TRY.
      CALL METHOD go_message_handler->initialize
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

ENDFORM.                    "initialize_global_parameters

*&---------------------------------------------------------------------*
*&      Form  SAVE_TO_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_to_db .

  DATA: lo_invoice_db_access TYPE REF TO if_farr_invoice_db_access.

  CREATE OBJECT lo_invoice_db_access TYPE cl_farr_invoice_db_access.
  TRY .
      IF  gt_invoice_defect IS NOT INITIAL.
        CALL METHOD lo_invoice_db_access->update_multiple
          EXPORTING
            it_invoice_data = gt_invoice_defect.
      ENDIF.

      COMMIT WORK.
    CATCH cx_farr_message.
      MESSAGE e000(farr_rai_check)
      WITH 'Fails to save to DB!'
      INTO gv_msg_str.

      CALL METHOD go_message_handler->add_symessage
        EXPORTING
          iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  ENDTRY.

  MESSAGE i000(fb) WITH 'Table FARR_D_INVOICE was updated' INTO gv_msg_str.

  CALL METHOD go_message_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
ENDFORM.                    " SAVE_TO
