*********************************************************************
*& Program           : ZRTR_CUSTOM_FPS3                             *
*& Module            : RTR                                          *
*& Sub-Module        : RTR                                          *
*& Functional Contact: Radhika Varakantam                           *
*& Funct. Spec. Ref. : Defect 18029                                 *
*& Developer(Company): Surekha Pawar                                *
*& Create Date       : 03/03/2022                                   *
*& Program Type      : Interface - Basic ABAP/4 Report              *
*& Project Phase     : Project Simplify                             *
*& Description       : Copy of Standard program RFEBKA40 (FPS3)     *
*& customized to avoid manual selection of statements               *
*********************************************************************
*----------------------------------------------------------------------*
*&  REVISION LOG                                                    *
*-------------------------------------------------------------------*
*& Date                : 03/16/2022                                 *
*& Ticket/Change Req.# : Defect 18178                               *
*& Requested by        : Radhika Varakantam                         *
*& Developer(Company)  : Surekha Pawar                              *
*& Description         : Validation added to avoid duplicate memos  *
*&                       from getting created
*********************************************************************
*&---------------------------------------------------------------------*
*& Report has been changed for ALV project.
*&
*& Date: 08-Apr-2004
*&
*& Name & C-User of the Programmer: Yogesh Ratnaparkhi (C5053262)
*&
*& Short description of the program:
*&   Colors in the Report output have been modified as per the
*&   requirement of the structure recognition tool for the following
*&   specifications:
*&   -Hierarchical-seq.: Two levels, grouping header at the top
*&   -Header in TOP-OF-PAGE area
*&   -Table with title
*&---------------------------------------------------------------------*
REPORT zrar_fps3
       MESSAGE-ID fb
       NO STANDARD PAGE HEADING
       LINE-SIZE 123. "AFLE: Changed from 110

TABLES: febko,  febvw, febpi,          " Kopf
        febep, febre, febcl,          " Position
        bhdgd,                        " Batch-Heading
        t028g, t028b, t037, t035d, t028l,       "customizing
        t100,                         " Error messages
        fdes.

TABLES:  rfradc.
TABLES:  rfpdo2.

*eject
************************************************************************
*        Selektionsbild
************************************************************************
*------- Dateiangaben -------------------------------------------------
SELECTION-SCREEN  BEGIN OF BLOCK 1 WITH FRAME TITLE TEXT-b01.
  SELECT-OPTIONS: s_azdat FOR febko-azdat,
                  s_aznum FOR febko-aznum,
                  s_hbkid FOR febko-hbkid,
                  s_hktid FOR febko-hktid,
                  s_bukrs FOR febko-bukrs,
                  s_waers FOR febko-waers.
SELECTION-SCREEN  END OF BLOCK 1.

SELECTION-SCREEN BEGIN OF BLOCK 2 WITH FRAME TITLE TEXT-b02.
  SELECT-OPTIONS:
                  s_euser FOR febko-euser,
                  s_edate FOR febko-edate,
                  s_etime FOR febko-etime.
SELECTION-SCREEN END   OF BLOCK 2.



*eject
************************************************************************
*        Interne Tabellen
************************************************************************
DATA: s_anwnd LIKE febko-anwnd VALUE '0004'. "same day only


* ------ ... zu bearbeitende Zeilen -----------------------------------
DATA:    BEGIN OF tfebep OCCURS 100.
DATA: xpick(1)       TYPE c,                 " Zeile ausgewählt
      febko          LIKE febko,
      febpi          LIKE febpi,
      febep          LIKE febep,
      febpi-archk    LIKE t037-archk,
      febpi-xarch(1) TYPE c,
      febpi-ebene    LIKE fdes-ebene,
      febep-ebene    LIKE fdes-ebene,
      febpi-numkr    LIKE t037-numkr,
      fdes-amount    LIKE fdes-dmshb,
      pomsg          LIKE balmt,
      bustat(1)      TYPE c.        "zu buchen, nicht...
DATA:    END   OF tfebep.

DATA: xfebpi-archk    LIKE t037-archk,
      xfebpi-xarch(1) TYPE c,
      xfebpi-ebene    LIKE fdes-ebene,
      xfebpi-numkr    LIKE t037-numkr.

DATA: c_merkm_balance LIKE fdes-merkm VALUE ' ',
      c_merkm_detail  LIKE fdes-merkm VALUE 'SAME DAY DETAIL'.

DATA: xfebre LIKE febre OCCURS 0 WITH HEADER LINE.

DATA: xmain(1)     TYPE c.             " Zeile mit xpick

*eject
************************************************************************
*        Strukturen
************************************************************************
* ------ .... HIDE-Felder ----------------------------------------------
DATA: BEGIN OF hide,
        kukey    LIKE febko-kukey,
        esnum    LIKE febep-esnum,
        xmain(1) TYPE c,
        xpick(1) TYPE c,
      END   OF hide.

*eject
************************************************************************
*        Einzelfelder
************************************************************************
DATA: count_febep TYPE i,        " selektierte Zeilen
      count_memo  TYPE i,        " no. memo rec.
      count_nok   TYPE i,        " error memo rec. creation
      count_stm   TYPE i,        " no of stmnts
      count_arch  TYPE i,        " no of memo rec archived
      i           TYPE i,
      lsind       LIKE sy-lsind,
      lstyp(1)    TYPE c,        " Listtyp: D=Daten,S=Statist
      ok-code(4)  TYPE c,
      header1(80) TYPE c,        " Kopfzeile
      spueb1(30)  TYPE c,        " Spaltenüberschrift
      spueb2(30)  TYPE c,        " Spaltenüberschrift
      spueb3(30)  TYPE c,        " Spaltenüberschrift
      spueb4(30)  TYPE c,        " Spaltenüberschrift
      spueb5(30)  TYPE c,        " Spaltenüberschrift
      spueb6(30)  TYPE c,        " Spaltenüberschrift
      spueb7(30)  TYPE c,        " Spaltenüberschrift
      spueb8(30)  TYPE c,        " Spaltenüberschrift
      spueb9(30)  TYPE c,        " Spaltenüberschrift
      spueb10(30) TYPE c,        " Spaltenüberschrift
      xpick(1)    TYPE c,
      out_belnr   LIKE bkpf-belnr,
      out_gjahr   LIKE bkpf-gjahr,
      out_bukrs   LIKE t001-bukrs.
DATA:    error_txt_on(1) TYPE c VALUE ' '.
*eject
************************************************************************
*        Initialization
************************************************************************
INITIALIZATION.

* ------ Buchungskreis: Parmeter 'BUK' ---------------------------------
  GET PARAMETER ID 'BUK' FIELD s_bukrs-low.
  IF s_bukrs-low NE space.
    s_bukrs-high   = ' '.
    s_bukrs-option = 'EQ'.
    s_bukrs-sign   = 'I'.
    APPEND s_bukrs.
  ENDIF.

* ------ Angelegt von: SY-UNAME ----------------------------------------
*  s_euser-low    = sy-uname.
*  s_euser-high   = ' '.
*  s_euser-option = 'EQ'.
*  s_euser-sign   = 'I'.
*  APPEND s_euser.

* ------ Angelegt am ---------------------------------------------------
  s_edate-low    = sy-datum.
  s_edate-high   = sy-datum.
  s_edate-option = 'EQ'.
  s_edate-sign   = 'I'.
  APPEND s_edate.

  CALL FUNCTION 'FCLM_CASH_MEMO_NR_CHECK'.




*eject
************************************************************************
*        Start of Selection
************************************************************************
START-OF-SELECTION.


* ------ Batchheading --------------------------------------------------
  bhdgd-inifl = '0'.
  bhdgd-lines = sy-linsz.              " Zeilenbreite aus Report
  bhdgd-uname = sy-uname.              " Benutzername
  bhdgd-repid = sy-repid.              " Name des ABAP-Programmes
  bhdgd-line1 = sy-title.              " Titel des ABAP-Programmes
  bhdgd-separ = space.                 " Keine Listseparation

* ------ Avise einlesen ------------------------------------------------
  PERFORM daten_einlesen.

**** Customizing logic for background Run for FPS3 Defect 18029

  "Comment below Perform to displaying the items
* ------ Vorschlagsliste -----------------------------------------------
*  PERFORM LISTE_AUSGEBEN.

  "Mark all the statements that has no Credit memos created yet as selected
  LOOP AT tfebep ASSIGNING FIELD-SYMBOL(<fs_febep>).
    "Added as part of Defect 18178 to avoid duplicate memo creation
    IF <fs_febep>-febep-idenr IS INITIAL.
      <fs_febep>-xpick = 'X'.
    ELSE.
      "End of Changes for Defect 18178
      CLEAR: <fs_febep>-xpick.
    ENDIF.    "Change by Defect 18178
  ENDLOOP.

  "Create Memo Records
  PERFORM avise_buchen.
  sy-lsind = sy-lsind - 1.
  error_txt_on = 'X'.

  "Display Output List
  PERFORM liste_ausgeben.
  CLEAR error_txt_on.


  " Comment below code to avoid manual selection step
*eject
*-----------------------------------------------------------------------
*       AT USER-COMMAND
*-----------------------------------------------------------------------
*AT USER-COMMAND.
*  CASE sy-ucomm.
*
** ------ Alle buchen ---------------------------------------------------
*    WHEN 'POS'.
*      PERFORM markierung_uebernehmen.
*      PERFORM avise_buchen.
*      sy-lsind = sy-lsind - 1.
*      error_txt_on = 'X'.
*      PERFORM liste_ausgeben.
*      CLEAR error_txt_on.
*
** ------ Alle entmarkieren ---------------------------------------------
*    WHEN 'MAOF'.
*      LOOP AT tfebep.
*        CLEAR: tfebep-xpick.
*        MODIFY tfebep.
*      ENDLOOP.
*      sy-lsind = sy-lsind - 1.
*      PERFORM liste_ausgeben.
*
** ------ Alle markieren ------------------------------------------------
*    WHEN 'MAON'.
*      LOOP AT tfebep.
*        tfebep-xpick = 'X'.
*        MODIFY tfebep.
*      ENDLOOP.
*      sy-lsind = sy-lsind - 1.
*      PERFORM liste_ausgeben.
*
** ------- Sichern nach 'Anz->Ändern' eventuell nötig -------------------
*
*  ENDCASE.

****End of Customization Defect 18029
*-----------------------------------------------------------------------
*       AT LINE-SELECTION
*-----------------------------------------------------------------------
AT LINE-SELECTION.

*------ anzeigen ------------------------------------------------------
  IF hide-esnum = 0.
    SUBMIT rfebkap0
             WITH r_kukey EQ hide-kukey
          AND RETURN.
  ELSE.
    SUBMIT rfebkap0
             WITH r_kukey EQ hide-kukey
             WITH r_esnum EQ hide-esnum
          AND RETURN.
  ENDIF.


*eject
*-----------------------------------------------------------------------
*       TOP-OF-PAGE
*-----------------------------------------------------------------------
TOP-OF-PAGE.
  PERFORM top.

*eject
*-----------------------------------------------------------------------
*       TOP-OF-PAGE
*-----------------------------------------------------------------------
TOP-OF-PAGE DURING LINE-SELECTION.
  PERFORM top.

*eject
************************************************************************
*        MODULE EXIT
************************************************************************
MODULE exit.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMODULE.                    "EXIT

*eject

*******   FORM-Routinen ************************************************


*eject
************************************************************************
*        FORM DATEN_EINLESEN
************************************************************************
FORM daten_einlesen.
  DATA: feblines TYPE p,
        vozpm    LIKE t028g-vozpm.

  REFRESH: tfebep.

*--------------------------------------------------------------*
* Selektion der Kontoauszuege                                  *
*--------------------------------------------------------------*
  SELECT * FROM febko WHERE anwnd = s_anwnd AND
                            azdat IN s_azdat.
    CHECK febko-aznum IN s_aznum.
    CHECK febko-bukrs IN s_bukrs.
    CHECK febko-waers IN s_waers.
    CHECK febko-hbkid IN s_hbkid.
    CHECK febko-euser IN s_euser.
    CHECK febko-edate IN s_edate.
    CHECK febko-etime IN s_etime.

    SELECT SINGLE * FROM  febpi WHERE  kukey = febko-kukey
                                  AND  esnum = 0.
    CHECK febpi-hktid IN s_hktid.

*-- one entry for archiving the balance --
    CLEAR tfebep.
    MOVE-CORRESPONDING febko TO tfebep-febko.
    MOVE-CORRESPONDING febpi TO tfebep-febpi.
*    tfebep-xpick = 'X'.
    IF tfebep-febpi-dsart IS INITIAL.
      tfebep-febpi-dsart = tfebep-febko-dsart.
    ENDIF.
    CLEAR: tfebep-febpi-ebene.
    IF NOT tfebep-febpi-dsart IS INITIAL.
* Identify Planning Level
      SELECT SINGLE * FROM  t037
             WHERE dsart = tfebep-febpi-dsart.
      IF sy-subrc <> 0
        OR t037-archk = space.         "no archiving class
      ENDIF.
      tfebep-febpi-archk = t037-archk.
      tfebep-febpi-ebene = t037-ebene.
      tfebep-febpi-numkr = t037-numkr.
    ENDIF.
*-- read table T035D --
    IF NOT tfebep-febpi-bnkko IS INITIAL.
      SELECT SINGLE * FROM t035d
              WHERE bukrs = tfebep-febko-bukrs
                AND diskb = tfebep-febpi-bnkko.
      IF sy-subrc = 0 AND NOT t035d-bnkko IS INITIAL.
        tfebep-febpi-bnkko = t035d-bnkko.
      ENDIF.
    ELSE.
      tfebep-febpi-bnkko = tfebep-febpi-hkont.
    ENDIF.
*-- read FDES --
    SELECT * FROM fdes                                  "#EC CI_NOFIRST
             WHERE bukrs = tfebep-febpi-bukrs
               AND bnkko = tfebep-febpi-bnkko
               AND grupp = space
               AND ebene = tfebep-febpi-ebene
               AND dispw = tfebep-febko-waers
               AND datum = tfebep-febko-azdat  "value date
               AND idenr = tfebep-febpi-idenr
               AND merkm = c_merkm_balance
      ORDER BY PRIMARY KEY.
      IF fdes-archk <> space.
        tfebep-febpi-archk = fdes-archk.
        tfebep-febpi-xarch = 'X'.
        CLEAR tfebep-xpick.
      ENDIF.
      tfebep-fdes-amount = fdes-dmshb.
      EXIT.
    ENDSELECT.

*-- save new values --
    MOVE-CORRESPONDING tfebep-febpi TO febpi.
    xfebpi-archk = tfebep-febpi-archk.
    xfebpi-ebene = tfebep-febpi-ebene.
    xfebpi-numkr = tfebep-febpi-numkr.
    xfebpi-xarch = tfebep-febpi-xarch.
    APPEND tfebep.

    SELECT * FROM febep WHERE kukey = febko-kukey AND
                              eperl <> 'X'
                        ORDER BY esnum.

      count_febep = count_febep + 1.
      CLEAR tfebep.
      MOVE-CORRESPONDING febko TO tfebep-febko.
      MOVE-CORRESPONDING febpi TO tfebep-febpi.
      MOVE-CORRESPONDING febep TO tfebep-febep.
*      tfebep-xpick = 'X'.
      tfebep-febpi-archk = xfebpi-archk.
      tfebep-febpi-ebene = xfebpi-ebene.
      tfebep-febpi-numkr = xfebpi-numkr.
*-- read table T028L ---
      SELECT SINGLE * FROM t028l WHERE bankl = tfebep-febpi-bankl AND
                                       ktonr = tfebep-febpi-bankn.
      IF sy-subrc = 0.
        SELECT SINGLE * FROM  t037
               WHERE dsart = t028l-dadet.
        IF sy-subrc = 0.
          tfebep-febpi-dsart = t028l-dadet.
          tfebep-febpi-archk = t037-archk.
          tfebep-febep-ebene = t037-ebene.
          tfebep-febpi-numkr = t037-numkr.
        ENDIF.
      ENDIF.
*-- read T028G --
      IF tfebep-febep-vozei = 'C'
      OR tfebep-febep-vozei = 'RD'
      OR tfebep-febep-epvoz = 'H'.
        vozpm = '+'.
      ELSE.
        vozpm = '-'.
      ENDIF.
      SELECT SINGLE * FROM t028g WHERE vgtyp = tfebep-febko-vgtyp
                                   AND vgext = tfebep-febep-vgext
                                   AND vozpm = vozpm.
      IF sy-subrc = 0 AND NOT t028g-dadet IS INITIAL.
        SELECT SINGLE * FROM  t037
               WHERE dsart = t028g-dadet.
        IF sy-subrc = 0.
          tfebep-febpi-dsart = t028g-dadet.
          tfebep-febpi-archk = t037-archk.
          tfebep-febep-ebene = t037-ebene.
          tfebep-febpi-numkr = t037-numkr.
        ENDIF.
      ENDIF.
      IF vozpm = '-'.
        tfebep-febep-kwbtr = tfebep-febep-kwbtr * -1.
      ENDIF.
      APPEND tfebep.
    ENDSELECT.
    IF sy-subrc <> 0.                  "no details - delete balance
      DESCRIBE TABLE tfebep LINES feblines.
      DELETE tfebep INDEX feblines.
    ENDIF.
  ENDSELECT.

ENDFORM.                    "DATEN_EINLESEN

*eject
************************************************************************
*        FORM HIDE
************************************************************************
FORM hide.
  hide-kukey = tfebep-febko-kukey.
  hide-esnum = tfebep-febep-esnum.
  hide-xmain = xmain.
  hide-xpick = xpick.
  HIDE hide.
ENDFORM.                    "HIDE

*eject
************************************************************************
*        FORM LISTE_AUSGEBEN
************************************************************************
FORM liste_ausgeben.
  DATA: text65(65)   TYPE c,
        text5(5)     TYPE c,
        xflag_det(1) TYPE c.

* ------ Status, Initialisierungen -------------------------------------
  lstyp = 'D'.
  CLEAR: hide.
  SET PF-STATUS 'STDA'.

  CLEAR xflag_det.
* ------ Zeilen -------------------------------------------------------
  LOOP AT tfebep.
    IF tfebep-febep-esnum = 0.
      IF xflag_det = 'X'.
* ------ Abschließende Strichzeile -------------------------------------
        WRITE: /   sy-vline NO-GAP,
                   sy-uline(121),   "AFLE: Changed from 108
                   122 sy-vline NO-GAP.  "AFLE: Changed from 121
        CLEAR xflag_det.
      ENDIF.
      PERFORM header_stmt.
      CONTINUE.
    ENDIF.
    IF tfebep-febep-esnum = 1.
*      Start Comment- C5053262 - Commented for ALV changes
*      PERFORM DETAIL_TOP.
*      End Comment- C5053262 - Commented for ALV changes
      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
      xflag_det = 'X'.
    ENDIF.
    xpick = tfebep-xpick.
    WRITE: /   sy-vline NO-GAP.
    IF tfebep-febep-idenr IS INITIAL.
      WRITE    xpick AS CHECKBOX.
    ELSE.
      CLEAR xpick.
      WRITE xpick AS CHECKBOX INPUT OFF.
    ENDIF.

    SELECT * FROM febre INTO TABLE xfebre
             WHERE kukey = tfebep-febep-kukey
               AND esnum = tfebep-febep-esnum
      ORDER BY PRIMARY KEY.
    READ TABLE xfebre INDEX 1.
    IF sy-subrc = 0.
      text65 = xfebre-vwezw.
    ELSE.
      text65 = tfebep-febep-butxt.
      IF text65 IS INITIAL.
        text65 = febko-vgtyp.
        text65+10 = tfebep-febep-vorgc.
        IF NOT tfebep-febep-vgext IS INITIAL.
*
          IF tfebep-febep-vgext = '581'.
            text65+14 = TEXT-007.
          ELSE.
            IF NOT tfebep-febep-vgext = tfebep-febep-vorgc.
              text65+14 = tfebep-febep-vgext.
            ENDIF.
          ENDIF.
*
        ENDIF.
      ENDIF.
    ENDIF.

*    Start Comment- C5053262 - Commented for ALV changes
*    WRITE: 3 SY-VLINE NO-GAP,
*             TFEBEP-FEBEP-ESNUM,
*             SY-VLINE NO-GAP,
*             TEXT65,
*             SY-VLINE NO-GAP,
*             TFEBEP-FEBEP-KWBTR CURRENCY TFEBEP-FEBKO-WAERS,
*             SY-VLINE NO-GAP.
*    End Comment- C5053262 - Commented for ALV changes

*   Start Addition - C5053262
    WRITE:   4 tfebep-febep-esnum,
             11 text65,
             78(31) tfebep-febep-kwbtr CURRENCY tfebep-febko-waers.
    "AFLE
*   End Addition - C5053262

    IF tfebep-febep-idenr IS INITIAL.
      WRITE 111 '          '. "AFLE: Changed from 31 spaces
    ELSE.
      WRITE 111 tfebep-febep-idenr. "AFLE: Changed from 98
    ENDIF.
    WRITE  122 sy-vline NO-GAP.  "AFLE: Changed from 109
    xmain = 'X'.
    PERFORM hide.
    LOOP AT xfebre FROM 2.
      text65 = xfebre-vwezw.
      WRITE: /   sy-vline, sy-vline NO-GAP,
                 '     ',
                 sy-vline NO-GAP,
                 text65,
                 sy-vline NO-GAP,
                 '                               ',
                 "AFLE Add 31 spaces to message
                 sy-vline NO-GAP,
                 '          ',
                 sy-vline NO-GAP.
      CLEAR xmain.
      PERFORM hide.
    ENDLOOP.
    IF error_txt_on = 'X' AND NOT tfebep-pomsg-msgty IS INITIAL.
      WHILE tfebep-pomsg-msgtxt <> space.
        CLEAR text5.
        IF sy-index = 1.
          text5   = tfebep-pomsg-msgty.
          text5+1 = tfebep-pomsg-msgno.
        ENDIF.
        WRITE: /   sy-vline, sy-vline NO-GAP.
        FORMAT COLOR COL_NEGATIVE ON.
        WRITE:     text5,
                   sy-vline NO-GAP,
                   tfebep-pomsg-msgtxt(65).
        FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
        WRITE:     sy-vline NO-GAP,
                   '                               ',
                   "AFLE Add 31 spaces to message
                   sy-vline NO-GAP,
                   '          ',
                   sy-vline NO-GAP.
        SHIFT tfebep-pomsg-msgtxt BY 65 PLACES LEFT.
      ENDWHILE.
    ENDIF.
  ENDLOOP.

  IF xflag_det = 'X'.
* ------ Abschließende Strichzeile -------------------------------------
    WRITE: /   sy-vline NO-GAP,
               sy-uline(121),  "AFLE: Changed from 108
               122 sy-vline NO-GAP. "AFLE: Changed from 109
  ENDIF.

* ------ Statistik -----------------------------------------------------
  PERFORM statistik.
  CLEAR: hide.
ENDFORM.                    "LISTE_AUSGEBEN

*eject

*eject
************************************************************************
*        FORM MARKIERUNG_UEBERNEHMEN
************************************************************************
FORM markierung_uebernehmen.
  DO.
    CLEAR hide.
    READ LINE sy-index INDEX lsind FIELD VALUE xpick.
    IF sy-subrc = 0.
      CHECK hide-kukey NE space.
      CHECK hide-xmain EQ 'X'.
      LOOP AT tfebep WHERE febko-kukey = hide-kukey
                     AND   febep-esnum = hide-esnum.
        tfebep-xpick = xpick.
        MODIFY tfebep.
      ENDLOOP.
    ELSE.
      EXIT.
    ENDIF.
  ENDDO.
ENDFORM.                    "MARKIERUNG_UEBERNEHMEN

*eject
************************************************************************
*        FORM STATISTIK
************************************************************************
FORM statistik.
  lstyp = 'S'.
  IF count_febep = 0.
    CALL FUNCTION 'POPUP_NO_LIST'.
  ELSE.
    SKIP 5.
    CLEAR: count_memo, count_nok, count_stm, count_arch.
    LOOP AT tfebep.
      IF tfebep-febep-esnum = 0.
        count_stm = count_stm + 1.
        IF tfebep-febpi-xarch = 'X'.
          count_arch = count_arch + 1.
        ENDIF.
      ELSE.
        IF tfebep-febep-idenr IS INITIAL.
          count_nok = count_nok + 1.
        ELSE.
          count_memo = count_memo + 1.
        ENDIF.
      ENDIF.
    ENDLOOP.

*    Start Comment- C5053262 - Commented for ALV changes
*    FORMAT COLOR COL_TOTAL INTENSIFIED.
*    WRITE: /3 TEXT-005, COUNT_STM.
*    WRITE: /3 TEXT-006, COUNT_ARCH.
*    WRITE: /3 TEXT-001, COUNT_FEBEP.
*    WRITE: /3 TEXT-002, COUNT_MEMO.
*    WRITE: /3 TEXT-003, COUNT_NOK.
*    End Comment- C5053262 - Commented for ALV changes

*   Start Addition - C5053262
    FORMAT COLOR COL_HEADING INTENSIFIED OFF.
    WRITE: / sy-uline(42).
    WRITE: / sy-vline, TEXT-sta, 42 sy-vline.
    FORMAT COLOR COL_TOTAL INTENSIFIED.
    WRITE: / sy-vline,  3 TEXT-005, count_stm, 42 sy-vline.
    WRITE: / sy-vline, 3 TEXT-006, count_arch, 42 sy-vline.
    WRITE: / sy-vline, 3 TEXT-001, count_febep, 42 sy-vline.
    WRITE: / sy-vline, 3 TEXT-002, count_memo, 42 sy-vline.
    WRITE: / sy-vline, 3 TEXT-003, count_nok, 42 sy-vline.
    WRITE: / sy-uline(42).
*   End Addition - C5053262
  ENDIF.
ENDFORM.                    "STATISTIK

*eject
************************************************************************
*        FORM DETAIL_TOP
************************************************************************
FORM detail_top.
*  PERFORM batch-heading(rsbtchh0).
* SKIP 1.
  FORMAT COLOR COL_HEADING INTENSIFIED.
  CASE lstyp.
    WHEN 'D'.
      CLEAR: header1.
*     WRITE: /   SY-ULINE(109).
      header1 = TEXT-h02.
*      Start Comment- C5053262 - Commented for ALV changes
*        WRITE: /   SY-VLINE NO-GAP,
*                10 HEADER1(60),
*               109 SY-VLINE NO-GAP.
*      End Comment- C5053262 - Commented for ALV changes
      CLEAR: spueb1, spueb2, spueb3, spueb4, spueb5.
*     Start Comment- C5053262 - Commented for ALV changes
      spueb1 = TEXT-s06.
*     End Comment- C5053262 - Commented for ALV changes
*     Start Addition - C5053262
      spueb1 = TEXT-s16.
*     End Addition - C5053262
      spueb2 = TEXT-s07.
      spueb3 = TEXT-s08.
      spueb4 = TEXT-s14.
      TRANSLATE spueb1 USING '; '.
      TRANSLATE spueb2 USING '; '.
      TRANSLATE spueb3 USING '; '.
      TRANSLATE spueb4 USING '; '.
      TRANSLATE spueb5 USING '; '.
*     Start Comment- C5053262 - Commented for ALV changes
*     WRITE: /   SY-ULINE(109).
*     End Comment- C5053262 - Commented for ALV changes

*     Start Addition - C5053262
      FORMAT COLOR COL_HEADING INTENSIFIED.
*     End Addition - C5053262

*     Start Comment- C5053262 - Commented for ALV changes
*      WRITE: /   SY-VLINE NO-GAP,
*               3 SY-VLINE NO-GAP,
*               4 SPUEB1,
*              10 SY-VLINE NO-GAP,
*              11 SPUEB2,
*              77 SY-VLINE NO-GAP,
*              78 SPUEB3(17),
*              97 SY-VLINE NO-GAP,
*              98 SPUEB4(10),
*             109 SY-VLINE NO-GAP.
*      WRITE: /   SY-ULINE(108),
*             109 SY-VLINE NO-GAP.
*     End Comment- C5053262 - Commented for ALV changes

*     Start Addition - C5053262
      WRITE: / sy-vline NO-GAP,
              4 spueb1,
              11 spueb2,
              78(31) spueb3(17) RIGHT-JUSTIFIED, "AFLE(31)
              111 spueb4(10), "AFLE: Changed from 98
              122 sy-vline NO-GAP. "AFLE: Changed from 109
      FORMAT RESET.
*     End Addition - C5053262
    WHEN 'S'.
      WRITE: /3 TEXT-sta.
  ENDCASE.
ENDFORM.                    "DETAIL_TOP

*eject
************************************************************************
*        FORM TOP
************************************************************************
FORM top.

  DATA: l_bhdgd TYPE bhdgd.
*l_bhdgd-line1 =
*l_bhdgd-bukrs =
  l_bhdgd-repid = sy-repid.
  l_bhdgd-uname = sy-uname.
  l_bhdgd-mandt = sy-mandt.
  l_bhdgd-datum = sy-datum.
  l_bhdgd-zeit  = sy-uzeit.
  l_bhdgd-lines = sy-linsz.

  CALL FUNCTION 'FAGL_BATCH_HEADING_PERFORM'
    EXPORTING
      is_bhdgd = l_bhdgd.
*  PERFORM BATCH-HEADING(RSBTCHH0).
ENDFORM.                    "TOP

*---------------------------------------------------------------------*
*       FORM HEADER_STMT                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM header_stmt.
  SKIP 2.

  CASE lstyp.
    WHEN 'D'.
*      Start Comment- C5053262 - Commented for ALV changes
*      FORMAT COLOR COL_HEADING INTENSIFIED.
*      End Comment- C5053262 - Commented for ALV changes

*      Start Addition - C5053262
      FORMAT COLOR COL_NORMAL.
*      End Addition - C5053262
      CLEAR: header1.
      WRITE: /   sy-uline(122). "AFLE: Changed from 109
      header1 = TEXT-h01.
      WRITE: /   sy-vline NO-GAP,
              10 header1(60),
              122 sy-vline NO-GAP. "AFLE: Changed from 109
*     Start Addition - C5053262
      header1 = TEXT-h02.
      WRITE: /   sy-vline NO-GAP,
              10 header1(60),
             122 sy-vline NO-GAP. "AFLE: Changed from 109
*     End Addition - C5053262
      CLEAR: spueb1, spueb2, spueb3, spueb4, spueb5.
      spueb1 = TEXT-s01.
      spueb2 = TEXT-s11.
      spueb3 = TEXT-s02.
      spueb4 = TEXT-s12.
      spueb5 = TEXT-s03.
      spueb6 = TEXT-s10.
      spueb7 = TEXT-s05.
      spueb8 = TEXT-s08.
      spueb9 = TEXT-s14.
      spueb10 = TEXT-s15.
      TRANSLATE spueb1 USING '; '.
      TRANSLATE spueb2 USING '; '.
      TRANSLATE spueb3 USING '; '.
      TRANSLATE spueb4 USING '; '.
      TRANSLATE spueb5 USING '; '.
      TRANSLATE spueb6 USING '; '.
      TRANSLATE spueb7 USING '; '.
      TRANSLATE spueb8 USING '; '.
      TRANSLATE spueb9 USING '; '.
      TRANSLATE spueb10 USING '; '.
*     Start Addition - C5053262
      FORMAT COLOR COL_GROUP INTENSIFIED.
*     End Addition - C5053262
      WRITE: /   sy-uline(122). "AFLE: Changed from 109

*      Start Comment- C5053262 - Commented for ALV changes
*      WRITE: /   SY-VLINE NO-GAP,
*                 3 SY-VLINE NO-GAP,
*                 4 SPUEB1,
*                 9 SY-VLINE NO-GAP,
*                10 SPUEB2,
*                16 SY-VLINE NO-GAP,
*                17 SPUEB3,
*                28 SY-VLINE NO-GAP,
*                29 SPUEB4(12),
*                35 SY-VLINE NO-GAP,
*                36 SPUEB5(9),
*                53 SY-VLINE NO-GAP,
*                54 SPUEB6(5),
*                60 SY-VLINE NO-GAP,
*                61 SPUEB7(5),
*                70 SY-VLINE NO-GAP,
*                71 SPUEB8(15),
*                93 SY-VLINE NO-GAP,
*                94 SPUEB9(10),
*               105 SY-VLINE NO-GAP,
*               106 SPUEB10(1),
*               109 SY-VLINE NO-GAP.
*      WRITE: /   SY-ULINE(108),
*                109 SY-VLINE NO-GAP.
*      End Comment- C5053262 - Commented for ALV changes

*     Start Addition - C5053262
      WRITE: /   sy-vline NO-GAP,
                 4 spueb1,
                10 spueb2,
                17 spueb3,
                29 spueb4(12),
                36 spueb5(9),
                54 spueb6(5),
                61 spueb7(5),
                71(31) spueb8(20) RIGHT-JUSTIFIED, "AFLE(31)
               107 spueb9(10), "AFLE: Changed from 94
               119 spueb10(1), "AFLE: Changed from 106
               122 sy-vline NO-GAP. "AFLE: Changed from 109
      PERFORM detail_top.
      FORMAT COLOR COL_GROUP INTENSIFIED OFF.
*     End Addition - C5053262

*      Start Comment- C5053262 - Commented for ALV changes
*      FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
*      End Comment- C5053262 - Commented for ALV changes

*     Start Addition - C5053262
      WRITE: /   sy-uline(122). "AFLE: Changed from 109
*     End Addition - C5053262
      IF tfebep-febpi-xarch = space AND
         NOT tfebep-febpi-idenr IS INITIAL.
        xpick = tfebep-xpick.
        WRITE: /   sy-vline NO-GAP,
                   xpick AS CHECKBOX.
      ELSE.
        CLEAR xpick.
        WRITE: /   sy-vline NO-GAP,
                   xpick AS CHECKBOX INPUT OFF.
      ENDIF.

*      Start Comment- C5053262 - Commented for ALV changes
*      WRITE: 3 SY-VLINE NO-GAP,
*               TFEBEP-FEBKO-BUKRS,
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBKO-HBKID,
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBPI-BANKL(10),
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBPI-HKTID,
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBPI-BANKN(16),
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBKO-WAERS,
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBKO-EDATE DD/MM/YY,
*               SY-VLINE NO-GAP,
*               TFEBEP-FDES-AMOUNT,
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBPI-IDENR,
*               SY-VLINE NO-GAP,
*               TFEBEP-FEBPI-XARCH(1) NO-GAP,
*               '  ' NO-GAP,
*               SY-VLINE NO-GAP.
*    End Comment- C5053262 - Commented for ALV changes

*     Start Addition - C5053262
      WRITE:   4 tfebep-febko-bukrs,
               10 tfebep-febko-hbkid,
               17 tfebep-febpi-bankl(10),
               29 tfebep-febpi-hktid,
               36 tfebep-febpi-bankn(16),
               54 tfebep-febko-waers,
               61 tfebep-febko-edate DD/MM/YY,
               71(31) tfebep-fdes-amount CURRENCY febko-waers,
               "AFLE Enablement: add fixed length (31)
               105 tfebep-febpi-idenr, "AFLE: Changed from 92
               119 tfebep-febpi-xarch(1) NO-GAP, "AFLE: Changed from 106
               122 sy-vline NO-GAP. "AFLE: Changed from 109
*     End Addition - C5053262
      xmain = 'X'.
      PERFORM hide.
* ------ Abschließende Strichzeile -------------------------------------
*      Start Comment- C5053262 - Commented for ALV changes
*      WRITE: /   SY-VLINE NO-GAP,
*                 SY-ULINE(108),
*              109 SY-VLINE NO-GAP.
*      End Comment- C5053262 - Commented for ALV changes

*     Start Addition - C5053262
      FORMAT RESET.
*     End Addition - C5053262
    WHEN 'S'.
      FORMAT COLOR COL_HEADING INTENSIFIED.
      WRITE: /3 TEXT-sta.
  ENDCASE.
ENDFORM.                    "HEADER_STMT

*&---------------------------------------------------------------------*
*&      Form  GET_MSG_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TAVIK_POMSG  text
*----------------------------------------------------------------------*
FORM get_msg_text CHANGING p_pomsg LIKE balmt.

  CLEAR p_pomsg-msgtxt.
  SELECT SINGLE * FROM t100 WHERE sprsl = sy-langu AND
                                  arbgb = p_pomsg-msgid AND
                                  msgnr = p_pomsg-msgno.
  IF sy-subrc = 0.
    p_pomsg-msgtxt = t100-text.
    REPLACE '&' WITH p_pomsg-msgv1 INTO p_pomsg-msgtxt.
    CONDENSE p_pomsg-msgtxt.
    REPLACE '&' WITH p_pomsg-msgv2 INTO p_pomsg-msgtxt.
    CONDENSE p_pomsg-msgtxt.
    REPLACE '&' WITH p_pomsg-msgv3 INTO p_pomsg-msgtxt.
    CONDENSE p_pomsg-msgtxt.
    REPLACE '&' WITH p_pomsg-msgv4 INTO p_pomsg-msgtxt.
    CONDENSE p_pomsg-msgtxt.
  ENDIF.

ENDFORM.                               " GET_MSG_TEXT

*----------------------------------------------------------------------*

FORM avise_buchen.
  DATA: charx(1) TYPE c VALUE 'X'.
  DATA: xsgtxt  LIKE fdes-sgtxt.
  DATA: xdsart  LIKE fdes-dsart.
  DATA: xebene  LIKE fdes-ebene.
  DATA: xrefer  LIKE fdes-refer.
  DATA: new_idenr LIKE fdes-idenr.
  DATA: lines   TYPE p.
  DATA: rcode   LIKE inri-returncode.
  DATA: det_exist(1) TYPE c.

* Internal table for Fdes
  DATA: BEGIN OF xfdes  OCCURS 10.
          INCLUDE STRUCTURE fdes.
  DATA: END OF xfdes.

* Internal table: FDES entries that need to be created
  DATA: BEGIN OF tab_fdes_new OCCURS 10.
          INCLUDE STRUCTURE fdes.
  DATA: END OF tab_fdes_new.

* Internal table: FDES entries that need to be updated
  DATA: BEGIN OF tab_fdes_upd OCCURS 10.
          INCLUDE STRUCTURE fdes.
  DATA: END OF tab_fdes_upd.

*----------------------------------------------------------------------*
  REFRESH: tab_fdes_new, tab_fdes_upd.

  CLEAR det_exist.
  LOOP AT tfebep.
*-- only selected lines --
    CHECK tfebep-xpick NE space.

    IF tfebep-febep-esnum = 0.
*-- ESNUM = 0 => archive balance memo record --
*******
* determine if corresponding FDES entry exists
*******
      SELECT * FROM fdes INTO TABLE xfdes
               WHERE archk = space
                 AND bukrs = tfebep-febpi-bukrs
                 AND bnkko = tfebep-febpi-bnkko
                 AND grupp = space
                 AND ebene = tfebep-febpi-ebene
                 AND dispw = tfebep-febko-waers
                 AND datum = tfebep-febko-azdat  "value date
                 AND idenr = tfebep-febpi-idenr
                 AND merkm = c_merkm_balance.
      IF sy-subrc EQ 0.                "record found
        DESCRIBE TABLE xfdes LINES lines.
        IF lines GT 1.                 "have found more than one
          CLEAR tfebep-pomsg.
          tfebep-pomsg-msgid = 'FTCM'.
          tfebep-pomsg-msgty = 'E'.
          tfebep-pomsg-msgno = '001'.
          tfebep-pomsg-msgv1 = tfebep-febpi-bukrs.
          tfebep-pomsg-msgv2 = tfebep-febpi-bnkko.
          tfebep-pomsg-msgv3 = tfebep-febpi-ebene.
          tfebep-pomsg-msgv4 = tfebep-febko-waers.
          tfebep-bustat      = 'E'.
          PERFORM get_msg_text USING tfebep-pomsg.
          MODIFY tfebep.
        ELSE.
          LOOP AT xfdes.
            CLEAR tab_fdes_upd.
            REFRESH tab_fdes_upd.
            MOVE-CORRESPONDING xfdes TO tab_fdes_upd.
            APPEND tab_fdes_upd.
            tab_fdes_upd-aenus = sy-uname.
            tab_fdes_upd-aendt = sy-datum.
            tab_fdes_upd-avdat = sy-datum.
            tab_fdes_upd-archk = tfebep-febpi-archk.
            APPEND tab_fdes_upd.
          ENDLOOP.

          CALL FUNCTION 'CASH_FORECAST_MEMO_RECORD_UPD'
            EXPORTING
              aktion   = '2'     "change
            TABLES
              tab_fdes = tab_fdes_upd
            EXCEPTIONS
              OTHERS   = 1.
          IF sy-subrc = 0.
            CLEAR tfebep-pomsg.
*            TFEBEP-POMSG-MSGID = 'FB'.
*            TFEBEP-POMSG-MSGTY = 'S'.
*            TFEBEP-POMSG-MSGNO = '999'.
*            TFEBEP-POMSG-MSGV1 = TFEBEP-FEBPI-IDENR.
*            TFEBEP-POMSG-MSGV2 = TFEBEP-FEBPI-BUKRS.
*            TFEBEP-POMSG-MSGV3 = TFEBEP-FEBPI-BNKKO.
*            TFEBEP-POMSG-MSGV4 = TFEBEP-FEBPI-EBENE.
            tfebep-bustat      = 'O'.
*            PERFORM GET_MSG_TEXT USING TFEBEP-POMSG.
            tfebep-febpi-xarch = 'X'.
            MODIFY tfebep.
          ELSE.
            CLEAR tfebep-pomsg.
            tfebep-pomsg-msgid = sy-msgid.
            tfebep-pomsg-msgty = sy-msgty.
            tfebep-pomsg-msgno = sy-msgno.
            tfebep-pomsg-msgv1 = sy-msgv1.
            tfebep-pomsg-msgv2 = sy-msgv2.
            tfebep-pomsg-msgv3 = sy-msgv3.
            tfebep-pomsg-msgv4 = sy-msgv4.
            tfebep-bustat      = 'E'.
            PERFORM get_msg_text USING tfebep-pomsg.
            MODIFY tfebep.
          ENDIF.
        ENDIF.
      ELSE.
        CLEAR tfebep-pomsg.
        tfebep-pomsg-msgid = 'FB'.
        tfebep-pomsg-msgty = 'S'.
        tfebep-pomsg-msgno = '999'.
        tfebep-pomsg-msgv1 = tfebep-febpi-idenr.
        tfebep-pomsg-msgv2 = tfebep-febpi-bukrs.
        tfebep-pomsg-msgv3 = tfebep-febpi-bnkko.
        tfebep-pomsg-msgv4 = tfebep-febpi-ebene.
        tfebep-bustat      = 'E'.
        PERFORM get_msg_text USING tfebep-pomsg.
        MODIFY tfebep.
      ENDIF.
    ELSE.
      IF tfebep-febep-ebene IS INITIAL.
        CLEAR tfebep-pomsg.
        tfebep-pomsg-msgid = 'FTCM'.
        tfebep-pomsg-msgty = 'E'.
        tfebep-pomsg-msgno = '002'.
        tfebep-bustat      = 'E'.
        PERFORM get_msg_text USING tfebep-pomsg.
        MODIFY tfebep.
      ELSE.
*-- create memo records ---
        xsgtxt = TEXT-004.
*     determine ident number IDENR
        CALL FUNCTION 'NUMBER_GET_NEXT'
          EXPORTING
            nr_range_nr        = '01'
            object             = 'FCLM_MRN'
          IMPORTING
            number             = new_idenr
            returncode         = rcode
          EXCEPTIONS
            interval_not_found = 1
            OTHERS             = 1.
        IF sy-subrc = 1.
          CLEAR tfebep-pomsg.
          tfebep-pomsg-msgid = sy-msgid.
          tfebep-pomsg-msgty = sy-msgty.
          tfebep-pomsg-msgno = sy-msgno.
          tfebep-pomsg-msgv1 = sy-msgv1.
          tfebep-pomsg-msgv2 = sy-msgv2.
          tfebep-pomsg-msgv3 = sy-msgv3.
          tfebep-pomsg-msgv3 = sy-msgv4.
          tfebep-bustat      = 'E'.
          PERFORM get_msg_text USING tfebep-pomsg.
          MODIFY tfebep.
        ELSE.
          CLEAR tab_fdes_new.
          tab_fdes_new-bukrs = tfebep-febko-bukrs.
          tab_fdes_new-bnkko = tfebep-febpi-bnkko.
          tab_fdes_new-ebene = tfebep-febep-ebene.
          tab_fdes_new-sgtxt = xsgtxt.
          tab_fdes_new-dispw = tfebep-febko-waers.
          tab_fdes_new-datum = tfebep-febep-valut.
          tab_fdes_new-dsart = tfebep-febpi-dsart.
          tab_fdes_new-usrid = sy-uname.
          tab_fdes_new-hzdat = sy-datum.
          tab_fdes_new-avdat = sy-datum.
          tab_fdes_new-idenr = new_idenr.
          tab_fdes_new-stknz = 'J'.                         "n 2595533
          tab_fdes_new-merkm = c_merkm_detail.
*          TAB_FDES_NEW-DMSHB = TFEBEP-FEBEP-KWBTR.
*          TAB_FDES_NEW-WRSHB = TAB_FDES_NEW-DMSHB.
*          TAB_FDES_NEW-WRSHB = TAB_FDES_NEW-DMSHB.
          tab_fdes_new-wrshb = tfebep-febep-kwbtr.
          DATA: t_waers LIKE t001-waers.
          SELECT waers FROM t001 INTO t_waers
                WHERE bukrs = tfebep-febko-bukrs.
          ENDSELECT.
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
              client           = sy-mandt
              date             = tab_fdes_new-datum
              foreign_amount   = tab_fdes_new-wrshb
              foreign_currency = tab_fdes_new-dispw
              local_currency   = t_waers
*             RATE             = 0
*             TYPE_OF_RATE     = 'M'
*             READ_TCURR       = 'X'
            IMPORTING
*             EXCHANGE_RATE    =
*             FOREIGN_FACTOR   =
              local_amount     = tab_fdes_new-dmshb
*             LOCAL_FACTOR     =
*             EXCHANGE_RATEX   =
*             FIXED_RATE       =
*             DERIVED_RATE_TYPE       =
            EXCEPTIONS
              no_rate_found    = 1
              overflow         = 2
              no_factors_found = 3
              no_spread_found  = 4
              derived_2_times  = 5
              OTHERS           = 6.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
          ENDIF.

          tab_fdes_new-austg = tfebep-febko-azdat.
          tab_fdes_new-ausnr = tfebep-febko-aznum.
          tab_fdes_new-refer = tfebep-febko-kukey.
          tab_fdes_new-bs_esnum = tfebep-febep-esnum.  "Note 2919901
          tab_fdes_new-hbkid = tfebep-febko-hbkid.  "notes 2507659
          tab_fdes_new-hktid = tfebep-febko-hktid.  "notes 2507659
          APPEND tab_fdes_new.
          det_exist = 'X'.
          tfebep-febep-idenr = new_idenr.
          MODIFY tfebep.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

*-- add new memo rec --
  IF det_exist = 'X'.
    CALL FUNCTION 'CASH_FORECAST_MEMO_RECORD_UPD'
      EXPORTING
        aktion        = '1'                                "add
        i_nr_external = 'X'
      TABLES
        tab_fdes      = tab_fdes_new
      EXCEPTIONS
        OTHERS        = 1.
    IF sy-subrc = 0.
      LOOP AT tfebep WHERE febep-esnum > 0.
        UPDATE febep SET idenr = tfebep-febep-idenr
               WHERE kukey = tfebep-febep-kukey
                 AND esnum = tfebep-febep-esnum.
      ENDLOOP.
*-- message
      DESCRIBE TABLE tab_fdes_new LINES lines.
      MESSAGE s630 WITH lines.
    ELSE.
      LOOP AT tfebep WHERE febep-esnum > 0.
        xrefer   = tfebep-febep-kukey.
        "xrefer+8 = tfebep-febep-esnum.
        LOOP AT tab_fdes_new WHERE refer = xrefer AND bs_esnum = tfebep-febep-esnum.
          CLEAR tfebep-pomsg.
          tfebep-pomsg-msgid = sy-msgid.
          tfebep-pomsg-msgty = sy-msgty.
          tfebep-pomsg-msgno = sy-msgno.
          tfebep-pomsg-msgv1 = sy-msgv1.
          tfebep-pomsg-msgv2 = sy-msgv2.
          tfebep-pomsg-msgv3 = sy-msgv3.
          tfebep-pomsg-msgv4 = sy-msgv4.
          tfebep-bustat      = 'E'.
          PERFORM get_msg_text USING tfebep-pomsg.
          CLEAR tfebep-febpi-idenr.
          MODIFY tfebep.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDIF.
  COMMIT WORK.
ENDFORM.                    "AVISE_BUCHEN
