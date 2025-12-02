*&---------------------------------------------------------------------*
*& Report  ZFARR_CLEAR_INV_FX_ED
*&
*&---------------------------------------------------------------------*
*& clear is_calculated flag in invoices
*& clear current period in INV_FX_ED
*&---------------------------------------------------------------------*
REPORT  zfarr_clear_inv_fx_ed.

*TYPES: BEGIN OF s_ty_e14,
*  contract_id  TYPE farr_contract_id,
*  waers        TYPE waers,
*  hwaer        TYPE hwaer,
*  hwae2        TYPE hwae2,
*  hwae3        TYPE hwae3,
*  betrh        TYPE farr_amount_lc,
*  betr2        TYPE farr_amount_lc2,
*  betr3        TYPE farr_amount_lc3,
*  END OF s_ty_e14.
*TYPES: ts_ty_e14 TYPE SORTED TABLE OF s_ty_e14 WITH NON-UNIQUE KEY contract_id.

DATA: go_msg_handler          TYPE REF TO cl_farr_message_handler,
      go_recon_key_mgmt       TYPE REF TO if_farr_reconkey_mgt,
      gv_msg_str              TYPE string,
      gx_farr_message         TYPE REF TO cx_farr_message,
      gv_external_number      TYPE balhdr-extnumber,
      gv_log_handler          TYPE balloghndl,
      gv_contract_id          TYPE farr_contract_id,
      gts_contract_id         TYPE farr_ts_contract_id,
      gts_contract_id_failed  TYPE farr_ts_contract_id,
      gts_contract_id_success TYPE farr_ts_contract_id,
      gts_contract_data       TYPE farr_ts_contract_data,
      gts_contract_pob        TYPE farr_ts_contract_pob,
      gv_open_fiscal_year     TYPE gjahr,
      gv_open_period          TYPE poper.
*DATA: gts_contract_e14            TYPE ts_ty_e14.
*----------------------------------------------------------------------*
*             SELECTION SCREEN                                         *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE t_data.
  PARAMETER: p_bukrs TYPE bukrs OBLIGATORY.
  SELECT-OPTIONS:
  so_contr  FOR gv_contract_id NO INTERVALS.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t_ctrl.
  PARAMETER: p_pkg  TYPE i DEFAULT 100000 OBLIGATORY.
  PARAMETER: p_test TYPE boole_d DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
*              INITIALIZATION                                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  t_data  = 'Data selection'.
  t_ctrl  = 'Control'.
  %_so_contr_%_app_%-text     = 'Contract ID'.
  %_p_bukrs_%_app_%-text    = 'Company_code'.
  %_p_test_%_app_%-text     = 'Simulation'.
  %_p_pkg_%_app_%-text     = 'Package Size'.


START-OF-SELECTION.
  PERFORM initialize USING if_farrc_msg_handler_cons=>co_subobj_cleanup.

  PERFORM write_run_mode_log.

  PERFORM load_data.

  PERFORM work_on_package.

  PERFORM close_application_log.

  PERFORM display_result.

*&---------------------------------------------------------------------*
*&      Form  initialize
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_SUB_OBJ  TYPE  text
*      -->BALSUBOBJ        text
*----------------------------------------------------------------------*
FORM initialize    USING iv_sub_obj	TYPE balsubobj.

  TRY.

      go_msg_handler = cl_farr_message_handler=>get_instance( ).

      IF go_msg_handler IS INITIAL.
        MESSAGE x001(00) WITH 'Cannot open application log'.
      ENDIF.

      CALL FUNCTION 'BANK_API_PP_LOG_CREATE_LOGNO'
        IMPORTING
          e_lognumber = gv_external_number.

      go_msg_handler->initialize(
      EXPORTING
        iv_sub_obj = iv_sub_obj
        iv_ext_num = gv_external_number
        ).

      gv_log_handler = go_msg_handler->get_log_handler( ).

      IF gv_log_handler IS INITIAL.
        MESSAGE x001(00) WITH 'Cannot open application log'.
      ENDIF.

    CATCH cx_farr_message.
      MESSAGE x001(00) WITH 'Cannot open application log'.
  ENDTRY.


ENDFORM.                    "initialize

*&---------------------------------------------------------------------*
*&      Form  write_run_mode_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM write_run_mode_log.
  IF p_test = abap_true.
    MESSAGE s000(fb)
      WITH 'Testing Run (No DB Update)'
      INTO gv_msg_str.
  ELSE.
    MESSAGE s000(fb)
      WITH 'Production Run (DB will be Updated)'
      INTO gv_msg_str.
  ENDIF.

  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

ENDFORM.                    "write_run_mode_log

*&---------------------------------------------------------------------*
*&      Form  LOAD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM load_data .

  IF so_contr IS INITIAL AND p_bukrs IS INITIAL.
    WRITE:/, 'Please provide the Company Code or Contract ID List '.
    EXIT.
  ENDIF.

*  PERFORM select_err_contr_id.
ENDFORM.                    " LOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  add_log_end_of_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_log_end_of_work.
  DATA: lv_string TYPE string.
  FIELD-SYMBOLS:
                 <ls_contract_id> TYPE farr_contract_id.

  lv_string = lines( gts_contract_id_success ).
  MESSAGE i000(fb) WITH 'Clear INV&ED for ' lv_string 'contracts are succeed'  INTO gv_msg_str.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  MESSAGE i000(fb) WITH 'Following Contract ID are fixed: ' 'IS_CALCULATED cleared in FARR_D_INVOICE/' 'Amounts cleared in FARR_D_INV_FX_ED' INTO gv_msg_str.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  LOOP AT gts_contract_id_success ASSIGNING <ls_contract_id>.
    MESSAGE i000(fb) WITH 'Fix success' <ls_contract_id> INTO gv_msg_str.
    CALL METHOD go_msg_handler->add_symessage
      EXPORTING
        iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
        iv_ctx_value = <ls_contract_id>.
  ENDLOOP.

  lv_string = lines( gts_contract_id_failed ).
  MESSAGE i000(fb) WITH 'Clear INV&ED for ' lv_string 'contracts are failed'  INTO gv_msg_str.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  TRY .
      CALL METHOD go_msg_handler->save_app_log( ).

    CATCH cx_farr_message.
      WRITE:/, 'Application log error'.
  ENDTRY.
ENDFORM.                    "add_log_select_counter

*&---------------------------------------------------------------------*
*&      Form  lock_contract
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lock_contract.

  DATA:
    lv_user_id             TYPE xubname,
    lv_user_name           TYPE ad_namtext,
    lts_lock_fail_contract TYPE farr_ts_contract_id,
    lv_index_contract      TYPE sy-tabix,
    ls_contr_id_range      TYPE farr_s_contract_id_range,
    lv_msgv_contract_id    TYPE symsgv.

  FIELD-SYMBOLS:
         <ls_contract_data>      TYPE farr_s_contract_data.

  LOOP AT gts_contract_data ASSIGNING <ls_contract_data>.
    lv_index_contract = sy-tabix.

    CALL FUNCTION 'ENQUEUE_EFARR_D_CONTRACT'
      EXPORTING
        contract_id    = <ls_contract_data>-contract_id
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    CASE sy-subrc.
      WHEN 0.
        "lock success
      WHEN 1.
        lv_user_id   = sy-msgv1.
        lv_user_name = cl_farr_shmm=>get_user_name( lv_user_id ).
        lv_msgv_contract_id = cl_farr_contract_utility=>conversion_exit_alpha_output( <ls_contract_data>-contract_id ).

        " Contract &1 is locked by user &2 (&3)
        TRY.
            CALL METHOD go_msg_handler->add_message
              EXPORTING
                iv_msgid    = 'FARR_CONTRACT_MAIN'
                iv_msgno    = '041'
                iv_msgty    = 'E'
                iv_msgv1    = lv_msgv_contract_id
                iv_msgv2    = lv_user_id
                iv_msgv3    = lv_user_name
                iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
          CATCH cx_farr_message.
        ENDTRY.

        DELETE gts_contract_data INDEX lv_index_contract.

      WHEN OTHERS.
        "Error while locking contract &1
        lv_msgv_contract_id = cl_farr_contract_utility=>conversion_exit_alpha_output( <ls_contract_data>-contract_id ).

        TRY.
            CALL METHOD go_msg_handler->add_message
              EXPORTING
                iv_msgid    = 'FARR_CONTRACT_MAIN'
                iv_msgno    = '042'
                iv_msgty    = 'E'
                iv_msgv1    = lv_msgv_contract_id
                iv_msgv2    = lv_user_id
                iv_msgv3    = lv_user_name
                iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
          CATCH cx_farr_message.
        ENDTRY.

        DELETE gts_contract_data INDEX lv_index_contract.

    ENDCASE.

  ENDLOOP.
ENDFORM.                    "lock_contract

*&---------------------------------------------------------------------*
*&      Form  PREPARE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_data USING its_contract TYPE farr_ts_contract_id.
  DATA: lv_index_from         TYPE sytabix VALUE 1,
        lv_index_to           TYPE sytabix VALUE 1800,
        lt_inv_fx_ed_future   TYPE STANDARD TABLE OF farr_d_inv_fx_ed,
        lt_contract_id_range  TYPE farr_tt_contract_id_range,
        lv_fiscal_year_period TYPE farr_fiscal_year_period.
  FIELD-SYMBOLS:
    <ls_contract_id_range> TYPE farr_s_contract_id_range,
    <ls_inv_fx_ed>         TYPE farr_d_inv_fx_ed,
    <ls_contract_pob>      TYPE farr_s_contract_pob,
    <ls_contract_data>     TYPE farr_s_contract_data.

  IF its_contract IS INITIAL.
    MESSAGE i000(fb) WITH 'No Contract to be fixed' INTO gv_msg_str.
    CALL METHOD go_msg_handler->add_symessage
      EXPORTING
        iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
    EXIT.
  ENDIF.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gts_contract_data  ##TOO_MANY_ITAB_FIELDS
    FROM farr_d_contract
    FOR ALL ENTRIES IN its_contract
    WHERE contract_id  = its_contract-table_line.

  IF gts_contract_data IS NOT INITIAL.
    SELECT contract_id pob_id
      INTO CORRESPONDING FIELDS OF TABLE gts_contract_pob
      FROM farr_d_pob
      FOR ALL ENTRIES IN gts_contract_data
      WHERE contract_id = gts_contract_data-contract_id.

    READ TABLE gts_contract_data INDEX 1 ASSIGNING <ls_contract_data>.

    TRY .
        CALL METHOD cl_farr_accr_util=>get_period_close
          EXPORTING
            iv_company_code         = <ls_contract_data>-company_code
            iv_acct_principle       = <ls_contract_data>-acct_principle
          IMPORTING
            ev_fiscal_year_ra_close = gv_open_fiscal_year
            ev_period_ra_close      = gv_open_period.

      CATCH cx_farr_message.
        MESSAGE x000(fb) WITH 'Read first open period failed'.
    ENDTRY.

    CONCATENATE gv_open_fiscal_year gv_open_period INTO lv_fiscal_year_period.

    SELECT * FROM farr_d_inv_fx_ed AS inv_ed
      INNER JOIN farr_d_pob AS pob
      ON inv_ed~pob_id = pob~pob_id
      INTO CORRESPONDING FIELDS OF TABLE lt_inv_fx_ed_future
      FOR ALL ENTRIES IN gts_contract_data
      WHERE pob~contract_id = gts_contract_data-contract_id
      AND period > lv_fiscal_year_period.

    LOOP AT lt_inv_fx_ed_future ASSIGNING <ls_inv_fx_ed>.
      READ TABLE gts_contract_pob WITH KEY pob_id = <ls_inv_fx_ed>-pob_id
      ASSIGNING <ls_contract_pob>.
      IF sy-subrc = 0.
        READ TABLE gts_contract_data WITH TABLE KEY contract_id = <ls_contract_pob>-contract_id TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          DELETE gts_contract_data INDEX sy-tabix.

          MESSAGE e000(fb) WITH <ls_contract_pob>-contract_id ' has future entries in INV_FX_ED' ' Cannot be fixed' INTO gv_msg_str.
          CALL METHOD go_msg_handler->add_symessage
            EXPORTING
              iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
          INSERT <ls_contract_pob>-contract_id INTO TABLE gts_contract_id_failed.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.


  PERFORM lock_contract.

ENDFORM.                    " PREPARE_DATA
*&---------------------------------------------------------------------*
*&      Form  PREPARE_DEFITEM_POSTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM request_recon_key .
  DATA: lv_recon_key      TYPE farr_recon_key,
        lv_company_code   TYPE bukrs,
        lv_acct_principle TYPE accounting_principle,
        lv_index          TYPE sy-tabix.
  FIELD-SYMBOLS:
                 <ls_contract_data>   TYPE farr_s_contract_data.

  IF go_recon_key_mgmt IS NOT BOUND.
    CREATE OBJECT go_recon_key_mgmt TYPE cl_farr_recon_key_mgmt.
  ENDIF.

  LOOP AT gts_contract_data ASSIGNING <ls_contract_data>.
    lv_index = sy-tabix.
    AT FIRST.
      lv_company_code = <ls_contract_data>-company_code.
      lv_acct_principle = <ls_contract_data>-acct_principle.
    ENDAT.

    AT NEW contract_id.
      CLEAR lv_recon_key.
      IF <ls_contract_data>-lc_calc_method <> 'A'.
        MESSAGE w000(fb) WITH 'Cannot fix FX1 Contracts' <ls_contract_data>-contract_id INTO gv_msg_str.
        CALL METHOD go_msg_handler->add_symessage
          EXPORTING
            iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

        DELETE gts_contract_data INDEX lv_index.
        CONTINUE.
      ENDIF.

      IF <ls_contract_data>-company_code <> lv_company_code
        OR <ls_contract_data>-acct_principle <> lv_acct_principle.
        MESSAGE w000(fb) WITH 'Cannot fix contract in different' <ls_contract_data>-contract_id ' Company Code or accounting principle' INTO gv_msg_str.
        CALL METHOD go_msg_handler->add_symessage
          EXPORTING
            iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

        DELETE gts_contract_data INDEX lv_index.
        CONTINUE.
      ENDIF.

      IF p_test = abap_false.
        TRY .
            CALL METHOD go_recon_key_mgmt->get_recon_key_by_period
              EXPORTING
                iv_company_code   = <ls_contract_data>-company_code
                iv_acct_principle = <ls_contract_data>-acct_principle
                iv_contract_id    = <ls_contract_data>-contract_id
                iv_year           = gv_open_fiscal_year
                iv_period         = gv_open_period
                iv_simulate       = abap_false
              IMPORTING
                ev_recon_key      = lv_recon_key.

          CATCH cx_farr_message INTO gx_farr_message.
            TRY .
                CALL METHOD go_msg_handler->add_exception_msg
                  EXPORTING
                    ix_exception = gx_farr_message
                    iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
                    iv_ctx_value = <ls_contract_data>-contract_id.

              CATCH cx_farr_message.
                "Ignore messages
            ENDTRY.
            INSERT <ls_contract_data>-contract_id INTO TABLE gts_contract_id_failed.
            DELETE gts_contract_data INDEX lv_index.
            CONTINUE.
        ENDTRY.

      ENDIF.
    ENDAT.

    IF p_test = abap_false AND lv_recon_key IS INITIAL.
      INSERT <ls_contract_data>-contract_id INTO TABLE gts_contract_id_failed.
      DELETE gts_contract_data INDEX lv_index.
      CONTINUE.
    ENDIF.

    INSERT <ls_contract_data>-contract_id INTO TABLE gts_contract_id_success.
  ENDLOOP.

  IF p_test = abap_false.
    CALL METHOD go_recon_key_mgmt->save_all_contracts_to_db( ).
  ENDIF.
ENDFORM.                    " PREPARE_DEFITEM_POSTING_DATA
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_result .
  IF sy-batch = abap_false.
    PERFORM show_application_log.
  ENDIF.
ENDFORM.                    " DISPLAY_RESULT
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
*&      Form  insert_to_result_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM insert_to_result_table.
  TRY.
      IF gv_contract_id IS NOT INITIAL.
        INSERT gv_contract_id INTO TABLE gts_contract_id.
      ENDIF.
    CATCH cx_sy_itab_duplicate_key.
* just ignore duplicate key
  ENDTRY.
ENDFORM.                    "insert_to_result_table
*&---------------------------------------------------------------------*
*&      Form  WORK_ON_PACKAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM work_on_package .
  DATA: lv_index_from    TYPE sytabix VALUE 1,
        lv_index_to      TYPE sytabix,
        lv_contract_id   TYPE farr_contract_id,
        lts_contract_all TYPE farr_ts_contract_id,
        lts_contract_id  TYPE farr_ts_contract_id.
  FIELD-SYMBOLS:
        <ls_contr>                  TYPE farr_s_contract_id_range.

  lv_index_to = p_pkg.

  CLEAR lts_contract_all.
  SELECT contract_id
    INTO TABLE lts_contract_all  ##TOO_MANY_ITAB_FIELDS
    FROM farr_d_contract
    WHERE company_code = p_bukrs
      AND contract_id  IN so_contr
      AND lc_calc_method = if_farrc_contr_mgmt=>co_lc_calc_method_actual_rate
     ORDER BY contract_id.

  CLEAR lts_contract_id.
  LOOP AT lts_contract_all INTO lv_contract_id FROM lv_index_from TO lv_index_to.
    INSERT lv_contract_id INTO TABLE lts_contract_id.
  ENDLOOP.

  WHILE lts_contract_id IS NOT INITIAL.
    PERFORM work_on_single_package USING lts_contract_id.

    lv_index_from = lv_index_from + p_pkg.
    lv_index_to = lv_index_to + p_pkg.

    CLEAR lts_contract_id.
    LOOP AT lts_contract_all INTO lv_contract_id FROM lv_index_from TO lv_index_to.
      INSERT lv_contract_id INTO TABLE lts_contract_id.
    ENDLOOP.
  ENDWHILE.
ENDFORM.                    " WORK_ON_PACKAGE

*&---------------------------------------------------------------------*
*&      Form  work_on_single_package
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IT_POB_ID_RANGE  text
*----------------------------------------------------------------------*
FORM work_on_single_package USING its_contract TYPE farr_ts_contract_id.

  CLEAR gts_contract_data.

  PERFORM prepare_data USING its_contract.
  PERFORM request_recon_key.

  IF gts_contract_data IS NOT INITIAL.
    PERFORM clear_inv_fx_ed USING its_contract.
  ENDIF.

  PERFORM add_log_end_of_work.

  COMMIT WORK.

ENDFORM.                    "work_on_single_package

*&---------------------------------------------------------------------*
*&      Form  close_application_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM close_application_log.
  TRY.
      gv_log_handler = go_msg_handler->get_log_handler( ).
      CALL METHOD go_msg_handler->save_and_close_app_log( ).
      COMMIT WORK.
    CATCH cx_farr_message.
  ENDTRY.
ENDFORM.                    "close_application_log
*&---------------------------------------------------------------------*
*&      Form  CLEAR_INV_FX_ED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM clear_inv_fx_ed USING its_contract_e14 TYPE farr_ts_contract_id.
  DATA: lt_invoice            TYPE STANDARD TABLE OF farr_d_invoice,
        lt_inv_fx_ed          TYPE STANDARD TABLE OF farr_d_inv_fx_ed,
        lt_inv_fx_ed_i        TYPE STANDARD TABLE OF farr_d_inv_fx_ed,
        lt_inv_fx_ed_future   TYPE STANDARD TABLE OF farr_d_inv_fx_ed,
        ls_inv_fx_ed          TYPE farr_d_inv_fx_ed,
        ls_close              TYPE farr_c_close,
        lv_fiscal_year_period TYPE farr_fiscal_year_period.
  FIELD-SYMBOLS:
    <ls_invoice>       TYPE farr_d_invoice,
    <ls_inv_fx_ed>     TYPE farr_d_inv_fx_ed,
    <ls_contract_data> TYPE farr_s_contract_data,
    <ls_contract_pob>  TYPE farr_s_contract_pob,
    <ls_contract>      TYPE farr_contract_id.

  READ TABLE gts_contract_data ASSIGNING <ls_contract_data> INDEX 1.

  SELECT * FROM farr_d_invoice AS invoice
    INNER JOIN farr_d_pob AS pob
    ON invoice~pob_id = pob~pob_id
    INTO CORRESPONDING FIELDS OF TABLE lt_invoice
    FOR ALL ENTRIES IN gts_contract_data
    WHERE pob~contract_id = gts_contract_data-contract_id.

  LOOP AT lt_invoice ASSIGNING <ls_invoice> WHERE is_calculated = abap_true.
    CLEAR <ls_invoice>-is_calculated.
  ENDLOOP.

  CONCATENATE gv_open_fiscal_year gv_open_period INTO lv_fiscal_year_period.

  SELECT * FROM farr_d_inv_fx_ed AS inv_ed
    INNER JOIN farr_d_pob AS pob
    ON inv_ed~pob_id = pob~pob_id
    INTO CORRESPONDING FIELDS OF TABLE lt_inv_fx_ed
    FOR ALL ENTRIES IN gts_contract_data
    WHERE pob~contract_id = gts_contract_data-contract_id
    AND period = lv_fiscal_year_period.


  LOOP AT lt_inv_fx_ed ASSIGNING <ls_inv_fx_ed>.
    CLEAR <ls_inv_fx_ed>-betrw.
    CLEAR <ls_inv_fx_ed>-betrh.
    CLEAR <ls_inv_fx_ed>-betr2.
    CLEAR <ls_inv_fx_ed>-betr3.
    CLEAR <ls_inv_fx_ed>-due_lc.
    CLEAR <ls_inv_fx_ed>-due_lc2.
    CLEAR <ls_inv_fx_ed>-due_lc3.
    CLEAR <ls_inv_fx_ed>-exdf1.
    CLEAR <ls_inv_fx_ed>-exdf2.
    CLEAR <ls_inv_fx_ed>-exdf3.
  ENDLOOP.

  SORT lt_inv_fx_ed BY pob_id.

  CLEAR lt_inv_fx_ed_i.
  LOOP AT gts_contract_pob ASSIGNING <ls_contract_pob>.
    READ TABLE lt_inv_fx_ed WITH KEY pob_id = <ls_contract_pob>-pob_id BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      READ TABLE lt_invoice
        WITH KEY pob_id = <ls_contract_pob>-pob_id ASSIGNING <ls_invoice>.
      IF sy-subrc = 0.
        ls_inv_fx_ed-period = lv_fiscal_year_period.
        ls_inv_fx_ed-pob_id = <ls_contract_pob>-pob_id.
        ls_inv_fx_ed-waers  = <ls_invoice>-waers.
        ls_inv_fx_ed-hwaer  = <ls_invoice>-hwaer.
        ls_inv_fx_ed-hwae2  = <ls_invoice>-hwae2.
        ls_inv_fx_ed-hwae3  = <ls_invoice>-hwae3.
        INSERT ls_inv_fx_ed INTO TABLE lt_inv_fx_ed_i.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF p_test = abap_false.
    cl_farr_db_update=>update_multiple( it_update = lt_invoice
                                        iv_dbname = if_farrc_db_update=>co_farr_d_invoice ).

    cl_farr_db_update=>insert_multiple( it_insert = lt_inv_fx_ed_i
                                        iv_dbname = if_farrc_db_update=>co_farr_d_inv_fx_ed ).

    cl_farr_db_update=>update_multiple( it_update = lt_inv_fx_ed
                                        iv_dbname = if_farrc_db_update=>co_farr_d_inv_fx_ed ).
  ENDIF.
ENDFORM.                    " CLEAR_INV_FX_ED
