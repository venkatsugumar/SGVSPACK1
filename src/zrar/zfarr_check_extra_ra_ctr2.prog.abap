*&---------------------------------------------------------------------*
*& Report zfarr_check_extra_ra_ctr2.
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfarr_check_extra_ra_ctr2.
*&---------------------------------------------------------------------*
*Check for extra RA contract
*&
*&---------------------------------------------------------------------*
TABLES: farr_d_contract.

TYPES: BEGIN OF ty_s_outdated_pob,
         pob_id          TYPE farr_pob_id,
         contract_id     TYPE farr_contract_id,
         srcdoc_comp     TYPE farr_rai_srcco,
         srcdoc_logsys   TYPE farr_rai_srcls,
         srcdoc_type     TYPE farr_rai_srcty,
         srcdoc_id       TYPE farr_rai_srcid,
         pob_id_c        TYPE farr_pob_id,
         contract_id_c   TYPE farr_contract_id,
         srcdoc_comp_c   TYPE farr_rai_srcco,
         srcdoc_logsys_c TYPE farr_rai_srcls,
         srcdoc_type_c   TYPE farr_rai_srcty,
         srcdoc_id_c     TYPE farr_rai_srcid,
       END OF ty_s_outdated_pob.

TYPES: BEGIN OF ty_wrong_inv_rai,
         srcdoc_id TYPE farr_rai_srcid,
         header_id TYPE farr_header_id,
         item_id   TYPE farr_item_id,
       END OF ty_wrong_inv_rai.

TYPES: BEGIN OF ty_wrong_ra_ctr,
         srcdoc_id TYPE farr_rai_srcid,
         header_id TYPE farr_header_id,
         item_id   TYPE farr_item_id,
       END OF ty_wrong_ra_ctr.

DATA: go_message_handler TYPE REF TO cl_farr_message_handler,
      gv_log_handler     TYPE balloghndl,
      gv_counter         TYPE int4,
      gv_msg_str         TYPE string.

* for data selection
DATA: gt_vbkd         TYPE TABLE OF vbkd,
      gt_vbap         TYPE TABLE OF vbap,
      gt_mapping      TYPE TABLE OF farr_d_mapping,
      gt_outdated_pob TYPE TABLE OF ty_s_outdated_pob,
      gt_wrong_ra_ctr TYPE TABLE OF ty_wrong_ra_ctr.

*----------------------------------------------------------------------*
*              Selection Screen                                        *
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK ctrl WITH FRAME TITLE t_data.
  PARAMETERS: p_vbeln TYPE vbeln,
              p_test  TYPE abap_bool AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK ctrl.

*----------------------------------------------------------------------*
*              Global variant identification                           *
*----------------------------------------------------------------------*

DATA:
  gi_fieldcat_pob  TYPE slis_t_fieldcat_alv.

*----------------------------------------------------------------------*
*              INITIALIZATION                                          *
*----------------------------------------------------------------------*
INITIALIZATION.
  t_data = 'Data selection'.

  %_p_vbeln_%_app_%-text  = 'Document Number'.
  %_p_test_%_app_%-text   = 'Test moode (No updates)'.

START-OF-SELECTION.
  PERFORM initialize_global_parameters.
  PERFORM start_of_work.

*&---------------------------------------------------------------------*
*&      Form  start_of_work
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM start_of_work.
  PERFORM  sel_data.

  PERFORM check_pob.

  IF p_test IS INITIAL.
    PERFORM adjust_rai.
  ENDIF.

  PERFORM close_application_log.
  PERFORM display_result.

ENDFORM.                    "start_of_work
*&---------------------------------------------------------------------*
*&      Form  sel_farr_cons_from_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM sel_data.
  DATA: lv_header_id      TYPE farr_header_id,
        lv_acct_principle TYPE accounting_principle.

* read invoice table entries
  SELECT *  INTO TABLE gt_vbkd FROM vbkd
            WHERE  vbeln EQ p_vbeln
            ORDER BY PRIMARY KEY.

  SELECT *  INTO TABLE gt_vbap FROM vbap
           WHERE  vbeln EQ p_vbeln
           ORDER BY PRIMARY KEY.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_vbeln
    IMPORTING
      output = lv_header_id.

  lv_acct_principle = 'GAAP'. " only accounting principle used

  SELECT * INTO TABLE gt_mapping FROM farr_d_mapping
             WHERE header_id EQ lv_header_id
             AND   acct_principle EQ lv_acct_principle
             AND   soft_deleted  EQ ' '
  ORDER BY PRIMARY KEY.

ENDFORM.                    "sel_dupplicate_missing_mapping
*&---------------------------------------------------------------------*
*&      Form  sel_farr_cons_from_db
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_pob.
  DATA: lv_orgigdoc_id TYPE farric_rai_oriid,
        lv_zzravbeln   TYPE vbkd-zzravbeln,
        lv_prctr       TYPE char9.

  DATA: ls_outdated_pob TYPE ty_s_outdated_pob,
        ls_vbkd_hd      TYPE vbkd.

  DATA: lt_mapping    TYPE TABLE OF farr_d_mapping.

  CONSTANTS: c_posnr_hd TYPE posnr  VALUE '000000'.

  FIELD-SYMBOLS:<ls_vbkd>     TYPE vbkd,
                <ls_vbap>     TYPE vbap,
                <ls_mapping1> TYPE farr_d_mapping,
                <ls_mapping2> TYPE farr_d_mapping.

  lt_mapping = gt_mapping.

  LOOP AT gt_vbap ASSIGNING <ls_vbap>.

    READ TABLE gt_vbkd ASSIGNING <ls_vbkd> WITH KEY vbeln = <ls_vbap>-vbeln
                                                    posnr = <ls_vbap>-posnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

    IF <ls_vbkd>-farr_reltype IS INITIAL.
      CONTINUE.
    ENDIF.

    lv_prctr  = <ls_vbap>-prctr+1.

    READ TABLE gt_vbkd INTO ls_vbkd_hd WITH KEY vbeln = <ls_vbap>-vbeln
                                             posnr = c_posnr_hd.

    IF sy-subrc EQ 0 AND ls_vbkd_hd-zzravbeln  IS NOT INITIAL.
      lv_zzravbeln  = ls_vbkd_hd-zzravbeln.
    ELSE.
      lv_zzravbeln = <ls_vbkd>-zzravbeln.
    ENDIF.

    CONCATENATE <ls_vbkd>-vbeln <ls_vbkd>-posnr INTO lv_orgigdoc_id.
    LOOP AT gt_mapping ASSIGNING <ls_mapping1> WHERE acct_principle EQ 'GAAP'.
      IF ( <ls_mapping1>-srcdoc_id+19(16) EQ lv_orgigdoc_id ) AND
         ( <ls_mapping1>-srcdoc_id(10)    NE lv_zzravbeln  OR     "zzravbeln
           <ls_mapping1>-srcdoc_id+10(9)  NE lv_prctr  ).

* if a wrong entry exists look if a correct one is available
        LOOP AT lt_mapping ASSIGNING <ls_mapping2>.
          IF ( <ls_mapping2>-srcdoc_id+19(16) EQ lv_orgigdoc_id ) AND
             ( <ls_mapping2>-srcdoc_id(10)    EQ lv_zzravbeln ) AND    "zzravbeln
             ( <ls_mapping2>-srcdoc_id+10(9)  EQ lv_prctr ).

            MOVE-CORRESPONDING <ls_mapping1> TO ls_outdated_pob.

            ls_outdated_pob-pob_id_c        = <ls_mapping2>-pob_id.
            ls_outdated_pob-contract_id_c   = <ls_mapping2>-contract_id.
            ls_outdated_pob-srcdoc_comp_c   = <ls_mapping2>-srcdoc_comp.
            ls_outdated_pob-srcdoc_logsys_c = <ls_mapping2>-srcdoc_logsys.
            ls_outdated_pob-srcdoc_type_c   = <ls_mapping2>-srcdoc_type.
            ls_outdated_pob-srcdoc_id_c     = <ls_mapping2>-srcdoc_id.

            APPEND ls_outdated_pob TO gt_outdated_pob.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  add_select_counter_to_log.
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM add_select_counter_to_log.
  MESSAGE i000(fb)
  WITH gv_counter
  'Number of POB in error'
  INTO gv_msg_str.

  CALL METHOD go_message_handler->add_symessage
    EXPORTING
      iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global.
ENDFORM.                    "add_select_counter_to_log

*&---------------------------------------------------------------------*
*&      Form  adjust_rev_quantity_delta
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM adjust_rai.
  DATA: ls_defitem TYPE farr_d_defitem.

  DATA: lv_msg       TYPE string ##NEEDED,
        lv_timestamp TYPE tzntstmps.

  DATA: lt_rai_mi_all TYPE   farr_tt_rai_mi_all,
        lt_rai_co_all TYPE   farr_tt_rai_co_all,
        lt_rai12_mi   TYPE farr_tt_rai2_mi_all,
        lt_rai12_co   TYPE farr_tt_rai2_co_all,
        lt_rai32_mi   TYPE farr_tt_rai2_mi_all,
        lt_rai32_co   TYPE farr_tt_rai2_co_all.

  DATA: ls_rai2_mi TYPE farr_s_rai2_mi_all,
        ls_rai2_co TYPE farr_s_rai2_co_all.

  DATA: lo_rai_selection TYPE REF TO if_farr_rai_db_selection.
  DATA: lo_rai_db_service TYPE REF TO cl_farr_rai_db_service.

  lo_rai_db_service   = cl_farr_rai_db_service=>get_instance( ).

  FIELD-SYMBOLS: <ls_outdated_pob> TYPE ty_s_outdated_pob,
                 <ls_rai_mi_all>   TYPE farr_s_rai_mi_all,
                 <ls_rai_co_all>   TYPE farr_s_rai_co_all.

  IF lo_rai_selection IS NOT BOUND.
    lo_rai_selection = cl_farr_rai_factory=>get_instance_selection( ).
  ENDIF.

  CLEAR: lt_rai12_mi,
         lt_rai12_co,
         lt_rai32_mi,
         lt_rai32_co.

  GET TIME STAMP FIELD  lv_timestamp.

  LOOP AT gt_outdated_pob ASSIGNING <ls_outdated_pob>.

    SELECT SINGLE * FROM farr_d_defitem INTO ls_defitem WHERE pob_id = <ls_outdated_pob>
                                                        AND category       = if_farrc_contr_mgmt=>co_category_price
                                                        AND spec_indicator = if_farrc_contr_mgmt=>co_indicator_main_price
                                                        AND latest_defitem = abap_true.

    IF sy-subrc EQ 0.
      IF ( ls_defitem-inv_amt_total + ls_defitem-inv_amt_delta )  EQ 0.

        CALL METHOD lo_rai_selection->rai_db_select_single_key
          EXPORTING
*           iv_raic          = '01'
            iv_srcdoc_comp   = <ls_outdated_pob>-srcdoc_comp
            iv_srcdoc_logsys = <ls_outdated_pob>-srcdoc_logsys
            iv_srcdoc_type   = <ls_outdated_pob>-srcdoc_type
            iv_srcdoc_id     = <ls_outdated_pob>-srcdoc_id
            iv_status        = '4'
          IMPORTING
            et_rai_mi_all    = lt_rai_mi_all
            et_rai_co_all    = lt_rai_co_all
          EXCEPTIONS
            not_found        = 1
            OTHERS           = 2.

        LOOP AT lt_rai_mi_all ASSIGNING <ls_rai_mi_all>.
          MOVE-CORRESPONDING <ls_rai_mi_all> TO ls_rai2_mi.
          ls_rai2_mi-deletion_ind   = abap_true.
          ls_rai2_mi-timestamp_utc = lv_timestamp.
          ls_rai2_mi-status        = '2'.
          APPEND ls_rai2_mi TO lt_rai12_mi.
          IF <ls_rai_mi_all>-status NE '4'.
            MESSAGE e119(farr_application) INTO lv_msg
             WITH | { 'Unprocessed RAI'  } { <ls_outdated_pob>-srcdoc_id } |  ##NEEDED ##MG_MISSING.

            go_message_handler->add_symessage( iv_ctx_type = if_farrc_msg_handler_cons=>co_ctx_global
                                               iv_probcl   = if_shdb_pfw_logger=>c_probclass_high ).

            EXIT.
          ENDIF.
        ENDLOOP.

        LOOP AT lt_rai_co_all ASSIGNING <ls_rai_co_all>.
          MOVE-CORRESPONDING <ls_rai_co_all> TO ls_rai2_co.
          ls_rai2_co-timestamp_utc = lv_timestamp.
          APPEND ls_rai2_co TO lt_rai12_co.
        ENDLOOP.

      ELSE.
        CALL METHOD lo_rai_selection->rai_db_select_with_origin
          EXPORTING
            iv_origdoc_comp   = <ls_outdated_pob>-srcdoc_comp
            iv_origdoc_logsys = <ls_outdated_pob>-srcdoc_logsys
            iv_origdoc_type   = <ls_outdated_pob>-srcdoc_type
            iv_origdoc_id     = <ls_outdated_pob>-srcdoc_id
          IMPORTING
            et_rai_mi_all     = lt_rai_mi_all
            et_rai_co_all     = lt_rai_co_all
          EXCEPTIONS
            not_found         = 1
            OTHERS            = 2.

        LOOP AT lt_rai_mi_all ASSIGNING <ls_rai_mi_all> WHERE srcdoc_type EQ 'SDII' AND status EQ '4'.
          MOVE-CORRESPONDING <ls_rai_mi_all> TO ls_rai2_mi.
          ls_rai2_mi-quantity = ls_rai2_mi-quantity * -1.
          ls_rai2_mi-status   = '2'.
          ls_rai2_mi-srcdoc_logsys = 'CANCEL'.
          ls_rai2_mi-timestamp_utc = lv_timestamp.
          APPEND ls_rai2_mi TO lt_rai32_mi.

          " new RAI entries for correct POB
          MOVE-CORRESPONDING <ls_rai_mi_all> TO ls_rai2_mi.
          ls_rai2_mi-origdoc_comp   = <ls_outdated_pob>-srcdoc_comp_c.
          ls_rai2_mi-origdoc_logsys = <ls_outdated_pob>-srcdoc_logsys_c.
          ls_rai2_mi-origdoc_type   = <ls_outdated_pob>-srcdoc_type_c.
          ls_rai2_mi-origdoc_id     = <ls_outdated_pob>-srcdoc_id_c.
          ls_rai2_mi-status        = '2'.
          ls_rai2_mi-srcdoc_logsys = 'CORR'.
          ls_rai2_mi-timestamp_utc = lv_timestamp.
          APPEND ls_rai2_mi TO lt_rai32_mi.
        ENDLOOP.

        LOOP AT lt_rai_co_all ASSIGNING <ls_rai_co_all> WHERE srcdoc_type EQ 'SDII'.
          " cancellation RAI for wrong POB
          MOVE-CORRESPONDING <ls_rai_co_all> TO ls_rai2_co.
          ls_rai2_co-srcdoc_logsys = 'CANCEL'.
          ls_rai2_co-timestamp_utc = lv_timestamp.
          ls_rai2_co-betrw = ls_rai2_co-betrw * -1.
          ls_rai2_co-betrh = ls_rai2_co-betrh * -1.
          ls_rai2_co-betr2 = ls_rai2_co-betr2 * -1.
          ls_rai2_co-betr3 = ls_rai2_co-betr3 * -1.
          APPEND ls_rai2_co TO lt_rai32_co.

          " new RAI entries for correct POB
          MOVE-CORRESPONDING <ls_rai_co_all> TO ls_rai2_co.
          ls_rai2_co-srcdoc_logsys = 'CORR'.
          ls_rai2_co-timestamp_utc = lv_timestamp.
          APPEND ls_rai2_co TO lt_rai32_co.
        ENDLOOP.

      ENDIF.
    ENDIF.
  ENDLOOP.


  IF lt_rai32_mi IS INITIAL.
    " Insert RAI2 into database
    IF lt_rai12_mi IS NOT INITIAL.
      lo_rai_db_service->if_farr_rai_db_access~rai2_insert(
            EXPORTING
              iv_raic       = 'SD01'
              it_rai2_mi    = lt_rai12_mi
              it_rai2_co    = lt_rai12_co  ).
      WRITE: 'SD01 Correction items created'.
    ENDIF.

  ELSE.

    lo_rai_db_service->if_farr_rai_db_access~rai2_insert(
    EXPORTING
      iv_raic       = 'SD03'
      it_rai2_mi    = lt_rai32_mi
      it_rai2_co    = lt_rai32_co  ).

    WRITE: 'SD03 Correction items created'.
  ENDIF.

  COMMIT WORK.

ENDFORM.                    "set_currency_key

*&---------------------------------------------------------------------*
*&      Form  close_application_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM close_application_log.
  TRY.
      gv_log_handler = go_message_handler->get_log_handler( ).
      CALL METHOD go_message_handler->save_and_close_app_log( ).

      COMMIT WORK.
    CATCH cx_farr_message.
  ENDTRY.
ENDFORM.                    "close_application_log

*&---------------------------------------------------------------------*
*&      Form  display_result
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_result.
  DATA: lt_fieldcat  TYPE slis_t_fieldcat_alv,
        ls_fieldcat  TYPE slis_fieldcat_alv,
        lv_alv_title TYPE lvc_title.

  IF sy-batch = abap_false.
*    PERFORM show_application_log.

    IF gt_outdated_pob[] IS INITIAL.
      WRITE 'No duplicate POB found'.
    ELSE.

      ls_fieldcat-fieldname = 'POB_ID'.
      ls_fieldcat-outputlen = 16.
      ls_fieldcat-seltext_m = 'POB ID Incorrect'.
      APPEND ls_fieldcat TO lt_fieldcat.

      ls_fieldcat-fieldname = 'CONTRACT_ID'.
      ls_fieldcat-outputlen = 14.
      ls_fieldcat-seltext_m = 'Contract ID Incorrect'.
      APPEND ls_fieldcat TO lt_fieldcat.

      ls_fieldcat-fieldname = 'SRCDOC_ID'.
      ls_fieldcat-outputlen = 35.
      ls_fieldcat-seltext_m = 'SRCDOC_ID'.
      APPEND ls_fieldcat TO lt_fieldcat.

      ls_fieldcat-fieldname = 'POB_ID_C'.
      ls_fieldcat-outputlen = 16.
      ls_fieldcat-seltext_m = 'POB ID Correct'.
      APPEND ls_fieldcat TO lt_fieldcat.

      ls_fieldcat-fieldname = 'CONTRACT_ID_C'.
      ls_fieldcat-outputlen = 14.
      ls_fieldcat-seltext_m = 'Contract ID. Correct'.
      APPEND ls_fieldcat TO lt_fieldcat.

      lv_alv_title = 'Outdated POB'.

      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
        EXPORTING
          it_fieldcat  = lt_fieldcat
          i_grid_title = lv_alv_title
        TABLES
          t_outtab     = gt_outdated_pob.

    ENDIF.
  ENDIF.
ENDFORM.                    "repair_one_contract

*&---------------------------------------------------------------------*
*&      Form  show_application_log
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM show_application_log.
  DATA: ls_filter          TYPE bal_s_lfil,
        lrs_log_handler    TYPE bal_s_logh,
        lt_header          TYPE balhdr_t,
        ls_display_profile TYPE bal_s_prof.

  lrs_log_handler-sign  = 'I'.
  lrs_log_handler-option = 'EQ'.
  TRY.
      lrs_log_handler-low =  gv_log_handler.
    CATCH cx_farr_message.
  ENDTRY.
  APPEND lrs_log_handler TO ls_filter-log_handle.

  CALL FUNCTION 'BAL_DB_SEARCH'
    EXPORTING
      i_s_log_filter = ls_filter
    IMPORTING
      e_t_log_header = lt_header
    EXCEPTIONS
      OTHERS         = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CALL FUNCTION 'BAL_DB_LOAD'
    EXPORTING
      i_t_log_header         = lt_header
      i_do_not_load_messages = abap_false
    EXCEPTIONS
      OTHERS                 = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* get a prepared profile
  CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
    IMPORTING
      e_s_display_profile = ls_display_profile
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  ls_display_profile-disvariant-report = sy-repid.
  ls_display_profile-disvariant-handle = 'LOG'.

*  Display without context
  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile = ls_display_profile
    EXCEPTIONS
      OTHERS              = 1.
  IF sy-subrc <> 0.
    MESSAGE ID   sy-msgid
    TYPE sy-msgty
    NUMBER sy-msgno
    WITH sy-msgv1
    sy-msgv2
    sy-msgv3
    sy-msgv4.
  ENDIF.
ENDFORM.                    "show_application_log

*&---------------------------------------------------------------------*
*&      Form  initialize_global_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM initialize_global_parameters.
  DATA:
        lx_farr_message         TYPE REF TO cx_farr_message.

  CREATE OBJECT go_message_handler.
  TRY.
      CALL METHOD go_message_handler->initialize
        EXPORTING
          iv_sub_obj = 'CLEANUP'.
    CATCH cx_farr_message INTO lx_farr_message.
      MESSAGE ID lx_farr_message->mv_msgid
      TYPE lx_farr_message->mv_msgty
      NUMBER lx_farr_message->mv_msgno
      WITH lx_farr_message->mv_msgv1
      lx_farr_message->mv_msgv2
      lx_farr_message->mv_msgv3
      lx_farr_message->mv_msgv4.
  ENDTRY.

ENDFORM.                    "initialize_global_parameters
