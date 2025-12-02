*&---------------------------------------------------------------------*
*& Include          ZRAR_REFXMIG_F01
*&---------------------------------------------------------------------*
*********************************************************************
*& Program           : ZRAR_REFXMIG                                 *
*& Module            : Accounting & MD                              *
*& Sub-Module        : RTR                                          *
*& Functional Contact: Somnath Bhattacharjee                        *
*& Funct. Spec. Ref. : Somnath Bhattacharjee                       *
*& Developer(Company): Shefali Jumnani                              *
*& Create Date       : 03/11/2022                                   *
*& Program Type      : Upload Program                               *
*& Project Phase     : Project Simplify                             *
*& Description       : Defect ID 18140 Conversion Program for REFX  *
*&                    (WRICEF-E110)                                 *
*&                                                                  *
*********************************************************************
* PROGRAMMER|  DATE    |  TASK#   |  DESCRIPTION                    *
*                                                                   *
*********************************************************************

CLASS lcl_zrarrefxmig DEFINITION.
  PUBLIC SECTION.

    CONSTANTS: lc_excel TYPE string VALUE 'Excel Files(*.xlsx)|*.xlsx'  ##NO_TEXT.

    CLASS-METHODS:
      select_file
        IMPORTING i_file         TYPE string
                  i_type         TYPE string
        RETURNING VALUE(re_file) TYPE localfile,

      read_file
        IMPORTING i_file TYPE string
        CHANGING  ct_tab TYPE ztrar_refxmig.

ENDCLASS.

CLASS lcl_zrarrefxmig IMPLEMENTATION.

  METHOD select_file.

    "F4 help for dialog file
    re_file = cl_openxml_helper=>browse_local_file_open(
    iv_title = 'Select File'    ##NO_TEXT
    iv_filename = i_file
    iv_extpattern = i_type ).

  ENDMETHOD.

  METHOD read_file.

*****data Declarations
    DATA: lv_size   TYPE i,
          lt_xtab   TYPE cpt_x255,
          lt_data   TYPE REF TO data,
          lo_record TYPE REF TO data,
          lv_count  TYPE i.

****Field Symbols
    FIELD-SYMBOLS: <fs_input> TYPE table.

    "Read Excel File from Presentation Server
    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename                = i_file "lv_filename
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
      MESSAGE TEXT-t01 TYPE 'S' DISPLAY LIKE 'E'.
      EXIT.
    ELSE.
      " If success, transfer data into internal table
      cl_scp_change_db=>xtab_to_xstr( EXPORTING im_xtab = lt_xtab
                                                im_size = lv_size
                                      IMPORTING ex_xstring = DATA(lv_xstring) ).

      DATA(lo_excel) = NEW cl_fdt_xl_spreadsheet( document_name = i_file
      xdocument = lv_xstring ).

      lo_excel->if_fdt_doc_spreadsheet~get_worksheet_names( IMPORTING worksheet_names = DATA(lt_worksheets) ).
      lt_data = lo_excel->if_fdt_doc_spreadsheet~get_itab_from_worksheet( lt_worksheets[ 1 ] ).

      ASSIGN lt_data->* TO <fs_input>.

      "Move Header Record for attachment
      LOOP AT <fs_input> ASSIGNING FIELD-SYMBOL(<fs_header>).
        IF sy-tabix = 1.
          DO.
            ASSIGN COMPONENT sy-index OF STRUCTURE <fs_header> TO FIELD-SYMBOL(<fs_headerval>).
            IF sy-subrc = 0.
              IF gv_string IS INITIAL.
                gv_string = <fs_headerval>.
              ELSE.
                gv_string = |{ gv_string }| && |{ gc_tab }| && |{ <fs_headerval> }|.
              ENDIF.
              lv_count = lv_count + 1.
            ELSE.
              IF gv_string IS INITIAL.
                gv_string = gc_crlf.
              ELSE.
                gv_string = |{ gv_string }| && |{ gc_crlf }|.
              ENDIF.
              EXIT.
            ENDIF.
          ENDDO.
        ENDIF.
      ENDLOOP.

      "Delete Header Record
      DELETE <fs_input> INDEX 1.
      DATA: lv_name TYPE char30.
      CREATE DATA lo_record TYPE zsrar_refxmig.
      lv_name = 'ZSRAR_REFXMIG'.

      ASSIGN lo_record->* TO FIELD-SYMBOL(<fs_record>).

      "Get structure of the table
      DATA(i_struct) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( lv_name ) )->components.
      DESCRIBE TABLE i_struct LINES DATA(lv_struct).
      IF lv_struct NE lv_count.
        MESSAGE TEXT-t08 TYPE 'S' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.

      "Assign file data as per the structure
      LOOP AT <fs_input> ASSIGNING FIELD-SYMBOL(<fs_rec>).
        CLEAR: <fs_record>.
        LOOP AT i_struct INTO DATA(ls_field).
          ASSIGN COMPONENT ls_field-name OF STRUCTURE <fs_record> TO FIELD-SYMBOL(<fs_target>).
          ASSIGN COMPONENT sy-tabix OF STRUCTURE <fs_rec> TO FIELD-SYMBOL(<fs_source>).
          IF <fs_target> IS ASSIGNED AND <fs_source> IS ASSIGNED.
            <fs_target> = <fs_source>.
            UNASSIGN: <fs_source>, <fs_target>.
          ENDIF.
          CLEAR: ls_field.
        ENDLOOP.
        APPEND <fs_record> TO ct_tab.
        CLEAR: <fs_rec>.
      ENDLOOP.

      REFRESH: i_struct[].
      UNASSIGN: <fs_record>, <fs_rec>, <fs_input>.
      CLEAR: lo_record, lt_data, lo_excel, lv_name.
    ENDIF.

  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*&      Form  GET_DIRECTORY
*&---------------------------------------------------------------------*
FORM get_directory  USING p_pcdir.
*Get the directory to download the output file

  IF sy-batch EQ ' '.

    DATA:lv_folder TYPE string.
* Get download path
    CALL METHOD cl_gui_frontend_services=>directory_browse
      CHANGING
        selected_folder      = lv_folder
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        not_supported_by_gui = 3
        OTHERS               = 4.

    p_pcdir = lv_folder.

    IF sy-subrc <> 0.
      MESSAGE TEXT-t07 TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

  ENDIF.

ENDFORM.                    " GET_DIRECTORY

*&---------------------------------------------------------------------*
*& Form transfer_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM transfer_data .

  "Output Structure
  TYPES : BEGIN OF  ty_output,
            type      TYPE c LENGTH 20,
            asset     TYPE c LENGTH 20,
            subnumber TYPE c LENGTH 20,
            area      TYPE c LENGTH 2,
            message   TYPE bapi_msg,
          END OF ty_output.

  "data declarations
  DATA:wa_key     TYPE bapi1022_key,
       lt_cumval  TYPE  STANDARD TABLE OF bapi1022_cumval,
       lw_cumval  LIKE LINE OF lt_cumval,
       lt_postval TYPE STANDARD TABLE OF bapi1022_postval,
       lw_postval LIKE LINE OF lt_postval,
       lt_return  TYPE STANDARD TABLE OF bapiret2,
       lt_output  TYPE STANDARD TABLE OF ty_output,
       ls_output  LIKE LINE OF lt_output,
       lv_str     TYPE string,
       lv_str1    TYPE string,
       lv_msg     TYPE string,
       lv_cnt     TYPE i.

  IF p_testrn IS INITIAL.
    ls_output-type = 'Message Type' ##NO_TEXT.
    ls_output-asset = 'Asset' ##NO_TEXT.
    ls_output-subnumber = 'Subnumber' ##NO_TEXT.
    ls_output-area = 'Depreciation Area' ##NO_TEXT.
    ls_output-message = 'Message' ##NO_TEXT.
    APPEND ls_output TO lt_output.
    CLEAR:ls_output.
  ENDIF.

  LOOP AT i_input INTO wa_input.

    lv_str =  wa_input-ord_dep.
    lv_str1 = wa_input-ord_dep_post.

*Validate the Acc and Book depreciation value
    IF wa_input-ord_dep IS NOT INITIAL AND lv_str NA '-'.
      CONCATENATE TEXT-t04 wa_input-asset TEXT-t05 lv_str INTO lv_msg SEPARATED BY space.
    ELSEIF wa_input-ord_dep_post IS NOT INITIAL AND lv_str1 NA '-'.
      CONCATENATE TEXT-t04 wa_input-asset TEXT-t05 lv_str1 INTO lv_msg SEPARATED BY space.
    ENDIF.

*Transfer Values
    IF lv_msg IS INITIAL.
      wa_key-asset = wa_input-asset.
      wa_key-companycode = wa_input-companycode.
      wa_key-subnumber = wa_input-subnumber.

      lw_cumval-acq_value = wa_input-acq_value.
      lw_cumval-area = wa_input-area.
      lw_cumval-currency = wa_input-currency.
      lw_cumval-fisc_year = wa_input-fisc_year.
      lw_cumval-ord_dep = wa_input-ord_dep.

      APPEND lw_cumval TO lt_cumval.
      CLEAR:lw_cumval.

      lw_postval-fisc_year = wa_input-fisc_year.
      lw_postval-area = wa_input-area.
      lw_postval-currency = wa_input-currency.
      lw_postval-ord_dep = wa_input-ord_dep_post.
      lw_postval-last_posted_depr_period = wa_input-last_posted_depr.

      APPEND lw_postval TO lt_postval.
      CLEAR:lw_postval.

      CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_POST'
        EXPORTING
          key             = wa_key
          testrun         = p_testrn
        TABLES
          cumulatedvalues = lt_cumval
          postedvalues    = lt_postval
          return          = lt_return.

      CLEAR :wa_key.
      REFRESH:lt_cumval[],lt_postval[].
*Adding return messages to the output structure

      LOOP AT lt_return INTO DATA(ls_return).

        ls_output-type = ls_return-type.
        ls_output-asset = wa_input-asset.
        ls_output-subnumber = wa_input-subnumber.
        ls_output-area = wa_input-area.
        ls_output-message = ls_return-message.

        APPEND ls_output TO lt_output.
        CLEAR:ls_output.

        IF ls_return-type = 'S' AND p_testrn IS INITIAL.
          lv_cnt = lv_cnt + 1.
          IF lv_cnt = 1.
            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait   = 'X'
              IMPORTING
                return = ls_return.
          ENDIF.
        ELSEIF ls_return-type = 'E' AND p_testrn IS INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF.

      ENDLOOP.
    ELSE.
      ls_output-type = 'E'.
      ls_output-asset = wa_input-asset.
      ls_output-subnumber = wa_input-subnumber.
      ls_output-area = wa_input-area.
      ls_output-message = lv_msg.
      APPEND ls_output TO lt_output.
      CLEAR:ls_output,lv_msg.
    ENDIF.
    CLEAR:wa_input,lv_cnt.
  ENDLOOP.

  "Download data for transfer;or display the result for test run

  IF p_testrn IS INITIAL.
    PERFORM download_data TABLES lt_output.
  ELSE.
    PERFORM display_data TABLES lt_output.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_OUTPUT
*&---------------------------------------------------------------------*
FORM download_data TABLES p_lt_output.

  DATA: p_outfile TYPE string.

  CONCATENATE 'ZRAR_REFXMIG' '.xls'
             INTO p_outfile.

*Download the output file
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename              = p_outfile
      write_field_separator = 'X'
    TABLES
      data_tab              = p_lt_output.
  IF sy-subrc <> 0  ##FM_SUBRC_OK.
    MESSAGE TEXT-t03 TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_OUTPUT
*&---------------------------------------------------------------------*
FORM display_data  TABLES   p_lt_output.

  DATA : gt_fcat TYPE slis_t_fieldcat_alv,      "Internal table to store field catalog
         gw_fcat LIKE LINE OF gt_fcat.

*Display data for test run

  gw_fcat-col_pos       = 1.
  gw_fcat-fieldname     = 'TYPE'.
  gw_fcat-tabname       = 'LT_OUTPUT'.
  gw_fcat-seltext_m     = 'Message Type' ##NO_TEXT.

  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-col_pos       = 2.
  gw_fcat-fieldname     = 'ASSET'.
  gw_fcat-tabname       = 'LT_OUTPUT'.
  gw_fcat-seltext_m     = 'Asset Number' ##NO_TEXT.

  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-col_pos       = 3.
  gw_fcat-fieldname     = 'SUBNUMBER'.
  gw_fcat-tabname       = 'LT_OUTPUT'.
  gw_fcat-seltext_m     = 'Asset Sub Number' ##NO_TEXT.

  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-col_pos       = 4.
  gw_fcat-fieldname     = 'AREA'.
  gw_fcat-tabname       = 'LT_OUTPUT'.
  gw_fcat-seltext_m     = 'Depreciation Area' ##NO_TEXT.

  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  gw_fcat-col_pos       = 4.
  gw_fcat-fieldname     = 'MESSAGE'.
  gw_fcat-tabname       = 'LT_OUTPUT'.
  gw_fcat-seltext_m     = 'Message' ##NO_TEXT .
  gw_fcat-outputlen     =  75.

  APPEND gw_fcat TO gt_fcat.
  CLEAR gw_fcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'   "Calling ALV function module to generate output
    EXPORTING
      it_fieldcat = gt_fcat
    TABLES
      t_outtab    = p_lt_output.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form f_modification
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM f_modification .

* Make the field for download directory mandatory,if it is not a test run

  LOOP AT SCREEN.
    IF p_testrn IS INITIAL.
      IF screen-name = 'P_PCDIR'.
        screen-required = '1'.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
