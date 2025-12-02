"Name: \TY:CL_FARR_AC_DOCUMENT\ME:POST\SE:BEGIN\EI
ENHANCEMENT 0 Z_FARR_CUSTOMER_UPDATE.

  CHECK NOT mt_accit[] IS INITIAL.

    "Ranges for STVARV
    DATA: R_AWTYP TYPE STANDARD TABLE OF SELOPT.
    DATA: lv_xblnr TYPE xblnr1.
    DATA: ls_mt_accit LIKE LINE OF mt_accit.

    CALL FUNCTION 'ZEXTRACT_TVARVC'
      EXPORTING
        i_name         = 'Z_FARR_AWTYP'
      tables
        t_selopt       = R_AWTYP
              .

      LOOP AT r_awtyp ASSIGNING FIELD-SYMBOL(<fs_awtyp>).

          READ TABLE mt_accit INTO ls_mt_accit INDEX 1.
          IF sy-subrc EQ 0 AND ls_mt_accit-awtyp EQ <fs_awtyp>-low.
            " if awtyp type is FARA move the accit to memory id MID1
            EXPORT ls_mt_accit FROM ls_mt_accit TO MEMORY ID 'MID1'.
            CLEAR: ls_mt_accit.
          ENDIF.

      ENDLOOP.

ENDENHANCEMENT.
