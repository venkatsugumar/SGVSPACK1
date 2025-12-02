"Name: \TY:CL_FARR_REV_COLLECT_DB_ACCESS\ME:COLLECT_POSTING_DATA_SIMULATE\SE:BEGIN\EI
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
        it_contract_id_range TYPE farr_tt_contract_id_range,
        lw_contract_id_range LIKE LINE OF it_contract_id_range,
        lw_contract_id       LIKE LINE OF its_contract_id,
        it_default_selclause TYPE farr_tt_edid_line,
        it_default_grouplist TYPE farr_tt_fieldname.

  CLEAR et_posting_list.
  CLEAR it_contract_id_range.

  LOOP AT its_contract_id INTO lw_contract_id.
    lw_contract_id_range-sign   = 'I'.
    lw_contract_id_range-option = 'EQ'.
    lw_contract_id_range-low    = lw_contract_id.
    APPEND lw_contract_id_range TO it_contract_id_range.
  ENDLOOP.

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

  APPEND 'CONDITION_TYPE' TO it_selclause.
  APPEND 'P~CONTRACT_ID AS CONTRACT_ID' TO it_selclause.
*  APPEND 'P~RECON_KEY AS RECON_KEY' TO lt_selclause.         Note 2647129

  APPEND 'P~CONDITION_TYPE' TO it_grouplist.
  APPEND 'P~CONTRACT_ID' TO it_grouplist.
*  APPEND 'P~RECON_KEY' TO lt_grouplist.         Note 2647129

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

  "Collect additional data from FARR_D_POSTING
  APPEND 'P~CONTRACT_ID AS ZZCNTRID' TO it_selclause.
  APPEND 'ZZACCCFL' TO it_selclause.
  APPEND 'ZZACCCFL' TO it_grouplist.
  APPEND 'ZZCNTRID' TO it_grouplist.

  CALL METHOD select_table
    EXPORTING
      it_company_code     = it_company_code
      iv_acct_principle   = iv_acct_principle
      iv_fiscal_year      = iv_fiscal_year
      iv_period           = iv_period
      it_sel_contract     = it_contract_id_range
      it_recon_key_status = it_recon_key_status
      it_selclause        = it_selclause
      it_grouplist        = it_grouplist
    IMPORTING
      et_data             = et_posting_list.

  "Skip Standard implementation
  RETURN.
  EXIT.
ENDENHANCEMENT.
