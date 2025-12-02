FUNCTION GET_SOURCEID.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(EX_FLAG)
*"----------------------------------------------------------------------

IF gv_flag IS NOT INITIAL.
  ex_flag = abap_true.
ENDIF.



ENDFUNCTION.
