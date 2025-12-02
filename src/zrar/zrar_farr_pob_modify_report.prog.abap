*&---------------------------------------------------------------------*
*& Report ZRAR_FARR_POB_MODIFY_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*********************************************************************
*& Program           : ZRAR_FARR_POB_MODIFY_REPORT                  *
*& Module            : RAR                                          *
*& Sub-Module        :                                              *
*& Functional Contact: Rathnakar                                    *
*& Funct. Spec. Ref. :                                              *
*& Developer(Company): Babu/Shaliya (Fiserv)                        *
*& Create Date       : 05/27/2022                                   *
*& Program Type      : REPORT - Basic ABAP/4 Report                 *
*& Project Phase     : Fiserv Project Transformation – Wave 1       *
*& Description       : Utility program to clear the value on filed  *
*&                     DISTINCT_FULFILL                             *
*********************************************************************
report zrar_farr_pob_modify_report.
"%data declaration
tables : farr_d_pob.
data:ist_pob_data type standard table of farr_d_pob.
"%Selection screen
selection-screen begin of block pob with frame title text-001.
  select-options: s_pob_id for farr_d_pob-pob_id. "Performance Obligation ID
selection-screen end of block pob.
"%start of selection

start-of-selection.
  "%select values from FARR_D_POB based on POB ID
  if s_pob_id[] is not initial.
    "%Refresh internal table
    refresh ist_pob_data.
    select * from farr_d_pob
             into  table ist_pob_data
             where pob_id in s_pob_id.
    if sy-subrc eq 0.
      sort ist_pob_data by pob_id.
      loop at ist_pob_data into data(wa_pob_tab).
        if wa_pob_tab-distinct_fulfill is not initial.
          wa_pob_tab-distinct_fulfill = space.
          modify farr_d_pob from wa_pob_tab.     "Updating table
          commit work and wait.
          if sy-subrc eq 0.
            data(lv_success) =  |{ text-002 }| & | | & |{ wa_pob_tab-POB_ID }|.  "success
            write : /5 lv_success color 5.
          else.
            data(lv_error)  =  |{ text-003 }| & | | & |{ wa_pob_tab-POB_ID }|.  "error
            write: /5 lv_error color 6.
          endif.
        endif.
        clear wa_pob_tab.
        clear : lv_success , lv_error.
      endloop.
    endif.
  else.
    message 'Please enter POB ID' type 'I'.
    exit.
  endif.
