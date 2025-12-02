class ZCL_FARR_POSTING_ENHANCEMENT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FARR_POSTING_ENHANCEMENT .
protected section.
private section.
ENDCLASS.



CLASS ZCL_FARR_POSTING_ENHANCEMENT IMPLEMENTATION.


  METHOD if_farr_posting_enhancement~process_cust_fields.
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
*& Description         : Removed logic to get the contract ID and   *
*&                       pass the data from incoming item to the    *
*&                       accounting document.                       *
*********************************************************************
*& Date                : 12/30/2024                                 *
*& Ticket/Change Req.# : FSAP - 369                                 *
*& Developer(Company)  : Mohammed Imran Khan                        *
*& Description         : Accounting Contract in RAR POB required    *
*&                       to be from sales contract line item        *                      *
*********************************************************************
    DATA: lv_acccfl(20) TYPE c.
    DATA lv_zzsddoc(10).

    IF  is_rr_line_item-zzsddoc IS NOT INITIAL
    AND is_rr_line_item-zzsdditm IS NOT INITIAL.

**Begin of Insertion by F3XOFTB FSAP - 369
      SELECT SINGLE * FROM vbkd
        INTO @DATA(ls_vbkd)
        WHERE vbeln = @is_rr_line_item-zzsddoc AND
              posnr = @is_rr_line_item-zzsdditm.
**End of Insertion by F3XOFTB FSAP - 369
*      select contract_id,zzsddoc,ZZSDDITM,ZZRAVBELN,post_cat,ZZACCCFL,gjahr"RALVARADO-03092022 - Defect 18123 - Fiscal year not allowed
*****Begin of changes by SUREPAWAR Defect 19276
*      SELECT contract_id,zzsddoc,zzsdditm,zzravbeln,post_cat,zzacccfl
*        FROM farr_d_posting
*        INTO @DATA(ls_posting)
*        UP TO 1 ROWS
*        WHERE zzsddoc     = @is_rr_line_item-zzsddoc
*          AND zzsdditm    = @is_rr_line_item-zzsdditm
*          AND post_cat    = @is_rr_line_item-post_cat
*          ORDER BY zzsddoc,zzsdditm.
*      ENDSELECT.
*****End of changes by SUREPAWAR Defect 19276
      CALL FUNCTION 'CONVERSION_EXIT_RRCON_OUTPUT'
        EXPORTING
          input  = is_rr_line_item-zzcntrid  "ls_posting-contract_id      "Changed by SUREPAWAR Defect 19276
        IMPORTING
          output = cs_acc_it-xblnr.

      MOVE cs_acc_it-xblnr      TO cs_acc_it-xref1.
      MOVE is_rr_line_item-post_cat TO cs_acc_it-xref2. "ls_posting-post_cat  TO cs_acc_it-xref2.  "Changed by SUREPAWAR Defect 19276

      CALL FUNCTION 'CONVERSION_EXIT_RRCON_OUTPUT'
        EXPORTING
          input  = is_rr_line_item-zzacccfl "ls_posting-zzacccfl   "Changed by SUREPAWAR Defect 19276
        IMPORTING
          output = cs_acc_it-zuonr.

*          move ls_posting-zzacccfl to cs_acc_it-sgtxt.
*      MOVE is_rr_line_item-zzravbeln TO cs_acc_it-zzravbeln.  "ls_posting-zzravbeln TO cs_acc_it-zzravbeln. "Changed by SUREPAWAR Defect 19276
**Begin of Insertion by F3XOFTB FSAP - 369
      IF ls_vbkd-zzravbeln IS NOT INITIAL.
        MOVE ls_vbkd-zzravbeln TO cs_acc_it-zzravbeln.
      ENDIF.
**End of Insertion by F3XOFTB FSAP - 369

      DATA(lv_doc) = is_rr_line_item-zzsddoc.       "Added by SUREPAWAR Defect 19276
      IF is_rr_line_item-zzsddoc+0(1) <> 'O'. "defect 18035SAKOTA

        CALL FUNCTION 'CONVERSION_EXIT_RRCON_INPUT'
          EXPORTING
            input  = lv_doc "ls_posting-zzsddoc       "Changed by SUREPAWAR Defect 19276
          IMPORTING
            output = lv_doc. "ls_posting-zzsddoc.     "Changed by SUREPAWAR Defect 19276
      ELSE.
        lv_zzsddoc = is_rr_line_item-zzsddoc+1(9).  "ls_posting-zzsddoc+1(9).   "Changed by SUREPAWAR Defect 19276
        CALL FUNCTION 'CONVERSION_EXIT_RRCON_INPUT'
          EXPORTING
            input  = lv_zzsddoc
          IMPORTING
            output = lv_doc. "ls_posting-zzsddoc.     "Changed by SUREPAWAR Defect 19276
        CLEAR lv_zzsddoc.
      ENDIF.                                 "defect 18035SAKOTA
      MOVE lv_doc TO cs_acc_it-kdauf. "ls_posting-zzsddoc   TO cs_acc_it-kdauf.     "Changed by SUREPAWAR Defect 19276


      CALL FUNCTION 'CONVERSION_EXIT_RRCON_INPUT'
        EXPORTING
          input  = is_rr_line_item-zzsdditm "ls_posting-zzsdditm    "Changed by SUREPAWAR Defect 19276
        IMPORTING
          output = cs_acc_it-kdpos.

      CLEAR: lv_acccfl.

*          cs_acc_it-gjahr = ls_posting-gjahr.        "RALVARADO-03092022 - Defect 18123 - Fiscal year not allowed


    ENDIF.



  ENDMETHOD.
ENDCLASS.
