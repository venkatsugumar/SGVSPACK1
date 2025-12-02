*
**----------------------------------------------------------------------*
**       CLASS lcl_Farr_Il_Contract DEFINITION
**----------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*CLASS lcl_farr_il_contract DEFINITION FOR TESTING
*  DURATION SHORT
*  RISK LEVEL HARMLESS
*.
**?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
**?<asx:values>
**?<TESTCLASS_OPTIONS>
**?<TEST_CLASS>lcl_Farr_Il_Contract
**?</TEST_CLASS>
**?<TEST_MEMBER>f_Cut
**?</TEST_MEMBER>
**?<OBJECT_UNDER_TEST>CL_FARR_IL_CONTRACT
**?</OBJECT_UNDER_TEST>
**?<OBJECT_IS_LOCAL/>
**?<GENERATE_FIXTURE/>
**?<GENERATE_CLASS_FIXTURE/>
**?<GENERATE_INVOCATION/>
**?<GENERATE_ASSERT_EQUAL/>
**?</TESTCLASS_OPTIONS>
**?</asx:values>
**?</asx:abap>
*  PRIVATE SECTION.
** ================
*    DATA:
*      f_cut TYPE REF TO cl_farr_il_contract.  "class under test
*
*    METHODS: setup.
*    METHODS: calculate_pob_qty FOR TESTING.
*ENDCLASS.       "lcl_Farr_Il_Contract
*
*
**----------------------------------------------------------------------*
**       CLASS lcl_Farr_Il_Contract IMPLEMENTATION
**----------------------------------------------------------------------*
**
**----------------------------------------------------------------------*
*CLASS lcl_farr_il_contract IMPLEMENTATION.
** ==========================================
*
*  METHOD setup.
*
*
*    CREATE OBJECT f_cut
*      EXPORTING
*        iv_mode           =  abap_false   " Single-Character Indicator
**        iv_component_name =     " Component Name
*      .
*
*    DELETE FROM farr_d_pob
*    WHERE pob_id BETWEEN '0000999999991000' AND '0000999999991010'.
*
*    DELETE FROM farr_d_deferral
*    WHERE pob_id BETWEEN '0000999999991000' AND '0000999999991010'.
*
*    DELETE FROM farr_d_defitem
*    WHERE pob_id BETWEEN '0000999999991000' AND '0000999999991010'.
*
*    DELETE FROM farr_d_fulfillmt
*    WHERE pob_id BETWEEN '0000999999991000' AND '0000999999991010'.
*
*    DELETE FROM farr_d_contract
*    WHERE contract_id BETWEEN '00009999991000' AND '00009999991002'.
*  ENDMETHOD.                    "setup
*
*  METHOD calculate_pob_qty.
** =========================
*
*
*    DATA: lv_tdc               TYPE etobj_name VALUE 'FARR_TDC_IL_CONTRACT', "Name of Test Data Container
*          lo_tdc_ref           TYPE REF TO cl_apl_ecatt_tdc_api, "API to access TDC
*          lv_param_name        TYPE etpar_name, "Parameter name
*          lv_variant           TYPE etvar_id, "Variant name
*          lt_variants          TYPE etvar_name_tabtype. "ITAB of variants
*
*    DATA: ls_contract_create   TYPE farr_s_contract_create,
*          ls_contract          TYPE farr_d_contract,
*          lt_pob_create        TYPE farr_tt_pob_create_if,
*          lt_pob_data          TYPE farr_tt_pob_data,
*          lt_pob_exp           TYPE farr_tt_pob_data,
*          lt_cond_type_create  TYPE farr_tt_cond_type_create,
*          lv_contract_id       TYPE farr_contract_id,
*          lt_pob_id_map        TYPE farr_tt_pob_id_map,
*          ls_act_deferral_item TYPE farr_s_defitem_data,
*          ls_exp_deferral_item TYPE farr_s_defitem_data,
*          lt_act_deferral_item TYPE farr_tt_defitem_data,
*          lt_exp_deferral_item TYPE farr_tt_defitem_data,
*          lv_count_act         TYPE i,
*          lv_count_exp         TYPE i,
*          lv_index             TYPE i.
*
*    cl_farr_fnd_cust_db_access=>gv_test_mode   = abap_true.
*    cl_farr_contr_cust_db_access=>gv_test_mode = abap_true.
*    cl_farr_id_services=>mv_test_mode          = abap_true.
*    CALL METHOD cl_farr_defitem_proxy=>set_test_mode.
*    TRY.
*        cl_farr_message_handler=>get_instance( )->initialize( if_farrc_contr_mgmt=>co_appl_log_subobj_contr_mgmt ).
*      CATCH cx_farr_message.
*    ENDTRY.
*
*    TRY.
*        lo_tdc_ref = cl_apl_ecatt_tdc_api=>get_instance( i_testdatacontainer = lv_tdc ).
*        lt_variants = lo_tdc_ref->get_variant_list( ).
*
*        lv_variant = 'CALCULATE_WITH_ADDITIONAL'.
*
*
*        lv_param_name = 'IT_POB_CREATE'.
*
*        lo_tdc_ref->get_value(
*          EXPORTING
*            i_param_name   = lv_param_name
*            i_variant_name = lv_variant
*          CHANGING
*            e_param_value = lt_pob_create
*        ).
*
*        lv_param_name = 'IT_POB_DATA'.
*        lo_tdc_ref->get_value(
*          EXPORTING
*            i_param_name   = lv_param_name
*            i_variant_name = lv_variant
*          CHANGING
*            e_param_value = lt_pob_data
*         ).
*
*
*        lv_param_name = 'IT_COND_TYPE_CREATE'.
*        lo_tdc_ref->get_value(
*          EXPORTING
*            i_param_name   = lv_param_name
*            i_variant_name = lv_variant
*          CHANGING
*            e_param_value = lt_cond_type_create
*        ).
*
*        lv_param_name = 'EX_DEFERRAL_ITEM'.
*        lo_tdc_ref->get_value(
*          EXPORTING
*            i_param_name   = lv_param_name
*            i_variant_name = lv_variant
*          CHANGING
*            e_param_value  = lt_exp_deferral_item
*        ).
*
*        CLEAR ls_contract_create.
*        ls_contract_create-contract_cat = '0001'.
*        ls_contract_create-customer_id = '0001'.
*        ls_contract_create-customer_grp = '0001'.
*        ls_contract_create-acct_principle = 'IFRS'.
*        ls_contract_create-description   = 'Test contract'.
*        ls_contract_create-adapter_id    = 'SD'.
*
*        MOVE-CORRESPONDING ls_contract_create TO ls_contract.
*
**        TRY.
**            CALL METHOD mo_cut->if_farr_contract_mgmt~create_contract
**              EXPORTING
**                is_contract_create  = ls_contract_create
**                it_pob_create       = lt_pob_create
**                it_cond_type_create = lt_cond_type_create
**              IMPORTING
**                ev_contract_id      = lv_contract_id
**                et_pob_id_map       = lt_pob_id_map.
**          CATCH cx_farr_message.
**            cl_abap_unit_assert=>fail( msg = lv_variant ).
**        ENDTRY.
*
*        TRY.
*            CALL METHOD cl_farr_defitem_db_access=>read_multi_per_contract
*              EXPORTING
*                iv_contract_id = lv_contract_id
*              IMPORTING
*                et_defitem     = lt_act_deferral_item.
*          CATCH cx_farr_not_found.
*            cl_abap_unit_assert=>fail( msg = lv_variant ).
*        ENDTRY.
*
*
*
*        call method f_cut->if_genil_appl_intlay~get_objects
*
*
*
*         cl_abap_unit_assert=>assert_equals(
*                  act   = lt_pob_data
*                  exp   = lt_pob_exp
*                  msg   = lv_variant
*                ).
*
*        SORT lt_act_deferral_item BY condition_type deferral_cat fulfill_type.
*        SORT lt_exp_deferral_item BY condition_type deferral_cat fulfill_type.
*
*        lv_index = 1.
*        WHILE lv_index <= lv_count_act.
*          READ TABLE lt_act_deferral_item INDEX lv_index INTO ls_act_deferral_item.
*          READ TABLE lt_exp_deferral_item INDEX lv_index INTO ls_exp_deferral_item.
*
*          CLEAR ls_act_deferral_item-pob_id.
*          CLEAR ls_exp_deferral_item-pob_id.
*          CLEAR ls_act_deferral_item-recon_key.
*          CLEAR ls_exp_deferral_item-recon_key.
*          CLEAR ls_act_deferral_item-source_acct.
*          CLEAR ls_exp_deferral_item-source_acct.
*          CLEAR ls_act_deferral_item-target_acct.
*          CLEAR ls_exp_deferral_item-target_acct.
*
*          cl_abap_unit_assert=>assert_equals(
*            act   = ls_act_deferral_item
*            exp   = ls_exp_deferral_item         "<--- please adapt expected value
*            msg   = lv_variant
*            quit  = if_aunit_constants=>no
*        ).
*
*          lv_index = lv_index + 1.
*        ENDWHILE.
*
*      CATCH cx_ecatt_tdc_access.
*        cl_abap_unit_assert=>fail( msg = lv_variant ).
*    ENDTRY.
*
*  ENDMETHOD.       "calculate_Pob_Qty
*
*
*
*
*ENDCLASS.       "lcl_Farr_Il_Contract
