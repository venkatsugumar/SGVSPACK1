***********************************************************************
*& Program           : ZFARR_UPDATE_CLCA_FLAG                         *
*& Module            : RAR                                            *
*& Functional Contact: Nageshwara Raju                                *
*&                                                                    *
*& Developer(Company): RAJU MANDAVALE(FISERV)                         *
*& Create Date       : 08/24/2022                                     *
*& Program Type      : REPORT                                         *
*& Project Phase     : Wave 1                                         *
*& Description       : Defect 20028 FARR_D_RECON_KEY table is not     *
*&                     updating CA-CL flag with X                     *
*&                     Implementation of SAP Note 3235001             *
*& Transports        : DS4K909942                                     *
***********************************************************************
*&---------------------------------------------------------------------*
*& Report zfarr_update_clca_flag
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zfarr_update_clca_flag.

* This report is to update the CL/CA flag if the period is already in closing

* step 1: select the reconkey that are closed
DATA ls_contract  TYPE farr_d_contract.

SELECTION-SCREEN COMMENT /1(83) comm1.
SELECTION-SCREEN COMMENT /1(83) comm2.
SELECTION-SCREEN COMMENT /1(83) comm3.


PARAMETERS: p_acct   TYPE accounting_principle OBLIGATORY,
            p_year   TYPE gjahr OBLIGATORY,
            p_period TYPE poper OBLIGATORY,
            p_bukrs  TYPE bukrs.

SELECT-OPTIONS: s_contr FOR ls_contract-contract_id.

AT SELECTION-SCREEN OUTPUT.
  comm1 = 'Set CL/CA flag per accounting principle up to certain year/period.'.
  comm2 = 'All reconkey must be closed before that year/period.'.
  comm3 = 'You must specify the accounting principle, fiscal year/period.'.


* step 2: select the reconkey
AT SELECTION-SCREEN.
  SELECT * INTO TABLE @DATA(lt_recon_key) FROM farr_d_recon_key
    WHERE company_code = @p_bukrs
    AND acct_principle = @p_acct
    AND gjahr <= @p_year
    AND poper <= @p_period
    AND contract_id IN @s_contr
    ORDER BY recon_key ASCENDING.

* step 3: validate all reconkey must be closed
  LOOP AT lt_recon_key ASSIGNING FIELD-SYMBOL(<fs_recon_key>) WHERE status <> 'C'.
    WRITE: 'Reconkey of company code',  <fs_recon_key>-company_code, ' in period ',  <fs_recon_key>-gjahr, ' / ', <fs_recon_key>-poper, 'is not yet closed!!!'.
    EXIT.
  ENDLOOP.

* step 4: update the reconkey to set the CL/CA flag to X
  LOOP AT lt_recon_key ASSIGNING <fs_recon_key>.
    <fs_recon_key>-liab_asset_flag = abap_true.
  ENDLOOP.

  UPDATE farr_d_recon_key FROM TABLE lt_recon_key.
  COMMIT WORK.
  IF sy-subrc = 0.
    WRITE: 'Reconkey is updated correclty with the CL/CA flag.'.
  ENDIF.
