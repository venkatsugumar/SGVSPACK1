FUNCTION SET_SOURCEID.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_FLAG_SET)
*"----------------------------------------------------------------------


IF IM_FLAG_SET is NOT INITIAL.
  gv_flag = abap_true.
ENDIF.




ENDFUNCTION.
