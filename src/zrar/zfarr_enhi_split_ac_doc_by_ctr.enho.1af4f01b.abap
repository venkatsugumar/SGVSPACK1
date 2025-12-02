"Name: \TY:CL_FARR_AC_DOCUMENT_HANDLER\ME:HANDLE_DOCUMENT\SE:BEGIN\EI
ENHANCEMENT 0 ZFARR_ENHI_SPLIT_AC_DOC_BY_CTR.
*********************************************************************
*&  REVISION LOG                                                    *
*-------------------------------------------------------------------*
*& Date                : MM/DD/YYYY                                 *
*& Ticket/Change Req.# : Help desk ticket number                    *
*& Requested by        : Business Analyst Name                      *
*& Developer(Company)  : Developer Name (Company Name)              *
*& Description         : Brief description of change                *
*********************************************************************
*& Date                : 05/26/2022                                 *
*& Ticket/Change Req.# : Defect 19276                               *
*& Requested by        : Ratnakar Venkat                            *
*& Developer(Company)  : Surekha Pawar                              *
*& Description         : Removed logic to get the contract ID       *
*********************************************************************
  TYPES : BEGIN OF ty_posting,
            zzsddoc        type farr_d_posting-zzsddoc,
            zzsdditm       type farr_d_posting-zzsdditm,
            contract_id    type farr_d_posting-contract_id,
            ZZRAVBELN      type ZZRAVBELN,
            post_cat       type farr_d_posting-post_cat,
            ZZACCCFL       type ZZACCCFL,
            gjahr          TYPE gjahr,
          END OF ty_posting.

  DATA: lt_posting TYPE TABLE of ty_posting,
        lt_mt_posting TYPE farr_tt_ac_document,
        lt_posting_uniqdoc TYPE farr_tt_ac_document,
        lv_emptykey_exists TYPE c,
        lx_exception TYPE REF TO cx_farr_message,
        lwa_posting TYPE farr_s_ac_document,
        lwa_document_to_be_post TYPE farr_s_ac_document,
        lwa_ac_document_original TYPE farr_s_ac_document.

  FIELD-SYMBOLS: <lfwa_posting> TYPE FARR_S_AC_DOCUMENT,
                 <lfw_posting_uniqdoc> TYPE FARR_S_AC_DOCUMENT,
                 <lfw_pob> TYPE ty_posting.

*  Move RAR contract ID to mt_posting-zzcontract_id
  IF lines( mt_posting ) > 0.

************    TEST
*  LOOP AT mt_posting ASSIGNING <lfwa_posting> where zzravbeln is initial.
*  lv_emptykey_exists = abap_true.
*  exit.
*  ENDLOOP.
************  TEST
  IF lv_emptykey_exists = abap_true.
*  -- Raise exception
*  lx_exception = cx_farr_message=>create(
*  iv_msgid = if_farrc_accrual_constants=>co_farr_accr_main " i.e. FARR_MSG_CUSTOM
*  iv_msgno = '856'
*  iv_msgty = 'E'
*  iv_msgv1 = 'Empty CONTRACT_ID exists.'
*  iv_msgv2 = 'single GL posting not possible per contract'
*  iv_msgv3 = 'for company code'
*  iv_msgv4 = mv_company_code
*  ).
  MESSAGE E856(FARR_MSG_CUSTOM) WITH mv_company_code.
  RAISE EXCEPTION lx_exception.
  ELSE.
*****Begin of changes by SUREPAWAR Defect 19276
*    lt_mt_posting = mt_posting.
*    SORT lt_mt_posting by zzsddoc zzsdditm.
*    DELETE ADJACENT DUPLICATES FROM lt_mt_posting COMPARING zzsddoc zzsdditm.
*    SELECT zzsddoc
*           zzsdditm
*           contract_id
*           ZZRAVBELN
*           post_cat
*           ZZACCCFL
*           gjahr
*    FROM farr_d_posting
*    INTO TABLE lt_posting
*    FOR ALL ENTRIES IN lt_mt_posting
*    WHERE zzsddoc     = lt_mt_posting-zzsddoc
*      AND zzsdditm    = lt_mt_posting-zzsdditm.
*
*    IF sy-subrc eq 0.
*      SORT lt_posting by zzsddoc zzsdditm.
*
*      LOOP AT mt_posting ASSIGNING <lfwa_posting>.
*        READ TABLE lt_posting ASSIGNING <lfw_pob> with key zzsddoc = <lfwa_posting>-zzsddoc zzsdditm = <lfwa_posting>-zzsdditm.
*        IF sy-subrc eq 0.
*          <lfwa_posting>-zzcntrid = <lfw_pob>-contract_id.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.
*****End of changes by SUREPAWAR Defect 19276
*    --------------------------------------------------------------------*
    rv_has_post = abap_false.
*     Initial value
    CLEAR mt_single_doc_curr_to_post. " All line items with single document currency
    CLEAR lwa_document_to_be_post. " To be posted posted line items details
    CLEAR lwa_ac_document_original. " All line item
*    *- keep only unique contract id entries in posting doc internal table
    lt_posting_uniqdoc = mt_posting.
    SORT lt_posting_uniqdoc by zzcntrid.
    DELETE ADJACENT DUPLICATES FROM lt_posting_uniqdoc COMPARING zzcntrid.
    CLEAR lt_mt_posting.
    lt_mt_posting = mt_posting.
    CLEAR mt_posting.

    LOOP AT lt_posting_uniqdoc ASSIGNING <lfw_posting_uniqdoc>.
      CLEAR: mt_single_doc_curr_to_post, " All line items with single document currency
             mt_posting, " To be posted posted line items details
             mv_start_posnr_acc, " Accounting Document Line Item Number
             mt_to_split_line_items. " Accounting Document data with split lines to be added

*    -- Fill the unique document related entries into mt_posting table
      LOOP AT lt_mt_posting INTO lwa_posting WHERE zzcntrid = <lfw_posting_uniqdoc>-zzcntrid.
        APPEND lwa_posting to mt_posting.
      ENDLOOP.

      CHECK mt_posting IS NOT INITIAL.
*     Sort by document currency
      SORT mt_posting BY waers.
*     Get the first line to compare document currency
      IF lines( mt_posting ) > 0.
        READ TABLE mt_posting INTO lwa_document_to_be_post INDEX 1.
      ENDIF.

      LOOP AT mt_posting INTO lwa_ac_document_original.
*     Filter input table, delete useless data
        IF lwa_ac_document_original-betrw = 0 AND
           lwa_ac_document_original-betrh = 0 AND
           lwa_ac_document_original-betr2 = 0 AND
           lwa_ac_document_original-betr3 = 0.
          DELETE TABLE mt_posting FROM lwa_ac_document_original.
          CONTINUE.
        ENDIF.

        IF rv_has_post = abap_false.
          rv_has_post = abap_true.
        ENDIF.

        IF lwa_document_to_be_post-waers EQ lwa_ac_document_original-waers.
*         If the document currency is same as the last one,
*         append this line item to the internal table
          APPEND lwa_ac_document_original TO mt_single_doc_curr_to_post.
          DELETE TABLE mt_posting FROM lwa_ac_document_original.
        ELSE.
*         If the document currency is different from the last one,
*         save the new document currency,
*         post the internal table,
*         clear the internal table,
*         apend this line item to the internal table
          lwa_document_to_be_post = lwa_ac_document_original.

          CALL METHOD do_handle_post.
*           EXPORTING
*           it_ac_document = lt_document_to_be_post.
          CLEAR mt_single_doc_curr_to_post.
          APPEND lwa_ac_document_original TO mt_single_doc_curr_to_post.
          DELETE TABLE mt_posting FROM lwa_ac_document_original.
        ENDIF.
      ENDLOOP.

*     If the internal table is not empty,
*     post the internal table
    IF lines( mt_single_doc_curr_to_post ) > 0.
      CALL METHOD do_handle_post.
    ENDIF.

    ENDLOOP.

    clearup( ).
    RETURN. "Once posting is complete exit to skip the standard logic
  ENDIF.
  ENDIF.


ENDENHANCEMENT.
