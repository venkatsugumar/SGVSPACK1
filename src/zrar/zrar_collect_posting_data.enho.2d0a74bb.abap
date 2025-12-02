"Name: \TY:CL_FARR_REV_COLLECT_DB_ACCESS\ME:COLLECT_POSTING_DATA_GRANULAR\SE:BEGIN\EI
ENHANCEMENT 0 ZRAR_COLLECT_POSTING_DATA.
***********************************************************************
*& Enhancement       : ZRAR_COLLECT_POSTING_DATA                      *
*& Module            : RAR                                            *
*& Sub-Module        : Revenue Accounting                             *
*& Functional Contact: Ratnakar Venkat                                *
*& Funct. Spec. Ref. : -                                              *
*& Developer(Company): Surekha Pawar                                  *
*& Create Date       : 05/26/2022                                     *
*& Program Type      : Enhancement                                    *
*& Project Phase     : Wave 1                                         *
*& Description       : Collect Contract ID and Contract flex details  *
*& Transports        : DS4K908410                                     *
***********************************************************************
  DATA: it_selclause         TYPE farr_tt_edid_line,
        it_grouplist         TYPE farr_tt_fieldname,
        it_company_code	     TYPE farr_tt_sel_company_code,
        lw_company_code      LIKE LINE OF it_company_code,
        it_sel_run_id        TYPE farr_tt_sel_run_id,
        lw_sel_run_id        LIKE LINE OF it_sel_run_id,
        it_default_selclause TYPE farr_tt_edid_line,
        it_default_grouplist TYPE farr_tt_fieldname.

  FIELD-SYMBOLS: <lf_posting_list> LIKE LINE OF et_posting_list.

  CLEAR et_posting_list.
  CLEAR it_company_code.
  CLEAR it_selclause.
  CLEAR it_grouplist.
  CLEAR it_sel_run_id.

  lw_company_code-sign   = if_farrc_accrual_constants=>co_range_sign_inclusive.
  lw_company_code-option = if_farrc_accrual_constants=>co_range_option_equal.
  lw_company_code-low    = iv_company_code.
  APPEND lw_company_code TO it_company_code.

  IF iv_run_id IS NOT INITIAL.
    lw_sel_run_id-sign   = if_farrc_accrual_constants=>co_range_sign_inclusive.
    lw_sel_run_id-option = if_farrc_accrual_constants=>co_range_option_equal.
    lw_sel_run_id-low    = iv_run_id.
    APPEND lw_sel_run_id TO it_sel_run_id.
  ENDIF.

  CALL METHOD cl_farr_utility_db_access=>build_fieldlist
    EXPORTING
      iv_name        = 'FARR_D_POSTING'
      iv_ex_name     = 'FARR_S_EXC_GRANULAR'
      iv_aggregation = abap_true
    IMPORTING
      et_selclause   = it_selclause
      et_grouplist   = it_grouplist.

  CALL METHOD cl_farr_rev_collect_db_access=>exclude_eew_farr_rep
    CHANGING
      ct_selclause = it_selclause
      ct_grouplist = it_grouplist.


  APPEND 'P~CONDITION_TYPE AS KSCHL' TO it_selclause.
  APPEND 'P~CONDITION_TYPE' TO it_grouplist.

  IF iv_aggregate_by_shkzg EQ abap_true.
    DELETE it_grouplist WHERE table_line EQ 'SHKZG'.
    DELETE it_selclause WHERE table_line EQ 'SHKZG'.
  ENDIF.

*  Append default selection fields and group by
*  Overlap columns between structure INCL_EEW_FARR_REP & CI_COBL
*  are default selection fields and group by
  CALL METHOD cl_farr_rev_collect_db_access=>default_selection
    IMPORTING
      et_selclause = it_default_selclause
      et_grouplist = it_default_grouplist.
  APPEND LINES OF it_default_selclause TO it_selclause.
  APPEND LINES OF it_default_grouplist TO it_grouplist.

  APPEND LINES OF it_aggregate_fields TO it_selclause.
  APPEND LINES OF it_aggregate_fields TO it_grouplist.

  "Added to collect Contract ID and Flex contract details from FARR_D_POSTING based on custom logic
  APPEND 'P~CONTRACT_ID AS ZZCNTRID' TO it_selclause.
  APPEND 'ZZACCCFL' TO it_selclause.
  APPEND 'P~CONTRACT_ID' TO it_grouplist.
  APPEND 'ZZACCCFL' TO it_grouplist.
  APPEND 'ZZCNTRID' TO it_grouplist.

  CALL METHOD select_table
    EXPORTING
      it_company_code     = it_company_code
      iv_acct_principle   = iv_acct_principle
      iv_fiscal_year      = iv_fiscal_year
      iv_period           = iv_period
      it_sel_contract     = its_contract_id
      it_recon_key_status = it_recon_key_status
      it_selclause        = it_selclause
      it_grouplist        = it_grouplist
      it_where_tab        = it_where_tab
      it_sel_run_id       = it_sel_run_id
    IMPORTING
      et_data             = et_posting_list.

  "Skip standard implementation
  RETURN.
  EXIT.

ENDENHANCEMENT.
