*&---------------------------------------------------------------------*
*& Include          ZRAR_REFXMIG_TOP
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
TYPE-POOLS: truxs,slis.
DATA:gv_string TYPE string.

DATA:i_input  TYPE ztrar_refxmig,
     wa_input LIKE LINE OF i_input.

CONSTANTS: gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
           gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf.
