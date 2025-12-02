*&---------------------------------------------------------------------*
*& Include          Z_ETL_CBR_RULE_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_9001 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9001 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.
  SET TITLEBAR 'TITLE9001'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9001 INPUT.
  CLEAR : error_flag.
  CASE sy-ucomm.
    WHEN '&F03' OR '&F15' OR '&F12'.
*      LEAVE TO SCREEN 0.
      LEAVE PROGRAM.
    WHEN 'FC_CRT'.
      PERFORM f_check_mandatory_fields.
      IF error_flag NE abap_true.
        PERFORM f_create_entry.
      ENDIF.
*    WHEN 'FC_UPD'.
*      PERFORM f_update_entry.
    WHEN 'FC_DEL'.
      PERFORM f_check_mandatory_fields.
      IF error_flag NE abap_true.
        PERFORM f_delete_entry.
      ENDIF.

    WHEN 'FC_DISP'.
      IF disp_rule1 EQ abap_true AND disp_rule2 EQ abap_true.
        MESSAGE 'Please select only one table to display' TYPE 'S' DISPLAY LIKE 'E'.
        CLEAR : disp_rule1, disp_rule2.
        error_flag = abap_true.
        EXIT.
      ENDIF.
      IF error_flag NE abap_true.
        CALL SCREEN 9002.
      ENDIF.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form f_create_entry
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_create_entry .
  DATA : ls_rule1 TYPE zetl_cbr_rule1,
         ls_rule2 TYPE zetl_cbr_rule2.
  IF NOT gs_etl_cbr_rule1 IS INITIAL OR NOT gs_etl_cbr_rule2 IS INITIAL.
    IF NOT gs_etl_cbr_rule1 IS INITIAL.
      SELECT SINGLE * FROM zetl_cbr_rule1
        INTO ls_rule1
        WHERE rule_id        = gs_etl_cbr_rule1-rule_id.
*        AND   company_code   = gs_etl_cbr_rule1-company_code
*        AND   gl_proj_code   = gs_etl_cbr_rule1-gl_proj_code
*        AND   gl_prod_code   = gs_etl_cbr_rule1-gl_prod_code
*        AND   sub_code       = gs_etl_cbr_rule1-sub_code.
      IF sy-subrc EQ 0.
        MESSAGE 'Entry already exists in Rule1 table' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        gs_etl_cbr_rule1-created_by = sy-uname.
        gs_etl_cbr_rule1-creation_date = sy-datum.
        gs_etl_cbr_rule1-last_update_login = sy-datum.
        MODIFY zetl_cbr_rule1 FROM gs_etl_cbr_rule1.
        IF sy-subrc EQ 0.
          MESSAGE 'Entry updated successfully' TYPE 'S'.
          CLEAR : gs_etl_cbr_rule1.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT gs_etl_cbr_rule2 IS INITIAL.
      SELECT SINGLE * FROM zetl_cbr_rule2
        INTO ls_rule2
        WHERE rule_id           = gs_etl_cbr_rule2-rule_id
*        AND   pass_counter      = gs_etl_cbr_rule2-pass_counter
        AND   status            = 'A'.
      IF sy-subrc EQ 0.
        MESSAGE 'Entry already exists in Rule2 table' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        gs_etl_cbr_rule2-created_by = sy-uname.
        gs_etl_cbr_rule2-creation_date = sy-datum.
        gs_etl_cbr_rule2-last_update_login = sy-datum.
        MODIFY zetl_cbr_rule2 FROM gs_etl_cbr_rule2.
        IF sy-subrc EQ 0.
          MESSAGE 'Entry updated successfully' TYPE 'S'.
          CLEAR : gs_etl_cbr_rule2.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF gs_etl_cbr_rule1 IS INITIAL AND gs_etl_cbr_rule2 IS INITIAL.
    MESSAGE 'Please maintain alteast one table entry' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_update_entry
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_update_entry .
*  DATA : ls_rule1 TYPE zetl_cbr_rule1,
*         ls_rule2 TYPE zetl_cbr_rule2.
*  IF NOT gs_etl_cbr_rule1 IS INITIAL OR NOT gs_etl_cbr_rule2 IS INITIAL.
*    IF NOT gs_etl_cbr_rule1 IS INITIAL.
*      SELECT SINGLE * FROM zetl_cbr_rule1
*        INTO ls_rule1
*        WHERE rule_id         = gs_etl_cbr_rule1-rule_id
*        AND   s_company       = gs_etl_cbr_rule1-s_company
*        AND   sap_gl          = gs_etl_cbr_rule1-sap_gl
*        AND   s_proft_center  = gs_etl_cbr_rule1-s_proft_center
*        AND   purpose_of_rule = gs_etl_cbr_rule1-purpose_of_rule
*        AND   s_intercompany  = gs_etl_cbr_rule1-s_intercompany
*        AND   s_project       = gs_etl_cbr_rule1-s_project
*        AND   s_product       = gs_etl_cbr_rule1-s_product
*        AND   s_client        = gs_etl_cbr_rule1-s_client
*        AND   sub_code        = gs_etl_cbr_rule1-sub_code
*        AND   sub_name        = gs_etl_cbr_rule1-sub_name
*        and   delind = space.
*      IF sy-subrc NE 0.
*        MESSAGE 'Entry doesnot exists in Rule1 table' TYPE 'S' DISPLAY LIKE 'E'.
*        EXIT.
*      ELSE.
*        gs_etl_cbr_rule1-last_update_date = sy-datum.
*        gs_etl_cbr_rule1-last_updated_by = sy-uname.
*        MODIFY zetl_cbr_rule1 FROM gs_etl_cbr_rule1.
*        IF sy-subrc EQ 0.
*          MESSAGE 'Entry updated successfully' TYPE 'S'.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*    IF NOT gs_etl_cbr_rule2 IS INITIAL.
*      SELECT SINGLE * FROM zetl_cbr_rule2
*        INTO ls_rule2
*        WHERE rule_id           = gs_etl_cbr_rule2-rule_id
*        AND   t_company         = gs_etl_cbr_rule2-t_company
*        AND   sap_gl            = gs_etl_cbr_rule2-sap_gl
*        AND   sap_profit_center = gs_etl_cbr_rule2-sap_profit_center
*        AND   purpose_of_rule   = gs_etl_cbr_rule2-purpose_of_rule
*        AND   pass_counter      = gs_etl_cbr_rule2-pass_counter
*        AND   status            = gs_etl_cbr_rule2-status
*        AND   rule_descr        = gs_etl_cbr_rule2-rule_descr
*        AND   product           = gs_etl_cbr_rule2-product
*        AND   t_client          = gs_etl_cbr_rule2-t_client
*        AND   t_intercompany    = gs_etl_cbr_rule2-t_intercompany
*        AND   t_project         = gs_etl_cbr_rule2-t_project
*        AND   t_product         = gs_etl_cbr_rule2-t_product
*        AND   statistic_amount  = gs_etl_cbr_rule2-statistic_amount
*        AND   journal_line_descr = gs_etl_cbr_rule2-journal_line_descr
*        and   delind = space.
*      IF sy-subrc NE 0.
*        MESSAGE 'Entry doesnot exists in Rule2 table' TYPE 'S' DISPLAY LIKE 'E'.
*        EXIT.
*      ELSE.
*        gs_etl_cbr_rule2-last_update_dat = sy-datum.
*        gs_etl_cbr_rule2-last_updated_by = sy-uname.
*        MODIFY zetl_cbr_rule2 FROM gs_etl_cbr_rule2.
*        IF sy-subrc EQ 0.
*          MESSAGE 'Entry updated successfully' TYPE 'S'.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*  ELSEIF gs_etl_cbr_rule1 IS INITIAL AND gs_etl_cbr_rule2 IS INITIAL.
*    MESSAGE 'Please maintain alteast one table entry' TYPE 'S' DISPLAY LIKE 'E'.
*    EXIT.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_delete_entry
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_delete_entry .
  DATA : ls_rule1 TYPE zetl_cbr_rule1,
         ls_rule2 TYPE zetl_cbr_rule2.
  IF NOT gs_etl_cbr_rule1 IS INITIAL OR NOT gs_etl_cbr_rule2 IS INITIAL.
    IF NOT gs_etl_cbr_rule1 IS INITIAL.
      SELECT SINGLE * FROM zetl_cbr_rule1
        INTO ls_rule1
        WHERE rule_id         = gs_etl_cbr_rule1-rule_id
        AND   company_code       = gs_etl_cbr_rule1-company_code
*        AND   sap_gl          = gs_etl_cbr_rule1-sap_gl
*        AND   s_proft_center  = gs_etl_cbr_rule1-s_proft_center
*        AND   purpose_of_rule = gs_etl_cbr_rule1-purpose_of_rule
*        AND   s_intercompany  = gs_etl_cbr_rule1-s_intercompany
*        AND   s_project       = gs_etl_cbr_rule1-s_project
*        AND   s_product       = gs_etl_cbr_rule1-s_product
*        AND   s_client        = gs_etl_cbr_rule1-s_client
*        AND   sub_code        = gs_etl_cbr_rule1-sub_code
*        AND   sub_name        = gs_etl_cbr_rule1-sub_name
        AND   delind = space.
      IF sy-subrc NE 0.
        MESSAGE 'Entry doesnot exists in Rule1 table' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        gs_etl_cbr_rule1 = ls_rule1.
        gs_etl_cbr_rule1-delind = abap_true.
        gs_etl_cbr_rule1-last_update_date = sy-datum.
        gs_etl_cbr_rule1-last_updated_by = sy-uname.
        gs_etl_cbr_rule1-last_update_login = sy-datum.
        MODIFY zetl_cbr_rule1 FROM gs_etl_cbr_rule1.
        IF sy-subrc EQ 0.
          MESSAGE 'Entry deleted successfully' TYPE 'S'.
          CLEAR : gs_etl_cbr_rule1.
        ENDIF.
      ENDIF.
    ENDIF.
    IF NOT gs_etl_cbr_rule2 IS INITIAL.
      SELECT SINGLE * FROM zetl_cbr_rule2
        INTO ls_rule2
        WHERE rule_id           = gs_etl_cbr_rule2-rule_id
*        AND   t_company         = gs_etl_cbr_rule2-t_company
*        AND   sap_gl            = gs_etl_cbr_rule2-sap_gl
*        AND   sap_profit_center = gs_etl_cbr_rule2-sap_profit_center
*        AND   purpose_of_rule   = gs_etl_cbr_rule2-purpose_of_rule
        AND   pass_counter      = gs_etl_cbr_rule2-pass_counter
*        AND   status            = gs_etl_cbr_rule2-status
*        AND   rule_descr        = gs_etl_cbr_rule2-rule_descr
*        AND   product           = gs_etl_cbr_rule2-product
*        AND   t_client          = gs_etl_cbr_rule2-t_client
*        AND   t_intercompany    = gs_etl_cbr_rule2-t_intercompany
*        AND   t_project         = gs_etl_cbr_rule2-t_project
*        AND   t_product         = gs_etl_cbr_rule2-t_product
*        AND   statistic_amount  = gs_etl_cbr_rule2-statistic_amount
*        AND   journal_line_descr = gs_etl_cbr_rule2-journal_line_descr
        AND   delind = space.
      IF sy-subrc NE 0.
        MESSAGE 'Entry doesnot exists in Rule2 table' TYPE 'S' DISPLAY LIKE 'E'.
        EXIT.
      ELSE.
        gs_etl_cbr_rule2 = ls_rule2.
        gs_etl_cbr_rule2-status = 'IA'.
        gs_etl_cbr_rule2-delind = abap_true.
        gs_etl_cbr_rule2-last_update_dat = sy-datum.
        gs_etl_cbr_rule2-last_updated_by = sy-uname.
        gs_etl_cbr_rule2-last_update_login = sy-datum.
        MODIFY zetl_cbr_rule2 FROM gs_etl_cbr_rule2.
        IF sy-subrc EQ 0.
          MESSAGE 'Entry deleted successfully' TYPE 'S'.
          CLEAR : gs_etl_cbr_rule2.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSEIF gs_etl_cbr_rule1 IS INITIAL AND gs_etl_cbr_rule2 IS INITIAL.
    MESSAGE 'Please maintain alteast one table entry' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_RULE1
*&---------------------------------------------------------------------*
FORM f_rule1_display_alv.

  DATA : container1  TYPE REF TO cl_gui_custom_container,
         grid        TYPE REF TO cl_gui_alv_grid,
         it_fieldcat TYPE lvc_t_fcat,
         w_variant   TYPE disvariant.
*  DATA : lt_rule1 TYPE TABLE OF zetl_cbr_rule1.


  CLEAR : lt_rule1.
  SELECT * FROM zetl_cbr_rule1 INTO TABLE lt_rule1
    WHERE delind = space.
*

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      i_structure_name       = 'ZETL_CBR_RULE1'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
      i_internal_tabname     = 'LT_RULE1'
    CHANGING
      ct_fieldcat            = it_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



  CREATE OBJECT container1
    EXPORTING
      container_name = 'CUSTOM'.

  CREATE OBJECT grid
    EXPORTING
      i_parent = container1.

  w_variant-report = sy-repid.

  CALL METHOD grid->set_table_for_first_display
    EXPORTING
      is_variant                    = w_variant
      i_save                        = 'A'
    CHANGING
      it_outtab                     = lt_rule1[]
      it_fieldcatalog               = it_fieldcat[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_9002 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'STATUS_9001'.
* SET TITLEBAR 'xxx'.

  IF disp_rule1 EQ abap_true .
    PERFORM f_rule1_display_alv.
  ELSEIF disp_rule2 EQ abap_true.
    PERFORM f_rule2_display_alv.
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.


  CASE sy-ucomm.
    WHEN '&F03' OR '&F12' OR '&F15'.
      LEAVE TO SCREEN 0.
*	WHEN .
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Form f_rule2_display_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_rule2_display_alv .

  DATA : container1  TYPE REF TO cl_gui_custom_container,
         grid        TYPE REF TO cl_gui_alv_grid,
         it_fieldcat TYPE lvc_t_fcat.
*  DATA : lt_rule2 TYPE TABLE OF zetl_cbr_rule2.


  CLEAR : lt_rule2.
  SELECT * FROM zetl_cbr_rule2 INTO TABLE lt_rule2
    WHERE delind = space.
*

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
*     I_BUFFER_ACTIVE        =
      i_structure_name       = 'ZETL_CBR_RULE2'
*     I_CLIENT_NEVER_DISPLAY = 'X'
*     I_BYPASSING_BUFFER     =
      i_internal_tabname     = 'LT_RULE2'
    CHANGING
      ct_fieldcat            = it_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.



  CREATE OBJECT container1
    EXPORTING
      container_name = 'CUSTOM'.

  CREATE OBJECT grid
    EXPORTING
      i_parent = container1.

  CALL METHOD grid->set_table_for_first_display
    CHANGING
      it_outtab                     = lt_rule2[]
      it_fieldcatalog               = it_fieldcat[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f_check_mandatory_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_check_mandatory_fields .
  IF gs_etl_cbr_rule1 IS NOT INITIAL.
    IF gs_etl_cbr_rule1-rule_id IS INITIAL .
*      OR gs_etl_cbr_rule1-company_code IS INITIAL.     " Removed validation
      MESSAGE 'Please enter mandatory fields' TYPE 'W' DISPLAY LIKE 'E'.
      error_flag = abap_true.
      EXIT.
    ENDIF.
  ENDIF.
  IF gs_etl_cbr_rule2 IS NOT INITIAL.
    IF gs_etl_cbr_rule2-rule_id IS INITIAL .
*       gs_etl_cbr_rule2-account IS INITIAL OR        " Removed validation
*       gs_etl_cbr_rule2-profit_center IS INITIAL OR
*       gs_etl_cbr_rule2-pass_counter IS INITIAL OR
*       gs_etl_cbr_rule2-status IS INITIAL OR
*       gs_etl_cbr_rule2-journal_line_descr IS INITIAL.
      MESSAGE 'Please enter mandatory fields' TYPE 'W' DISPLAY LIKE 'E'.
      error_flag = abap_true.
      EXIT.
    ENDIF.
  ENDIF.
ENDFORM.
