REPORT zfarr_fix_recon_key_table.
*&---------------------------------------------------------------------*
*&Create missing recon key table entries
*&
*&---------------------------------------------------------------------*
TABLES: farr_d_contract.

DATA: go_message_handler TYPE REF TO cl_farr_message_handler,
      gv_log_handler     TYPE balloghndl,
      gv_counter         TYPE int4,
      gv_msg_str         TYPE string.

* for data selection
DATA: gt_contract_id       TYPE farr_tt_contract_id,
      gt_recon_key_missing TYPE farr_tt_recon_key.

*----------------------------------------------------------------------*
*              Selection Screen                                        *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE t_data.

  SELECT-OPTIONS:
  s_bukrs  FOR farr_d_contract-company_code OBLIGATORY,
  s_con    FOR farr_d_contract-contract_id,
  s_status FOR farr_d_contract-status.

SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK ctrl WITH FRAME TITLE t_ctrl.
  PARAMETERS: p_test   TYPE arch_processing_options-delete_testmode AS CHECKBOX  DEFAULT 'X',
              p_maxsel TYPE farr_pp_dblimit  DEFAULT 1000.
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
  %_s_status_%_app_%-text  = 'Status'.

  %_p_test_%_app_%-text  = 'Simulation'.
  %_p_maxsel_%_app_%-text  = 'Max. batch size of contracts'.

START-OF-SELECTION.
  PERFORM initialize_global_parameters.
  PERFORM start_of_work.

*&---------------------------------------------------------------------*
*&      Form  start_of_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM start_of_work.
  PERFORM  sel_contract_ids.

  PERFORM check_recon_key.

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
FORM sel_contract_ids.

* read invoice table entries
  SELECT contract_id
    INTO TABLE gt_contract_id
    FROM farr_d_contract
            WHERE  contract_id  IN s_con
            AND    company_code IN s_bukrs
            AND    status       IN s_status
            ORDER BY PRIMARY KEY.
ENDFORM.                    "sel_dupplicate_missing_mapping
*&---------------------------------------------------------------------*
*&      Form  add_select_counter_to_log.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_select_counter_to_log.
  MESSAGE i000(fb)
  WITH gv_counter
  'Number of missing FARR_D_RECON_KEY entries'
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
FORM check_recon_key.

* Selection Tables
  DATA: lts_contr_ids TYPE farr_ts_contract_id,
        lt_contr_sel  TYPE farr_tt_contract_id_range,
        ls_contr_sel  TYPE farr_s_contract_id_range.

* contract data
  DATA: lt_defitem_data    TYPE farr_tt_defitem_data,
        lts_defitem_data   TYPE farr_ts_defitem_data,
        lt_recon_key_data  TYPE farr_tt_recon_key,
        lts_recon_key_data TYPE farr_ts_recon_key,
        ls_recon_key_data  TYPE farr_s_recon_key.

  DATA: lo_persistency     TYPE REF TO if_farr_reconkey_persistency.

  DATA: lv_from_index TYPE farr_pp_dblimit,
        lv_to_index   TYPE farr_pp_dblimit,
        lv_batch_size TYPE farr_pp_dblimit VALUE 1000,
        lv_timestamp  TYPE timestamp.

  DATA(lo_defitem_db_access) = NEW cl_farr_defitem_db_access( ).
  DATA(lo_recon_key_db_access) = NEW cl_farr_recon_key_db_access( ).
* Field Symbols
  FIELD-SYMBOLS: <ls_contract_id>  TYPE farr_contract_id,
                 <ls_defitem_data> TYPE farr_s_defitem_data.

  GET TIME STAMP FIELD lv_timestamp.

  CLEAR: gt_recon_key_missing.

**********************************************************************
* Read Defitems,  Recon Keys
* Limit memory consumtion by batch spliting the contracts into lots of 1000
**********************************************************************
  " Set contract block size if passed
  IF p_maxsel IS NOT INITIAL.
    lv_batch_size = p_maxsel.
  ENDIF.
  " Set initial from-to index window
  lv_from_index = 1.
  lv_to_index = lv_batch_size.

  " Selection table for contracts
  ls_contr_sel-sign   = 'I'.
  ls_contr_sel-option = 'EQ'.
  LOOP AT gt_contract_id ASSIGNING <ls_contract_id> FROM lv_from_index TO lv_to_index.
    " Build selection tables for contracts
    ls_contr_sel-low = <ls_contract_id>.
    " Contract Range Table
    APPEND ls_contr_sel TO lt_contr_sel.
    " Contract ID table
    INSERT <ls_contract_id> INTO TABLE lts_contr_ids.
  ENDLOOP.

  WHILE lt_contr_sel IS NOT INITIAL
    AND lts_contr_ids IS NOT INITIAL.
    " Read contract batch data from DB

    " Read recon key data
    TRY.
        lo_recon_key_db_access->query_recon_key(
          EXPORTING
            it_contract_id_range = lt_contr_sel
          IMPORTING
            et_recon_key         = lt_recon_key_data ).
        " Sort data and insert into recon key buffer
        INSERT LINES OF lt_recon_key_data INTO TABLE lts_recon_key_data.
        CLEAR lt_recon_key_data.
      CATCH cx_farr_not_found .                         "#EC NO_HANDLER
    ENDTRY.

    TRY.
        lo_defitem_db_access->read_multiple_by_contract_id(
          EXPORTING
            its_contract_id  = lts_contr_ids    " Table type of POB Key
          IMPORTING
            et_defitem_data = lt_defitem_data ).    " Table Type Deferral item DB Access
        " Delete defitems for statistic condition types
        DELETE  lt_defitem_data WHERE statistic = abap_true.
        " Sort data and insert into defitem buffer
        INSERT LINES OF lt_defitem_data INTO TABLE lts_defitem_data.
        CLEAR lt_defitem_data.
      CATCH cx_farr_not_found.                          "#EC NO_HANDLER
    ENDTRY.

    LOOP AT lts_defitem_data ASSIGNING <ls_defitem_data>.
      READ TABLE lts_recon_key_data WITH KEY contract_id = <ls_defitem_data>-contract_id
                                             recon_key    = <ls_defitem_data>-recon_key
                                             TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        " Check if missing entry was already created
        READ TABLE gt_recon_key_missing WITH KEY contract_id = <ls_defitem_data>-contract_id
                                                 recon_key    = <ls_defitem_data>-recon_key
                                                 TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          CLEAR: ls_recon_key_data.
          ls_recon_key_data-contract_id     = <ls_defitem_data>-contract_id.
          ls_recon_key_data-company_code    = <ls_defitem_data>-company_code.
          ls_recon_key_data-acct_principle  = <ls_defitem_data>-acct_principle.
          .
          ls_recon_key_data-gjahr       =  <ls_defitem_data>-recon_key(4).
          ls_recon_key_data-poper       =  <ls_defitem_data>-recon_key+3(4).
          ls_recon_key_data-recon_key   =  <ls_defitem_data>-recon_key.

          ls_recon_key_data-status           = if_farrc_accrual_constants=>co_recon_key_status_open.
          ls_recon_key_data-keypp            = cl_farr_string_utility=>get_keypp_from_hash( iv_string = <ls_defitem_data>-contract_id ).
          ls_recon_key_data-created_by       = sy-uname.
          ls_recon_key_data-created_on       = lv_timestamp.
          ls_recon_key_data-last_changed_by  = sy-uname.
          ls_recon_key_data-last_changed_on  = lv_timestamp.

          APPEND ls_recon_key_data TO gt_recon_key_missing.
        ENDIF.
      ENDIF.

    ENDLOOP.

    " Set index from-to window to next batch
    lv_from_index = lv_from_index + lv_batch_size.
    lv_to_index   = lv_to_index   + lv_batch_size.

    " Clear selection table
    CLEAR: lt_contr_sel,
           lts_contr_ids.
    " Selection table for contracts
    ls_contr_sel-sign   = 'I'.
    ls_contr_sel-option = 'EQ'.
    " Build next contract ID selection batch
    LOOP AT gt_contract_id ASSIGNING <ls_contract_id> FROM lv_from_index TO lv_to_index.
      " Build selection tables for contracts
      ls_contr_sel-low = <ls_contract_id>.
      " Contract Range Table
      INSERT ls_contr_sel INTO TABLE lt_contr_sel.
      " Contract ID table
      INSERT <ls_contract_id> INTO TABLE lts_contr_ids.
    ENDLOOP.

  ENDWHILE. " WHILE LT_CONTR_SEL IS NOT INITIAL

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
*    PERFORM show_application_log.

    ls_fieldcat-fieldname = 'COMPANY_CODE'.
    ls_fieldcat-outputlen = 4.
    ls_fieldcat-seltext_m = 'COMPANY_CODE'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'ACCT_PRINCIPLE'.
    ls_fieldcat-outputlen = 4.
    ls_fieldcat-seltext_m = 'Acc. Princ.'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'CONTRACT_ID'.
    ls_fieldcat-outputlen = 14.
    ls_fieldcat-seltext_m = 'Contract ID'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'GJAHR'.
    ls_fieldcat-outputlen = 4.
    ls_fieldcat-seltext_m = 'Fiscal Year'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'POPER'.
    ls_fieldcat-outputlen = 3.
    ls_fieldcat-seltext_m = 'Posting Period'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'RECON_KEY'.
    ls_fieldcat-outputlen = 14.
    ls_fieldcat-seltext_m = 'Recon Key'.
    APPEND ls_fieldcat TO lt_fieldcat.

    IF p_test IS NOT INITIAL.
      lv_alv_title = 'Missiing Recon Key (Simulation Run)'.
    ELSE.
      lv_alv_title = 'Missiing Recon Key (Productive Run)'.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat  = lt_fieldcat
        i_grid_title = lv_alv_title
      TABLES
        t_outtab     = gt_recon_key_missing.
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

  DATA: lv_msg  TYPE string ##NEEDED.

  DATA: lo_reconkey_db_access TYPE  REF TO cl_farr_recon_key_db_access.

  CREATE OBJECT lo_reconkey_db_access TYPE cl_farr_recon_key_db_access.

  TRY .
      IF  gt_recon_key_missing IS NOT INITIAL.
        CALL METHOD lo_reconkey_db_access->insert_multi_recon_key
          EXPORTING
            it_recon_key = gt_recon_key_missing.
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

  MESSAGE i000(fb) WITH 'Table FARR_D_RECON_KEY was updated' INTO gv_msg_str.

  CALL METHOD go_message_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  DESCRIBE TABLE gt_recon_key_missing LINES gv_counter.

  PERFORM add_select_counter_to_log.

  LOOP AT gt_recon_key_missing ASSIGNING FIELD-SYMBOL(<ls_recon_key>).

    MESSAGE i119(farr_application) INTO lv_msg
     WITH | { <ls_recon_key>-contract_id } { <ls_recon_key>-recon_key } |  ##NEEDED ##MG_MISSING.

    go_message_handler->add_symessage( iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global
                                       iv_probcl   = if_shdb_pfw_logger=>c_probclass_high ).

  ENDLOOP.

ENDFORM.                    " SAVE_TO
