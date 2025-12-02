CLASS lcl_zrar_farr_spdi_origid_enh DEFINITION DEFERRED.
CLASS cl_farric_sd_order DEFINITION LOCAL FRIENDS lcl_zrar_farr_spdi_origid_enh.
CLASS lcl_zrar_farr_spdi_origid_enh DEFINITION.
  PUBLIC SECTION.
    CLASS-DATA obj TYPE REF TO lcl_zrar_farr_spdi_origid_enh. "#EC NEEDED
    DATA core_object TYPE REF TO cl_farric_sd_order .       "#EC NEEDED
 INTERFACES  IPO_ZRAR_FARR_SPDI_ORIGID_ENH.
    METHODS:
      constructor IMPORTING core_object
                              TYPE REF TO cl_farric_sd_order OPTIONAL.
ENDCLASS.
CLASS lcl_zrar_farr_spdi_origid_enh IMPLEMENTATION.
  METHOD constructor.
    me->core_object = core_object.
  ENDMETHOD.
* Enhacement start code changes defect 16064 SAKOTA DS4K901999
  METHOD ipo_zrar_farr_spdi_origid_enh~insert_custom_sdpi_conditions.
*"------------------------------------------------------------------------*
*" Declaration of POST-method, do not insert any comments here please!
*"
*"methods INSERT_CUSTOM_SDPI_CONDITIONS
*"  importing
*"    !IS_VBAK type VBAK
*"    !IS_RAI_MAIN_ITEM type FARRIC_S_SD01MI
*"    !IT_KOMV type KOMV_TAB
*"    !IT_VBPA type VA_VBPAVB_T
*"    !IS_VBAP type VBAPVB
*"    !IS_VBKD type VBKDVB
*"    !IS_FPLA type FPLAVB
*"    !IS_FPLT type IF_FARRIC_SD_ORDER=>TY_FPLT_EX
*"    !IV_PLACEHOLDER_RAI type XFELD optional
*"  changing
*"    !CS_PLANNED_INV_ITEM type FARRIC_S_SD03MI
*"    !CT_PLANNED_INV_COND type FARRIC_TT_SD03CO
*"    !CT_RAI_CONDITIONS type FARRIC_TT_SD01CO
*"    !CV_KOND_UPDKZ type BOOLEAN.
*"------------------------------------------------------------------------*

*    IF cs_planned_inv_item-srcdoc_type = 'SDPI'.
** Begnin of changes Defect 18930 SAKOTA
*      DATA: lv_zzravbeln TYPE vbkd-zzravbeln.
*      CONSTANTS c_posnr TYPE posnr VALUE '000000'.
*      CLEAR lv_zzravbeln.
*
*      SELECT SINGLE zzravbeln
*               INTO lv_zzravbeln
*               FROM vbkd
*               WHERE vbeln = is_vbak-vbeln
*                 AND posnr = c_posnr.
**  cs_planned_inv_item-origdoc_id = is_vbkd-zzravbeln && is_vbap-prctr+1(9)
*   "Begin of changes 19499 FCJSJ22 02/06/2022
*     IF lv_zzravbeln IS INITIAL AND NOT is_vbkd-zzravbeln IS INITIAL.
*       lv_zzravbeln = is_vbkd-zzravbeln.
*     ENDIF.
*   "End of changes 19499 FCJSJ22 02/06/2022
*
*    cs_planned_inv_item-origdoc_id = lv_zzravbeln && is_vbap-prctr+1(9)
** End of changes Defect 18930 SAKOTA
*                                    && is_rai_main_item-srcdoc_id.
*    ENDIF.


    IF cs_planned_inv_item-srcdoc_type = 'SDPI'.
* Begnin of changes Defect 18930 SAKOTA
      DATA: lv_zzravbeln TYPE vbkd-zzravbeln,
            lv_flag      TYPE c,
            lr_flag      TYPE STANDARD TABLE OF selopt.
      CONSTANTS c_posnr TYPE posnr VALUE '000000'.
      CLEAR lv_zzravbeln.

      SELECT SINGLE zzravbeln
               INTO lv_zzravbeln
               FROM vbkd
               WHERE vbeln = is_vbak-vbeln
                 AND posnr = c_posnr.
*  cs_planned_inv_item-origdoc_id = is_vbkd-zzravbeln && is_vbap-prctr+1(9)
      "Begin of changes 19499 FCJSJ22 02/06/2022
      IF lv_zzravbeln IS INITIAL AND NOT is_vbkd-zzravbeln IS INITIAL.
        lv_zzravbeln = is_vbkd-zzravbeln.
      ENDIF.
      "End of changes 19499 FCJSJ22 02/06/2022

*Begin of change Defect - 2003 F3XOFTB

* Date variant to check (Historic or Go-forward) contract
      CALL FUNCTION 'ZEXTRACT_TVARVC'
        EXPORTING
          i_name   = 'Z_PC_DATE'
        TABLES
          t_selopt = lr_flag.

      READ TABLE lr_flag INTO DATA(ls_flag) INDEX 1.

      IF ls_flag-low > is_vbak-erdat.
          cs_planned_inv_item-origdoc_id = lv_zzravbeln && is_vbap-prctr+1(9)
                                            && is_rai_main_item-srcdoc_id.
      ELSE.
        cs_planned_inv_item-origdoc_id = is_rai_main_item-srcdoc_id.
      ENDIF.
*End of change Defect - 2003 F3XOFTB

** End of changes Defect 18930 SAKOTA

    ENDIF.

  ENDMETHOD.
* Enhacement start code changes defect 16064 SAKOTA DS4K901999
ENDCLASS.
