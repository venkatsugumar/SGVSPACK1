*&---------------------------------------------------------------------*
*& Report ZFARR_FIX_RV_NOT_IN_POST_FX2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfarr_fix_rv_not_in_post_fx2.

TYPES: BEGIN OF ty_s_rev_delta,
         company_code    TYPE bukrs,
         contract_id     TYPE farr_contract_id,
         pob_id          TYPE farr_pob_id,
         condition_type  TYPE kscha,
         rev_amt_delta   TYPE farr_amount_tc,
         rev_amt_catchup TYPE farr_amount_tc,
         post_betrw      TYPE farr_amount_tc,
         defitem_betrw   TYPE farr_amount_tc,
         delta_betrw     TYPE farr_amount_tc,
         waers           TYPE waers,
       END OF ty_s_rev_delta.

TYPES: ty_ts_rev_delta TYPE SORTED TABLE OF ty_s_rev_delta
       WITH UNIQUE KEY company_code
                       contract_id
                       pob_id
                       condition_type.

TYPES : BEGIN OF ys_lc_calc_method,
          contract_id    TYPE farr_contract_id,
          pob_id         TYPE farr_pob_id,
          lc_calc_method TYPE farr_lc_calc_method,
        END OF ys_lc_calc_method.

TYPES : yt_lc_calc_method TYPE STANDARD TABLE OF ys_lc_calc_method.

DATA: go_msg_handler          TYPE REF TO cl_farr_message_handler,
      go_recon_key_mgmt       TYPE REF TO if_farr_reconkey_mgt,
      gv_msg_str              TYPE string,
      gx_farr_message         TYPE REF TO cx_farr_message,
      gv_external_number      TYPE balhdr-extnumber,
      gv_log_handler          TYPE balloghndl,
      gv_pob_id               TYPE farr_pob_id,
      gv_contract_id          TYPE farr_contract_id,
      gts_pob_id              TYPE farr_ts_pob_id,
      gt_pob_id_range         TYPE farr_tt_pob_id_range,
      gts_rev_delta           TYPE ty_ts_rev_delta,
      gts_rev_delta_success   TYPE ty_ts_rev_delta,
      gts_rev_delta_failed    TYPE ty_ts_rev_delta,
      gt_defitem_posting_data TYPE farr_tt_defitem_posting_data,
      gt_posting_data         TYPE farr_tt_posting_data,
      go_rai_selection        TYPE REF TO cl_farr_rai_selection,
      gts_contract_data       TYPE farr_ts_contract_data,
      gts_pob_new_data        TYPE farr_ts_pob_posting_data,
      gts_pob_data_fx2        TYPE farr_ts_pob_data_rev_transfer,
      gts_contr_ex_rates      TYPE farr_ts_contract_ex_rates,
      gts_contract_fx2        TYPE farr_ts_cont_data_rev_transfer,
      gt_defitem              TYPE farr_tt_defitem,
      gv_company_code         TYPE bukrs,
      gv_open_fiscal_year     TYPE gjahr,
      gv_open_period          TYPE poper,
      p_size                  TYPE i VALUE 1800.

*----------------------------------------------------------------------*
*             SELECTION SCREEN                                         *
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE t_data.
  PARAMETER: p_bukrs TYPE bukrs OBLIGATORY.
  PARAMETER: p_accpr TYPE accounting_principle OBLIGATORY.
  SELECT-OPTIONS:
  so_contr  FOR gv_contract_id,
  so_pob  FOR gv_pob_id.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t_ctrl.
  PARAMETER: p_test TYPE boole_d DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b1.


*----------------------------------------------------------------------*
*              INITIALIZATION                                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  t_data  = 'Data selection'.
  t_ctrl  = 'Control'.
  %_so_pob_%_app_%-text     = 'Performance Obligation'.
  %_so_contr_%_app_%-text   = 'Contract'.
  %_p_bukrs_%_app_%-text    = 'Company_code'.
  %_p_accpr_%_app_%-text    = 'Accounting_principle'.
  %_p_test_%_app_%-text     = 'Simulation'.


AT SELECTION-SCREEN.

  IF so_pob IS INITIAL AND so_contr IS INITIAL.
    MESSAGE e000(fb)
      WITH 'Please specify contract or POB selection'.
  ENDIF.


START-OF-SELECTION.
  PERFORM initialize USING if_farrc_msg_handler_cons=>co_subobj_cleanup.

  PERFORM write_run_mode_log.

  PERFORM load_data.

  IF gts_rev_delta IS NOT INITIAL.
    PERFORM fix_rv_not_in_posting.
  ENDIF.

  PERFORM add_log_end_of_work.

  PERFORM display_result.

*&---------------------------------------------------------------------*
*&      Form  initialize
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IV_SUB_OBJ  TYPE  text
*      -->BALSUBOBJ        text
*----------------------------------------------------------------------*
FORM initialize    USING iv_sub_obj  TYPE balsubobj.

  TRY.
      go_rai_selection = cl_farr_rai_selection=>get_instance( ).

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

  gt_pob_id_range      = so_pob[].

  IF p_bukrs IS INITIAL AND p_accpr IS INITIAL.
    WRITE:/, 'Please provide the Company Code and Accounting Principle '.
    EXIT.
  ENDIF.

  PERFORM select_err_pob_id.

  PERFORM determine_rev_delta_posting CHANGING gts_rev_delta.

  PERFORM prepare_data.
  PERFORM prepare_defitem_posting_data.

ENDFORM.                    " LOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  add_log_end_of_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_log_end_of_work.
  DATA: lv_string TYPE string.
  FIELD-SYMBOLS:
    <ls_rev_delta>    TYPE ty_s_rev_delta,
    <ls_posting_data> TYPE farr_s_posting_data.

  lv_string = lines( gts_rev_delta_success ).
  MESSAGE i000(fb) WITH 'Fix Revenue not transfer to Posting entries' lv_string 'are succeed'  INTO gv_msg_str.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  MESSAGE i000(fb) WITH 'Following Posting Entries are successfully' 'inserted into Posting Table' INTO gv_msg_str.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  LOOP AT gt_posting_data ASSIGNING <ls_posting_data>.
    CHECK <ls_posting_data>-post_cat = if_farrc_contr_mgmt=>co_post_cat_receivable_adjust.
    MESSAGE i000(fb) WITH <ls_posting_data>-guid <ls_posting_data>-pob_id <ls_posting_data>-condition_type <ls_posting_data>-betrw INTO gv_msg_str.
    CALL METHOD go_msg_handler->add_symessage
      EXPORTING
        iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_pob_id
        iv_ctx_value = <ls_posting_data>-pob_id.
  ENDLOOP.

  lv_string = lines( gts_rev_delta_failed ).
  MESSAGE i000(fb) WITH 'Fix Revenue not transfer to Posting entries' lv_string 'are failed'  INTO gv_msg_str.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  LOOP AT gts_rev_delta_failed ASSIGNING <ls_rev_delta>.
    MESSAGE e000(fb) WITH 'Fix rev failed' <ls_rev_delta>-pob_id <ls_rev_delta>-condition_type <ls_rev_delta>-delta_betrw INTO gv_msg_str.
    CALL METHOD go_msg_handler->add_symessage
      EXPORTING
        iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_pob_id
        iv_ctx_value = <ls_rev_delta>-pob_id.

  ENDLOOP.

  TRY .
      CALL METHOD go_msg_handler->save_and_close_app_log( ).

    CATCH cx_farr_message.
      WRITE:/, 'Application log error'.
  ENDTRY.
  COMMIT WORK.
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
*&      Form  determine_rev_delta_posting
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--CTS_INVOICE_POSTING  text
*----------------------------------------------------------------------*
FORM determine_rev_delta_posting CHANGING cts_rev_delta   TYPE ty_ts_rev_delta.

  DATA: lv_index_from     TYPE sytabix VALUE 1,
        lv_index_to       TYPE sytabix VALUE 1800,
        lt_pob_id_range   TYPE farr_tt_pob_id_range,
        lts_rev_delta     LIKE cts_rev_delta,
        lt_lc_calc_method TYPE yt_lc_calc_method,
        lt_contract_id    TYPE STANDARD TABLE OF farr_contract_id.

  FIELD-SYMBOLS: <ls_rev_delta>      LIKE LINE OF cts_rev_delta,
                 <cs_rev_delta>      LIKE LINE OF cts_rev_delta,
                 <ls_pob_id_range>   TYPE farr_s_pob_id_range,
                 <ls_lc_calc_method> TYPE ys_lc_calc_method,
                 <lv_contract_id>    TYPE farr_contract_id.

  CLEAR lt_pob_id_range.
  LOOP AT so_pob ASSIGNING <ls_pob_id_range> FROM lv_index_from TO lv_index_to.
    APPEND <ls_pob_id_range> TO lt_pob_id_range.
  ENDLOOP.

  WHILE lt_pob_id_range IS NOT INITIAL.

    " --1. VALIDATE THAT POBs ARE FX2
    " Load LC_CALC_METHOD
    CLEAR : lt_lc_calc_method.
    SELECT p~contract_id
           p~pob_id
           c~lc_calc_method

    INTO CORRESPONDING FIELDS OF TABLE lt_lc_calc_method ##TOO_MANY_ITAB_FIELDS
    FROM farr_d_pob AS p
    INNER JOIN farr_d_contract AS c
      ON p~contract_id = c~contract_id
    WHERE p~pob_id IN lt_pob_id_range.

    " Delete FX1 POBs + remember FX1 contract IDs
    CLEAR : lt_contract_id.
    LOOP AT lt_lc_calc_method ASSIGNING <ls_lc_calc_method>
      WHERE lc_calc_method IS INITIAL.

      INSERT <ls_lc_calc_method>-contract_id INTO TABLE lt_contract_id.
      DELETE lt_pob_id_range WHERE low = <ls_lc_calc_method>-pob_id.

    ENDLOOP.

    " Report FX1 contract IDs
    IF lt_contract_id IS NOT INITIAL.

      SORT lt_contract_id BY table_line.
      DELETE ADJACENT DUPLICATES FROM lt_contract_id.

      LOOP AT lt_contract_id ASSIGNING <lv_contract_id>.

        MESSAGE w000(fb) WITH
        'Contract cannot be processed '
        <lv_contract_id> ' - The contract calculates LC via FX1'
        INTO gv_msg_str.

        CALL METHOD go_msg_handler->add_symessage
          EXPORTING
            iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

      ENDLOOP.

    ENDIF.

    IF lt_pob_id_range IS NOT INITIAL.
      CLEAR lts_rev_delta.
      SELECT
           d~company_code
           d~contract_id
           d~pob_id
           d~condition_type
           SUM( d~betrw ) AS post_betrw
           d~waers
      INTO CORRESPONDING FIELDS OF TABLE lts_rev_delta ##TOO_MANY_ITAB_FIELDS

      FROM farr_d_posting AS d
      INNER JOIN farr_d_recon_key AS r
        ON d~recon_key = r~recon_key
       AND d~contract_id = r~contract_id

      WHERE d~pob_id IN lt_pob_id_range
        AND d~post_cat = if_farrc_contr_mgmt=>co_post_cat_revenue
        AND d~company_code = p_bukrs
        AND d~acct_principle = p_accpr
        AND ( r~status = 'C' OR r~status = 'S' OR r~status = 'P' ) " Skip R - shifted reconciliation keys

      GROUP BY d~company_code
               d~contract_id
               d~pob_id
               d~condition_type
               d~waers.

      LOOP AT lts_rev_delta ASSIGNING <ls_rev_delta>.
        READ TABLE cts_rev_delta ASSIGNING <cs_rev_delta>
          WITH TABLE KEY company_code   = <ls_rev_delta>-company_code
                         contract_id    = <ls_rev_delta>-contract_id
                         pob_id         = <ls_rev_delta>-pob_id
                         condition_type = <ls_rev_delta>-condition_type.
        IF sy-subrc = 0.
          <cs_rev_delta>-post_betrw = <ls_rev_delta>-post_betrw.
        ELSE.
          INSERT <ls_rev_delta> INTO TABLE cts_rev_delta.
        ENDIF.
      ENDLOOP.

      CLEAR lts_rev_delta.

      SELECT d~company_code
           b~contract_id
           d~pob_id
           condition_type
           SUM( rev_amt_delta ) AS rev_amt_delta
           SUM( rev_amt_catchup ) AS rev_amt_catchup
           amount_curk AS waers
      INTO CORRESPONDING FIELDS OF TABLE lts_rev_delta ##TOO_MANY_ITAB_FIELDS
      FROM farr_d_defitem AS d
        INNER JOIN farr_d_recon_key AS k
        ON d~contract_id = k~contract_id
        AND d~recon_key = k~recon_key
        INNER JOIN farr_d_pob AS b
        ON d~pob_id = b~pob_id
      WHERE d~pob_id IN lt_pob_id_range
*        and ( k~status <> 'O' or ( b~contract_id <> k~contract_id ) )
        AND ( ( k~status = 'C' OR k~status = 'S' OR k~status = 'P' OR k~status = 'R' ) OR ( b~contract_id <> k~contract_id ) )
        AND d~category = if_farrc_contr_mgmt=>co_category_price
        AND d~company_code = p_bukrs
        AND d~acct_principle = p_accpr
      GROUP BY d~company_code
               b~contract_id
               d~pob_id
               condition_type
               amount_curk.

      LOOP AT lts_rev_delta ASSIGNING <ls_rev_delta>.
        <ls_rev_delta>-defitem_betrw = <ls_rev_delta>-rev_amt_catchup + <ls_rev_delta>-rev_amt_delta.
        READ TABLE cts_rev_delta ASSIGNING <cs_rev_delta>
          WITH TABLE KEY company_code   = <ls_rev_delta>-company_code
                         contract_id    = <ls_rev_delta>-contract_id
                         pob_id         = <ls_rev_delta>-pob_id
                         condition_type = <ls_rev_delta>-condition_type.
        IF sy-subrc = 0.
          <cs_rev_delta>-defitem_betrw = <ls_rev_delta>-defitem_betrw.
        ELSE.
          INSERT <ls_rev_delta> INTO TABLE cts_rev_delta.
        ENDIF.
      ENDLOOP.
    ENDIF.

    lv_index_from = lv_index_from + p_size.
    lv_index_to = lv_index_to + p_size.
    CLEAR lt_pob_id_range.
    LOOP AT so_pob ASSIGNING <ls_pob_id_range> FROM lv_index_from TO lv_index_to.
      APPEND <ls_pob_id_range> TO lt_pob_id_range.
    ENDLOOP.

  ENDWHILE.

ENDFORM.                    "determine_rev_delta_posting

*&---------------------------------------------------------------------*
*&      Form  FIX_IC_LOCA_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fix_rv_not_in_posting .
  DATA: lv_str                   TYPE string,
        lt_failed_contract       TYPE farr_tt_contract_id,
        lts_time_material_pob_id TYPE farr_ts_pob_id,
        lt_acct_principle        TYPE farr_tt_acct_principle,
        ls_acct_principle        LIKE LINE OF lt_acct_principle,
        lt_bukrs                 TYPE farr_tt_sel_company_code,
        ls_bukrs                 LIKE LINE OF lt_bukrs,
        lo_posting_mgmt          TYPE REF TO if_farr_posting_mgmt,
        lo_invoice_agent         TYPE REF TO cl_farr_invoice_agent,
        lo_fx_mgmt               TYPE REF TO if_farr_fx_mgmt.
  FIELD-SYMBOLS:
    <ls_contract_id> TYPE farr_contract_id,
    <ls_rev_delta>   TYPE ty_s_rev_delta.

  CREATE OBJECT lo_posting_mgmt TYPE cl_farr_posting_mgmt
    EXPORTING
      io_msg_handler = go_msg_handler.

  CREATE OBJECT lo_invoice_agent.

  CALL METHOD cl_farr_fnd_cust_db_access=>read_acct_principles
    IMPORTING
      et_acct_principles = lt_acct_principle.

  READ TABLE lt_acct_principle INTO ls_acct_principle WITH KEY acct_principle = p_accpr.
  ls_bukrs-sign = if_farrc_accrual_constants=>co_range_sign_inclusive.
  ls_bukrs-option = if_farrc_accrual_constants=>co_range_option_equal.
  ls_bukrs-low    = p_bukrs.
  APPEND ls_bukrs TO lt_bukrs.
  CREATE OBJECT lo_fx_mgmt TYPE cl_farr_fx_mgmt
    EXPORTING
      io_invoice_agent      = lo_invoice_agent
      io_msg_handler        = go_msg_handler
      it_company_code_range = lt_bukrs
      iv_acct_principle     = p_accpr
      iv_fiscal_year        = gv_open_fiscal_year
      iv_period             = gv_open_period
      iv_liab_method        = ls_acct_principle-liab_method.

*Call posting correction interface
  CLEAR gt_posting_data.
  TRY .
      CALL METHOD lo_fx_mgmt->calculate_exdf(
        EXPORTING
          its_contract_data = gts_contract_fx2
          its_pob_data      = gts_pob_data_fx2
      ).
      CALL METHOD lo_posting_mgmt->process_posting_for_revenue_f2
        EXPORTING
          io_fx_mgmt               = lo_fx_mgmt
          it_defitem_posting_data  = gt_defitem_posting_data
          its_pob_posting_data     = gts_pob_new_data
          its_contract_ex_rates    = gts_contr_ex_rates
          its_time_material_pob_id = lts_time_material_pob_id
        IMPORTING
          et_posting_data          = gt_posting_data.

      CALL METHOD go_msg_handler->get_error_contract_list
        IMPORTING
          et_contract_list = lt_failed_contract.

      SORT lt_failed_contract BY table_line.
      LOOP AT gts_rev_delta_success ASSIGNING <ls_rev_delta>.
        READ TABLE lt_failed_contract WITH KEY table_line = <ls_rev_delta>-contract_id
          TRANSPORTING NO FIELDS BINARY SEARCH.
        IF sy-subrc = 0.
          INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_failed.
          DELETE gts_rev_delta_success WHERE contract_id =  <ls_rev_delta>-contract_id.
        ENDIF.
      ENDLOOP.

      LOOP AT lt_failed_contract ASSIGNING <ls_contract_id>.
        CALL METHOD go_recon_key_mgmt->refresh_buffer_table
          EXPORTING
            iv_contract_id = <ls_contract_id>.
      ENDLOOP.

      IF p_test = abap_false.
        go_recon_key_mgmt->save_all_contracts_to_db( ).
        lo_posting_mgmt->save_to_db( ).
        lo_fx_mgmt->save_to_db( ).
        COMMIT WORK.
      ELSE.
        ROLLBACK WORK.
      ENDIF.

    CATCH cx_farr_message INTO gx_farr_message.
      TRY .
          CALL METHOD go_msg_handler->add_exception_msg
            EXPORTING
              ix_exception = gx_farr_message
              iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_global.

        CATCH cx_farr_message.
          "Ignore messages
      ENDTRY.
      INSERT LINES OF gts_rev_delta_success INTO TABLE gts_rev_delta_failed.
      CLEAR gts_rev_delta_success.
  ENDTRY.

ENDFORM.                    "fix_ic_loca_amount

*&---------------------------------------------------------------------*
*&      Form  PREPARE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_data .
  DATA:
    lts_rev_delta_no_latest TYPE ty_ts_rev_delta,
    lt_defitem_no_latest    TYPE STANDARD TABLE OF farr_d_defitem.
  FIELD-SYMBOLS:
    <ls_rev_delta> TYPE ty_s_rev_delta,
    <ls_defitem>   TYPE farr_d_defitem.

  LOOP AT gts_rev_delta ASSIGNING <ls_rev_delta>.
    <ls_rev_delta>-delta_betrw = <ls_rev_delta>-defitem_betrw + <ls_rev_delta>-post_betrw.
  ENDLOOP.

  DELETE gts_rev_delta WHERE delta_betrw = 0.

  IF gts_rev_delta IS INITIAL.
    MESSAGE i000(fb) WITH 'No difference to be fixed' INTO gv_msg_str.
    CALL METHOD go_msg_handler->add_symessage
      EXPORTING
        iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
    EXIT.
  ENDIF.

  SELECT DISTINCT *
    INTO CORRESPONDING FIELDS OF TABLE gts_contract_data  ##TOO_MANY_ITAB_FIELDS
    FROM farr_d_contract
    FOR ALL ENTRIES IN gts_rev_delta
    WHERE contract_id = gts_rev_delta-contract_id.

  PERFORM lock_contract.

  SELECT DISTINCT *
    INTO CORRESPONDING FIELDS OF TABLE gts_pob_new_data   ##TOO_MANY_ITAB_FIELDS
    FROM farr_d_pob
    FOR ALL ENTRIES IN gts_rev_delta
    WHERE pob_id      = gts_rev_delta-pob_id.

  SELECT DISTINCT *
    INTO CORRESPONDING FIELDS OF TABLE gts_pob_data_fx2   ##TOO_MANY_ITAB_FIELDS
    FROM farr_d_pob
    FOR ALL ENTRIES IN gts_rev_delta
    WHERE contract_id = gts_rev_delta-contract_id.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_defitem
    FROM farr_d_defitem
    FOR ALL ENTRIES IN gts_rev_delta
    WHERE pob_id = gts_rev_delta-pob_id
    AND condition_type = gts_rev_delta-condition_type
    AND latest_defitem = abap_true.
  SORT gt_defitem BY contract_id pob_id condition_type.

  CLEAR lts_rev_delta_no_latest.
  LOOP AT gts_rev_delta ASSIGNING <ls_rev_delta>.
    READ TABLE gt_defitem ASSIGNING <ls_defitem>
      WITH KEY contract_id = <ls_rev_delta>-contract_id pob_id = <ls_rev_delta>-pob_id condition_type = <ls_rev_delta>-condition_type BINARY SEARCH.
    IF sy-subrc <> 0.
      "DEFITEM has no latest defitem entries, need get MAX recon key defiem.
      INSERT <ls_rev_delta> INTO TABLE lts_rev_delta_no_latest.
    ELSE.
      IF <ls_rev_delta>-contract_id <> <ls_defitem>-contract_id.
        "Compare legacy entries.
        INSERT <ls_rev_delta> INTO TABLE lts_rev_delta_no_latest.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lts_rev_delta_no_latest IS NOT INITIAL.
    SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_defitem_no_latest
    FROM farr_d_defitem
    FOR ALL ENTRIES IN lts_rev_delta_no_latest
    WHERE
      contract_id = lts_rev_delta_no_latest-contract_id
      AND pob_id = lts_rev_delta_no_latest-pob_id
      AND condition_type = lts_rev_delta_no_latest-condition_type
      AND recon_key IN (
      SELECT MAX( recon_key ) FROM farr_d_defitem
        WHERE
          contract_id = lts_rev_delta_no_latest-contract_id
          AND pob_id = lts_rev_delta_no_latest-pob_id
          AND condition_type = lts_rev_delta_no_latest-condition_type
      ).

    SORT lt_defitem_no_latest BY contract_id pob_id condition_type recon_key DESCENDING.
    DELETE ADJACENT DUPLICATES FROM lt_defitem_no_latest COMPARING contract_id pob_id condition_type.

    APPEND LINES OF lt_defitem_no_latest TO gt_defitem.
    SORT gt_defitem BY contract_id pob_id condition_type.
  ENDIF.

  CLEAR gts_rev_delta_failed.
  CLEAR gts_rev_delta_success.

ENDFORM.                    " PREPARE_DATA
*&---------------------------------------------------------------------*
*&      Form  PREPARE_DEFITEM_POSTING_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM prepare_defitem_posting_data .
  DATA: ls_currencies           TYPE farr_s_cocd_local_currency,
        ls_defitem_posting_data TYPE farr_s_defitem_posting_data,
        ls_contr_ex_rates       TYPE farr_s_contract_ex_rates,
        ls_contract_fx2         TYPE farr_s_cont_data_rev_transfer,
        lv_recon_key            TYPE farr_recon_key.
  FIELD-SYMBOLS:
    <ls_rev_delta>        TYPE ty_s_rev_delta,
    <ls_invoice_total>    TYPE farr_d_invoice,
    <ls_contract_data>    TYPE farr_s_contract_data,
    <ls_defitem>          TYPE farr_d_defitem,
    <ls_pob_posting_data> TYPE farr_s_pob_posting_data.

  CLEAR gt_defitem_posting_data.
  CLEAR gts_contr_ex_rates.

  IF go_recon_key_mgmt IS NOT BOUND.
    CREATE OBJECT go_recon_key_mgmt TYPE cl_farr_recon_key_mgmt.
  ENDIF.

  LOOP AT gts_rev_delta ASSIGNING <ls_rev_delta>.

    AT NEW contract_id.
      CLEAR lv_recon_key.
      READ TABLE gts_contract_data
        WITH TABLE KEY contract_id = <ls_rev_delta>-contract_id
        ASSIGNING <ls_contract_data>.
      IF sy-subrc = 0.
        IF <ls_contract_data>-lc_calc_method IS INITIAL.
          MESSAGE w000(fb) WITH 'Cannot fix FX1 Contracts' <ls_rev_delta>-contract_id 'POB ID ' <ls_rev_delta>-pob_id INTO gv_msg_str.
          CALL METHOD go_msg_handler->add_symessage
            EXPORTING
              iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

          INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_failed.
          CONTINUE.
        ENDIF.

        MOVE-CORRESPONDING <ls_contract_data> TO ls_contr_ex_rates.
        MOVE-CORRESPONDING <ls_contract_data> TO ls_contract_fx2.
        INSERT ls_contr_ex_rates INTO TABLE gts_contr_ex_rates.
        INSERT ls_contract_fx2 INTO TABLE gts_contract_fx2.
        TRY .
            CALL METHOD cl_farr_accr_util=>get_period_close
              EXPORTING
                iv_company_code         = <ls_contract_data>-company_code
                iv_acct_principle       = <ls_contract_data>-acct_principle
              IMPORTING
                ev_fiscal_year_ra_close = gv_open_fiscal_year
                ev_period_ra_close      = gv_open_period.

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
            INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_failed.
            CONTINUE.
        ENDTRY.
      ELSE.
        INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_failed.
        CONTINUE.
      ENDIF.
    ENDAT.

    IF p_test = abap_false AND lv_recon_key IS INITIAL.
      INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_failed.
      CONTINUE.
    ENDIF.

    CLEAR ls_defitem_posting_data.
    READ TABLE gt_defitem
      WITH KEY contract_id = <ls_rev_delta>-contract_id pob_id = <ls_rev_delta>-pob_id condition_type = <ls_rev_delta>-condition_type
      ASSIGNING <ls_defitem> BINARY SEARCH.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING <ls_defitem> TO ls_defitem_posting_data.

      READ TABLE gts_pob_new_data
        WITH KEY pob_id = <ls_rev_delta>-pob_id
        ASSIGNING <ls_pob_posting_data>.
      IF sy-subrc = 0.
        ls_defitem_posting_data-xnegative_item = <ls_pob_posting_data>-xnegative_item.
      ELSE.
        "No POB found.
        INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_failed.
        CONTINUE.
      ENDIF.

      ls_defitem_posting_data-rev_amt_delta = <ls_rev_delta>-delta_betrw.
      ls_defitem_posting_data-amount_curk   = <ls_rev_delta>-waers.

      ls_defitem_posting_data-recon_key = lv_recon_key.

      APPEND ls_defitem_posting_data TO gt_defitem_posting_data.

      INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_success.
    ELSE.
      "No defitem found.
      INSERT <ls_rev_delta> INTO TABLE gts_rev_delta_failed.
    ENDIF.

  ENDLOOP.
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
*&      Form  SELECT_ERR_POB_ID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_err_pob_id .
  DATA: ls_pob_id_range TYPE farr_s_pob_id_range.
  FIELD-SYMBOLS:
                 <ls_pob_id> TYPE farr_pob_id.

  "only compare revenue, VF does not have cost
  IF so_pob IS INITIAL AND so_contr IS INITIAL
    AND p_bukrs IS NOT INITIAL
    AND p_accpr IS NOT INITIAL.
    EXEC SQL PERFORMING insert_to_result_table.
      SELECT DISTINCT pob_id INTO :gv_pob_id FROM
        ( select c.*,
            ( select ( sum(betrw) * -1 )
                from farr_d_posting
               where client         = c.client
                 and pob_id         = c.pob_id
                 and condition_type = c.condition_type
                 and post_cat    = 'RV'
            ) as sum_pos_rev
            from
            (
              select client,
                     company_code,
                     pob_id,
                     condition_type,
                     sum(sum_rev) sum_def_rev
                     from
                     (   select a.client, a.company_code,
                                a.pob_id,
                                a.condition_type,
                                sum(a.rev_amt_delta) sum_rev
                                from farr_d_defitem a
                                  join farr_d_recon_key b
                                    on  a.client       = b.client
                                    and a.contract_id  = b.contract_id
                                    and a.recon_key = b.recon_key
                                  where b.client = :sy-mandt
                                    and b.company_code = :p_bukrs
                                    and b.acct_principle = :p_accpr
                                    and b.status   <> 'O'
                                    and a.category     = 'P'
                                  group by a.client,
                                           a.company_code,
                                           a.pob_id,
                                           a.condition_type
                     )
                     group by client,
                              company_code,
                              pob_id,
                              condition_type

                ) c
                )
           where sum_pos_rev <> sum_def_rev

    ENDEXEC.

    LOOP AT gts_pob_id ASSIGNING <ls_pob_id>.
      ls_pob_id_range-sign = 'I'.
      ls_pob_id_range-option = 'EQ'.
      ls_pob_id_range-low = <ls_pob_id>.
      INSERT ls_pob_id_range INTO TABLE so_pob.
    ENDLOOP.
  ELSE.
*does not determine errors, jus tlist of POBs according to POB/contract selection
    CLEAR so_pob.
    REFRESH so_pob.

    SELECT pob_id INTO gv_pob_id
      FROM farr_d_pob
      WHERE contract_id IN so_contr AND
            pob_id IN gt_pob_id_range AND
            company_code = p_bukrs AND
            acct_principle = p_accpr.
      ls_pob_id_range-sign = 'I'.
      ls_pob_id_range-option = 'EQ'.
      ls_pob_id_range-low = gv_pob_id.
      INSERT ls_pob_id_range INTO TABLE so_pob.
    ENDSELECT.
  ENDIF.
ENDFORM.                    " SELECT_ERR_POB_ID

*&---------------------------------------------------------------------*
*&      Form  insert_to_result_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM insert_to_result_table.
  TRY.
      IF gv_pob_id IS NOT INITIAL.
        INSERT gv_pob_id INTO TABLE gts_pob_id.
      ENDIF.
    CATCH cx_sy_itab_duplicate_key.
* just ignore duplicate key
  ENDTRY.
ENDFORM.                    "insert_to_result_table
