class ZCL_RAR_FARRIC_BADI_DELIVERY definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_FARRIC_DELIVERY .
protected section.
private section.
ENDCLASS.



CLASS ZCL_RAR_FARRIC_BADI_DELIVERY IMPLEMENTATION.


  method IF_FARRIC_DELIVERY~DELIVERY_DATA_TO_ARL.
  endmethod.


  METHOD if_farric_delivery~delivery_data_to_arl_custom.

    DATA: lv_srcdoc_id TYPE /1ra/0sd014mi-srcdoc_id,
          lv_header_id TYPE /1ra/0sd014mi-header_id,
          lv_item_id   TYPE /1ra/0sd014mi-item_id.

    DATA: it_et_table TYPE STANDARD TABLE OF farric_s_sd02mi,
          WA_et_MOD   LIKE LINE OF et_sd02mi.

    FIELD-SYMBOLS: <fs_sd02mi> LIKE LINE OF it_sd02mi.

    CONSTANTS: c_000000000  TYPE c LENGTH 9  VALUE '000000000',
               c_0000000000 TYPE c LENGTH 10 VALUE '0000000000'.

*Loop RAI class SD03 Main Item table to update the Source Id
    LOOP AT it_sd02mi
      ASSIGNING <fs_sd02mi>.

      CLEAR: WA_et_MOD, lv_srcdoc_id, lv_header_id, lv_item_id.

      MOVE <fs_sd02mi> TO WA_et_MOD.

      CONCATENATE c_0000000000 <fs_sd02mi>-origdoc_id(10) INTO lv_header_id.
      CONCATENATE c_000000000  <fs_sd02mi>-origdoc_id+10(6) INTO lv_item_id.

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
    et_sd02mi[] = it_et_table[].
**Condition table.
    et_sd02co[] = it_sd02co[].

  ENDMETHOD.


  method IF_FARRIC_DELIVERY~EXCLUDE_CONDITIONS.
  endmethod.
ENDCLASS.
