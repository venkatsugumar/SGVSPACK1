class ZCL_RAR_FARR_BADI_RAI2 definition
  public
  final
  create public .

public section.

*"* public components of class ZCL_RAR_FARR_BADI_RAI2
*"* do not include other source files here!!!
  interfaces IF_BADI_INTERFACE .
  interfaces IF_FARR_BADI_RAI2 .

  methods FILL_REFERENCE
    importing
      !IV_RAIC type FARR_RAIC
    changing
      !CT_RAI2_MI type FARR_TT_RAI2_MI_ALL optional
      !CT_RAI2_CO type FARR_TT_RAI2_CO_ALL optional
      !CT_MESSAGES type FARR_TT_RAI_MSG optional .
protected section.
*"* protected components of class ZCL_RAR_FARR_BADI_RAI2
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_RAR_FARR_BADI_RAI2
*"* do not include other source files here!!!

  data MO_RAI_DB_SELECTION type ref to IF_FARR_RAI_DB_SELECTION .
ENDCLASS.



CLASS ZCL_RAR_FARR_BADI_RAI2 IMPLEMENTATION.


METHOD FILL_REFERENCE.
* IMPORTANT: all RAIs with the same Reference Type and Reference ID will be processed together.
* Furthermore, if using the default BAdI implementation of BAdI FARR_BADI_CONTRACT_COMBINATION
* all RAIs with the same reference type and if will lead to POBs in the same contract,
* RAIs with different refernce types and IDs will end up in seperate contracts.
* Please consider this when using another implementation.
* For more details please refer to documentation of DTEL FARR_RAI_REFID and FARR_RAI_REFTYPE.

  DATA:
    ls_messages     TYPE farr_s_rai_msg,
    ls_rai2_mi      TYPE farr_s_rai2_mi_all,
    ls_rai_srckey   TYPE farr_s_rai_srckey,
    lv_rai_id_short TYPE tex50,
    lv_ctx_value    TYPE farr_rai_id_char,
        lv_tabix          TYPE sy-tabix.
  DATA:
    lr_mapping  TYPE REF TO cl_farr_rai_mapping_ctrl.
  DATA:
    ls_mapping TYPE farr_s_mapping,
    lt_mapping TYPE farr_tt_mapping.
  DATA:
    ls_srcdoc TYPE farr_s_srcdoc,
    lt_srcdoc TYPE farr_tt_srcdoc.

*--Fill ReferenceID and ReferenceType in Main Item
*  but only for order items
  LOOP AT ct_rai2_mi INTO ls_rai2_mi
    WHERE reference_id IS INITIAL AND
          raic_type = cl_farr_rai_co=>gc_raic_type_orderitem.
    lv_tabix = sy-tabix.

    "check first if mapping table is filled
    CLEAR: lt_srcdoc.
    MOVE-CORRESPONDING ls_rai2_mi TO ls_srcdoc.
    APPEND ls_srcdoc TO lt_srcdoc.
    CREATE OBJECT lr_mapping.
    TRY.
        CALL METHOD lr_mapping->if_farr_rai_mapping_ctrl~read_mapping_by_srcdoc
          EXPORTING
            it_srcdoc  = lt_srcdoc
          IMPORTING
            et_mapping = lt_mapping.
      CATCH cx_farr_not_found.
        CLEAR: lt_mapping.
    ENDTRY.
    READ TABLE lt_mapping INTO ls_mapping INDEX 1.
    IF sy-subrc = 0.
      ls_rai2_mi-reference_type = ls_mapping-reference_type.
      ls_rai2_mi-reference_id = ls_mapping-reference_id.

    ELSE.
      "based on reference type
      IF ls_rai2_mi-reference_type IS NOT INITIAL.
        "check if ReferenceType is valid
        IF cl_farr_rai_cust=>exists_reference_type( ls_rai2_mi-reference_type ) IS INITIAL.
          MOVE-CORRESPONDING ls_rai2_mi TO ls_rai_srckey.
          CALL METHOD cl_farr_rai_util=>get_rai_id
            EXPORTING
              is_rai_key      = ls_rai_srckey
            IMPORTING
              ev_rai_id_short = lv_rai_id_short
              ev_rai_id       = lv_ctx_value.
          MESSAGE e051(farr_rai) WITH ls_rai2_mi-reference_type lv_rai_id_short
            INTO cl_farr_rai_util=>str.
          MOVE-CORRESPONDING ls_rai2_mi TO ls_messages.     "#EC ENHOK
          MOVE-CORRESPONDING sy TO ls_messages.
          "the context value and type is used in the application log
          "all messages stored for one RAI can be displayed together.
          ls_messages-ctx_type  = if_farrc_msg_handler_cons=>co_ctx_rai_id.
          MOVE lv_ctx_value TO ls_messages-ctx_value.
          APPEND ls_messages TO ct_messages.
          CONTINUE.
        ENDIF.

        IF ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_customer.
          MOVE ls_rai2_mi-kunnr TO ls_rai2_mi-reference_id.
        ELSEIF ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_partner.
          MOVE ls_rai2_mi-partner TO ls_rai2_mi-reference_id.
        ELSEIF ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_order OR
               ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_prov_order OR
               ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_header.
          MOVE ls_rai2_mi-header_id TO ls_rai2_mi-reference_id.
        ENDIF.
      ELSE."ReferenceType not filled
        "based on data fields
        IF ls_rai2_mi-header_id IS NOT INITIAL.
          MOVE ls_rai2_mi-header_id TO ls_rai2_mi-reference_id.
          IF ls_rai2_mi-raic = cl_farr_rai_co=>gc_raic_ca01.
            ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_prov_order.
          ELSEIF ls_rai2_mi-raic = cl_farr_rai_co=>gc_raic_sd01.
            ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_order.
          ELSE.
            ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_header.
          ENDIF.
        ELSEIF ls_rai2_mi-kunnr IS NOT INITIAL.
          MOVE ls_rai2_mi-kunnr TO ls_rai2_mi-reference_id.
          ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_customer.
        ELSEIF ls_rai2_mi-partner IS NOT INITIAL.
          MOVE ls_rai2_mi-partner TO ls_rai2_mi-reference_id.
          ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_partner.
        ELSE.
          MOVE ls_rai2_mi-srcdoc_id(10) TO ls_rai2_mi-reference_id.
          IF ls_rai2_mi-raic = cl_farr_rai_co=>gc_raic_ca01.
            ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_prov_order.
          ELSEIF ls_rai2_mi-raic = cl_farr_rai_co=>gc_raic_sd01.
            ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_order.
          ELSE.
            ls_rai2_mi-reference_type = cl_farr_rai_co=>gc_reftype_header.
          ENDIF.
        ENDIF.
      ENDIF."reftype filled
    ENDIF.

    MODIFY ct_rai2_mi FROM ls_rai2_mi INDEX lv_tabix.
  ENDLOOP.


ENDMETHOD.


METHOD IF_FARR_BADI_RAI2~CHECK_BEFORE_SAVE.
*checks that should be executed before RAI2 is saved to data base
*key of erroneous items with correponding error messages have
*to be added to CT_MESSAGES


ENDMETHOD.


METHOD if_farr_badi_rai2~enrich.
*********************************************************************
*&  REVISION LOG                                                    *
*-------------------------------------------------------------------*
*& Date                : 12/02/2021                                 *
*& Ticket/Change Req.# : Defect 17537                               *
*& Requested by        : Sudhesh Anapakula                          *
*& Developer(Company)  : Surekha Pawar                              *
*& Description         : Setting the negative item flag for Document*
*                        with negative amount                       *
*********************************************************************
*-------------------------------------------------------------------*
*& Date                : 12/09/2021                                 *
*& Ticket/Change Req.# : Defect 17617                               *
*& Requested by        : Sudhesh Anapakula                          *
*& Developer(Company)  : Surekha Pawar                              *
*& Description         : Exempt Items having NO condition records.  *
*&                       Set the status to Processable - Exempted   *
*********************************************************************
*-------------------------------------------------------------------*
*& Date                : 12/20/2024                                 *
*& Ticket/Change Req.# : Defect 3059                                *
*& Developer(Company)  : Mohammed Imran Khan (F4SAWAM)              *
*& Description         : ACDOCA not populating Customer number for  *
*&                       RAR ECC converted Sales Docs starting      *
*&                       8/27/2024                                  *
*********************************************************************
*This badi implemention is a use case where Products have Parent Child structure,
* RAR is relevant for Child POBs.
* We need to de-link the Parent link with the Child POBs while process revenue accounting.

***Start of changes for Defect 17537 SUREPAWAR
  TYPES: BEGIN OF ty_co,
          srcdoc_id TYPE farr_rai_srcid,      "Source ID
          betrw TYPE farr_amount_tc,          "Amount
          flag TYPE boolean,                  "Flag for Multiple Conditions Set as Main
          main_cond TYPE kscha,               "Main Condition Type
         END OF ty_co,
         BEGIN OF ty_cond,
           srcdoc_id TYPE farr_rai_srcid,           "Source ID
           condition_type TYPE kscha,               "Condition Type
           main_cond_type TYPE farr_main_cond_type, "Flag for Main Condition Type
         END OF ty_cond.

  DATA: ls_total TYPE ty_co,
        lt_total TYPE STANDARD TABLE OF ty_co,
        ls_cond TYPE ty_cond,
        lt_cond TYPE STANDARD TABLE OF ty_cond,
        lt_nocond TYPE STANDARD TABLE OF ty_cond.

  CONSTANTS: lc_exempt TYPE farr_rai_status VALUE '3'.        "Added as part of Defect 17617 SUREPAWAR

  "Get the preference of Condition Types
  SELECT low FROM tvarvc
          WHERE name = 'ZRAR_MAIN_COND_SET'
          INTO TABLE @DATA(lt_set).
  IF sy-subrc = 0.

  ENDIF.

  REFRESH: lt_total[], lt_cond[].
  CLEAR: ls_total, ls_cond.
  DATA(lt_co) = ct_rai2_co[].
*Begin of Insertion by F4SAWAM Defect 3059 on 12/20/2024
    LOOP AT ct_rai2_mi ASSIGNING FIELD-SYMBOL(<fs>).

    IF  <fs>-KNDNR is INITIAL.
      <fs>-KNDNR = <fs>-kunnr.
    ENDIF.

  ENDLOOP.
  UNASSIGN : <fs>.
*End of Insertion by F4SAWAM Defect 3059 on 12/20/2024
"Calculate the total amount value for each SRCDOC_ID
  SORT lt_co BY srcdoc_id.
  LOOP AT lt_co INTO DATA(ls_co) WHERE statistic IS INITIAL. "For Non Statistical conditions
    ls_total = CORRESPONDING #( ls_co ).
    COLLECT ls_total INTO lt_total.
    CLEAR: ls_total, ls_co.
  ENDLOOP.

  LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<fs_total>).    "For Each Source ID
"Identify items with negative amount value and Set the Negative Item flag as X in Main Items
    IF <fs_total>-betrw LT 0.
      READ TABLE ct_rai2_mi ASSIGNING FIELD-SYMBOL(<fs_mi>) WITH KEY srcdoc_id = <fs_total>-srcdoc_id.
      IF sy-subrc = 0.
        <fs_mi>-xnegative_item = abap_true.
      ENDIF.
      IF <fs_mi> IS ASSIGNED.
        UNASSIGN <fs_mi>.
      ENDIF.
    ENDIF.

" Check if multiple/No records with Main Condition Type set
    lt_cond[] = CORRESPONDING #( ct_rai2_co[] ).
    DELETE lt_cond WHERE srcdoc_id NE <fs_total>-srcdoc_id.
    lt_nocond[] = CORRESPONDING #( lt_cond[] ).
    DELETE lt_cond WHERE main_cond_type NE 'X'.
    IF NOT lt_cond[] IS INITIAL.                    "Main Condition is set
      DESCRIBE TABLE lt_cond LINES DATA(lv_cnt).
      IF lv_cnt GT '1'.                             "If Multiple conditions are set as Main
        <fs_total>-flag = abap_true.                "Multiple records
        LOOP AT lt_set INTO DATA(ls_set).
          READ TABLE lt_cond INTO ls_cond WITH KEY condition_type = ls_set-low.
          IF sy-subrc = 0.
            <fs_total>-main_cond = ls_set-low.      "Set Main Condition Type
            EXIT.
          ELSE.
            CONTINUE.
          ENDIF.
          CLEAR: ls_set, ls_cond.
        ENDLOOP.
      ENDIF.
    ELSE.   "If No conditions are set as Main
      <fs_total>-flag = abap_false.      "No Records
      CLEAR: ls_set.
      LOOP AT lt_set INTO ls_set.
        READ TABLE lt_nocond INTO DATA(ls_nocond) WITH KEY condition_type = ls_set-low.
        IF sy-subrc = 0.
          <fs_total>-main_cond = ls_set-low.
          EXIT.
        ELSE.
          CONTINUE.
        ENDIF.
        CLEAR: ls_set, ls_cond.
      ENDLOOP.
    ENDIF.
    REFRESH: lt_cond[], lt_nocond[].
  ENDLOOP.

" Check if multiple/No records with Main Condition Type set
  LOOP AT ct_rai2_co ASSIGNING FIELD-SYMBOL(<fs_co>).
    CLEAR: ls_total.
    READ TABLE lt_total INTO ls_total WITH KEY srcdoc_id = <fs_co>-srcdoc_id.
    IF sy-subrc = 0.
      IF ls_total-flag = abap_true.  "Multiple Condition set as Main
        IF <fs_co>-condition_type EQ ls_total-main_cond.
          "Do nothing
          CONTINUE.
        ELSE.
          CLEAR: <fs_co>-main_cond_type.
        ENDIF.
      ELSE. "No Main Condition set
        IF NOT ls_total-main_cond IS INITIAL.
          IF <fs_co>-condition_type EQ ls_total-main_cond.
            <fs_co>-main_cond_type = abap_true.
          ELSE.
            CONTINUE.
          ENDIF.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

***End of changes for Defect 17537 SUREPAWAR

***Begin of changes for Defect 17617 SUREPAWAR
    "Get the Source Doc types maintained in TVARVC
    SELECT low
           INTO TABLE @DATA(lt_type)
           FROM tvarvc
           WHERE name = 'ZRAR_SRCDOC_TYPE'
           AND type = 'S'.
    IF sy-subrc = 0.
      "Do nothing
    ENDIF.
***End of changes for Defect 17617 SUREPAWAR
*Begin of defect 18109 SAKOTA
  "Get the effective date update indicator in TVARVC
  SELECT SINGLE low FROM tvarvc
          WHERE name = 'ZRAR_EFF_DATE_UPD_IND'
            AND type = 'P'
          INTO @DATA(lv_ind).

  "Get the effective date in TVARVC
  SELECT SINGLE low FROM tvarvc
          WHERE name = 'ZRAR_EFFECTIVE_DATE_YYYYMMDD'
            AND type = 'P'
          INTO @DATA(lv_date).
*End of defect 18109 SAKOTA

*Begin of defect 17245 SAKOTA
LOOP AT ct_rai2_mi ASSIGNING FIELD-SYMBOL(<fs_ct_rai2_mi>).
  IF NOT <fs_ct_rai2_mi>-hildoc_comp IS INITIAL.
    CLEAR <fs_ct_rai2_mi>-hildoc_comp.
  ENDIF.
  IF NOT <fs_ct_rai2_mi>-hildoc_logsys IS INITIAL.
    CLEAR <fs_ct_rai2_mi>-hildoc_logsys.
  ENDIF.
  IF NOT <fs_ct_rai2_mi>-hildoc_type IS INITIAL.
    CLEAR <fs_ct_rai2_mi>-hildoc_type.
  ENDIF.
  IF NOT <fs_ct_rai2_mi>-hildoc_id IS INITIAL.
    CLEAR <fs_ct_rai2_mi>-hildoc_id.
  ENDIF.
*  Begin of defect 17251
  IF <fs_ct_rai2_mi>-ktgrm = '19'.
     <fs_ct_rai2_mi>-bill_plan_type = 'P'.
  ENDIF.
*  End of defect 17251
*  Begin of defect 17523

  DATA(lv_tabkey) = sy-mandt && <fs_ct_rai2_mi>-header_id+10(10) && <fs_ct_rai2_mi>-item_id+9(6) .
  SELECT * FROM cdpos INTO TABLE @DATA(lt_cdpos) WHERE
    objectclas = 'VERKBELEG' AND
    objectid = @<fs_ct_rai2_mi>-header_id+10(10) AND
    tabname = 'VBAP' AND
    tabkey =  @lv_tabkey AND
    fname = 'ABGRU'.
    IF NOT lt_cdpos IS INITIAL.
      SORT lt_cdpos by changenr DESCENDING.
      DATA(wa_cdpos) = VALUE #( lt_cdpos[ 1 ] optional ).

*      IF NOT wa_cdpos-value_old IS INITIAL AND wa_cdpos-value_new IS INITIAL. "1039 SAKOTA
       IF NOT wa_cdpos is INITIAL.
        SELECT SINGLE * FROM veda INTO @DATA(wa_veda) WHERE
          vbeln = @<fs_ct_rai2_mi>-header_id+10(10) AND
          vposn = @<fs_ct_rai2_mi>-item_id+9(6).
          IF sy-subrc = 0.
             <fs_ct_rai2_mi>-end_date = wa_veda-venddat.
          ENDIF.
* Begin of comments 1039 SAKOTA
*      ELSEIF NOT wa_cdpos-value_new IS INITIAL.
*        SELECT SINGLE * FROM cdhdr INTO @DATA(wa_cdhdr) WHERE
*          objectclas = 'VERKBELEG' AND
*          objectid = @<fs_ct_rai2_mi>-header_id+10(10) AND
*          changenr = @wa_cdpos-changenr.
*          IF sy-subrc = 0.
*            <fs_ct_rai2_mi>-end_date = wa_cdhdr-udate.
*          ENDIF.
* End of comments 1039 SAKOTA
      ENDIF.
    ENDIF.
*  End of defect 17523

***Begin of changes for Defect 17617 SUREPAWAR
    READ TABLE lt_type INTO DATA(ls_type) WITH KEY low = <fs_ct_rai2_mi>-srcdoc_type. "Only for certain doc types, based on TVARVC ZRAR_SRCDOC_TYPE
    IF sy-subrc = 0.
      "Exempt Items that have no condition records associated with it
      READ TABLE ct_rai2_co INTO DATA(ls_rai_co) WITH KEY srcdoc_id = <fs_ct_rai2_mi>-srcdoc_id.
      IF sy-subrc = 0.
        "Do nothing
      ELSE.
        <fs_ct_rai2_mi>-status = lc_exempt.     "Set to Processable - Exempted if no conditions
      ENDIF.
    ENDIF.
***End of changes for Defect 17617 SUREPAWAR
*Begin of defect 18109 SAKOTA
    IF NOT lv_ind IS INITIAL.
      <fs_ct_rai2_mi>-effective_date = lv_date.
    ENDIF.
*End of defect 18109 SAKOTA
ENDLOOP.
*End of defect 17245 SAKOTA
*--Fill ReferenceID and ReferenceType
* only with newly created RAIs, otheriwse mapping table entries are taken into account
  CALL METHOD me->fill_reference
    EXPORTING
      iv_raic          = iv_raic
    CHANGING
      ct_rai2_mi       = ct_rai2_mi
      ct_rai2_co       = ct_rai2_co
      ct_messages      = ct_messages.

ENDMETHOD.
ENDCLASS.
