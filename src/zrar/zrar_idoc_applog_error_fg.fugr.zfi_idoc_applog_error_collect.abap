FUNCTION ZFI_IDOC_APPLOG_ERROR_COLLECT .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(USE_ARCKEY) TYPE  XFELD OPTIONAL
*"     VALUE(USE_IDOC_NUMBER) TYPE  XFELD OPTIONAL
*"  TABLES
*"      T_EDIDC STRUCTURE  EDIDC OPTIONAL
*"      T_RETURN STRUCTURE  ZRAR_IDOC_APPLOG
*"  EXCEPTIONS
*"      CHECK_ARCKEY_OR_IDOC_NUMBER
*"----------------------------------------------------------------------


*----------------------------------------------------------------------
* Type Declaration
*----------------------------------------------------------------------
TYPES: BEGIN OF lty_balm_f,
       docnum TYPE edids-docnum.
       INCLUDE STRUCTURE balm.
TYPES: END OF lty_balm_f.

TYPES: BEGIN OF lty_arckey,
       arckey type IDOCCARKEY,
       END OF lty_arckey.

TYPES: BEGIN OF lty_docnum,
       docnum type EDI_DOCNUM,
       END OF lty_docnum.

*----------------------------------------------------------------------
* Internal tables
*----------------------------------------------------------------------
DATA: lt_edids   TYPE STANDARD TABLE OF edids,
      lt_balhdr  TYPE STANDARD TABLE OF balhdr,
      lt_balhdr_t TYPE STANDARD TABLE OF balhdr,
      lt_balhdrp TYPE STANDARD TABLE OF balhdrp,
      lt_balm    TYPE STANDARD TABLE OF balm,
      lt_balmp   TYPE STANDARD TABLE OF balmp,
      lt_balc    TYPE STANDARD TABLE OF balc,
      lt_exp     TYPE STANDARD TABLE OF bal_s_exception,
      lt_einfo   TYPE STANDARD TABLE OF einfo,
      lt_balm_f  TYPE TABLE OF          lty_balm_f,
      lt_return  TYPE TABLE OF          ZRAR_IDOC_APPLOG,
      lt_date    TYPE STANDARD TABLE OF rsis_s_range,
      lt_time    TYPE STANDARD TABLE OF rsis_s_range,
      lt_edidc   TYPE STANDARD TABLE OF edidc,
      lt_arckey  TYPE TABLE OF          lty_arckey,
      lt_docnum  TYPE TABLE OF          lty_docnum.

*----------------------------------------------------------------------
* STRUCTURES
*----------------------------------------------------------------------
  DATA: ls_date    TYPE rsis_s_range,
        ls_time    TYPE rsis_s_range,
        ls_edids   TYPE edids,
        ls_balhdr  TYPE balhdr,
        ls_balhdr_t TYPE balhdr,
        ls_balhdrp TYPE balhdrp,
        ls_balm    TYPE balm,
        ls_balmp   TYPE balmp,
        ls_balc    TYPE balc,
        ls_exp     TYPE bal_s_exception,
        ls_einfo   TYPE einfo,
        ls_balm_f  TYPE lty_balm_f,
        ls_return  TYPE ZRAR_IDOC_APPLOG,
        ls_edidc   TYPE edidc,
        ls_arckey  TYPE lty_arckey,
        ls_docnum  TYPE lty_docnum.

*----------------------------------------------------------------------
* Variables
*----------------------------------------------------------------------
DATA: lv_errnum TYPE balhdr-extnumber,
      lv_etext  TYPE string,
      lv_docnum TYPE CHAR16.

*----------------------------------------------------------------------
* Constants
*----------------------------------------------------------------------
CONSTANTS: lk_option_i TYPE rsis_s_range-sign   VALUE 'I',
           lk_sign_eq  TYPE rsis_s_range-option VALUE 'EQ',
           lk_mstyp_e  TYPE char1               VALUE 'E'.

*----------------------------------------------------------------------
* Clear & Refresh
*----------------------------------------------------------------------
CLEAR: ls_date, ls_time, lv_errnum, lv_etext, ls_einfo, ls_return, ls_balm_f, ls_arckey, ls_docnum.
REFRESH: lt_date[], lt_time[], lt_edids[], lt_balhdr[], lt_balhdrp[], lt_balm[], lt_balmp[],
         lt_balc[], lt_exp[], lt_return[], t_return[], lt_balm_f, lt_arckey[], lt_docnum[].

*----------------------------------------------------------------------
* Start of Data Extraction
*----------------------------------------------------------------------

** Check if ARCKEY or IDOC_NUMBER check box is checked
IF USE_ARCKEY IS INITIAL and USE_IDOC_NUMBER IS INITIAL.
  RAISE CHECK_ARCKEY_OR_IDOC_NUMBER.
ENDIF.


**-- Collect ARCKEY
  IF T_EDIDC[] IS NOT INITIAL AND USE_ARCKEY = 'X'.
    REFRESH: lt_arckey.
     LOOP AT t_edidc[] INTO ls_edidc.
       IF ls_edidc-arckey is NOT INITIAL.
        ls_arckey-arckey = ls_edidc-arckey.
        APPEND ls_arckey to lt_arckey.
       ENDIF.
       CLEAR: ls_arckey, ls_edidc.
     ENDLOOP.
  ENDIF.

**-- Collect IDOC Number
  IF T_EDIDC[] IS NOT INITIAL AND USE_IDOC_NUMBER = 'X'.
    REFRESH: lt_docnum.
     LOOP AT t_edidc[] INTO ls_edidc.
       IF ls_edidc-docnum is NOT INITIAL.
        UNPACK ls_edidc-docnum to lv_docnum.
        ls_docnum-docnum = lv_docnum.
        APPEND ls_docnum to lt_docnum.
       ENDIF.
       CLEAR: ls_docnum, ls_edidc, lv_docnum.
     ENDLOOP.
  ENDIF.

*-- If Arckey is available, fetch the relevant idocs
  IF lt_arckey[] IS NOT INITIAL AND USE_ARCKEY = 'X'.
    SELECT * FROM edidc INTO TABLE lt_edidc
                        FOR ALL ENTRIES IN lt_arckey
                        WHERE arckey = lt_arckey-arckey.

    IF sy-subrc IS INITIAL.
      SELECT * FROM edids INTO TABLE lt_edids
                          FOR ALL ENTRIES IN lt_edidc
                          WHERE docnum = lt_edidc-docnum.
    ENDIF.
  ENDIF.

*-- If IDOC Number is available, fetch the relevant idocs
  IF lt_docnum[] IS NOT INITIAL and USE_IDOC_NUMBER = 'X'.
    SELECT * FROM edids INTO TABLE lt_edids
                        FOR ALL ENTRIES IN lt_docnum
                        WHERE docnum = lt_docnum-docnum.
  ENDIF.


  IF lt_edids is NOT INITIAL.
    REFRESH: lt_balhdr_t.
    SELECT * FROM balhdr INTO TABLE lt_balhdr_t
                         FOR ALL ENTRIES IN lt_edids
                         WHERE lognumber = lt_edids-appl_log.
  ENDIF.


  IF lt_balhdr_t IS NOT INITIAL.
    LOOP AT lt_balhdr_t INTO ls_balhdr_t.
      IF ls_balhdr_t-lognumber IS NOT INITIAL.
        CALL FUNCTION 'APPL_LOG_READ_DB'
          EXPORTING
            object             = ls_balhdr_t-object
            subobject          = '*'
            external_number    = ls_balhdr_t-EXTNUMBER
*            date_from          = from_date                     "'00000000'
*            date_to            = to_date                       "SY-DATUM
*            time_from          = from_time                     "'000000'
*            time_to            = to_time                       "SY-UZEIT
*            log_class          = '4'
*           PROGRAM_NAME       = '*'
*           TRANSACTION_CODE   = '*'
*           USER_ID            = ' '
*           MODE               = '+'
*           PUT_INTO_MEMORY    = ' '
*      IMPORTING
*           NUMBER_OF_LOGS     = G_LOG
          TABLES
            header_data        = lt_balhdr
            header_parameters  = lt_balhdrp
            messages           = lt_balm
            message_parameters = lt_balmp
            contexts           = lt_balc
            t_exceptions       = lt_exp.


        IF sy-subrc = 0 AND lt_balm[] IS NOT INITIAL.
          SORT lt_balmp BY parname ASCENDING.
            LOOP AT lt_balm INTO ls_balm.
**** Get IDOC_Number from EDIDS table
              READ TABLE lt_edids INTO ls_edids WITH KEY appl_log = ls_balhdr_t-lognumber.
              IF sy-subrc IS INITIAL.
              ls_balm_f-docnum = ls_edids-docnum.
              ENDIF.
              MOVE-CORRESPONDING ls_balm TO ls_balm_f.
              APPEND ls_balm_f to lt_balm_f.
              CLEAR: ls_balm_f, ls_balm, ls_edidc.
            ENDLOOP.
        ENDIF.
      ENDIF.
      CLEAR: lv_errnum, ls_edids, ls_balhdr_t.
      REFRESH: lt_balhdr[], lt_balhdrp[], lt_balm[], lt_balmp[], lt_balc[], lt_exp[].
    ENDLOOP.

*-- To generate the list of error messages
  SORT lt_balm_f BY docnum lognumber msgid msgno.
  LOOP AT lt_balm_f INTO ls_balm_f.

    ls_einfo-mandt = sy-mandt.
    ls_einfo-msgty = ls_balm_f-msgty.
    ls_einfo-msgid = ls_balm_f-msgid.
    ls_einfo-msgno = ls_balm_f-msgno.
    ls_einfo-msgv1 = ls_balm_f-msgv1.
    ls_einfo-msgv2 = ls_balm_f-msgv2.
    ls_einfo-msgv3 = ls_balm_f-msgv3.
    ls_einfo-msgv4 = ls_balm_f-msgv4.

    CALL FUNCTION 'MESSAGE_GET_TEXT'
    EXPORTING
      ieinfo        = ls_einfo
      ilangu        = sy-langu
    IMPORTING
      etext         = lv_etext
    EXCEPTIONS
      no_t100_found = 1
      OTHERS        = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

    ls_return-zdocnum = ls_balm_f-docnum.
    ls_return-ZAPPL_LOG_NUM = ls_balm_f-lognumber.
    ls_return-ZMSTYP  = ls_balm_f-msgty.
    ls_return-ZERRTXT = lv_etext.
    READ TABLE lt_edidc INTO ls_edidc WITH KEY docnum = ls_balm_f-docnum.
      IF sy-subrc IS INITIAL.
        ls_return-zarckey = ls_edidc-arckey.
      ENDIF.

    APPEND ls_return TO lt_return.
    CLEAR: ls_return, lv_etext, ls_balm_f, ls_einfo, ls_edidc.
  ENDLOOP.
 ELSE.
    CLEAR: ls_return.
    ls_return-ZMSTYP  = lk_mstyp_e.
    ls_return-ZERRTXT = text-001.

    APPEND ls_return TO lt_return.
    CLEAR: ls_return.
 ENDIF.

  DELETE ADJACENT DUPLICATES FROM lt_return COMPARING zdocnum zappl_log_num zmstyp zerrtxt.
  t_return[] = lt_return[].



ENDFUNCTION.
