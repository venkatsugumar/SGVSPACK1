*&---------------------------------------------------------------------*
*& Include          ZRAR_PC_CHANGE_UPLOAD_TOP
*&---------------------------------------------------------------------*
TABLES: sscrfields.

TYPES : BEGIN OF ty_tab,
          srcdoc_id     TYPE farr_rai_srcid,
          prctr(10)     TYPE c,
          old_prctr(10) TYPE c,
          pob_id        TYPE farr_pob_id,
          msg(60)       TYPE c,
          type          TYPE c,
        END OF ty_tab,

          BEGIN OF ty_tab_new,  "Defect - 3059
          srcdoc_id     TYPE farr_rai_srcid,
          pob_id        TYPE farr_pob_id,
          msg(60)       TYPE c,
          type          TYPE c,
        END OF ty_tab_new.

DATA : it_mi_tab         TYPE /1ra/1sd010mi_api_tab,
       it_co_tab         TYPE /1ra/1sd010co_api_tab,
       it_msg            TYPE farr_tt_msg,
       it_mi_eq_pc       TYPE /1ra/1sd010mi_api_tab,
       it_sd012mi        TYPE TABLE OF /1ra/0sd012mi,
       it_src_id         TYPE TABLE OF ty_tab,
       wa_src_id         TYPE  ty_tab,
       it_src_id_new     TYPE TABLE OF ty_tab_new, "Defect - 3059
       wa_src_id_new     TYPE ty_tab_new, "Defect - 3059
       gv_farr_rai_srcid TYPE farr_rai_srcid,
       gv_prctr          TYPE prctr,
       gs_return         TYPE bapiret2,
       gv_dir_name       TYPE epsf-epsdirnam,
       gv_sel_button     TYPE smp_dyntxt,
       gv_file_name      TYPE c LENGTH 60,
       it_pc_tab         TYPE TABLE OF zst_pc_chg,
       it_rai_mi_disp TYPE farr_tt_rai_mi_disp,
       gt_mvke TYPE TABLE OF mvke.  "Inserted by F4SAWAM Defect 3059


CONSTANTS: gc_tab  TYPE c VALUE cl_bcs_convert=>gc_tab,
           gc_crlf TYPE c VALUE cl_bcs_convert=>gc_crlf,
           gc_s    TYPE c VALUE 'S',
           gc_e    TYPE c VALUE 'E',
           gc_x    TYPE c VALUE 'X'.


*
