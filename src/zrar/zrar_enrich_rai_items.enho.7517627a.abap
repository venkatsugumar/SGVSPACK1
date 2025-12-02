"Name: \TY:CL_FARRIC_SD_ORDER\IN:IF_FARRIC_SD_ORDER\ME:CALL_BADI_ENRICHMENTS\SE:BEGIN\EI
ENHANCEMENT 0 ZRAR_ENRICH_RAI_ITEMS.

DATA: LV_RAI_TEMP TYPE REF TO ZCL_RAR_FARRIC_BADI_ORDER.

CREATE OBJECT LV_RAI_TEMP.

*Call Method to update corresponding SourceID from CT_MAIN_IT and CT_RAI_COND tables, to be able to pass the SourceID into the complete flow.
CALL METHOD lv_rai_temp->zchange_rai_items
  EXPORTING
    is_vbak     = is_vbak
    it_vbap     = me->mt_vbap[]
    it_vbkd     = me->mt_vbkd[]
  CHANGING
    ct_main_it  = ct_main_it
    ct_rai_cond = ct_rai_cond .

ENDENHANCEMENT.
