class ZCL_RAR_FARR_BADI_RAI0 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FARR_BADI_RAI0 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_RAR_FARR_BADI_RAI0 IMPLEMENTATION.


  method IF_FARR_BADI_RAI0~CHECK_BEFORE_SAVE.
  endmethod.


  method IF_FARR_BADI_RAI0~ENRICH.
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
*This badi implemention is a use case where Products have Parent Child structure,
* RAR is relevant for Child POBs.
*We need to de-link the Parent link with the Child POBs while raw revenue accounting.

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
  DATA(lt_co) = ct_rai0_co[].

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
      READ TABLE ct_rai0_mi ASSIGNING FIELD-SYMBOL(<fs_mi>) WITH KEY srcdoc_id = <fs_total>-srcdoc_id.
      IF sy-subrc = 0.
        <fs_mi>-xnegative_item = abap_true.
      ENDIF.
      IF <fs_mi> IS ASSIGNED.
        UNASSIGN <fs_mi>.
      ENDIF.
    ENDIF.

" Check if multiple records with Main Condition Type set
    lt_cond[] = CORRESPONDING #( ct_rai0_co[] ).
    DELETE lt_cond WHERE srcdoc_id NE <fs_total>-srcdoc_id.
    lt_nocond[] = CORRESPONDING #( lt_cond[] ).
    DELETE lt_cond WHERE main_cond_type NE 'X'.
    IF NOT lt_cond[] IS INITIAL.                  "Main Condition is set
      DESCRIBE TABLE lt_cond LINES DATA(lv_cnt).
      IF lv_cnt GT '1'.                           "If Multiple conditions are set as Main
        <fs_total>-flag = abap_true.              "Multiple records flag set
        LOOP AT lt_set INTO DATA(ls_set).
          READ TABLE lt_cond INTO ls_cond WITH KEY condition_type = ls_set-low.
          IF sy-subrc = 0.
            <fs_total>-main_cond = ls_set-low.    "Set Main Condition Type
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

" Check if multiple records with Main Condition Type set
  LOOP AT ct_rai0_co ASSIGNING FIELD-SYMBOL(<fs_co>).
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
    ELSE.
      CONTINUE. "Do nothing
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
LOOP AT ct_rai0_mi ASSIGNING FIELD-SYMBOL(<fs_ct_rai0_mi>).
  IF NOT <fs_ct_rai0_mi>-hildoc_comp IS INITIAL.
    CLEAR <fs_ct_rai0_mi>-hildoc_comp.
  ENDIF.
  IF NOT <fs_ct_rai0_mi>-hildoc_logsys IS INITIAL.
    CLEAR <fs_ct_rai0_mi>-hildoc_logsys.
  ENDIF.
  IF NOT <fs_ct_rai0_mi>-hildoc_type IS INITIAL.
    CLEAR <fs_ct_rai0_mi>-hildoc_type.
  ENDIF.
  IF NOT <fs_ct_rai0_mi>-hildoc_id IS INITIAL.
    CLEAR <fs_ct_rai0_mi>-hildoc_id.
  ENDIF.
*  Begin of defect 17251
  IF <fs_ct_rai0_mi>-ktgrm = '19'.
     <fs_ct_rai0_mi>-bill_plan_type = 'P'.
  ENDIF.
*  End of defect 17251

***Begin of changes for Defect 17617 SUREPAWAR
    READ TABLE lt_type INTO DATA(ls_type) WITH KEY low = <fs_ct_rai0_mi>-srcdoc_type. "Only for certain doc types, based on TVARVC ZRAR_SRCDOC_TYPE
    IF sy-subrc = 0.
      "Exempt Items that have no condition records associated with it
      READ TABLE ct_rai0_co INTO DATA(ls_rai_co) WITH KEY srcdoc_id = <fs_ct_rai0_mi>-srcdoc_id.
      IF sy-subrc = 0.
        "Do nothing
      ELSE.
        <fs_ct_rai0_mi>-status = lc_exempt.     "Set to Processable - Exempted if no conditions
      ENDIF.
    ENDIF.
***End of changes for Defect 17617 SUREPAWAR
*Begin of defect 18109 SAKOTA
    IF NOT lv_ind IS INITIAL.
      <fs_ct_rai0_mi>-effective_date = lv_date.
    ENDIF.
*End of defect 18109 SAKOTA
ENDLOOP.
*End of defect 17245 SAKOTA


  endmethod.
ENDCLASS.
