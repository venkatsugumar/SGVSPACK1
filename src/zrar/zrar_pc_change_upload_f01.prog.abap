*&---------------------------------------------------------------------*
*& Include          ZRAR_PC_CHANGE_UPLOAD_F01
*&---------------------------------------------------------------------*
CLASS lcl_cust_upload DEFINITION.

  PUBLIC SECTION.
    CONSTANTS: lc_excel TYPE string VALUE 'Excel Files(*.xlsx)|*.xlsx'.

    CLASS-METHODS:

      select_file
        IMPORTING i_file         TYPE string
                  i_type         TYPE string
        RETURNING VALUE(re_file) TYPE localfile,

      read_local_file,

      validate_record,

      create_api_rai,

      alv_dis,

      alv_dis_new. "Defect - 3059

ENDCLASS. " CLASS lcl_cust_upload DEFINITION.
CLASS lcl_cust_upload IMPLEMENTATION.


  METHOD select_file.

    "F4 help for dialog file from presentaion server
    re_file = cl_openxml_helper=>browse_local_file_open(
    iv_title = 'Select File'
    iv_filename = i_file
    iv_extpattern = i_type ).

  ENDMETHOD.

  METHOD read_local_file.


* Types
    TYPES : BEGIN OF ty_tab,
              pob_id    TYPE farr_pob_id,
              prctr     TYPE prctr,
              srcdoc_id TYPE farr_rai_srcid,
            END OF ty_tab.

* Internal Table & Variables
    DATA : it_tab          TYPE TABLE OF ty_tab,
           lt_xtab         TYPE cpt_x255,
           lt_data         TYPE REF TO data,
           lo_record       TYPE REF TO data,
           ls_tab          TYPE ty_tab,
           lv_count        TYPE i VALUE 0,
           lv_string       TYPE string,
           lv_size         TYPE i,
           lv_file         TYPE string,
           lv_account_type TYPE string.

* Field Symbols
    FIELD-SYMBOLS: <fs_input> TYPE table.

    lv_file = p_file.

    "Read Excel File from Presentation Server
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = lv_file "lv_filename
        filetype                = 'BIN'
      IMPORTING
        filelength              = lv_size
      CHANGING
        data_tab                = lt_xtab
      EXCEPTIONS
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        OTHERS                  = 19.

    IF sy-subrc <> 0.
      MESSAGE TEXT-004 TYPE gc_e DISPLAY LIKE gc_s.
      EXIT.
    ELSE.
      " If success, transfer data into internal table
      cl_scp_change_db=>xtab_to_xstr( EXPORTING im_xtab = lt_xtab
                                                im_size = lv_size
                                      IMPORTING ex_xstring = DATA(lv_xstring) ).

      DATA(lo_excel) = NEW cl_fdt_xl_spreadsheet( document_name = lv_file
      xdocument = lv_xstring ).

      lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names( IMPORTING worksheet_names = DATA(lt_worksheets) ).
      lt_data = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lt_worksheets[ 1 ] ).

      ASSIGN lt_data->* TO <fs_input>.
      lv_count = 0.
      LOOP AT <fs_input> ASSIGNING FIELD-SYMBOL(<fs_header>).
        IF sy-tabix = 2.
          DO.
            ASSIGN COMPONENT sy-index OF STRUCTURE <fs_header> TO FIELD-SYMBOL(<fs_headerval>).
            IF sy-subrc = 0.
              IF lv_count = 0.
                lv_string = |{ lv_string }| && |{ <fs_headerval> }|.
                lv_count = lv_count + 1.
                CONTINUE.
              ENDIF.
              lv_string = |{ lv_string }| && |{ gc_tab }| && |{ <fs_headerval> }|.
              lv_count = lv_count + 1.
            ELSE.
              lv_string = |{ lv_string }| && |{ gc_crlf }|.
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDLOOP.

      "Delete Header Record
      DELETE <fs_input> FROM 1 TO 1.

      CREATE DATA lo_record LIKE LINE OF it_tab.


      ASSIGN lo_record->* TO FIELD-SYMBOL(<fs_record>).
*
*    "Get structure of the database table
      DATA(i_struct_create) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( 'ZST_PC_CHG' ) )->components.

*      "Assign file data as per the structure
      LOOP AT <fs_input> ASSIGNING FIELD-SYMBOL(<fs_rec>).
        CLEAR: <fs_record>.
        LOOP AT i_struct_create INTO DATA(ls_field).
          ASSIGN COMPONENT ls_field-name OF STRUCTURE <fs_record> TO FIELD-SYMBOL(<fs_target>).
          ASSIGN COMPONENT sy-tabix OF STRUCTURE <fs_rec> TO FIELD-SYMBOL(<fs_source>).
          IF <fs_target> IS ASSIGNED AND <fs_source> IS ASSIGNED.
            IF ( ls_field-name = 'SRCDOC_ID' OR ls_field-name = 'PRCTR'
                 OR ls_field-name = 'POB_ID' ) "Defect - 2599  F3XOFTB
              AND <fs_source> IS NOT INITIAL.
              REPLACE ALL OCCURRENCES OF '-' IN <fs_source> WITH ''.
              <fs_target> = <fs_source>.
            ELSE.
              <fs_target> = <fs_source>.
            ENDIF.
            UNASSIGN: <fs_source>, <fs_target>.
          ENDIF.
          CLEAR: ls_field.
        ENDLOOP.

        IF <fs_record> IS NOT INITIAL.
          APPEND <fs_record> TO it_tab.
        ENDIF.
        CLEAR: <fs_rec>.
      ENDLOOP.

      IF it_tab IS NOT INITIAL.
        MOVE-CORRESPONDING it_tab TO it_pc_tab.
      ENDIF.

      UNASSIGN: <fs_record>, <fs_rec>, <fs_input>.
      CLEAR: lo_record, lt_data, lo_excel .

    ENDIF.

  ENDMETHOD.

  METHOD validate_record.

    DATA : it_msg         TYPE farr_tt_msg,
           ls_return      TYPE bapiret2,
           wa_mi_eq_pc    TYPE /1ra/1sd010mi_api_tab,

* Begin of change defect - 2599  F3XOFTB
           ls_selcrit     TYPE farr_s_rai_mon_selcrit,
           wa_status_rtab TYPE farr_rs_rai_status,
           lt_status_rtab TYPE farr_rt_rai_status,
           wa_rtype_rtab  TYPE farr_rs_raic_type,
           lt_rtype_rtab  TYPE  farr_rt_raic_type,
           wa_pob_rtab    TYPE farr_s_pob_id_range,
           lt_pob_rtab    TYPE farr_tt_pob_id_range,
           lv_rc          TYPE c.

    CONSTANTS : c_i     TYPE c VALUE 'I',
                c_eq(2) TYPE c VALUE 'EQ',
                c_sname TYPE typename VALUE 'FARR_S_RAI_MI_DISP',
                c_0     TYPE c VALUE '0',
                c_1     TYPE c VALUE '1',
                c_2     TYPE c VALUE '2',
                c_3     TYPE c VALUE '3',
                c_4     TYPE c VALUE '4',
                c_01(2) TYPE c VALUE '01',
                c_sdoi  TYPE farr_rai_srcty VALUE 'SDOI'.

* Pass pob_id to Rai monitor FM to get the RAI ITEM data
    LOOP AT it_pc_tab INTO DATA(wa_tab).
      wa_pob_rtab-sign = c_i.
      wa_pob_rtab-option = c_eq.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = wa_tab-pob_id
        IMPORTING
          output = wa_tab-pob_id.
      wa_pob_rtab-low = wa_tab-pob_id.
      APPEND wa_pob_rtab TO lt_pob_rtab.
    ENDLOOP.

    wa_status_rtab-sign = c_i.
    wa_status_rtab-option = c_eq.
    wa_status_rtab-low = c_0.
    APPEND wa_status_rtab TO lt_status_rtab.

    wa_status_rtab-sign = c_i.
    wa_status_rtab-option = c_eq.
    wa_status_rtab-low = c_1.
    APPEND wa_status_rtab TO lt_status_rtab.

    wa_status_rtab-sign = c_i.
    wa_status_rtab-option = c_eq.
    wa_status_rtab-low = c_2.
    APPEND wa_status_rtab TO lt_status_rtab.

    wa_status_rtab-sign = c_i.
    wa_status_rtab-option = c_eq.
    wa_status_rtab-low = c_3.
    APPEND wa_status_rtab TO lt_status_rtab.

    wa_status_rtab-sign = c_i.
    wa_status_rtab-option = c_eq.
    wa_status_rtab-low = c_4.
    APPEND wa_status_rtab TO lt_status_rtab.

    wa_rtype_rtab-sign = c_i.
    wa_rtype_rtab-option = c_eq.
    wa_rtype_rtab-low = c_01.
    APPEND wa_rtype_rtab TO lt_rtype_rtab.

    ls_selcrit-strucname = c_sname."'FARR_S_RAI_MI_DISP'.
    ls_selcrit-maxsel = '10000 '.

    ls_selcrit-status_rtab = lt_status_rtab.
    ls_selcrit-rtype_rtab = lt_rtype_rtab.
    ls_selcrit-pob_rtab = lt_pob_rtab.


    CALL FUNCTION 'FARR_RAIC_DB_SELECT_FOR_MON'
      EXPORTING
        is_selcrit     = ls_selcrit
      IMPORTING
        et_rai_mi_disp = it_rai_mi_disp
      CHANGING
        c_rc           = lv_rc
      EXCEPTIONS
        not_found      = 1
        OTHERS         = 2.
    IF sy-subrc EQ 0.
      DELETE it_rai_mi_disp WHERE srcdoc_type <> c_sdoi.
    ENDIF.

* Update source id based on POB_ID
    LOOP AT it_pc_tab ASSIGNING FIELD-SYMBOL(<fs_pc_tab>).

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_pc_tab>-pob_id
        IMPORTING
          output = <fs_pc_tab>-pob_id.

      READ TABLE it_rai_mi_disp INTO DATA(wa_rai_mi_disp)
      WITH KEY  pob_id1 = <fs_pc_tab>-pob_id.
      IF sy-subrc  = 0.
        <fs_pc_tab>-srcdoc_id =  wa_rai_mi_disp-srcdoc_id.

***********************************
      ELSE.
*      LOOP AT lt_far_d_pob INTO DATA(ls_pob).
*        READ TABLE lt_far_d_pob WITH KEY pob_id = ls_pob-pob_id TRANSPORTING NO FIELDS.
*        IF sy-subrc = 0.
*          wa_src_id-srcdoc_id = wa_mi_tab-srcdoc_id.
        wa_src_id-pob_id = <fs_pc_tab>-pob_id.
        wa_src_id-msg  = 'POB_ID not found in table'.
        wa_src_id-type = gc_e.
        APPEND wa_src_id TO it_src_id.
*        ENDIF.
*      ENDLOOP.
***********************************

      ENDIF.

    ENDLOOP.

* End of change defect - 2599  F3XOFTB


* Get the Processd Item from 14MI,12MI,14CO table's
    IF it_pc_tab IS NOT INITIAL.

*      SELECT pob_id FROM farr_d_pob
*      INTO TABLE @DATA(lt_far_d_pob)
*      FOR ALL ENTRIES IN @it_pc_tab
*      WHERE pob_id = @it_pc_tab-pob_id.
*      IF sy-subrc = 0.
*      ENDIF.

      SELECT * FROM /1ra/0sd014mi
      INTO TABLE @DATA(it_srcdoc)
      FOR ALL ENTRIES IN @it_pc_tab
      WHERE  srcdoc_id = @it_pc_tab-srcdoc_id.

      IF sy-subrc = 0.

        SELECT * FROM /1ra/0sd012mi
        INTO TABLE it_sd012mi
        FOR ALL ENTRIES IN it_pc_tab
        WHERE srcdoc_id = it_pc_tab-srcdoc_id.

        SELECT * FROM /1ra/0sd014co
        INTO  TABLE @DATA(it_sd01co)
        FOR ALL ENTRIES IN @it_pc_tab
        WHERE srcdoc_id = @it_pc_tab-srcdoc_id.

        IF sy-subrc = 0.
          MOVE-CORRESPONDING it_srcdoc TO it_mi_tab.
          MOVE-CORRESPONDING it_sd01co TO it_co_tab.
        ENDIF.
      ENDIF.

      "Get Current TimeStamp
      GET TIME STAMP FIELD DATA(ts).

      LOOP AT it_co_tab ASSIGNING FIELD-SYMBOL(<fs_co_tab>).
        <fs_co_tab>-timestamp_utc = ts.
      ENDLOOP.

      "Validating MI table sourceID from Input  SourceId fr
      LOOP AT it_mi_tab ASSIGNING FIELD-SYMBOL(<fs_mi_tab>).
        <fs_mi_tab>-timestamp_utc = ts.
        READ TABLE it_pc_tab INTO DATA(wa_pc_tab)
        WITH KEY srcdoc_id = <fs_mi_tab>-srcdoc_id.
        IF sy-subrc = 0.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = wa_pc_tab-prctr
            IMPORTING
              output = wa_pc_tab-prctr.
          IF <fs_mi_tab>-prctr EQ wa_pc_tab-prctr.
            wa_src_id-srcdoc_id = <fs_mi_tab>-srcdoc_id.
            wa_src_id-prctr = <fs_mi_tab>-prctr.
            wa_src_id-msg  = TEXT-006.
            wa_src_id-type = gc_e.
            APPEND wa_src_id TO it_src_id.
          ELSE.
            <fs_mi_tab>-prctr = wa_pc_tab-prctr.
          ENDIF.
        ENDIF.
        IF <fs_mi_tab>-deletion_ind EQ abap_true.
          wa_src_id-srcdoc_id = <fs_mi_tab>-srcdoc_id.
          wa_src_id-prctr = <fs_mi_tab>-prctr.
          wa_src_id-msg  = TEXT-007.
          wa_src_id-type = gc_e.
          APPEND wa_src_id TO it_src_id.
        ENDIF.
      ENDLOOP.


      " Validate Source-ID in MI12 table
      LOOP AT it_pc_tab INTO wa_pc_tab.
        READ TABLE it_sd012mi INTO DATA(wa_sd012mi)
        WITH KEY srcdoc_id = wa_pc_tab-srcdoc_id.
        IF sy-subrc = 0.
          wa_src_id-srcdoc_id = wa_pc_tab-srcdoc_id.
          wa_src_id-prctr = wa_sd012mi-prctr.
          wa_src_id-msg  = TEXT-008.
          wa_src_id-type = gc_e.
          APPEND wa_src_id TO it_src_id.
        ENDIF.
        CLEAR : wa_pc_tab.
      ENDLOOP.

      LOOP AT it_mi_tab INTO DATA(wa_mi_tab).
        READ TABLE it_src_id INTO wa_src_id
        WITH KEY srcdoc_id = wa_mi_tab-srcdoc_id.
        IF sy-subrc <> 0.
          wa_src_id-srcdoc_id = wa_mi_tab-srcdoc_id.
          wa_src_id-prctr = wa_mi_tab-prctr.
          wa_src_id-msg  = TEXT-009.
          wa_src_id-type = gc_s.
          APPEND wa_src_id TO it_src_id.
        ENDIF.
      ENDLOOP.


      CLEAR : wa_mi_tab,wa_src_id,wa_src_id.

    ENDIF.

  ENDMETHOD.

  METHOD alv_dis.

    DATA : oref_alv     TYPE REF TO cl_salv_table,
           oref_func    TYPE REF TO cl_salv_functions,
           oref_columns TYPE REF TO cl_salv_columns_table,
           oref_column  TYPE REF TO cl_salv_column,
           it_colnames  TYPE salv_t_column_ref,
           wa_colname   LIKE LINE OF it_colnames,
           lv_txtmedium TYPE scrtext_m,
           lv_labelm    TYPE scrtext_m,
           lv_labels    TYPE scrtext_s,
           lv_labell    TYPE scrtext_l.

* Begin of change defect - 2599  F3XOFTB

* Update profit centre & POB_ID in ALV output
    LOOP AT it_src_id ASSIGNING FIELD-SYMBOL(<fs_src_id>).

      IF <fs_src_id>-srcdoc_id IS NOT INITIAL.
        READ TABLE it_pc_tab INTO DATA(wa_pc_tab)
        WITH KEY srcdoc_id = <fs_src_id>-srcdoc_id.
        IF sy-subrc = 0.
          <fs_src_id>-prctr  = wa_pc_tab-prctr.
          <fs_src_id>-pob_id = wa_pc_tab-pob_id.
        ENDIF.

        READ TABLE it_rai_mi_disp INTO DATA(wa_rai_disp)
        WITH KEY srcdoc_id = <fs_src_id>-srcdoc_id.
        IF sy-subrc  = 0.
          wa_rai_disp-prctr = | { wa_rai_disp-prctr ALPHA = OUT } |.
          <fs_src_id>-old_prctr = wa_rai_disp-prctr.
        ENDIF.
      ENDIF.
    ENDLOOP.

* End of change defect - 2599  F3XOFTB


    " Generate Alv output
    TRY.

        CHECK it_src_id IS NOT INITIAL.

        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = oref_alv
          CHANGING
            t_table      = it_src_id.

* Get the column name & Set the colum heading
        oref_columns = oref_alv->get_columns( ).
        it_colnames = oref_columns->get( ).

        LOOP AT it_colnames INTO wa_colname.
          oref_column = oref_columns->get_column( to_upper( wa_colname-columnname ) ).
          CLEAR: lv_txtmedium ,lv_labelm,lv_labell.
          lv_txtmedium = wa_colname-columnname.

          IF lv_txtmedium = 'MSG'.
            lv_labell  = 'COMMENTS'.
            oref_column->set_long_text( lv_labell ).
          ENDIF.

          IF lv_txtmedium = 'PRCTR'.
            lv_labell  = 'New_PC'.
            oref_column->set_long_text( lv_labell ).
          ENDIF.

          IF lv_txtmedium = 'OLD_PRCTR'.
            lv_labell  = 'Old_PC'.
            oref_column->set_long_text( lv_labell ).
          ENDIF.

        ENDLOOP.

        oref_column = oref_columns->get_column( 'TYPE' ).
        oref_column->set_technical( if_salv_c_bool_sap=>true ).

      CATCH cx_salv_msg.
    ENDTRY.

* Set all the functionality
    oref_func = oref_alv->get_functions( ).
    oref_func->set_all( abap_true ).

* Display ALV output
    oref_alv->display( ).

    CLEAR : it_src_id.
  ENDMETHOD.

  METHOD alv_dis_new.

    DATA : oref_alv     TYPE REF TO cl_salv_table,
           oref_func    TYPE REF TO cl_salv_functions,
           oref_columns TYPE REF TO cl_salv_columns_table,
           oref_column  TYPE REF TO cl_salv_column,
           it_colnames  TYPE salv_t_column_ref,
           wa_colname   LIKE LINE OF it_colnames,
           lv_txtmedium TYPE scrtext_m,
           lv_labelm    TYPE scrtext_m,
           lv_labels    TYPE scrtext_s,
           lv_labell    TYPE scrtext_l.

    IF p_test IS INITIAL.

      DELETE it_src_id_new WHERE msg IS INITIAL.

    ENDIF.

    " Generate Alv output
    TRY.

        CHECK it_src_id_new IS NOT INITIAL.

        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = oref_alv
          CHANGING
            t_table      = it_src_id_new.

* Get the column name & Set the colum heading
        oref_columns = oref_alv->get_columns( ).
        it_colnames = oref_columns->get( ).

        LOOP AT it_colnames INTO wa_colname.
          oref_column = oref_columns->get_column( to_upper( wa_colname-columnname ) ).
          CLEAR: lv_txtmedium ,lv_labelm,lv_labell.
          lv_txtmedium = wa_colname-columnname.

          IF lv_txtmedium = 'MSG'.
            lv_labell  = 'COMMENTS'.
            oref_column->set_long_text( lv_labell ).
          ENDIF.

          IF lv_txtmedium = 'POB_ID'.
            lv_labell  = 'POB_ID'.
            oref_column->set_long_text( lv_labell ).
          ENDIF.

        ENDLOOP.

        oref_column = oref_columns->get_column( 'TYPE' ).
        oref_column->set_technical( if_salv_c_bool_sap=>true ).

      CATCH cx_salv_msg.
    ENDTRY.

* Set all the functionality
    oref_func = oref_alv->get_functions( ).
    oref_func->set_all( abap_true ).

* Display ALV output
    oref_alv->display( ).

    CLEAR : it_src_id.
  ENDMETHOD.

  METHOD create_api_rai.

    DATA : it_api_mi TYPE /1ra/1sd010mi_api_tab,
           it_api_co TYPE /1ra/1sd010co_api_tab,
           lt_msg    TYPE farr_tt_msg,
           ls_return TYPE bapiret2.


* Eliminate the records from RAI generation
    IF p_test IS INITIAL.
      LOOP AT it_src_id ASSIGNING FIELD-SYMBOL(<wa_src_id>).
        IF <wa_src_id>-type = gc_e.
          DELETE it_mi_tab WHERE srcdoc_id = <wa_src_id>-srcdoc_id.
          DELETE it_co_tab WHERE srcdoc_id = <wa_src_id>-srcdoc_id.
        ELSE.
          CLEAR : <wa_src_id>-msg.
        ENDIF.
      ENDLOOP.
    ENDIF.

    CLEAR : wa_src_id.

* Generating RAI from API call
    IF it_mi_tab IS NOT INITIAL  AND p_test IS INITIAL.

      LOOP AT it_mi_tab INTO DATA(wa_mi_tab).
        APPEND wa_mi_tab TO it_api_mi.
        LOOP AT it_co_tab INTO DATA(wa_co_tab)
          WHERE srcdoc_id = wa_mi_tab-srcdoc_id.
          APPEND wa_co_tab TO it_api_co.
        ENDLOOP.

        CALL FUNCTION '/1RA/SD01_RAI_CREATE_API'
          EXPORTING
            it_api_mi     = it_api_mi
            it_api_co     = it_api_co
          IMPORTING
            et_messages   = lt_msg
          EXCEPTIONS
            general_fault = 1
            OTHERS        = 2.
        IF sy-subrc <> 0.

          wa_src_id-srcdoc_id = wa_mi_tab-srcdoc_id.
          wa_src_id-prctr = wa_mi_tab-prctr.
          wa_src_id-msg  = TEXT-010.
          APPEND wa_src_id TO it_src_id.
          DELETE it_src_id WHERE msg IS INITIAL.

        ELSE.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait   = gc_x
            IMPORTING
              return = ls_return.
          wa_src_id-srcdoc_id = wa_mi_tab-srcdoc_id.
          wa_src_id-prctr = wa_mi_tab-prctr.
          wa_src_id-msg  = TEXT-011.
          APPEND wa_src_id TO it_src_id.
          DELETE it_src_id WHERE msg IS INITIAL.
        ENDIF.
        CLEAR : wa_mi_tab ,it_api_mi,wa_co_tab,
        it_api_co,wa_src_id.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


ENDCLASS.
*&---------------------------------------------------------------------*
*& Form validate_record
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM validate_record .
  DATA : it_msg         TYPE farr_tt_msg,
         ls_return      TYPE bapiret2,
         wa_mi_eq_pc    TYPE /1ra/1sd010mi_api_tab,
         ls_selcrit     TYPE farr_s_rai_mon_selcrit,
         wa_status_rtab TYPE farr_rs_rai_status,
         lt_status_rtab TYPE farr_rt_rai_status,
         wa_rtype_rtab  TYPE farr_rs_raic_type,
         lt_rtype_rtab  TYPE  farr_rt_raic_type,
         wa_pob_rtab    TYPE farr_s_pob_id_range,
         lt_pob_rtab    TYPE farr_tt_pob_id_range,
         lv_rc          TYPE c.

  CONSTANTS : c_i     TYPE c VALUE 'I',
              c_c     TYPE c VALUE 'C',
              c_eq(2) TYPE c VALUE 'EQ',
              c_sname TYPE typename VALUE 'FARR_S_RAI_MI_DISP',
              c_0     TYPE c VALUE '0',
              c_1     TYPE c VALUE '1',
              c_2     TYPE c VALUE '2',
              c_3     TYPE c VALUE '3',
              c_4     TYPE c VALUE '4',
              c_01(2) TYPE c VALUE '01',
              c_sdoi  TYPE farr_rai_srcty VALUE 'SDOI'.

  LOOP AT it_pc_tab ASSIGNING FIELD-SYMBOL(<fs_tab>).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <fs_tab>-pob_id
      IMPORTING
        output = <fs_tab>-pob_id.
  ENDLOOP.
  UNASSIGN <fs_tab>.

  "Valid POB status not equal to "C"
  IF it_pc_tab IS NOT INITIAL.
    SELECT pob_id,status FROM farr_d_pob
    INTO TABLE @DATA(lt_farr_d_pob)
    FOR ALL ENTRIES IN @it_pc_tab
    WHERE pob_id = @it_pc_tab-pob_id
    AND status EQ @c_c.
    IF sy-subrc = 0.
      LOOP AT it_pc_tab INTO DATA(wa_pc_tab1).
        READ TABLE lt_farr_d_pob INTO DATA(ls_farr_d_pob)
        WITH KEY pob_id = wa_pc_tab1-pob_id.
        IF sy-subrc = 0 AND ls_farr_d_pob-status = c_c.
          wa_src_id_new-pob_id = wa_pc_tab1-pob_id.
          wa_src_id_new-msg  = 'POB status equal to C'.
          wa_src_id_new-type = gc_e.
          APPEND wa_src_id_new TO it_src_id_new.
          DELETE it_pc_tab.
        ELSE.
          wa_src_id_new-pob_id = wa_pc_tab1-pob_id.
          wa_src_id_new-msg  = 'POB Eligible for customer update'.
          wa_src_id_new-type = gc_s.
          APPEND wa_src_id_new TO it_src_id_new.
        ENDIF.
        CLEAR : wa_src_id_new.
      ENDLOOP.
    ENDIF.
  ENDIF.

  LOOP AT it_pc_tab INTO DATA(wa_tab).
    wa_pob_rtab-sign = c_i.
    wa_pob_rtab-option = c_eq.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_tab-pob_id
      IMPORTING
        output = wa_tab-pob_id.
    wa_pob_rtab-low = wa_tab-pob_id.
    APPEND wa_pob_rtab TO lt_pob_rtab.
  ENDLOOP.

  wa_status_rtab-sign = c_i.
  wa_status_rtab-option = c_eq.
  wa_status_rtab-low = c_0.
  APPEND wa_status_rtab TO lt_status_rtab.

  wa_status_rtab-sign = c_i.
  wa_status_rtab-option = c_eq.
  wa_status_rtab-low = c_1.
  APPEND wa_status_rtab TO lt_status_rtab.

  wa_status_rtab-sign = c_i.
  wa_status_rtab-option = c_eq.
  wa_status_rtab-low = c_2.
  APPEND wa_status_rtab TO lt_status_rtab.

  wa_status_rtab-sign = c_i.
  wa_status_rtab-option = c_eq.
  wa_status_rtab-low = c_3.
  APPEND wa_status_rtab TO lt_status_rtab.

  wa_status_rtab-sign = c_i.
  wa_status_rtab-option = c_eq.
  wa_status_rtab-low = c_4.
  APPEND wa_status_rtab TO lt_status_rtab.

  wa_rtype_rtab-sign = c_i.
  wa_rtype_rtab-option = c_eq.
  wa_rtype_rtab-low = c_01.
  APPEND wa_rtype_rtab TO lt_rtype_rtab.

  ls_selcrit-strucname = c_sname."'FARR_S_RAI_MI_DISP'.
  ls_selcrit-maxsel = '10000 '.

  ls_selcrit-status_rtab = lt_status_rtab.
  ls_selcrit-rtype_rtab = lt_rtype_rtab.
  ls_selcrit-pob_rtab = lt_pob_rtab.

  CALL FUNCTION 'FARR_RAIC_DB_SELECT_FOR_MON'
    EXPORTING
      is_selcrit     = ls_selcrit
    IMPORTING
      et_rai_mi_disp = it_rai_mi_disp
    CHANGING
      c_rc           = lv_rc
    EXCEPTIONS
      not_found      = 1
      OTHERS         = 2.
  IF sy-subrc EQ 0.

    DELETE it_rai_mi_disp WHERE srcdoc_type <> c_sdoi.

* Update source id based on POB_ID
    LOOP AT it_pc_tab ASSIGNING FIELD-SYMBOL(<fs_pc_tab>).

      CLEAR : <fs_pc_tab>-prctr.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <fs_pc_tab>-pob_id
        IMPORTING
          output = <fs_pc_tab>-pob_id.

      READ TABLE it_rai_mi_disp ASSIGNING FIELD-SYMBOL(<fs_rai_mi_disp>)
      WITH KEY  pob_id1 = <fs_pc_tab>-pob_id.
      IF sy-subrc  = 0.
        <fs_pc_tab>-srcdoc_id =  <fs_rai_mi_disp>-srcdoc_id.
        <fs_rai_mi_disp>-matnr = |{ <fs_rai_mi_disp>-matnr ALPHA = IN } |.

      ELSE.
        wa_src_id-pob_id = <fs_pc_tab>-pob_id.
        wa_src_id-msg  = 'POB_ID not found in table'.
        wa_src_id-type = gc_e.
        APPEND wa_src_id TO it_src_id.
      ENDIF.
    ENDLOOP.

* Get the Processd Item from 14MI,12MI,14CO table's
    IF it_pc_tab IS NOT INITIAL.

      SELECT * FROM /1ra/0sd014mi
      INTO TABLE @DATA(it_srcdoc)
      FOR ALL ENTRIES IN @it_pc_tab
      WHERE  srcdoc_id = @it_pc_tab-srcdoc_id.

      IF sy-subrc = 0.

        SELECT * FROM /1ra/0sd012mi
        INTO TABLE it_sd012mi
        FOR ALL ENTRIES IN it_pc_tab
        WHERE srcdoc_id = it_pc_tab-srcdoc_id.

        SELECT * FROM /1ra/0sd014co
        INTO  TABLE @DATA(it_sd01co)
        FOR ALL ENTRIES IN @it_pc_tab
        WHERE srcdoc_id = @it_pc_tab-srcdoc_id.

        IF sy-subrc = 0.
          MOVE-CORRESPONDING it_srcdoc TO it_mi_tab.
          MOVE-CORRESPONDING it_sd01co TO it_co_tab.
        ENDIF.
      ENDIF.

*     "Get Product hierachy from Material
      SELECT * FROM mvke
        INTO TABLE gt_mvke
        FOR ALL ENTRIES IN it_rai_mi_disp
        WHERE matnr = it_rai_mi_disp-matnr.


      "Get Current TimeStamp
      GET TIME STAMP FIELD DATA(ts).

      LOOP AT it_mi_tab ASSIGNING FIELD-SYMBOL(<fs_mi_tab>).
        <fs_mi_tab>-timestamp_utc = ts.
      ENDLOOP.

      LOOP AT it_co_tab ASSIGNING FIELD-SYMBOL(<fs_co_tab>).
        <fs_co_tab>-timestamp_utc = ts.
      ENDLOOP.

      PERFORM create_api_rai_pob.

    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_api_rai_pob
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_api_rai_pob .
  DATA : it_api_mi TYPE /1ra/1sd010mi_api_tab,
         it_api_co TYPE /1ra/1sd010co_api_tab,
         lt_msg    TYPE farr_tt_msg,
         ls_return TYPE bapiret2,
         ls_copa   TYPE farr_s_copa_fields.

* Eliminate the records from RAI generation
  IF p_test IS INITIAL.
    LOOP AT it_src_id_new ASSIGNING FIELD-SYMBOL(<wa_src_id>).
      IF <wa_src_id>-type = gc_e.
        DELETE it_mi_tab WHERE srcdoc_id = <wa_src_id>-srcdoc_id.
        DELETE it_co_tab WHERE srcdoc_id = <wa_src_id>-srcdoc_id.
      ELSE.
        CLEAR : <wa_src_id>-msg.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CLEAR : wa_src_id.
* Generating RAI from API call
  IF it_mi_tab IS NOT INITIAL  AND p_test IS INITIAL.
    LOOP AT it_mi_tab INTO DATA(wa_mi_tab).
      CLEAR : wa_mi_tab-paobjnr.
      READ TABLE it_rai_mi_disp INTO DATA(wa_mi_disp)
      WITH KEY srcdoc_id = wa_mi_tab-srcdoc_id.
      IF sy-subrc = 0.
        READ TABLE gt_mvke INTO DATA(wa_mvke)
        WITH KEY matnr = wa_mi_disp-matnr.
        IF sy-subrc = 0.
          wa_mi_tab-copadata-prodh =  wa_mvke-prodh.
        ENDIF.
      ENDIF.
      APPEND wa_mi_tab TO it_api_mi.
      LOOP AT it_co_tab INTO DATA(wa_co_tab)
        WHERE srcdoc_id = wa_mi_tab-srcdoc_id.
        APPEND wa_co_tab TO it_api_co.
      ENDLOOP.

      CALL FUNCTION '/1RA/SD01_RAI_CREATE_API'
        EXPORTING
          it_api_mi     = it_api_mi
          it_api_co     = it_api_co
        IMPORTING
          et_messages   = lt_msg
        EXCEPTIONS
          general_fault = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        wa_src_id_new-srcdoc_id = wa_mi_tab-srcdoc_id.
        wa_src_id_new-pob_id = wa_mi_disp-pob_id1.
        wa_src_id_new-msg  = TEXT-010.
        APPEND wa_src_id_new TO it_src_id_new.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait   = gc_x
          IMPORTING
            return = ls_return.
        wa_src_id_new-srcdoc_id = wa_mi_tab-srcdoc_id.
        wa_src_id_new-pob_id = wa_mi_disp-pob_id1.
        wa_src_id_new-msg  = TEXT-011.
        APPEND wa_src_id_new TO it_src_id_new.
      ENDIF.
      CLEAR : wa_mi_tab ,it_api_mi,wa_co_tab,wa_src_id_new,
      it_api_co,wa_src_id.
    ENDLOOP.
  ENDIF.
ENDFORM.
