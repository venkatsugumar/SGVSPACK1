class ZCL_RAR_FARRIC_BADI_INVOICE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FARRIC_DELIVERY .
  interfaces IF_FARRIC_INVOICE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_RAR_FARRIC_BADI_INVOICE IMPLEMENTATION.


  method IF_FARRIC_INVOICE~CLEAR_RELTYPE_FLAG.
  endmethod.


  method IF_FARRIC_INVOICE~CONVERT_INVOICE_CURRENCY.
  endmethod.


  method IF_FARRIC_INVOICE~EXCLUDE_CONDITIONS_SD01.
  endmethod.


  method IF_FARRIC_INVOICE~EXCLUDE_CONDTIONS.
  endmethod.


  method IF_FARRIC_INVOICE~EXCLUDE_IC_CONDITIONS_SD02.
  endmethod.


  METHOD if_farric_invoice~invoice_data_to_arl_custom.

    DATA: lv_srcdoc_id TYPE /1ra/0sd014mi-srcdoc_id,
          lv_header_id TYPE /1ra/0sd014mi-header_id,
          lv_item_id   TYPE /1ra/0sd014mi-item_id.

    DATA: it_et_table TYPE STANDARD TABLE OF farric_s_sd03mi,
          WA_et_MOD   LIKE LINE OF et_sd03mi.

    FIELD-SYMBOLS: <fs_sd03mi> LIKE LINE OF it_sd03mi.

    CONSTANTS: c_000000000  TYPE c LENGTH 9  VALUE '000000000',
               c_0000000000 TYPE c LENGTH 10 VALUE '0000000000'.

*Loop RAI class SD03 Main Item table to update the Source Id
    LOOP AT it_sd03mi
      ASSIGNING <fs_sd03mi>.

      CLEAR: WA_et_MOD, lv_srcdoc_id, lv_header_id, lv_item_id.

      MOVE <fs_sd03mi> TO WA_et_MOD.

      CONCATENATE c_0000000000 <fs_sd03mi>-origdoc_id(10) INTO lv_header_id.
      CONCATENATE c_000000000  <fs_sd03mi>-origdoc_id+10(6) INTO lv_item_id.

*Get Source ID from Items for Class SD01 - Processed
      SELECT SINGLE SRCDoc_ID
        INTO lv_srcdoc_id
        FROM /1ra/0sd014mi
       WHERE header_id EQ lv_header_id
         AND item_id   EQ lv_item_id.

      IF sy-subrc EQ 0 AND lv_srcdoc_id IS NOT INITIAL.

        MOVE lv_srcdoc_id TO WA_et_MOD-origdoc_id.

      ELSE.
*Get Source ID from Items for Class SD01 - Processable
        SELECT SINGLE SRCDoc_ID
          INTO lv_srcdoc_id
          FROM /1ra/0sd012mi
         WHERE header_id EQ lv_header_id
           AND item_id   EQ lv_item_id.

        IF sy-subrc EQ 0 AND lv_srcdoc_id IS NOT INITIAL..

          MOVE lv_srcdoc_id TO WA_et_MOD-origdoc_id.

        ELSE.
*Get Source ID From Items for Class SD01 - Raw Exempted
          SELECT SINGLE SRCDoc_ID
            INTO lv_srcdoc_id
            FROM /1ra/0sd011mi
           WHERE header_id EQ lv_header_id
             AND item_id   EQ lv_item_id.

          IF sy-subrc EQ 0 AND lv_srcdoc_id IS NOT INITIAL..

            MOVE lv_srcdoc_id TO WA_et_MOD-origdoc_id.

          ENDIF.

        ENDIF.

      ENDIF.

      APPEND WA_et_MOD TO it_et_table.

    ENDLOOP.

*Moving Importing to Exporting data.

**Item Table
    et_sd03mi[] = it_et_table[].
**Condition table.
    et_sd03co[] = it_sd03co[].

  ENDMETHOD.


  method IF_FARRIC_INVOICE~INVOICE_DATA_TO_ARL_SD01.

  endmethod.


  method IF_FARRIC_INVOICE~INVOICE_DATA_TO_ARL_SD01_CUST.
  endmethod.


  method IF_FARRIC_INVOICE~SET_EXTERNAL_INVOICE_CURRENCY.
  endmethod.
ENDCLASS.
