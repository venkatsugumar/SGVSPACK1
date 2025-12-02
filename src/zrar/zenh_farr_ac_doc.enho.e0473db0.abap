"Name: \TY:CL_FARR_AC_DOCUMENT\ME:CONVERT_TO_ACCIT_ACCCR\SE:END\EI
ENHANCEMENT 0 ZENH_FARR_AC_DOC.
 FIELD-SYMBOLS: <ls_accit> TYPE accit.
  data:          lwa_settl_acct TYPE farr_s_settl_act,
                 lv_adj_settl_dt TYPE c,
                 lwa_accit TYPE accit.

*-- Check for any settlement line exists in the MCCIT table
*-- Find the settlement account based on the company code from RAR configuration
  lwa_settl_acct = cl_farr_settle_account_access=>query_settlement_account( iv_bukrs = mv_company_code ).

*-- If account exists
  IF lwa_settl_acct-hkont IS NOT INITIAL.


* TRY.
*-- Find any settlement account entry in item tables
    READ TABLE mt_accit INTO lwa_accit with key hkont = lwa_settl_acct-hkont.
    IF sy-subrc eq 0.
*-- If exists adjust the settlement account line with the custom fields information
      lv_adj_settl_dt = abap_true.
    ENDIF.
* CATCH cx_sy_itab_line_not_found.
* ENDTRY.
  ENDIF.
*-- If settlement account entry found
  CHECK lv_adj_settl_dt = abap_true.
  CLEAR lwa_accit.
  LOOP AT mt_accit ASSIGNING <ls_accit>.
*-- Copy first item data to copy the ZZ_CONTRACT_ID/XBLNR/XREF1_HD
    IF lwa_accit IS INITIAL.
      lwa_accit = <ls_accit>.
    ENDIF.
*-- Check for the current line is settlement line
    CHECK <ls_accit>-hkont = lwa_settl_acct-hkont.
*-- Copy the ZZ_CONTRACT_ID/XBLNR/XREF1_HD
* <ls_accit>-zzcontract_id = lwa_accit-zzcontract_id.
    <ls_accit>-xblnr = lwa_accit-xblnr.
    <ls_accit>-xref1_hd = lwa_accit-xref1_hd.
    <ls_accit>-xref1 = lwa_accit-xref1.
    <ls_accit>-xref2 = lwa_accit-xref2.
    <ls_accit>-xref3 = lwa_accit-xref3.
  ENDLOOP.
ENDENHANCEMENT.
