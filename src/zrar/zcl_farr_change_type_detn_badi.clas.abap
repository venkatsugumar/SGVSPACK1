class ZCL_FARR_CHANGE_TYPE_DETN_BADI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FARR_CHANGE_TYPE_DETN .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_FARR_CHANGE_TYPE_DETN_BADI IMPLEMENTATION.


  METHOD if_farr_change_type_detn~determine_change_type.
***********************************************************************
*& BADI impl         : ZRAR_FARR_BADI_CHANGE_TYPE_DET                 *
*& Module            : RAR                                            *
*& Functional Contact: Sudhesh Anapakula                              *
*& Developer(Company): Sankara Rao Kota                               *
*& Create Date       : 09/10/2021                                     *
*& Program Type      : BADI impl                                      *
*& Project Phase     : SIMPLIFY SIT1                                  *
*& Description       : Defect 16416  RAR Enable Retro  Change for     *
*&                     AAGM 19 Matls                                  *
*& Transports        : DS4K903112                                     *
***********************************************************************
* PROGRAMMER|  DATE    |  TASK#   |  DESCRIPTION                      *
* F3XOFTB   |03/25/2024|DS4K916971|Defect 2275- RAR - Change          *
*                                   from Prospective to Retrospective *
***********************************************************************

    CONSTANTS: c_19 TYPE char2 VALUE '19'. "defect 16426 SAKOTA
    FIELD-SYMBOLS: <ls_pob_change_type> TYPE LINE OF farr_th_chg_type_result_badi."defect 16426 SAKOTA
    CLEAR result.
BREAK SAKOTA.
    LOOP AT pobnewdata ASSIGNING FIELD-SYMBOL(<ls_new_pob_data>).
* Begin of defect 2275 - F3XOFTB
*start of code defect 16426 SAKOTA
*      SELECT SINGLE zzaagfm INTO @DATA(lv_zzaagfm) FROM farr_d_pob
*             WHERE pob_id = @<ls_new_pob_data>-performanceobligation.
*        IF lv_zzaagfm = c_19.
          " create default change type for current POB as retrospective
           INSERT VALUE #( performanceobligation    = <ls_new_pob_data>-performanceobligation
                         perfobligationchangetype = if_farr_change_type_detn~cos_change_type-retrospective )
                 INTO TABLE result ASSIGNING <ls_pob_change_type>.
*        ELSE.
*End of code defect 16426 SAKOTA
          " create default change type for current POB as prospective
*          INSERT VALUE #( performanceobligation    = <ls_new_pob_data>-performanceobligation
*                          perfobligationchangetype = if_farr_change_type_detn~cos_change_type-prospective )
*                 INTO TABLE result ASSIGNING <ls_pob_change_type>.
*        ENDIF. "defect 16426 SAKOTA
* End of defect 2275 - F3XOFTB
*        CONTINUE. "defect SAKOTA
      " if the contract is terminated - this must be a prospective change type
      CHECK contractdata-revncontrassetsimpairmentdate IS INITIAL.

      READ TABLE pobolddata ASSIGNING FIELD-SYMBOL(<ls_old_pob_data>)
        WITH TABLE KEY performanceobligation = <ls_new_pob_data>-performanceobligation.

      IF sy-subrc <> 0.
        " the POB is new - this must be a retrospective change type
        <ls_pob_change_type>-perfobligationchangetype = if_farr_change_type_detn~cos_change_type-retrospective.

      ELSE.
        " Retro Change Type: POB is deleted
        DATA(lv_pob_is_deleted) = xsdbool( <ls_new_pob_data>-perfoblgnismarkedasdeleted = abap_true ).

        " Retro Change Type: start date is changed
        DATA(lv_start_date_is_changed) = xsdbool( <ls_new_pob_data>-performanceobligationstartdate <> <ls_old_pob_data>-performanceobligationstartdate ).

        " Retro Change Type: the deferral method is changed
        DATA(lv_deferral_method_is_changed) = xsdbool( <ls_new_pob_data>-perfobligationdeferralmethod <> <ls_old_pob_data>-perfobligationdeferralmethod ).

        " Retro Change Type: transaction price is CHANGED to 0
        DATA(lv_trans_price_is_changed) = xsdbool( <ls_old_pob_data>-transactionpriceinsalesdoccrcy   <> 0 AND
                                                   <ls_new_pob_data>-transactionpriceinsalesdoccrcy    = 0 ).

        " Retro Change Type: start date >= effective date
        DATA(lv_start_date_gt_eq_efctv_date) = xsdbool( <ls_new_pob_data>-performanceobligationstartdate >= contractdata-revnacctgcontrchangeeffctvdate ).

        " Retro Change Type: Only allocation related fields is changed
        DATA(lv_only_alloc_rltd_flds_chngd) = xsdbool(
              " trx price is not changed
              <ls_new_pob_data>-transactionpriceinsalesdoccrcy = <ls_old_pob_data>-transactionpriceinsalesdoccrcy
          AND " trx_price org is not changed
              <ls_new_pob_data>-origlperfoblgnprinsalesdoccrcy = <ls_old_pob_data>-origlperfoblgnprinsalesdoccrcy
          AND " start date is not changed
              <ls_new_pob_data>-performanceobligationstartdate = <ls_old_pob_data>-performanceobligationstartdate
          AND " end date is not changed
              <ls_new_pob_data>-performanceobligationenddate   = <ls_old_pob_data>-performanceobligationenddate
          AND " deferral method is not changed
              <ls_new_pob_data>-perfobligationdeferralmethod   = <ls_old_pob_data>-perfobligationdeferralmethod
          AND " quantity is not changed
              <ls_new_pob_data>-perfoblgncontractualquantity   = <ls_old_pob_data>-perfoblgncontractualquantity
          AND ( " SSP is changed
                <ls_new_pob_data>-sspriceinsalesdoccrcy          <> <ls_old_pob_data>-sspriceinsalesdoccrcy
            OR " SSP range percentage is changed
                <ls_new_pob_data>-priceallocationtolerancepct    <> <ls_old_pob_data>-priceallocationtolerancepct
            OR " SSP range amount is changed
                <ls_new_pob_data>-pricealloctolamtinsalesdoccrcy <> <ls_old_pob_data>-pricealloctolamtinsalesdoccrcy
            OR " residual POB flag is changed
                <ls_new_pob_data>-perfobligationhasresidual      <> <ls_old_pob_data>-perfobligationhasresidual
            OR " prevent allocation flag is changed
                <ls_new_pob_data>-perfoblgnisexclfrompricealloc  <> <ls_old_pob_data>-perfoblgnisexclfrompricealloc ) ).

        IF   lv_pob_is_deleted              = abap_true
          OR lv_start_date_is_changed       = abap_true
          OR lv_deferral_method_is_changed  = abap_true
          OR lv_trans_price_is_changed      = abap_true
          OR lv_start_date_gt_eq_efctv_date = abap_true
          OR lv_only_alloc_rltd_flds_chngd  = abap_true.
          <ls_pob_change_type>-perfobligationchangetype = if_farr_change_type_detn~cos_change_type-retrospective.
          " ELSE. Default change type is prospective
          "   <ls_pob_change_type>-perfobligationchangetype = if_farr_change_type_detn~cos_change_type-prospective.
        ENDIF.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
