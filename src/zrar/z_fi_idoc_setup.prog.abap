*&---------------------------------------------------------------------*
*& Report  Z_RTR_IDOC_SETUP
*&
*&---------------------------------------------------------------------*
*&
*& This program generates the IDoc inbound customizing settings to
*& use the ALE IDoc inbound from BObj DI partners.
*&
*& As ALE/IDoc customizing settings are client dependent,
*& this program has to run in the specific client.
*&
*& The single customizing steps are:
*&
*& 1) Create a partner in WE20:
*& The partner for BObj DI always is of type 'US'.
*& This partner name should be the name 'BOBJTFR' as DI is
*& sending IDocs with this name.
*&
*& 2) Create IDoc inbound parameters per message type in WE20:
*& All known and used IDoc message types and its process codes
*& will be created.
*&
*&---------------------------------------------------------------------*

REPORT   Z_RTR_IDOC_SETUP
        NO STANDARD PAGE HEADING LINE-SIZE 255.

DATA: automode VALUE 'X'.

* table declarations needed for the selection screens
TABLES: edidc,edp21.

* definition data

types truxs_t_text_data(4096) type c occurs 0.
DATA:  itab_raw_data  TYPE truxs_t_text_data WITH HEADER LINE,
       itab1 LIKE TABLE OF edp21 WITH HEADER LINE.
DATA:  flag,
       l_mtext   TYPE string.
DATA:  BEGIN OF lt_obj OCCURS 0,
          messtype TYPE /sapdmc/lsoatt-messtype,
          idoctype TYPE /sapdmc/lsoatt-idoctype,
          cimtype  TYPE /sapdmc/lsoatt-cimtype,
          evcode   TYPE edipevcode,
          flag,
        END OF lt_obj,
        BEGIN OF lt_mes OCCURS 0,
          messtype TYPE /sapdmc/lsoatt-messtype,
        END OF lt_mes,
        BEGIN OF itab OCCURS 0,
          messtype TYPE /sapdmc/lsoatt-messtype,
          evcode   TYPE edipevcode,
          flag,
        END OF itab.


* selection screen
SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.
PARAMETERS: p_part  TYPE edipsndprn  OBLIGATORY DEFAULT 'BOBJTFR',
            p_user  TYPE usr02-bname OBLIGATORY DEFAULT sy-uname.
SELECTION-SCREEN SKIP 1.
*PARAMETERS: p_file  TYPE rlgrap-filename DEFAULT ''.
*Function GUI_UPLOAD declare
PARAMETERS: p_file  TYPE string DEFAULT ''.
SELECTION-SCREEN SKIP 4.
SELECTION-SCREEN BEGIN OF BLOCK blocktrigger WITH FRAME TITLE text001.
PARAMETERS:  p_imme  TYPE edi_selbat RADIOBUTTON GROUP sel,
             p_bgrp  TYPE edi_selbat RADIOBUTTON GROUP sel.
SELECTION-SCREEN END   OF BLOCK blocktrigger.
SELECTION-SCREEN END OF SCREEN 1100.


SELECTION-SCREEN BEGIN OF SCREEN 1200 AS SUBSCREEN.
PARAMETERS: p_part2  TYPE edipsndprn  OBLIGATORY DEFAULT 'BOBJTFR',
            p_user2  TYPE usr02-bname OBLIGATORY DEFAULT sy-uname.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_file2  TYPE rlgrap-filename.
*SELECT-OPTIONS s_mestyp FOR edidc-mestyp MATCHCODE OBJECT alemestyp NO INTERVALS.
*PARAMETERS c_submit AS CHECKBOX USER-COMMAND ucom.
SELECT-OPTIONS s_mestyp FOR lt_obj-messtype NO INTERVALS.
SELECTION-SCREEN SKIP 3.
SELECTION-SCREEN BEGIN OF BLOCK blocktrigger2 WITH FRAME TITLE text002.
PARAMETERS:  p_imme2  TYPE edi_selbat RADIOBUTTON GROUP sel2,
             p_bgrp2  TYPE edi_selbat RADIOBUTTON GROUP sel2.
SELECTION-SCREEN END   OF BLOCK blocktrigger2.
SELECTION-SCREEN END OF SCREEN 1200.

*  definition of tab strip areas
SELECTION-SCREEN BEGIN OF TABBED BLOCK selscr FOR 25 LINES.
SELECTION-SCREEN TAB (15) st_auto USER-COMMAND ucomm_auto
                DEFAULT SCREEN 1100.
SELECTION-SCREEN TAB (30) st_manu USER-COMMAND ucomm_manu
                DEFAULT SCREEN 1200.
SELECTION-SCREEN END OF BLOCK selscr.

* ---------------------------------------------------------------------------------------

* select file
DATA: ftable   TYPE filetable,
      rc       TYPE i,
      fname    LIKE file_table-filename.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Please select a file'
      file_filter  = '.txt'
    CHANGING
      file_table   = ftable
      rc           = rc.
  IF rc > 0.
    READ TABLE ftable INDEX 1 INTO fname.
    p_file   = fname.
  ENDIF.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file2.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Please select a file'
      file_filter  = '.txt'
    CHANGING
      file_table   = ftable
      rc           = rc.
  IF rc > 0.
    READ TABLE ftable INDEX 1 INTO fname.
    p_file2   = fname.
  ENDIF.


AT SELECTION-SCREEN. "PAI

  IF sy-ucomm = 'UCOMM_AUTO'.
    p_part = p_part2.
    p_user = p_user2.
    p_bgrp = p_bgrp2.
    p_imme = p_imme2.
    p_file = p_file2.
    CLEAR s_mestyp[].
    automode = 'X'.
  ELSEIF sy-ucomm = 'UCOMM_MANU'.
    p_part2 = p_part.
    p_user2 = p_user.
    p_bgrp2 = p_bgrp.
    p_imme2 = p_imme.
    p_file2 = p_file.
    CLEAR s_mestyp[].
    CLEAR automode.
  ELSEIF automode IS INITIAL.
    p_part = p_part2.
    p_user = p_user2.
    p_bgrp = p_bgrp2.
    p_imme = p_imme2.
    p_file = p_file2.
  ENDIF.


INITIALIZATION.
* Generation of Partner Profile Settings
  st_auto = 'Automatic'.
* Manually adding message types
  st_manu = 'Manual'.
  text001 = 'Processing by function module (WE20 setting)'.
  text002 = text001.

START-OF-SELECTION.

*& 1) Create a partner in WE20
  PERFORM create_we20.

*& 2) Create IDoc inbound parameters per message type in WE20
  PERFORM set_idocs.

* ---------------------------------------------------------------------------------------


*&---------------------------------------------------------------------*
*&      Form  create_we20
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM create_we20.
  DATA: l_edpp1 TYPE edpp1,
        l_mtext TYPE string.

  l_edpp1-partyp = 'US'.
  l_edpp1-parnum = p_part.
  l_edpp1-matlvl = 'A'.
  l_edpp1-usrtyp = 'US'.
  l_edpp1-usrkey = p_user.
  l_edpp1-usrlng = sy-langu.

  CALL FUNCTION 'EDI_AGREE_PARTNER_INSERT'
    EXPORTING
      rec_edpp1                 = l_edpp1
*     NO_PTYPE_CHECK            = ' '
    EXCEPTIONS
       db_error                  = 1
       already exist             = 2
       parameter_error           = 3
       OTHERS                    = 4
          .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO l_mtext.
    WRITE: / 'Message:', l_mtext.
    WRITE: / '         Partner number is',l_edpp1-parnum.
    ULINE AT /1(100).
  ELSE.
    WRITE: / 'Success: Partner profile US', l_edpp1-parnum, 'created.'.
    ULINE AT /1(100).

  ENDIF.

ENDFORM.                    "create_we20


*&---------------------------------------------------------------------*
*&      Form  set_idocs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_idocs.

  CLEAR lt_obj.
  REFRESH lt_obj.

* Automatic
  IF automode = 'X'.

    perform txt_to_internaltable.

    LOOP AT lt_obj.
      CASE lt_obj-flag.
        WHEN 'X'.   "update message type
          CLEAR:itab1,itab1[].
          DATA wa_itab1 LIKE LINE OF itab1.

          SELECT *
            FROM edp21
            INTO CORRESPONDING FIELDS OF TABLE itab1
            WHERE sndprn = p_part AND sndprt = 'US'.
          LOOP AT itab1.
            IF itab1-mestyp EQ lt_obj-messtype.
              wa_itab1 = itab1.
              IF sy-subrc EQ 0.
                DELETE edp21 FROM wa_itab1.
              ELSE.
                WRITE:/ 'db_error'.
              ENDIF.
            ENDIF.
          ENDLOOP.

          PERFORM attributes_agreement_create
           USING 'US' p_part lt_obj-messtype
                  lt_obj-idoctype lt_obj-cimtype lt_obj-evcode.
          WRITE 'by overwrite.'.
          CLEAR wa_itab1.

        WHEN OTHERS.   "insert message type
          PERFORM attributes_agreement_create
            USING 'US' p_part lt_obj-messtype
                   lt_obj-idoctype lt_obj-cimtype lt_obj-evcode.
      ENDCASE.
    ENDLOOP.
  ELSE.

* Manual

  ENDIF.

ENDFORM.                    "set_idocs


*&---------------------------------------------------------------------*
*&      Form  ATTRIBUTES_AGREEMENT_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      ?P_PARTNERTYPE  text
*      ?P_PARTNERNR    text
*      ?P_MESSTYPE     text
*      ?P_IDOCTYPE     text
*      ?P_CIMTYPE      text
*      ?P_EVCODE       text
*----------------------------------------------------------------------*
FORM attributes_agreement_create USING p_partnertype  p_partnernr
                                       p_messtype     p_idoctype
                                       p_cimtype      p_evcode.
  TABLES: edifct, tbd52.
  DATA: l_eddp1  TYPE eddp1,
        l_edkp1  TYPE edkp1,
        l_edd21  TYPE edd21,
        l_edk21  TYPE edk21,
        l_edp21  TYPE edp21,
        lt_tmsg2 TYPE tmsg2 OCCURS 0 WITH HEADER LINE.

  DATA: l_counter TYPE i.

  l_edk21-mandt  = sy-mandt.
  l_edk21-sndprn = p_partnernr.
  l_edk21-sndprt = p_partnertype.
  l_edk21-mestyp = p_messtype.

  CALL FUNCTION 'EDI_AGREE_IN_MESSTYPE_READ'
    EXPORTING
      rec_edk21       = l_edk21
    IMPORTING
      rec_edd21       = l_edd21
    EXCEPTIONS
      db_error        = 1
      entry_not_exist = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.                    " PV anlegen
    CLEAR l_edp21.
    l_edp21-mandt  = sy-mandt.
    l_edp21-sndprn = p_partnernr.
    l_edp21-sndprt = p_partnertype.
    l_edp21-mestyp = p_messtype.
    l_edp21-evcode = p_evcode.
    l_edp21-synchk = 'X'.

    IF p_imme = 'X'.
      l_edp21-inmod  = '1'.
    ELSE.
      l_edp21-inmod  = '3'.
    ENDIF.

    IF l_edp21-evcode IS INITIAL.

      SELECT * FROM tmsg2 INTO TABLE lt_tmsg2
                               WHERE mestyp = p_messtype.
      DESCRIBE TABLE lt_tmsg2 LINES l_counter.

      IF l_counter > 0.
        READ TABLE lt_tmsg2 INDEX 1.
        l_edp21-mescod = lt_tmsg2-mescod.
        l_edp21-mesfct = lt_tmsg2-mesfct.
        l_edp21-evcode = lt_tmsg2-evcode.
      ELSE.
        SELECT SINGLE * FROM edifct
                WHERE idoctyp = p_idoctype
                  AND cimtyp = p_cimtype
                  AND mestyp = p_messtype.
        IF sy-subrc = 0.
          l_edp21-mescod = edifct-mescod.
          l_edp21-mesfct = edifct-mesfct.
          SELECT SINGLE * FROM tbd52 WHERE funcname = edifct-fctnam.
          IF sy-subrc = 0.
            l_edp21-evcode = tbd52-evcode.
          ENDIF.
        ENDIF.
      ENDIF.

      IF l_edp21-evcode IS INITIAL.
        MESSAGE i814(/sapdmc/lsmw) WITH p_messtype INTO l_mtext.
        WRITE: / l_mtext.
        EXIT.
      ENDIF.

    ENDIF.

    CALL FUNCTION 'EDI_AGREE_IN_MESSTYPE_INSERT'
      EXPORTING
        rec_edp21           = l_edp21
      EXCEPTIONS
        db_error            = 1
        entry_already_exist = 2
        parameter_error     = 3
        OTHERS              = 4.
    IF sy-subrc <> 0 AND sy-subrc <> 2.
      MESSAGE i811(/sapdmc/lsmw) WITH p_messtype INTO l_mtext.
      FORMAT COLOR = 6.
      WRITE: / l_mtext, ': ERROR! Please check your file.' intensified on.
      FORMAT COLOR = 0.
      EXIT.
    ELSE.
      MESSAGE i816(/sapdmc/lsmw) WITH p_messtype INTO l_mtext.
      WRITE: / l_mtext.
    ENDIF.
    IF l_counter > 1.
      MESSAGE i999(b1) WITH text-004 INTO l_mtext.
      WRITE: / l_mtext.
    ENDIF.
  ENDIF.

ENDFORM.                    "ATTRIBUTES_AGREEMENT_CREATE

*&---------------------------------------------------------------------*
*&      Form  TXT_TO_INTERNALTABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  ?  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM TXT_TO_INTERNALTABLE .
  CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    FILENAME                      = p_file
*   FILETYPE                      = 'ASC'
    HAS_FIELD_SEPARATOR           = 'X'
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE                      = ' '
*   CODEPAGE                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
  TABLES
    DATA_TAB                      = itab[]
 EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_READ_ERROR               = 2
   NO_BATCH                      = 3
   GUI_REFUSE_FILETRANSFER       = 4
   INVALID_TYPE                  = 5
   NO_AUTHORITY                  = 6
   UNKNOWN_ERROR                 = 7
   BAD_DATA_FORMAT               = 8
   HEADER_NOT_ALLOWED            = 9
   SEPARATOR_NOT_ALLOWED         = 10
   HEADER_TOO_LONG               = 11
   UNKNOWN_DP_ERROR              = 12
   ACCESS_DENIED                 = 13
   DP_OUT_OF_MEMORY              = 14
   DISK_FULL                     = 15
   DP_TIMEOUT                    = 16
   OTHERS                        = 17
          .
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
  LOOP AT itab.
    MOVE-CORRESPONDING itab TO lt_obj.
    APPEND lt_obj.
  ENDLOOP.

ENDFORM.                    " TXT_TO_INTERNALTABLE
