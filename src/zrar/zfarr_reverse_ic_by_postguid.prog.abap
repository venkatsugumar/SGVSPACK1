*&---------------------------------------------------------------------*
*& Report ZFARR_REVERSE_IC_BY_POSTGUID
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFARR_REVERSE_IC_BY_POSTGUID.

*---------------------------------------------------------------------------------------------------------------------*
*                                               GLOBAL DATA DECLARATIONS                                              *
*---------------------------------------------------------------------------------------------------------------------*
TABLES: farr_d_posting, farr_d_contract.

TYPES: BEGIN OF ys_recon_key,
         year    TYPE gjahr,
         period  TYPE poper,
         counter TYPE num7,
       END OF ys_recon_key.
TYPES: BEGIN OF ys_contract,
         contract_id       TYPE farr_contract_id,
         recei_adj_account TYPE farr_rece_adj_acct,
       END OF ys_contract.
TYPES: yt_contract TYPE HASHED TABLE OF ys_contract WITH UNIQUE KEY contract_id.

DATA: go_msg_handler          TYPE REF TO cl_farr_message_handler ##NEEDED,
      gv_log_handler          TYPE balloghndl ##NEEDED,
      go_recon_key_mgmt       TYPE REF TO if_farr_reconkey_mgt ##NEEDED,
      go_posting_db_access    TYPE REF TO if_farr_posting_db_access ##NEEDED,
      gt_posting_close        TYPE farr_tt_posting_data ##NEEDED,
      gt_posting_open         TYPE farr_tt_posting_data ##NEEDED,
      gt_posting_insert       TYPE farr_tt_posting_data ##NEEDED,
      gt_contract             TYPE yt_contract ##NEEDED,
      gt_contract_id_failed   TYPE farr_ts_contract_id ##NEEDED,
      gt_contract_id          TYPE farr_tt_contract_id ##NEEDED,
      gv_recon_key_first_prod TYPE farr_recon_key ##NEEDED,
      gv_recon_key_first_open TYPE farr_recon_key ##NEEDED,
      gv_time_string          TYPE string ##NEEDED,
      gv_error                TYPE boole_d ##NEEDED.
DATA go_docking_container     TYPE REF TO cl_gui_docking_container. "for displaying sidebar on selection screen
DATA go_change_logger         TYPE REF TO cl_farr_corr_log.         "Correction Log Framework logging object
DATA go_error                 TYPE REF TO cx_farr_corr_log_fault.   "Correction Log Framework error message
DATA gt_corr_data_alv         TYPE farr_tt_posting_data.  "for final ALV display

*---------------------------------------------------------------------------------------------------------------------*
*                                                   SELECTION SCREEN                                                  *
*---------------------------------------------------------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE t_data.
  PARAMETERS p_bukrs TYPE bukrs OBLIGATORY.
  PARAMETERS p_accpr TYPE accounting_principle OBLIGATORY.
  SELECT-OPTIONS so_cntrs FOR farr_d_contract-contract_id OBLIGATORY.
  SELECT-OPTIONS so_guid FOR farr_d_posting-guid NO INTERVALS.
SELECTION-SCREEN END OF BLOCK a1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE t_ctrl.
  PARAMETERS p_test TYPE boole_d DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b1.

*---------------------------------------------------------------------------------------------------------------------*
*                                                    INITIALIZATION                                                   *
*---------------------------------------------------------------------------------------------------------------------*
INITIALIZATION.
  t_data  = 'Data selection' ##NO_TEXT.
  t_ctrl  = 'Control' ##NO_TEXT.
  %_p_bukrs_%_app_%-text    = 'Company Code' ##NO_TEXT.
  %_p_accpr_%_app_%-text    = 'Accounting Principle' ##NO_TEXT.
  %_so_cntrs_%_app_%-text   = 'Contract ID' ##NO_TEXT.
  %_so_guid_%_app_%-text    = 'Posting GUID' ##NO_TEXT.
  %_p_test_%_app_%-text     = 'Simulation' ##NO_TEXT.

*---------------------------------------------------------------------------------------------------------------------*
*                                                AT SELECTION-SCREEN OUTPUT                                           *
*---------------------------------------------------------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  DATA lv_text TYPE c LENGTH 30000.
  CONCATENATE
    'REPORT DESCRIPTION' %_cr_lf
    'This report generates new IC/ED/CC postings, with their respective B/S counterpostings, which are reversals of '
    'unwanted IC/ED/CC postings already present in the FARR_D_POSTING table. ' %_cr_lf
    'These postings are created on open reconkeys, so they have to be posted by running programs A/B/C afterwards. '
    'The postings are not checked against any other tables, such as FARR_D_INVOICE or FARR_D_DEFITEM, so a proper '
    'analysis needs to be done prior to running this program, to ensure that these reversal postings can be created '
    'without negatively impacting the integrity of RAR data. '
    'The report doesn''t take into account that one IC posting may contain amounts from multiple invoices, and will '
    'always reverse the whole IC posting. The report may be used to reverse an IC posting of one condition type only, '
    'if the posting GUID of only this condition''s posting is supplied. If no posting GUID is supplied, the report '
    'will reverse all IC/ED/CC postings of the contract. ' %_cr_lf
    'This report can currently reverse only postings of contracts which are using the Fixed Exchange Rate method. '
    'Actual Exchange Rate method is currently not supported. There is no check for this!' %_cr_lf
                %_cr_lf
    '!!! GENERAL WARNING !!!' %_cr_lf
    'Never run SAP-supplied Z reports unless instructed by SAP support! '
    'These reports do not validate all dependencies and may introduce new '
    'inconsistencies if used incorrectly. SAP support must always review the data '
    'before any changes are made. We also recommend to run Z reports in simulation '
    'mode first, to verify the results without saving to the database. Preferrably test '
    'Z reports in a non-productive system before executing them production.'
  INTO lv_text RESPECTING BLANKS.
  PERFORM add_sidebar USING lv_text.

*---------------------------------------------------------------------------------------------------------------------*
*                                            START-OF-SELECTION (MAIN PROGRAM)                                        *
*---------------------------------------------------------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM initialize CHANGING gv_error.
  CHECK gv_error EQ abap_false.

  PERFORM write_run_mode_log.

  PERFORM initialize_corr_log        "creates correction log, used by RAR Correction Log Framework
    USING 'Reverse IC/ED/CC postings'. "description text for correction log

  DO 1 TIMES.   "This block can be ended by CHECK statements.

    " Get first recon key in the first productive period
    PERFORM get_recon_key_first_productive CHANGING gv_error.
    CHECK gv_error EQ abap_false.

    " Get first recon key in opened period
    PERFORM get_recon_key_first_opened CHANGING gv_error.
    CHECK gv_error EQ abap_false.

    " Fetch contract data
    PERFORM fetch_contract_data CHANGING gv_error.
    CHECK gv_error EQ abap_false.

    " Fetch posting data from closed periods
    PERFORM fetch_close_period_data CHANGING gv_error.
    CHECK gv_error EQ abap_false.

    " Fetch posting data from opened periods
    PERFORM fetch_open_period_data CHANGING gv_error.
    CHECK gv_error EQ abap_false.

    " Lock contract data before update
    PERFORM lock_contract_data CHANGING gv_error.
    CHECK gv_error EQ abap_false.

    " Reverse data from closed periods
    PERFORM reverse_closed CHANGING gv_error.
    CHECK gv_error EQ abap_false.

    " Reverse data from opened periods
    PERFORM reverse_open CHANGING gv_error.
    CHECK gv_error EQ abap_false.

  ENDDO.

  "Record succeed or fail  contract id Information
  PERFORM add_log_end_of_work.

  "Save to DB. including FARR_D_POSTING + FARR_D_RECON_KEY + log
  PERFORM save_to_db.

  "Show log
  PERFORM display_result.

  "Show resulting inserted postings in ALV
  PERFORM display_correction_alv     "ALV display of corrected data (doesn't show for more than 5000 lines)
    USING 'FARR_D_POSTING'           "the structure type for ALV displayed data needs to be specified here
          ''.                        "fields to display ('' for no filtering)


*&---------------------------------------------------------------------*
*&      Form  INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IF_FARRC_MSG_HANDLER_CONS=>CO_  text
*      <--P_GV_ERROR  text
*----------------------------------------------------------------------*
FORM initialize CHANGING cv_error TYPE boole_d.

  cv_error = abap_true.
  TRY.
      go_msg_handler = cl_farr_accr_util=>get_msg_handler( iv_sub_obj = if_farrc_msg_handler_cons=>co_subobj_cleanup ).
      gv_log_handler = go_msg_handler->get_log_handler( ).
      CHECK gv_log_handler IS NOT INITIAL.

      ##no_handler
    CATCH cx_farr_message.
      RETURN.
  ENDTRY.

  CALL METHOD cl_farr_accr_util=>get_recon_key_mgmt_instance
    IMPORTING
      eo_recon_key_mgmt = go_recon_key_mgmt.

  cv_error = abap_false.

ENDFORM.                    " INITIALIZE


*&---------------------------------------------------------------------*
*&      Form  write_run_mode_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM write_run_mode_log.

  CALL METHOD cl_farr_accr_util=>get_current_time_string
    IMPORTING
      ev_time_string = gv_time_string.

  PERFORM report_message USING 'ZFARR_REVERSE_IC_BY_POSTGUID Started at' gv_time_string ##NO_TEXT.

  IF p_test = abap_true.
    PERFORM report_message USING 'Testing Run (No DB Update)' space ##NO_TEXT.
  ELSE.
    PERFORM report_message USING 'Production Run (DB will be Updated)' space ##NO_TEXT.
  ENDIF.

ENDFORM.                    "write_run_mode_log


*&---------------------------------------------------------------------*
*&      Form  GET_RECON_KEY_FIRST_PRODUCTIVE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_recon_key_first_productive CHANGING cv_error TYPE boole_d.

  DATA : ls_acpr_bukr TYPE farr_s_acpr_bukr_data,
         ls_recon_key TYPE ys_recon_key,
         lv_year      TYPE gjahr,
         lv_period    TYPE poper.

  " Initialize
  CLEAR : cv_error.
  CLEAR : gv_recon_key_first_prod.

  TRY.
      " Get transfer date
      CLEAR : ls_acpr_bukr.
      CALL METHOD cl_farr_fnd_cust_db_access=>read_acpr_bukr_single
        EXPORTING
          iv_acct_principle = p_accpr
          iv_company_code   = p_bukrs
        IMPORTING
          es_acpr_bukr_data = ls_acpr_bukr.

      " Get transfer period
      CLEAR : lv_year, lv_period.
      IF ls_acpr_bukr-take_over_dat IS NOT INITIAL
      AND ls_acpr_bukr-mig_status EQ 'PO'.

        CALL METHOD cl_farr_accr_util=>convert_date_to_period
          EXPORTING
            iv_date           = ls_acpr_bukr-take_over_dat
            iv_company_code   = p_bukrs
            iv_acct_principle = p_accpr
          IMPORTING
            ev_fiscal_year    = lv_year
            ev_posting_period = lv_period.

        CLEAR : ls_recon_key.
        ls_recon_key-year    = lv_year.
        ls_recon_key-period  = lv_period.
        ls_recon_key-counter = if_farr_reconkey_mgt=>gc_recon_key_zero.
        gv_recon_key_first_prod = ls_recon_key.

      ENDIF.

    CATCH cx_farr_message ##NO_HANDLER.

      CLEAR : gv_recon_key_first_prod.
      PERFORM report_message USING 'First productive period not found' space ##NO_TEXT.
      cv_error = abap_true.

  ENDTRY.

ENDFORM. " GET_RECON_KEY_FIRST_PRODUCTIVE


*&---------------------------------------------------------------------*
*&      Form  GET_RECON_KEY_FIRST_OPENED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_recon_key_first_opened CHANGING cv_error TYPE boole_d.

  DATA : ls_recon_key TYPE ys_recon_key,
         ls_period    TYPE farr_s_period_close,
         lv_year      TYPE gjahr,
         lv_period    TYPE poper.

  CLEAR : cv_error.
  CLEAR : gv_recon_key_first_open.

  TRY.
      CLEAR : ls_period.
      CALL METHOD cl_farr_period_close_db_access=>get_period_close
        EXPORTING
          iv_bukrs          = p_bukrs
          iv_acct_principle = p_accpr
        IMPORTING
          es_period_close   = ls_period.

      lv_year   = ls_period-from_year.
      lv_period = ls_period-from_poper.

      IF ls_period-close_status = 'I'.

        CALL METHOD cl_farr_accr_util=>get_future_posting_period
          EXPORTING
            iv_company_code         = p_bukrs
            iv_acct_principle       = p_accpr
            iv_start_fiscal_year    = lv_year
            iv_start_posting_period = lv_period
            iv_shift_num            = 1
          IMPORTING
            ev_fiscal_year          = lv_year
            ev_posting_period       = lv_period.

      ENDIF.

      CLEAR : ls_recon_key.
      ls_recon_key-year       = lv_year.
      ls_recon_key-period     = lv_period.
      ls_recon_key-counter    = if_farr_reconkey_mgt=>gc_recon_key_zero.
      gv_recon_key_first_open = ls_recon_key.

    CATCH cx_farr_message ##NO_HANDLER.

      CLEAR : gv_recon_key_first_open.
      PERFORM report_message USING 'Opened period not found' space ##NO_TEXT.
      cv_error = abap_true.

  ENDTRY.

ENDFORM.      " GET_RECON_KEY_FIRST_OPENED


*&---------------------------------------------------------------------*
*&      Form  FETCH_CONTRACT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_contract_data CHANGING cv_error TYPE boole_d.

  CLEAR : cv_error.
  CLEAR : gt_contract.

  SELECT contract_id recei_adj_account INTO CORRESPONDING FIELDS OF TABLE gt_contract
    FROM farr_d_contract
    WHERE company_code  = p_bukrs
      AND acct_principle = p_accpr
      AND contract_id   IN so_cntrs
    ORDER BY contract_id.

  IF gt_contract IS INITIAL.
    PERFORM report_message USING 'No contract found' space ##NO_TEXT.
    cv_error = abap_true.
  ENDIF.

ENDFORM.                    "FETCH_CONTRACT_DATA


*&---------------------------------------------------------------------*
*&      Form  FETCH_CLOSE_PERIOD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_close_period_data CHANGING cv_error TYPE boole_d.

  CLEAR : cv_error.
  CLEAR : gt_posting_close.

  SELECT  p~company_code
          p~acct_principle
          p~pob_id
          p~condition_type
          p~post_cat

          SUM( p~betrw ) AS betrw
          p~waers
          SUM( p~betrh ) AS betrh
          p~hwaer
          SUM( p~betr2 ) AS betr2
          p~hwae2
          SUM( p~betr3 ) AS betr3
          p~hwae3

          p~contract_id
          p~hkont
          p~statistic
          p~pob_type
          p~shkzg_va
          p~spec_indicator
          " TODO : add FARR_D_POSTING relevant custom fields

          p~fkber
          p~gsber
          p~segment
          p~prctr

          p~paobjnr
          p~kostl
          p~aufnr
          p~kdauf
          p~kdpos
          p~ps_posid

    INTO CORRESPONDING FIELDS OF TABLE gt_posting_close
    FROM farr_d_posting AS p
    INNER JOIN farr_d_contract AS c
            ON p~contract_id = c~contract_id
    INNER JOIN farr_d_recon_key AS r
            ON p~recon_key = r~recon_key
           AND p~contract_id = r~contract_id
    WHERE p~company_code   = p_bukrs
      AND p~acct_principle = p_accpr
      AND p~recon_key      >= gv_recon_key_first_prod
      AND p~recon_key      <  gv_recon_key_first_open
      AND ( p~post_cat       = if_farrc_contr_mgmt=>co_post_cat_invoice_correction
        OR   p~post_cat       = if_farrc_contr_mgmt=>co_post_dat_exchange_rate_diff
        OR   p~post_cat       = if_farrc_contr_mgmt=>co_post_cat_cost_correction )
      AND p~contract_id    IN so_cntrs
*      and c~lc_calc_method = if_farrc_contr_mgmt=>co_lc_calc_method_actual_rate
      AND r~status         <> 'M'
      AND p~guid IN so_guid

      GROUP BY  p~company_code
                p~acct_principle
                p~pob_id
                p~condition_type
                p~post_cat

                p~waers
                p~hwaer
                p~hwae2
                p~hwae3

                p~contract_id
                p~hkont
                p~statistic
                p~pob_type
                p~shkzg_va
                p~spec_indicator
                " TODO : add FARR_D_POSTING relevant custom fields

                p~fkber
                p~gsber
                p~segment
                p~prctr

                p~paobjnr
                p~kostl
                p~aufnr
                p~kdauf
                p~kdpos
                p~ps_posid
          HAVING NOT (  SUM( p~betrw ) = 0 AND
                        SUM( p~betrh ) = 0 AND
                        SUM( p~betr2 ) = 0 AND
                        SUM( p~betr3 ) = 0 )   ##TOO_MANY_ITAB_FIELDS.

ENDFORM.                    " FETCH_CLOSE_PERIOD_DATA


*&---------------------------------------------------------------------*
*&      Form  FETCH_OPEN_PERIOD_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_open_period_data CHANGING cv_error TYPE boole_d.

  CLEAR : cv_error.
  CLEAR : gt_posting_open.

  SELECT  p~company_code
          p~acct_principle
          p~pob_id
          p~condition_type
          p~post_cat
          p~gjahr
          p~poper

          SUM( p~betrw ) AS betrw
          p~waers
          SUM( p~betrh ) AS betrh
          p~hwaer
          SUM( p~betr2 ) AS betr2
          p~hwae2
          SUM( p~betr3 ) AS betr3
          p~hwae3

          p~contract_id
          p~hkont
          p~statistic
          p~pob_type
          p~shkzg_va
          p~spec_indicator
          " TODO : add FARR_D_POSTING relevant custom fields

          p~fkber
          p~gsber
          p~segment
          p~prctr

          p~paobjnr
          p~kostl
          p~aufnr
          p~kdauf
          p~kdpos
          p~ps_posid

    INTO CORRESPONDING FIELDS OF TABLE gt_posting_open
    FROM farr_d_posting AS p
    INNER JOIN farr_d_contract AS c
            ON p~contract_id = c~contract_id
    INNER JOIN farr_d_recon_key AS r
            ON p~recon_key = r~recon_key
           AND p~contract_id = r~contract_id
    WHERE p~company_code   = p_bukrs
      AND p~acct_principle = p_accpr
      AND p~recon_key      > gv_recon_key_first_open
      AND ( p~post_cat       = if_farrc_contr_mgmt=>co_post_cat_invoice_correction
              OR   p~post_cat       = if_farrc_contr_mgmt=>co_post_dat_exchange_rate_diff
              OR   p~post_cat       = if_farrc_contr_mgmt=>co_post_cat_cost_correction )
      AND p~contract_id    IN so_cntrs
*      and c~lc_calc_method = if_farrc_contr_mgmt=>co_lc_calc_method_actual_rate
      AND r~status         <> 'M'
      AND p~guid IN so_guid

      GROUP BY  p~company_code
                p~acct_principle
                p~pob_id
                p~condition_type
                p~post_cat
                p~gjahr
                p~poper

                p~waers
                p~hwaer
                p~hwae2
                p~hwae3

                p~contract_id
                p~hkont
                p~statistic
                p~pob_type
                p~shkzg_va
                p~spec_indicator
                " TODO : add FARR_D_POSTING relevant custom fields

                p~fkber
                p~gsber
                p~segment
                p~prctr

                p~paobjnr
                p~kostl
                p~aufnr
                p~kdauf
                p~kdpos
                p~ps_posid
          HAVING NOT (  SUM( p~betrw ) = 0 AND
                        SUM( p~betrh ) = 0 AND
                        SUM( p~betr2 ) = 0 AND
                        SUM( p~betr3 ) = 0 )   ##TOO_MANY_ITAB_FIELDS.

ENDFORM. " FETCH_OPEN_PERIOD_DATA


*&---------------------------------------------------------------------*
*&      Form  LOCK_CONTRACT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM lock_contract_data CHANGING cv_error TYPE boole_d.

  CLEAR : cv_error.

  IF gt_posting_close IS INITIAL
  AND gt_posting_open IS INITIAL.

    PERFORM report_message USING 'No posting data found' space ##NO_TEXT.
    cv_error = abap_true.
    RETURN.

  ENDIF.

  IF p_test = abap_false.
    PERFORM lock_contract.
  ENDIF.

ENDFORM. " LOCK_CONTRACT_DATA


*&---------------------------------------------------------------------*
*&      Form  Reverse_closed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reverse_closed CHANGING cv_error TYPE boole_d.

  DATA : lv_posting_date TYPE d,
         ls_recon_key    TYPE ys_recon_key.

  FIELD-SYMBOLS : <ls_posting_data> TYPE farr_s_posting_data.

  " Init
  CLEAR : cv_error.
  CHECK gt_posting_close IS NOT INITIAL.

  " Get posting date (Last date of first opened period)
  TRY.
      CLEAR : ls_recon_key.
      ls_recon_key = gv_recon_key_first_open.

      CALL METHOD cl_farr_accr_util=>get_last_day_in_period
        EXPORTING
          iv_company_code   = p_bukrs
          iv_acct_principle = p_accpr
          iv_gjahr          = ls_recon_key-year
          iv_poper          = ls_recon_key-period
        IMPORTING
          ev_date           = lv_posting_date.
    CATCH cx_farr_message ##NO_HANDLER.
      CLEAR lv_posting_date.
  ENDTRY.

  IF lv_posting_date IS INITIAL.
    PERFORM report_message USING 'Posting date not found' space ##NO_TEXT.
    cv_error = abap_true.
    RETURN.
  ENDIF.

  "Generate reverse posting entries
  LOOP AT gt_posting_close ASSIGNING <ls_posting_data>.
    PERFORM build_entry USING <ls_posting_data> lv_posting_date.
  ENDLOOP.

ENDFORM.                    " Reverse_closed


*&---------------------------------------------------------------------*
*&      Form  REVERSE_OPEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM reverse_open CHANGING cv_error TYPE boole_d..

  DATA : lv_posting_date TYPE d.

  FIELD-SYMBOLS : <ls_posting_data> TYPE farr_s_posting_data.

  " Init
  CLEAR : cv_error.
  CHECK gt_posting_open IS NOT INITIAL.

  LOOP AT gt_posting_open ASSIGNING <ls_posting_data>.

    " Get posting (last date of the posting record period)
    TRY.
        CLEAR : lv_posting_date.
        CALL METHOD cl_farr_accr_util=>get_last_day_in_period
          EXPORTING
            iv_company_code   = p_bukrs
            iv_acct_principle = p_accpr
            iv_gjahr          = <ls_posting_data>-gjahr
            iv_poper          = <ls_posting_data>-poper
          IMPORTING
            ev_date           = lv_posting_date.

      CATCH cx_farr_message.
        CLEAR : lv_posting_date.
    ENDTRY.

    IF lv_posting_date IS INITIAL.
      PERFORM report_message USING 'Posting date not found' space ##NO_TEXT.
      cv_error = abap_true.
      CONTINUE.
    ENDIF.

    " Generate posting entry
    PERFORM build_entry USING <ls_posting_data> lv_posting_date.

  ENDLOOP.

ENDFORM.                    " REVERSE_OPEN


*&---------------------------------------------------------------------*
*&      Form  build_entry
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM build_entry USING is_posting_data TYPE farr_s_posting_data iv_posting_date TYPE d.

  DATA: ls_reverse          TYPE farr_s_posting_data,
        ls_cost_act_assment TYPE farr_s_co_acct_assignmt,
        lv_recon_key        TYPE farr_recon_key,
        lv_guid             TYPE farr_fulfill_guid.

  FIELD-SYMBOLS : <ls_contract> TYPE ys_contract.

  "-- 1. Get reconcilaiton key
  TRY.
      CLEAR : lv_recon_key.
      CALL METHOD go_recon_key_mgmt->get_recon_key_post_related
        EXPORTING
          iv_date           = iv_posting_date
          iv_contract_id    = is_posting_data-contract_id
          iv_company_code   = p_bukrs
          iv_acct_principle = p_accpr
        IMPORTING
          ev_recon_key      = lv_recon_key.
    CATCH cx_farr_message.
      CLEAR : lv_recon_key.
  ENDTRY.

  IF lv_recon_key IS INITIAL.
    INSERT is_posting_data-contract_id INTO TABLE gt_contract_id_failed.
    PERFORM report_message USING 'Failed to get recon. key for Contract' is_posting_data-contract_id ##NO_TEXT.
    RETURN.
  ENDIF.

  " -- 2. Get posting GUID
  TRY.
      CLEAR : lv_guid.
      lv_guid = cl_farr_contract_utility=>generate_guid( ).
    CATCH cx_farr_message.
      CLEAR : lv_guid.
  ENDTRY.

  IF lv_guid IS INITIAL.
    INSERT is_posting_data-contract_id INTO TABLE gt_contract_id_failed.
    PERFORM report_message USING  'Posting GUID can not be generated' is_posting_data-contract_id ##NO_TEXT.
    RETURN.
  ENDIF.

  " -- 3. Get receivable adjustment account
  READ TABLE gt_contract
        WITH TABLE KEY contract_id = is_posting_data-contract_id
        ASSIGNING <ls_contract>.

  IF sy-subrc <> 0.
    INSERT is_posting_data-contract_id INTO TABLE gt_contract_id_failed.
    PERFORM report_message USING 'Failed to get contract data' is_posting_data-contract_id ##NO_TEXT.
    RETURN.
  ENDIF.

  " -- 4. Build reversal entry (RV - revenue)
  CLEAR: ls_reverse.
  MOVE-CORRESPONDING is_posting_data TO ls_reverse.

*  ls_reverse-post_cat  = if_farrc_contr_mgmt=>co_post_cat_revenue.
  ls_reverse-recon_key = lv_recon_key.
  ls_reverse-betrw     = ls_reverse-betrw * ( -1 ).
  ls_reverse-betrh     = ls_reverse-betrh * ( -1 ).
  ls_reverse-betr2     = ls_reverse-betr2 * ( -1 ).
  ls_reverse-betr3     = ls_reverse-betr3 * ( -1 ).
  ls_reverse-guid      = lv_guid.
  ls_reverse-gjahr     = lv_recon_key+0(4).
  ls_reverse-poper     = lv_recon_key+4(3).

  " SHKZG
  IF is_posting_data-betrw > 0.
    ls_reverse-shkzg = if_farrc_contr_mgmt=>co_shkzg_credit.
  ELSE.
    ls_reverse-shkzg = if_farrc_contr_mgmt=>co_shkzg_debit.
  ENDIF.

  " SHKZG_VA
  IF ls_reverse-post_cat  <> if_farrc_contr_mgmt=>co_post_dat_exchange_rate_diff.
    IF is_posting_data-shkzg_va EQ abap_true.
      ls_reverse-shkzg_va = abap_false.
    ELSE.
      ls_reverse-shkzg_va = abap_true.
    ENDIF.
  ENDIF.

  INSERT ls_reverse INTO TABLE gt_posting_insert.

  " -- 5. Build reversal entry (RA - receivable adjustmetn)
  IF ls_reverse-statistic = abap_false.

    ls_reverse-post_cat = if_farrc_contr_mgmt=>co_post_cat_receivable_adjust.
    ls_reverse-betrw    = ls_reverse-betrw * ( -1 ).
    ls_reverse-betrh    = ls_reverse-betrh * ( -1 ).
    ls_reverse-betr2    = ls_reverse-betr2 * ( -1 ).
    ls_reverse-betr3    = ls_reverse-betr3 * ( -1 ).
    ls_reverse-hkont    = <ls_contract>-recei_adj_account.
    ls_reverse-fkber    = space.
    ls_reverse-shkzg_va = space.

    IF is_posting_data-betrw > 0.
      ls_reverse-shkzg = if_farrc_contr_mgmt=>co_shkzg_debit.
    ELSE.
      ls_reverse-shkzg = if_farrc_contr_mgmt=>co_shkzg_credit.
    ENDIF.

    " Cost attributes are irrelevant for receivable adjustment
    CLEAR : ls_cost_act_assment.
    MOVE-CORRESPONDING ls_cost_act_assment TO ls_reverse.

    INSERT ls_reverse INTO TABLE gt_posting_insert.
  ENDIF.

  " -- 6. Collect changed contracts
  READ TABLE gt_contract_id
     WITH KEY table_line = is_posting_data-contract_id BINARY SEARCH
     TRANSPORTING NO FIELDS.

  IF sy-subrc <> 0.
    APPEND is_posting_data-contract_id TO gt_contract_id.
  ENDIF.

ENDFORM.                    "BUILD_ENTRY

*&---------------------------------------------------------------------*
*&      Form  report_message
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM report_message USING i_p1 TYPE any i_p2 TYPE any.

  MESSAGE i276(farr_rai)
     WITH i_p1 i_p2
     INTO cl_farr_accr_util=>str ##NO_TEXT.

  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

ENDFORM. " report_message


*&---------------------------------------------------------------------*
*&      Form  SAVE_TO_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM save_to_db .
  "Copy contents of the newly created postings into the ALV data container for later display
  gt_corr_data_alv[] = gt_posting_insert[].

  "Simulation
  IF p_test = abap_false AND gv_error = abap_false.

    CREATE OBJECT go_posting_db_access TYPE cl_farr_posting_db_access.

    CALL METHOD go_posting_db_access->insert_multiple_entries
      EXPORTING
        it_posting_data = gt_posting_insert.

    CALL METHOD go_recon_key_mgmt->save_contracts_to_db
      EXPORTING
        it_contract_id = gt_contract_id.

  ENDIF.

  " When to start this program
  CALL METHOD cl_farr_accr_util=>get_current_time_string
    IMPORTING
      ev_time_string = gv_time_string.

  PERFORM report_message USING 'ZFARR_REVERSE_IC_BY_POSTGUID ended at' gv_time_string ##NO_TEXT.

  IF p_test = abap_false AND gv_error = abap_false.
    cl_farr_db_update=>commit_work( ).

    "Fill Correction Log
    TRY.
        IF gt_posting_insert IS NOT INITIAL.
          go_change_logger->protocol_db_changes(
              it_new_table = gt_posting_insert
              iv_tablename = 'FARR_D_POSTING' ).
        ENDIF.
      CATCH cx_farr_corr_log_fault INTO go_error.
        MESSAGE ID go_error->if_t100_message~t100key-msgid
          TYPE 'E'
          NUMBER go_error->if_t100_message~t100key-msgno
          WITH go_error->if_t100_message~t100key-attr1
               go_error->if_t100_message~t100key-attr2
               go_error->if_t100_message~t100key-attr3
               go_error->if_t100_message~t100key-attr4.
    ENDTRY.
  ELSE.
    cl_farr_db_update=>rollback_work( ).
  ENDIF.


  TRY.
      go_msg_handler->save_and_close_app_log( ).
    CATCH cx_farr_message ##NO_HANDLER.
  ENDTRY.

  cl_farr_db_update=>commit_work( ).
ENDFORM.                    "save_to_db


*&---------------------------------------------------------------------*
*&      Form  lock_contract
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM lock_contract.

  DATA : lv_user_id          TYPE xubname,
         lv_user_name        TYPE ad_namtext,
         lv_msgv_contract_id TYPE symsgv.

  FIELD-SYMBOLS : <ls_contract> TYPE ys_contract.

  LOOP AT gt_contract ASSIGNING <ls_contract>.

    CALL FUNCTION 'ENQUEUE_EFARR_D_CONTRACT'
      EXPORTING
        contract_id    = <ls_contract>-contract_id
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
        lv_msgv_contract_id = cl_farr_contract_utility=>conversion_exit_alpha_output( <ls_contract>-contract_id ).

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
          CATCH cx_farr_message ##NO_HANDLER.
        ENDTRY.

        DELETE gt_posting_close WHERE contract_id = <ls_contract>-contract_id.

      WHEN OTHERS.
        "Error while locking contract &1
        lv_msgv_contract_id = cl_farr_contract_utility=>conversion_exit_alpha_output( <ls_contract>-contract_id ).

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
          CATCH cx_farr_message ##NO_HANDLER.
        ENDTRY.

        DELETE gt_posting_close WHERE contract_id = <ls_contract>-contract_id.

    ENDCASE.

  ENDLOOP.
ENDFORM.                    "lock_contract


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
    CATCH cx_farr_message ##NO_HANDLER.
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
*&      Form  add_log_end_of_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_log_end_of_work.
  DATA: lv_string TYPE string.
  FIELD-SYMBOLS:
                 <ls_contract_id> TYPE farr_contract_id.

  lv_string = lines( gt_contract_id ).
  MESSAGE i000(fb) WITH 'Reverse and Repost ' lv_string 'contracts are succeed'  INTO cl_farr_accr_util=>str ##NO_TEXT.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  LOOP AT gt_contract_id ASSIGNING <ls_contract_id>.
    MESSAGE i000(fb) WITH 'Fix success' <ls_contract_id> INTO cl_farr_accr_util=>str ##NO_TEXT.
    CALL METHOD go_msg_handler->add_symessage
      EXPORTING
        iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
        iv_ctx_value = <ls_contract_id>.
  ENDLOOP.

  lv_string = lines( gt_contract_id_failed ).
  MESSAGE i000(fb) WITH 'Reverse and Repost ' lv_string 'contracts are failed'  INTO cl_farr_accr_util=>str ##NO_TEXT.
  CALL METHOD go_msg_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.

  TRY .
      CALL METHOD go_msg_handler->save_app_log( ).

    CATCH cx_farr_message.
      WRITE:/, 'Application log error' ##NO_TEXT.
  ENDTRY.
ENDFORM.                    "add_log_select_counter


FORM add_sidebar USING lv_text.
  IF go_docking_container IS NOT BOUND.
    CREATE OBJECT go_docking_container.
    go_docking_container->dock_at( cl_gui_docking_container=>dock_at_left ).
    go_docking_container->set_width( 500 ).

    DATA lo_textedit TYPE REF TO cl_gui_textedit.
    CREATE OBJECT lo_textedit
      EXPORTING
        parent = go_docking_container.
    lo_textedit->set_readonly_mode( 1 ).
    lo_textedit->set_toolbar_mode( 0 ).
    lo_textedit->set_statusbar_mode( 0 ).

    "input of set_text_as_stream needs to be a table type, even if just one line
    TYPES:
      BEGIN OF ty_text_line,
        line(30000) TYPE c,
      END OF ty_text_line.
    DATA lt_text TYPE STANDARD TABLE OF ty_text_line.
    APPEND lv_text TO lt_text.

    CALL METHOD lo_textedit->set_text_as_stream
      EXPORTING
        text            = lt_text
      EXCEPTIONS
        error_dp        = 1
        error_dp_create = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  "NOTE: The simpler alternative might be to just use an HTML-formatted string like this:
*  cl_abap_browser=>show_html(
*    container   = go_docking_container
*    html_string = lv_html_string   "the formatting could be done in any online WYSIWYG editor
*  ).
ENDFORM.


FORM initialize_corr_log USING lv_log_description.
  "This routine initializes the Correction Log Framework for later use.
  TRY.
      CREATE OBJECT go_change_logger
        EXPORTING
          iv_db_access_type = ' '
          iv_text           = lv_log_description
          iv_progname       = sy-repid      "report name
          iv_incidentyear   = sy-datum(4)   "incident year
          iv_is_mass_corr   = abap_false
          iv_is_sim_mode    = p_test.

    CATCH cx_farr_corr_log_fault INTO go_error.
      MESSAGE ID go_error->if_t100_message~t100key-msgid
              TYPE 'E'
              NUMBER go_error->if_t100_message~t100key-msgno
              WITH go_error->if_t100_message~t100key-attr1
                   go_error->if_t100_message~t100key-attr2
                   go_error->if_t100_message~t100key-attr3
                   go_error->if_t100_message~t100key-attr4.
      RETURN.
  ENDTRY.

  IF p_test = 'X'.
    PERFORM report_message USING 'The program simulated creation' 'of the Correction Log.' ##NO_TEXT.
  ELSE.
    PERFORM report_message USING 'Correction log created. To display it,' 'please use report FARR_DISP_CORRLOG.' ##NO_TEXT.
  ENDIF.
ENDFORM.


FORM display_correction_alv USING lv_corr_data_structure_type lv_fields_to_display.
  DATA:
    lt_fieldcat          TYPE slis_t_fieldcat_alv,
    lt_fieldcat_filtered TYPE slis_t_fieldcat_alv,
    ls_fieldcat          LIKE LINE OF lt_fieldcat,
    lv_alv_title         TYPE lvc_title,
    ls_alv_layout        TYPE slis_layout_alv,
    lv_lines_corr_data   TYPE i,
    lt_fields_to_display TYPE TABLE OF char30,
    lv_column_position   TYPE i.
  FIELD-SYMBOLS:
    <ls_fieldcat>         TYPE slis_fieldcat_alv,
    <ls_field_to_display> LIKE LINE OF lt_fields_to_display.

  "Exit if the table is too big to be usefully displayed (or empty).
  lv_lines_corr_data = lines( gt_corr_data_alv ).
  IF lv_lines_corr_data > 5000 OR lv_lines_corr_data = 0.
    RETURN.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING "         i_program_name         = <program name>
      i_structure_name       = lv_corr_data_structure_type
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  "Filtering out only field catalog fields that we want to display
  IF lv_fields_to_display <> ''.  "filtered fields were specified by subroutine caller
    SPLIT lv_fields_to_display AT space INTO TABLE lt_fields_to_display.
    LOOP AT lt_fields_to_display ASSIGNING <ls_field_to_display>.
      READ TABLE lt_fieldcat INTO ls_fieldcat WITH KEY fieldname = <ls_field_to_display>.
      IF sy-subrc = 0.
        APPEND ls_fieldcat TO lt_fieldcat_filtered.
      ENDIF.
    ENDLOOP.
  ELSE.
    lt_fieldcat_filtered[] = lt_fieldcat[].
  ENDIF.

  "Replacing field names with technical field names
  lv_column_position = 0.
  LOOP AT lt_fieldcat_filtered ASSIGNING <ls_fieldcat>.
    <ls_fieldcat>-seltext_m = <ls_fieldcat>-fieldname.
    <ls_fieldcat>-seltext_l = <ls_fieldcat>-fieldname.
    <ls_fieldcat>-seltext_s = <ls_fieldcat>-fieldname.
    <ls_fieldcat>-reptext_ddic = <ls_fieldcat>-fieldname.
    lv_column_position = lv_column_position + 1.
    <ls_fieldcat>-col_pos = lv_column_position.  "keeping the column order specified by subroutine caller
  ENDLOOP.

  IF sy-batch = abap_true.   "Background run: use ALV List to write the result list to spool
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        it_fieldcat   = lt_fieldcat_filtered
      TABLES
        t_outtab      = gt_corr_data_alv
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.                      "Online run: use ALV Grid to display the result
    IF p_test IS NOT INITIAL.
      CONCATENATE 'Changed data in table ' lv_corr_data_structure_type ' (Simulation Run)' INTO lv_alv_title RESPECTING BLANKS.
    ELSE.
      CONCATENATE 'Changed data in table ' lv_corr_data_structure_type ' (Productive Run)' INTO lv_alv_title RESPECTING BLANKS.
    ENDIF.

    ls_alv_layout-zebra = 'X'.
    ls_alv_layout-colwidth_optimize = 'X'.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat  = lt_fieldcat_filtered
        i_grid_title = lv_alv_title
        is_layout    = ls_alv_layout
      TABLES
        t_outtab     = gt_corr_data_alv.
  ENDIF.
ENDFORM.
