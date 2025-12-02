*&---------------------------------------------------------------------*
*& Include          Z_ETL_CBR_RULE_TOP
*&---------------------------------------------------------------------*


DATA : gs_etl_cbr_rule1 TYPE zetl_cbr_rule1,
       gs_etl_cbr_rule2 TYPE zetl_cbr_rule2.

DATA : disp_rule1 TYPE c,
       disp_rule2 TYPE c,
       error_flag TYPE c.

DATA : lt_rule1 TYPE TABLE OF zetl_cbr_rule1.
DATA : lt_rule2 TYPE TABLE OF zetl_cbr_rule2.
