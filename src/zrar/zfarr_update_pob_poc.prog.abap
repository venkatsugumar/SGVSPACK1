*&---------------------------------------------------------------------*
*& Report  ZFARR_UPDATE_POB_POC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zfarr_update_pob_poc.

TYPES: BEGIN OF ty_pob_poc,
         pob_id     TYPE farr_pob_id,
         event_date TYPE farr_fulfill_date,
         poc        TYPE farr_fulfilled_poc,
         zzsddoc    TYPE farr_d_pob-zzsddoc,
         zzsdditm   TYPE farr_d_pob-zzsdditm,
         status     type string,
         message    TYPE string,
         test_run   TYPE c,
         color      TYPE lvc_t_scol,
       END OF ty_pob_poc,
       tty_pob_poc TYPE STANDARD TABLE OF ty_pob_poc,

       BEGIN OF ty_con_poc,
         contract_id   TYPE farr_contract_id,
         pob_id        TYPE farr_pob_id,
         zzsddoc       TYPE farr_d_pob-zzsddoc,
         zzsdditm      TYPE farr_d_pob-zzsdditm,
         event_date    TYPE farr_fulfill_date,
         poc_qty       TYPE farr_quantity,
         quantity      TYPE farr_quantity,
         quantity_unit TYPE farr_quantity_unit,
       END OF ty_con_poc,
       tty_con_poc TYPE STANDARD TABLE OF ty_con_poc.


DATA: gt_pob_poc TYPE tty_pob_poc,
      gt_con_poc TYPE tty_con_poc,
      gv_flag    type c,
      gv_flag1   type c.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-s01.
PARAMETERS: p_file TYPE localfile OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.
PARAMETERS: p_test AS CHECKBOX DEFAULT 'X'.

INITIALIZATION.
*  CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
*    EXPORTING
*      tcode  = 'ZFARR_UPDATE_POB_POC'
*    EXCEPTIONS
*      ok     = 0
*      not_ok = 1
*      OTHERS = 2.
*  IF sy-subrc <> 0.
*    MESSAGE e172(00) WITH 'ZFARR_UPDATE_POB_POC'.
*  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_file CHANGING p_file.

START-OF-SELECTION.
  PERFORM read_file USING    p_file
                    CHANGING gt_pob_poc.

  PERFORM validate_file CHANGING gt_pob_poc
                                 gt_con_poc.

  IF p_test IS INITIAL AND gt_con_poc IS NOT INITIAL.
    PERFORM update_poc CHANGING gt_pob_poc
                                gt_con_poc.
  ENDIF.

END-OF-SELECTION.
  IF gt_pob_poc IS NOT INITIAL.
    PERFORM display_data USING    p_test
                         CHANGING gt_pob_poc.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  GET_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--PV_FILEPATH  text
*----------------------------------------------------------------------*
FORM get_file CHANGING pv_filepath TYPE localfile.

  DATA: li_filetable    TYPE filetable,
        lv_rc           TYPE i.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table              = li_filetable
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4.
  IF sy-subrc = 0 AND li_filetable IS NOT INITIAL.
    READ TABLE li_filetable INTO pv_filepath INDEX 1.
  ENDIF.

ENDFORM.                    " GET_FILE

*&---------------------------------------------------------------------*
*&      Form  READ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_FILEPATH  text
*      <--PT_POB_POC   text
*----------------------------------------------------------------------*
FORM read_file  USING    pv_filepath TYPE localfile
                CHANGING pt_pob_poc  TYPE tty_pob_poc.

  DATA: lt_input_file  TYPE TABLE OF alsmex_tabline,
        ls_input_file  TYPE alsmex_tabline,
        ls_pob_poc     TYPE ty_pob_poc.

  DATA: lv_scol TYPE i VALUE '1',
        lv_srow TYPE i VALUE '2',
        lv_ecol TYPE i VALUE '5',
        lv_erow TYPE i VALUE '65536'.

*-To read data from Excel
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = pv_filepath
      i_begin_col             = lv_scol
      i_begin_row             = lv_srow
      i_end_col               = lv_ecol
      i_end_row               = lv_erow
    TABLES
      intern                  = lt_input_file
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  CASE sy-subrc.
    WHEN '0'. "Don't do anything
    WHEN '1'. MESSAGE 'Inconsistent Parameters' TYPE 'E'.
    WHEN '2'. MESSAGE 'Upload Ole' TYPE 'E'.
    WHEN OTHERS. MESSAGE 'Others'  TYPE 'E'.
  ENDCASE.


  LOOP AT lt_input_file INTO ls_input_file.

    CASE ls_input_file-col.
      WHEN '0001'.
        CALL FUNCTION 'CONVERSION_EXIT_RRPOB_INPUT'
          EXPORTING
            input       = ls_input_file-value
          IMPORTING
            output      = ls_pob_poc-pob_id
          EXCEPTIONS
            wrong_input = 1
            OTHERS      = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
      WHEN '0002'.
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            date_external            = ls_input_file-value
          IMPORTING
            date_internal            = ls_pob_poc-event_date
          EXCEPTIONS
            date_external_is_invalid = 1
            OTHERS                   = 2.
      WHEN '0003'.
        if ls_input_file-value CS ','.
          MESSAGE 'Cumulative percentage format should be XX.XXXX, not with comma. Please correct and retry!!' TYPE 'E'.
        else.
          MOVE ls_input_file-value TO ls_pob_poc-poc.
        endif.
    ENDCASE.

    AT END OF row.
      APPEND ls_pob_poc TO pt_pob_poc.
      CLEAR: ls_pob_poc.
    ENDAT.
  ENDLOOP.

  IF pt_pob_poc IS INITIAL.
    MESSAGE text-m02 TYPE 'S'.
    LEAVE LIST-PROCESSING.
  ELSE.
    SORT pt_pob_poc BY pob_id.
    DELETE ADJACENT DUPLICATES FROM pt_pob_poc COMPARING pob_id.
  ENDIF.

ENDFORM.                    " READ_FILE

*&---------------------------------------------------------------------*
*&      Form  VALIDATE_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--PT_POB_POC  text
*      <--PT_CON_POC  text
*----------------------------------------------------------------------*
FORM validate_file CHANGING pt_pob_poc TYPE tty_pob_poc
                            pt_con_poc TYPE tty_con_poc.

  TYPES: BEGIN OF ty_pob,
           pob_id        TYPE farr_pob_id,
           quantity      TYPE farr_quantity,
           quantity_unit TYPE farr_quantity_unit,
           event_type    TYPE farr_event_type,
           fulfill_type  TYPE farr_fulfill_type,
           contract_id   TYPE farr_contract_id,
           effective_qty TYPE farr_effective_quantity,
           zzsddoc       TYPE farr_d_pob-zzsddoc,
           zzsdditm      TYPE farr_d_pob-zzsdditm,
         END OF ty_pob,
         tty_pob TYPE STANDARD TABLE OF ty_pob.

  DATA: lt_pob          TYPE tty_pob,
        ls_pob          TYPE ty_pob,
        lv_poc          TYPE char10,
        lv_length       TYPE i,
        ls_color        TYPE lvc_s_scol,
        ls_con_poc      TYPE ty_con_poc,
        lt_fulfill_qty  TYPE farr_ts_total_fulfill_qty,
        ls_fulfill_qty  TYPE farr_s_total_fulfill_qty,
        lt_pob_id_range TYPE farr_tt_pob_id_range,
        ls_pob_id_range TYPE farr_s_pob_id_range,
        lv_poc1         TYPE char10,
        lv_message4     TYPE string,
        ls_pob_poc      TYPE ty_pob_poc,
        lv_pob          TYPE farr_pob_id.


  FIELD-SYMBOLS: <fs_pob_poc> TYPE ty_pob_poc.


  IF pt_pob_poc IS INITIAL.
    RETURN.
  ENDIF.

  SELECT pob_id
         quantity
         quantity_unit
         event_type
         fulfill_type
         contract_id
         effective_qty
         zzsddoc
         zzsdditm
    FROM farr_d_pob
    INTO TABLE lt_pob
     FOR ALL ENTRIES IN pt_pob_poc
   WHERE pob_id      = pt_pob_poc-pob_id.



  IF sy-subrc = 0.
    SORT lt_pob BY pob_id.

    ls_pob_id_range-sign   = if_farrc_accrual_constants=>co_range_sign_inclusive.
    ls_pob_id_range-option = if_farrc_accrual_constants=>co_range_option_equal.
    LOOP AT lt_pob INTO ls_pob.
      ls_pob_id_range-low = ls_pob-pob_id.
      APPEND ls_pob_id_range TO lt_pob_id_range.
    ENDLOOP.

    CALL METHOD cl_farr_fulfillment_db_access=>read_total_act_qty_multi
      EXPORTING
        it_pob_id_range = lt_pob_id_range
      IMPORTING
        ets_fulfill_qty = lt_fulfill_qty.


  if pt_pob_poc is initial. "If File is empty
    CONCATENATE 'File is empty, please fill' 'and retry!!' into data(lv_message) SEPARATED BY space.
  else.

  LOOP AT pt_pob_poc ASSIGNING <fs_pob_poc>.

    if p_test = 'X'.
      <fs_pob_poc>-test_run = 'X'.
    ENDIF.

    CALL FUNCTION 'CONVERSION_EXIT_RRCON_OUTPUT'
      EXPORTING
        input         = <fs_pob_poc>-pob_id
     IMPORTING
       OUTPUT         = lv_pob
              .

    "Validations on Input File
    if <fs_pob_poc>-pob_id  is INITIAL. "POB ID Validation
      lv_poc1 = <fs_pob_poc>-poc.
      concatenate 'POB ID cannot be blank, please update missing POB and retry' '!!' into data(lv_message1) SEPARATED BY space.
    endif.

    CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY' "Event Data Validation
      EXPORTING
        date                           = <fs_pob_poc>-event_date
     EXCEPTIONS
       PLAUSIBILITY_CHECK_FAILED       = 1
       OTHERS                          = 2
              .
    IF sy-subrc <> 0.
      CONCATENATE 'Please correct the fulfillment date format to MM/DD/YYYY for the relevant POB ID and retry' '!!' into
      data(lv_message2) SEPARATED BY space.
    ENDIF.

    if <fs_pob_poc>-poc is INITIAL. "Cumulative Percentage Validation
      CONCATENATE 'Cumulative percentage cannot be left blank, please update missing entries and retry' '!!' into
      data(lv_message3) SEPARATED BY space.
    elseif <fs_pob_poc>-poc NOT BETWEEN 0 AND 100.
      CONCATENATE 'POB ID' lv_pob 'does not lie between 0 & 100' into lv_message3 SEPARATED BY space.
    ENDIF.

    if ( lv_message  is not INITIAL or
         lv_message1 is not INITIAL or
         lv_message2 is not INITIAL or
         lv_message3 is not INITIAL ).

      if lv_message is not initial.
        message lv_message type 'E'.
      else. "File is not blank

        if ( lv_message1 is not INITIAL and lv_message2 is not INITIAL and lv_message3 is not INITIAL ). "All 3 Fields are Blank
          MESSAGE '1. POB ID 2. Fulfillment date and 3. Cumulative Percentage are Blank, Please fill the missing entries and retry!!'
          TYPE 'E'.
        endif.

        "Message1 Message2  Message3
*	        X	                           1st Case
*                    X                 2nd Case
*                               X      3rd Case
*         X          X                 4th Case
*         X                     X      5th Case
*	                   X          X	"    6th Case


        if ( lv_message1 is not INITIAL and lv_message2 is INITIAL and lv_message3 is INITIAL ). "1st Case
          CONCATENATE lv_message1 ' ' into lv_message4 SEPARATED BY space.
          MESSAGE lv_message4 type 'E'.
        endif.

        if ( lv_message1 is INITIAL and lv_message2 is NOT INITIAL and lv_message3 is INITIAL ). "2nd Case
          CONCATENATE lv_message2 ' ' into lv_message4 SEPARATED BY space.
          MESSAGE lv_message4 type 'E'.
        endif.

        if ( lv_message1 is INITIAL and lv_message2 is INITIAL and lv_message3 is not INITIAL ). "3rd Case
          CONCATENATE lv_message3 ' ' into lv_message4 SEPARATED BY space.
          MESSAGE lv_message4 type 'E'.
        endif.

        if ( lv_message1 is not INITIAL and lv_message2 is not INITIAL and lv_message3 is INITIAL ). "4th Case
          CONCATENATE '1. ' lv_message1 '2. ' lv_message2 into lv_message4 SEPARATED BY space.
          MESSAGE lv_message4 type 'E'.
        endif.

        if ( lv_message1 is not INITIAL and lv_message2 is INITIAL and lv_message3 is not INITIAL ). "5th Case
          CONCATENATE '1. 'lv_message1 '2. ' lv_message3 into lv_message4 SEPARATED BY space.
          MESSAGE lv_message4 type 'E'.
        endif.

        if ( lv_message1 is INITIAL and lv_message2 is not INITIAL and lv_message3 is not INITIAL ). "6th Case
          CONCATENATE '1.' lv_message2 '2.' lv_message3 into lv_message4 SEPARATED BY space.
          MESSAGE lv_message4 type 'E'.
        endif.
      endif.
    endif.


    READ TABLE lt_pob INTO ls_pob WITH KEY pob_id = <fs_pob_poc>-pob_id BINARY SEARCH.
    IF sy-subrc <> 0.
      CONCATENATE 'POB' lv_pob 'is not POC% type, please correct and retry!!' INTO <fs_pob_poc>-message SEPARATED BY space.
      gv_flag = 'X'.
      <fs_pob_poc>-status = 'Fail'.
*      CONTINUE.
    ELSE.

      IF ls_pob-event_type   <> if_farrc_contr_mgmt=>co_event_type_manual_fulfill OR
         ls_pob-fulfill_type <> if_farrc_contr_mgmt=>co_fulfill_type_over_time.
        CONCATENATE 'POB ID' lv_pob 'does not have Fulfillment type as Manual or Overtime,please correct and retry!!' INTO <fs_pob_poc>-message
        SEPARATED BY SPACE.
        gv_flag = 'X'.
        <fs_pob_poc>-status = 'Fail'.
*         MESSAGE 'It is not POC% type POB, please correct and retry!!' TYPE 'E'.
*        CONTINUE.

      ENDIF.
      IF ls_pob-effective_qty IS INITIAL.
        CONCATENATE 'Effective Quantity is empty for POB ID' lv_pob into <fs_pob_poc>-message SEPARATED BY space.
        gv_flag = 'X'.
        <fs_pob_poc>-status = 'Fail'.
*        CONTINUE.
      ENDIF.

      IF <fs_pob_poc>-poc NOT BETWEEN 0 AND 100.
        CONCATENATE 'POC' lv_poc 'does not lie between 0 & 100' into <fs_pob_poc>-message SEPARATED BY space.
        gv_flag = 'X'.
        <fs_pob_poc>-status = 'Fail'.
*        CONTINUE.
      ENDIF.

      CLEAR: ls_fulfill_qty.
      READ TABLE lt_fulfill_qty INTO ls_fulfill_qty WITH KEY pob_id = ls_pob-pob_id.
      IF sy-subrc = 0.
        IF ls_fulfill_qty-fulfill_qty = <fs_pob_poc>-poc.
          gv_flag = 'X'.
          gv_flag1 = 'X'.
          <fs_pob_poc>-status = 'Fail'.
*          CONTINUE.
        ENDIF.
      ENDIF.

      ls_con_poc-contract_id   = ls_pob-contract_id.
      ls_con_poc-quantity      = 1."ls_pob-quantity.
      ls_con_poc-quantity_unit = ls_pob-quantity_unit.
      ls_con_poc-pob_id        = <fs_pob_poc>-pob_id.
      ls_con_poc-event_date    = <fs_pob_poc>-event_date.
      ls_con_poc-zzsddoc       = ls_pob-zzsddoc.
      ls_con_poc-zzsdditm      = ls_pob-zzsdditm.
      <fs_pob_poc>-zzsddoc     = ls_pob-zzsddoc.
      <fs_pob_poc>-zzsdditm    = ls_pob-zzsdditm.

      IF ls_fulfill_qty-fulfill_qty IS INITIAL.
        ls_con_poc-poc_qty = <fs_pob_poc>-poc * ls_con_poc-quantity.
      ELSE.
        ls_con_poc-poc_qty = ( <fs_pob_poc>-poc * ls_con_poc-quantity ) - ls_fulfill_qty-fulfill_qty.
      ENDIF.

      APPEND ls_con_poc TO pt_con_poc.
      CLEAR: ls_con_poc.


      lv_poc = <fs_pob_poc>-poc.

      CALL FUNCTION 'FTR_CORR_SWIFT_DELETE_ENDZERO'
        CHANGING
          c_value = lv_poc.

      lv_length = strlen( lv_poc ) - 1.

      IF lv_poc+lv_length = '.'.
        lv_poc+lv_length = ''.
      ENDIF.

      CONCATENATE lv_poc '%' INTO lv_poc.


      IF p_test = abap_true.
        IF gv_flag = 'X'.
          IF gv_flag1 = 'X'.
            CONCATENATE 'No changes carried out for POB' lv_pob into <fs_pob_poc>-message separated by space.
          else.
          CONCATENATE 'POB ID' lv_pob 'cannot be updated with Fulfillment of' lv_poc
          into <fs_pob_poc>-message SEPARATED BY space.
          <fs_pob_poc>-status = 'Fail'.
          endif.
        ELSE.
          CONCATENATE 'POB ID' lv_pob 'can be updated with Fulfillment of' lv_poc
          into <fs_pob_poc>-message SEPARATED BY space.
          <fs_pob_poc>-status = 'Success'.
        ENDIF.
      ELSE.
        IF gv_flag = 'X'.
          IF gv_flag1 = 'X'.
            CONCATENATE 'No changes carried out for POB' lv_pob into <fs_pob_poc>-message separated by space.
          else.
          CONCATENATE 'POB ID' lv_pob 'has not been updated with Fulfillment of' lv_poc
          into <fs_pob_poc>-message SEPARATED BY space.
          <fs_pob_poc>-status = 'Fail'.
          endif.
        ELSE.
          CONCATENATE 'POB ID' lv_pob 'has been updated with Fulfillment of' lv_poc
          into <fs_pob_poc>-message SEPARATED BY space.
          <fs_pob_poc>-status = 'Success'.
        ENDIF.
      ENDIF.
    ENDIF.

      if <fs_pob_poc>-status = 'Success'.
        ls_color-fname     = 'STATUS'.
        ls_color-color-col = 5.
        ls_color-color-int = 0.
        ls_color-color-inv = 0.
        APPEND ls_color TO <fs_pob_poc>-color.
      else.
        ls_color-fname     = 'STATUS'.
        ls_color-color-col = 6.
        ls_color-color-int = 0.
        ls_color-color-inv = 0.
        APPEND ls_color TO <fs_pob_poc>-color.
      endif.
      clear: gv_flag, gv_flag1.
  ENDLOOP.
  endif.
  ELSE.
    READ TABLE pt_pob_poc TRANSPORTING NO FIELDS with key pob_id = ' '.
    if sy-subrc = 0.
      MESSAGE 'POB cannot be blank, please update missing POB and retry' type 'E'.
    else.
      MESSAGE 'POB does not exist, please correct the POB on corresponding line and retry!!' TYPE 'E'.
    endif.
  ENDIF.



ENDFORM.                    " VALIDATE_FILE

*&---------------------------------------------------------------------*
*&      Form  UPDATE_POC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--PT_POB_POC  text
*      <--PT_CON_POC  text
*----------------------------------------------------------------------*
FORM update_poc CHANGING pt_pob_poc TYPE tty_pob_poc
                         pt_con_poc TYPE tty_con_poc.


  DATA: lv_xstr             TYPE xstring,
        ls_con_poc          TYPE ty_con_poc,
        ls_pob_poc          TYPE ty_pob_poc,
        lo_farr_msg         TYPE REF TO cx_farr_message,
        lv_rar_error        TYPE string,
        ls_parameter        TYPE crmt_name_value_pair,
        lt_parameter        TYPE crmt_name_value_pair_tab,
        ls_pob_fulfill_qty  TYPE farr_s_pob_fulfill_quantity,
        lt_pob_fulfill_qty  TYPE farr_tt_pob_fulfill_quantity,
        lt_pob_fulfill_con  TYPE farr_tt_contract_key,
        ls_pob_fulfill_con  TYPE FARR_S_CONTRACT_key,
        lo_contract_mgmt    type farr_tt_contract_id,
        lo_contract_mgmt_if type ref to if_farr_contract_mgmt_bol,
        lo_farr_manual_contract_mgmt type ref to ZCL_FARR_IL_CONTRACT,
        lo_farr_manual_contract_mgmt1 type ref to CL_FARR_MANUAL_CONTRACT_MGMT,
        LO_FARR_CONTRACT_UTILITY TYPE REF TO ZCL_FARR_CONTRACT_UTILITY,
        lo_FARR_CONTRACT_OLD TYPE REF TO ZCL_FARR_CONTRACT_OLD,
        lo_IF_GENIL_MSG_SERVICE_ACCESS TYPE REF TO IF_GENIL_MSG_SERVICE_ACCESS,
        IT_CRMT_GENIL_OBJ TYPE CRMT_GENIL_OBJ_INST_LINE_TAB,
        lv_object_id TYPE CRMT_GENIL_OBJECT_ID,
        lo_IF_GENIL_APPL_INTLAY TYPE REF TO IF_GENIL_APPL_INTLAY,
        ls_obj TYPE CRMT_GENIL_OBJ_INST_LINE,
        lv_success type abap_bool.



  FIELD-SYMBOLS: <fs_pob_poc> TYPE ty_pob_poc.


  SORT pt_pob_poc BY pob_id.
  SORT pt_con_poc BY contract_id.



  LOOP AT pt_con_poc INTO ls_con_poc.
    READ TABLE pt_pob_poc into ls_pob_poc with key pob_id = ls_con_poc-pob_id BINARY SEARCH.
    if sy-subrc = 0.
      if ls_pob_poc-status = 'Success'.
        CLEAR: ls_pob_fulfill_qty.
        ls_pob_fulfill_qty-pob_id        = ls_con_poc-pob_id.
        ls_pob_fulfill_qty-contract_id   = ls_con_poc-contract_id.
        ls_pob_fulfill_qty-quantity      = ls_con_poc-poc_qty.
        ls_pob_fulfill_qty-quantity_unit = ls_con_poc-quantity_unit.
        ls_pob_fulfill_qty-event_date    = ls_con_poc-event_date.
        APPEND ls_pob_fulfill_qty TO lt_pob_fulfill_qty.

        AT END OF contract_id.

          CREATE OBJECT lo_farr_manual_contract_mgmt
               EXPORTING
                 iv_mode            = abap_true                  " Single-Character Indicator
                 iv_component_name  = 'FARRCT'                   " Component Name
               .

*
                CALL METHOD lo_farr_manual_contract_mgmt->get_contract
                  EXPORTING
                    iv_contract_id         = ls_con_poc-contract_id  " Revenue Recognition Contract ID
*                    iv_is_temp_contract    = abap_false       " Boolean Variable (X=True, -=False, Space=Unknown)
*                    iv_create_if_not_found = abap_true        " Boolean Variable (X=True, -=False, Space=Unknown)
                  RECEIVING
                    ro_contract            = lo_contract_mgmt_if " Interface of contract management BOL
                  .
*    -Load RA Contract
          TRY.

          CALL METHOD lo_contract_mgmt_if->load_contract.

*                .
              CATCH cx_farr_message INTO lo_farr_msg.

              MESSAGE ID lo_farr_msg->mv_msgid TYPE lo_farr_msg->mv_msgty NUMBER lo_farr_msg->mv_msgno
                WITH lo_farr_msg->mv_msgv1
                     lo_farr_msg->mv_msgv2
                     lo_farr_msg->mv_msgv3
                     lo_farr_msg->mv_msgv4 INTO lv_rar_error.

              LOOP AT lt_pob_fulfill_qty INTO ls_pob_fulfill_qty.
                READ TABLE pt_pob_poc ASSIGNING <fs_pob_poc> WITH KEY pob_id = ls_pob_fulfill_qty-pob_id BINARY SEARCH.
                IF sy-subrc = 0.
                  <fs_pob_poc>-message = lv_rar_error.
                  CLEAR: <fs_pob_poc>-color.
                ENDIF.
              ENDLOOP.

              CONTINUE.
          ENDTRY.

          CLEAR: lv_xstr.
          EXPORT p1 = lt_pob_fulfill_qty TO DATA BUFFER lv_xstr.

          ls_parameter-name  = if_farrc_contr_mgmt=>co_sh_memo_pob_fulfill.
          ls_parameter-value = lv_xstr.
          APPEND ls_parameter TO lt_parameter.
          CLEAR: ls_parameter.

*    -Fulfill the POB with the POC
          TRY.

               CREATE OBJECT lo_farr_manual_contract_mgmt1
                 EXPORTING
                   io_contract = lo_contract_mgmt_if    " Interface of contract management BOL
                 .
               CALL METHOD lo_farr_manual_contract_mgmt1->manual_fulfill_pob
                 EXPORTING
                   it_parameter = lt_parameter    " Parameter Table of Name-Value Pairs
                 .
              COMMIT WORK.
              if sy-subrc = 0.
                gv_flag = 'X'.
              endif.

            CATCH cx_farr_message INTO lo_farr_msg.

              MESSAGE ID lo_farr_msg->mv_msgid TYPE lo_farr_msg->mv_msgty NUMBER lo_farr_msg->mv_msgno
                WITH lo_farr_msg->mv_msgv1
                     lo_farr_msg->mv_msgv2
                     lo_farr_msg->mv_msgv3
                     lo_farr_msg->mv_msgv4 INTO lv_rar_error.

              LOOP AT lt_pob_fulfill_qty INTO ls_pob_fulfill_qty.
                READ TABLE pt_pob_poc ASSIGNING <fs_pob_poc> WITH KEY pob_id = ls_pob_fulfill_qty-pob_id BINARY SEARCH.
                IF sy-subrc = 0.
                  <fs_pob_poc>-message = lv_rar_error.
                  CLEAR: <fs_pob_poc>-color.
                ENDIF.
              ENDLOOP.

              CREATE OBJECT lo_farr_contract_old
                EXPORTING
                  iv_contract_id = 'X'                 " Boolean Variable (X=True, -=False, Space=Unknown)
                .
*              CATCH cx_farr_message. " Exception of FARR with message

              CALL METHOD lo_FARR_CONTRACT_OLD->unlock_contract.
          ENDTRY.

          REFRESH: lt_pob_fulfill_qty, lt_parameter.
        ENDAT.
    endif.
   endif.
  ENDLOOP.

ENDFORM.                    " UPDATE_POC

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PV_TEST    text
*      <--PT_POB_POC  text
*----------------------------------------------------------------------*
FORM display_data USING    pv_test    TYPE c
                  CHANGING pt_pob_poc TYPE tty_pob_poc.

  DATA: lo_columns    TYPE REF TO cl_salv_columns_table,
        lo_column     TYPE REF TO cl_salv_column_table,
        lo_selection  TYPE REF TO cl_salv_selections,
        lo_functions  TYPE REF TO cl_salv_functions,
        lo_display    TYPE REF TO cl_salv_display_settings,
        lo_salv_table TYPE REF TO cl_salv_table.

  TRY.
      CALL METHOD cl_salv_table=>factory
        IMPORTING
          r_salv_table = lo_salv_table
        CHANGING
          t_table      = pt_pob_poc.
    CATCH cx_salv_msg.
  ENDTRY.

  IF lo_salv_table IS NOT BOUND.
    RETURN.
  ENDIF.

  lo_columns = lo_salv_table->get_columns( ).
  lo_columns->set_optimize( ).

  TRY.
      lo_columns->set_color_column( 'COLOR' ).
    CATCH cx_salv_data_error.
  ENDTRY.

  lo_selection = lo_salv_table->get_selections( ).
  lo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).

  lo_functions = lo_salv_table->get_functions( ).
  lo_functions->set_all( cl_salv_display_settings=>true ).

  lo_display = lo_salv_table->get_display_settings( ).

  IF pv_test = abap_true.
    lo_display->set_list_header( text-h01 ).
  ELSE.
    lo_display->set_list_header( text-h02 ).
  ENDIF.

  try.
      lo_column ?= lo_columns->get_column( 'STATUS' ).
      lo_column->set_short_text( 'Status' ).
      lo_column->set_medium_text( 'Status' ).
      lo_column->set_long_text( 'Status' ).
    catch cx_salv_not_found.                            "#EC NO_HANDLER
  endtry.

   try.
      lo_column ?= lo_columns->get_column( 'MESSAGE' ).
      lo_column->set_short_text( 'Message' ).
      lo_column->set_medium_text( 'Message' ).
      lo_column->set_long_text( 'Message' ).
    catch cx_salv_not_found.                            "#EC NO_HANDLER
  endtry.

   try.
      lo_column ?= lo_columns->get_column( 'TEST_RUN' ).
      lo_column->set_short_text( 'Test Run' ).
      lo_column->set_medium_text( 'Test Run' ).
      lo_column->set_long_text( 'Test Run' ).
    catch cx_salv_not_found.                            "#EC NO_HANDLER
  endtry.


  lo_salv_table->display( ).

ENDFORM.                    " DISPLAY_DATA
