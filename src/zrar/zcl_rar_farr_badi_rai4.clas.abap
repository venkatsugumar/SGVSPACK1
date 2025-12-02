class ZCL_RAR_FARR_BADI_RAI4 definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FARR_BADI_RAI4 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_RAR_FARR_BADI_RAI4 IMPLEMENTATION.


  method IF_FARR_BADI_RAI4~EXCLUDE_COMPANY_CODES.
    BREAK sakota.
  endmethod.


  method IF_FARR_BADI_RAI4~EXCLUDE_RAIS_AT_PROC_START.
    break sakota.
  endmethod.


  method IF_FARR_BADI_RAI4~MODIFY_PREDOC_DATA.
    break sakota.
  endmethod.
ENDCLASS.
