*&---------------------------------------------------------------------*
*& Report ZRAR_REFXMIG
*&---------------------------------------------------------------------*
*&
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


REPORT zrar_refxmig.

* Include Programs
INCLUDE zrar_refxmig_top."Data Declaration
INCLUDE zrar_refxmig_s01."Selection Screen
INCLUDE zrar_refxmig_f01. "Subroutines

* Initialization Event
INITIALIZATION.
  DATA: oref TYPE REF TO lcl_zrarrefxmig.
  CREATE OBJECT oref.
***********************************************************************************************

* At Selection Screen on Value Request
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pcdir.
  PERFORM get_directory USING p_pcdir.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  p_file = oref->select_file( i_file = CONV string( p_file )
                                        i_type = oref->lc_excel ).
***********************************************************************************************

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modification. "subroutine for modifying the selection screen

***********************************************************************************************

START-OF-SELECTION.
* Read data from File
  oref->read_file(
    EXPORTING
      i_file   = CONV string( p_file )
    CHANGING
      ct_tab = i_input ).

  IF i_input IS NOT INITIAL.
    PERFORM transfer_data.
  ELSE.
    MESSAGE TEXT-t06 TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

***********************************************************************************************
