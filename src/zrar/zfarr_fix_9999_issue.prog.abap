*&---------------------------------------------------------------------*
*& Report ZFARR_FIX_9999_ISSUE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*

REPORT zfarr_fix_9999_issue.
*&---------------------------------------------------------------------*
*&Change POB end date of pob from 12/31/9999 to 12/31/2025 and
*& delete recon keys, defitems and fulfillment items in 2026 and later
*&---------------------------------------------------------------------*
TABLES: farr_d_contract.

DATA: go_message_handler TYPE REF TO cl_farr_message_handler,
      gv_log_handler     TYPE balloghndl,
      gv_counter         TYPE int4,
      gv_msg_str         TYPE string.

* for data selection
DATA: gt_contract_id       TYPE farr_tt_contract_id.

*----------------------------------------------------------------------*
*              Selection Screen                                        *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE t_data.

  SELECT-OPTIONS:
  s_bukrs  FOR farr_d_contract-company_code OBLIGATORY,
  s_con    FOR farr_d_contract-contract_id.

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
         trx_price   TYPE farr_transaction_price,
       END OF ty_s_result.

DATA:
  gi_fieldcat_pob TYPE slis_t_fieldcat_alv,
  gt_result       TYPE STANDARD TABLE OF ty_s_result.

*----------------------------------------------------------------------*
*              INITIALIZATION                                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  t_data = 'Data selection'.
  t_ctrl = 'Control'.

  %_s_bukrs_%_app_%-text   = 'Company Code'.
  %_s_con_%_app_%-text     = 'Contract'.

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

  PERFORM check_pob_end_date.

  IF p_test IS INITIAL.
    PERFORM update_db.
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
  'Number of POBs with end date in 9999'
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
FORM check_pob_end_date.

* Selection Tables
  DATA: lts_contr_ids TYPE farr_ts_contract_id,
        lt_contr_sel  TYPE farr_tt_contract_id_range,
        ls_contr_sel  TYPE farr_s_contract_id_range,
        ls_pob_key    TYPE farr_s_mapping_pob_key,
        ls_result     TYPE ty_s_result.

* contract data
  DATA: lt_defitem_data  TYPE farr_tt_defitem_data,
        lts_defitem_data TYPE farr_ts_defitem_data,
        lt_invoice_data  TYPE farr_tt_invoice_data,
        lt_pob_data      TYPE farr_tt_pob_data,
        lt_mapping_i     TYPE farr_tt_mapping_i,
        lt_pob_key       TYPE farr_tt_mapping_key,
        lt_mapping       TYPE farr_tt_mapping,
        lt_invoice_rai   TYPE STANDARD TABLE OF /1ra/0sd034mi.

  DATA: lo_persistency     TYPE REF TO if_farr_reconkey_persistency.

  DATA: lv_from_index    TYPE farr_pp_dblimit,
        lv_to_index      TYPE farr_pp_dblimit,
        lv_batch_size    TYPE farr_pp_dblimit VALUE 1000,
        lv_quantity      TYPE farr_quantity,
        lv_total_inv_qty TYPE farr_quantity,
        lv_no_invoice    TYPE boolean,
        lv_generated     TYPE boolean.

  DATA(lo_invoice_db_access) = NEW cl_farr_invoice_db_access( ).
  DATA(lo_pob_db_access)     = NEW cl_farr_pob_db_access( ).
  DATA(lo_rai_mapping_ctrl)  = NEW cl_farr_rai_mapping_ctrl( ).
  DATA(lo_recon_key_db_access) = NEW cl_farr_recon_key_db_access( ).
* Field Symbols
  FIELD-SYMBOLS: <ls_contract_id>  TYPE farr_contract_id,
                 <ls_pob_data>     TYPE farr_s_pob_data,
                 <ls_mapping>      TYPE farr_s_mapping,
                 <la_mapping_i>    TYPE farr_s_mapping_i,
                 <ls_invoice_data> TYPE farr_s_invoice_data,
                 <ls_invoice_rai>  TYPE /1ra/0sd034mi,
                 <ls_defitem_data> TYPE farr_s_defitem_data.

  CLEAR: gt_result.

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
    " Readpob data from pob
    TRY.
        lo_pob_db_access->read_multi_by_contracts(
            EXPORTING
              it_contract_id = lt_contr_sel
            IMPORTING
             et_pob_data     = lt_pob_data ).
      CATCH: cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_pob_data ASSIGNING <ls_pob_data>.

      IF <ls_pob_data>-end_date EQ '99991231'.               " '99991231'
        .        ls_result-pob_id        = <ls_pob_data>-pob_id.
        ls_result-contract_id   = <ls_pob_data>-contract_id.
        ls_result-trx_price     = <ls_pob_data>-trx_price.
        APPEND ls_result TO gt_result.
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

    ls_fieldcat-fieldname = 'CONTRACT_ID'.
    ls_fieldcat-outputlen = 14.
    ls_fieldcat-seltext_m = 'Contract ID'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'POB_ID'.
    ls_fieldcat-outputlen = 16.
    ls_fieldcat-seltext_m = 'POB ID'.
    APPEND ls_fieldcat TO lt_fieldcat.

    ls_fieldcat-fieldname = 'TRX_PRICE'.
    ls_fieldcat-outputlen = 25.
    ls_fieldcat-seltext_m = 'Transaction price'.
    APPEND ls_fieldcat TO lt_fieldcat.

    IF p_test IS NOT INITIAL.
      lv_alv_title = 'POBs with end date in 9999 (Simulation Run)'.
    ELSE.
      lv_alv_title = 'POB with end date in 9999 (Productive Run)'.
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat  = lt_fieldcat
        i_grid_title = lv_alv_title
      TABLES
        t_outtab     = gt_result.
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
FORM update_db .

  DATA: lv_msg         TYPE string ##NEEDED,
        lv_contract_id TYPE farr_contract_id.

  DATA: lt_contract_id      TYPE farr_tt_contract_id,
        lt_pob_id           TYPE farr_tt_pob_id,
        lt_recon_key        TYPE farr_tt_reconkey_db,
        lt_reconkey_del     TYPE farr_tt_reconkey_db,
        lt_recon_key_sel    TYPE farr_tt_sel_recon_key,
        ls_recon_key_sel    LIKE LINE OF lt_recon_key_sel,
        ls_recon_key        TYPE farr_s_reconkey_db,
        lt_fulfill_data     TYPE farr_tt_fulfillment_db,
        lt_fulfill_data_del TYPE farr_tt_fulfillment_db,
        ls_fulfill_data     TYPE farr_s_fulfillment_db,
        lt_defitem_data     TYPE farr_tt_defitem_db,
        lt_defitem_data_del TYPE farr_tt_defitem_db,
        lt_defitem_data_upd TYPE farr_tt_defitem_db,
        ls_defitem_data     TYPE farr_s_defitem_db.

  DATA(lo_recon_key_persistency)  = cl_farr_reconkey_persistency=>create( ).
  DATA(lo_farr_fulfillmt_persistency) = cl_farr_fulfillmt_persistency=>create( ).
  DATA(lo_defitem_persistency)    = cl_farr_defitem_persistency=>create( ).

  CLEAR: lt_recon_key_sel.

  ls_recon_key_sel-sign = 'I'.
  ls_recon_key_sel-option = 'GE'.
  ls_recon_key_sel-low    = '20260010000101'.

  APPEND ls_recon_key_sel TO lt_recon_key_sel.
  LOOP AT gt_result ASSIGNING FIELD-SYMBOL(<ls_result>).

    IF lv_contract_id NE <ls_result>-contract_id.
      lv_contract_id = <ls_result>-contract_id.

      DELETE FROM  farr_d_recon_key
           WHERE contract_id  = <ls_result>-contract_id
           AND recon_key     IN lt_recon_key_sel.

    ENDIF.

    DELETE FROM farr_d_fulfillmt
         WHERE pob_id  = <ls_result>-pob_id
         AND recon_key IN lt_recon_key_sel.

    CLEAR: lt_pob_id.
    APPEND <ls_result>-pob_id TO lt_pob_id.

    lo_defitem_persistency->load( it_pob_id = lt_pob_id ).

    lt_defitem_data = lo_defitem_persistency->if_farr_defitem_persistency~read( iv_pob_id = <ls_result>-pob_id ).

    LOOP AT lt_defitem_data INTO ls_defitem_data WHERE latest_defitem EQ abap_true.
      ls_defitem_data-recon_key = '20250120000101'.
      APPEND ls_defitem_data TO lt_defitem_data_upd.
    ENDLOOP.

    DELETE FROM farr_d_defitem
         WHERE recon_key IN lt_recon_key_sel
         AND pob_id      = <ls_result>-pob_id
         AND contract_id = <ls_result>-contract_id.

    UPDATE farr_d_pob SET end_date = '20251231'
      WHERE pob_id = <ls_result>-pob_id .

    UPDATE farr_d_defitem FROM TABLE lt_defitem_data_upd.

*     MODIFY farr_d_pob FROM @( VALUE #( pob_id = <ls_result>-pob_id  end_date = '20251231' ) ).

  ENDLOOP.

  MESSAGE i000(fb) WITH 'Table FARR_D_RECON_KEY was updated' INTO gv_msg_str.

  CALL METHOD go_message_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  DESCRIBE TABLE gt_result LINES gv_counter.

  PERFORM add_select_counter_to_log.

  LOOP AT gt_result ASSIGNING <ls_result>.

    MESSAGE i119(farr_application) INTO lv_msg
     WITH | { <ls_result>-contract_id } { <ls_result>-pob_id } |  ##NEEDED ##MG_MISSING.

    go_message_handler->add_symessage( iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global
                                       iv_probcl   = if_shdb_pfw_logger=>c_probclass_high ).

  ENDLOOP.

  COMMIT WORK.

ENDFORM.                    " SAVE_TO
