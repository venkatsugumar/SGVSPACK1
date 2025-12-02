*&---------------------------------------------------------------------*
*& Include          ZRAR_REFXMIG_S01
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
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN SKIP.
  PARAMETERS: p_file LIKE rlgrap-filename DEFAULT 'C:/ ' MODIF ID g1 OBLIGATORY.
  SELECTION-SCREEN SKIP.
  PARAMETERS: p_pcdir LIKE rlgrap-filename.
  SELECTION-SCREEN SKIP.
  PARAMETERS : p_testrn AS CHECKBOX USER-COMMAND uc DEFAULT 'X' .   " TestRun
SELECTION-SCREEN END OF BLOCK b1.
