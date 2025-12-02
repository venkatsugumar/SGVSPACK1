*&---------------------------------------------------------------------*
*& Report ZFARR_MISSING_RECON_KEY
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZFARR_MISSING_RECON_KEY.
DATA ls_recon_key TYPE farr_d_recon_key.

SELECT SINGLE *
  FROM farr_d_recon_key
  INTO ls_recon_key
  WHERE contract_id = '00000000001464'
    AND recon_key = '20220120000103'.

ls_recon_key-recon_key+13(1) = '4'.
ls_recon_key-created_on = ls_recon_key-created_on + 1.
CLEAR:
  ls_recon_key-pro_split_date,
  ls_recon_key-runid,
  ls_recon_key-run_date.

INSERT farr_d_recon_key FROM ls_recon_key.
IF sy-subrc = 0.
  WRITE 'Reconkey 20220120000104 added successfully.'.
ELSE.
  WRITE 'Could not perform DB update!'.
ENDIF.
