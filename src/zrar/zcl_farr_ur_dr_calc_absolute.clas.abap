class ZCL_FARR_UR_DR_CALC_ABSOLUTE definition
  public
  inheriting from CL_FARR_CALC_LIAB_ASSET
  final
  create public .

public section.

  methods CONSTRUCTOR .
protected section.

  methods CALCULATE_BOOKING_AMOUNT
    redefinition .
  methods CHECK_CURRENCY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_FARR_UR_DR_CALC_ABSOLUTE IMPLEMENTATION.


METHOD calculate_booking_amount.
***************************************************************************
*& Date                : 06/07/2023                                       *
*& Ticket/Change Req.# : Defect 1554                                      *
*& Requested by        : Raghu Premchand Pillarisetti                     *
*& Developer(Company)  : Roger Alvarado - INFINITY                        *
*& Description         : Currency Check failures when running B job in RAR*
*Comments:  "RALVARADO-06072023 - Defect 1554                             *
***************************************************************************
*CALL METHOD SUPER->CALCULATE_BOOKING_AMOUNT
*  EXPORTING
*    IV_ACCT_PRINCIPLE  =
*    IV_CONTRACT_ID     =
*    IO_FX_CALCULATOR   =
*    IO_DATA_BUFFER     =
*    IO_MSG_HANDLER     =
*    IV_COMPANY_CODE    =
*    IV_LIABI_POST_MODE =
**  IMPORTING
**    es_liab_book       =
**    es_asset_book      =
**    ev_success         =
**    ets_pob_data_amt   =
**    ets_pob_data       =
*    .
  DATA: lt_pob_id                  TYPE farr_tt_pob_id,
        lv_pob_id                  TYPE farr_pob_id,
        ls_pob_data                TYPE farr_s_pob_4_liab_asset_badi,
        ls_pob_data_amt            TYPE farr_s_pob_data_amt,
        lv_success                 TYPE abap_bool,                 " temporary flag for success or not
        lv_contract_pob_success    TYPE abap_bool,                 " success in loop of POB?
        lv_need_aggregate_on_contr TYPE abap_bool,
        ls_currency_suite          TYPE ty_s_currency,
        ls_contract_data           TYPE farr_s_cont_4_liab_asset_badi,
        ls_pob_info                TYPE farr_s_pob_posting_data,
        ls_contract_info           TYPE ty_s_contract_info.

  " clear output parameters
  CLEAR es_liab_book.
  CLEAR es_asset_book.
  CLEAR ev_success.
  CLEAR ets_pob_data_amt.
  CLEAR ets_pob_data.

  io_fx_calculator->initialize( ).

  " by default, there won't be any failure in contract level
  lv_contract_pob_success = abap_true.

  " get contract info
  get_contract_info(
    EXPORTING
      iv_contract_id         = iv_contract_id
      iv_company_code        = iv_company_code
      io_data_buffer         = io_data_buffer
      iv_liabi_post_mode     = iv_liabi_post_mode
    IMPORTING
      es_contract_info       = ls_contract_info
      es_contract_data       = ls_contract_data
  ).

  " get related POB of specific contract
  " only get pob_id but not all the pob master data in order to save stack memory
  io_data_buffer->read_pob_id_list(
    EXPORTING
      iv_contract_id = iv_contract_id
    IMPORTING
      et_pob_id      = lt_pob_id
  ).

  " get related currency information according to current contract and company code
  get_all_currency(
    EXPORTING
      is_contract_info  = ls_contract_info
      io_data_buffer    = io_data_buffer
    IMPORTING
      es_currency_suite = ls_currency_suite
  ).

  " set currency
  io_fx_calculator->set_currency(
    EXPORTING
      iv_waers = ls_currency_suite-waers
      iv_hwaer = ls_currency_suite-hwaer
      iv_hwae2 = ls_currency_suite-hwae2
      iv_hwae3 = ls_currency_suite-hwae3
  ).

  " make use of liability and asset of POB level to aggregate Liability and Asset on contract level
  io_fx_calculator->need_aggre_liab_asst_on_contr(
    EXPORTING
      iv_post_mode      = ls_contract_info-liability_post_mode
    IMPORTING
      ev_need_aggregate = lv_need_aggregate_on_contr
  ).

  " Calculate with each POB
  LOOP AT lt_pob_id INTO lv_pob_id.

    CLEAR ls_pob_data_amt.

    " get one POB master data one time for not consume stack to much
    io_data_buffer->read_pob_data(
      EXPORTING
        iv_pob_id   = lv_pob_id
      IMPORTING
        es_pob_data = ls_pob_data
    ).
    MOVE-CORRESPONDING ls_pob_data TO ls_pob_data_amt.

    " get liability and asset calculation related amount
    " that is revenue, invoice and billable amount and posted assets and liability
    IF ls_contract_info-liability_post_mode = if_farrc_contr_mgmt=>co_cl_post_contract_level .

      IF ls_pob_data-distinct_type = if_farrc_contr_mgmt=>co_distinct_type_non_distinct."Skip non-distinct POB
        CONTINUE.

      ELSEIF ls_pob_data-distinct_type = if_farrc_contr_mgmt=>co_distinct_type_compound.
        get_cpd_amt_for_la_calct(
          EXPORTING
            iv_contract_id  =   iv_contract_id
            iv_pob_id       =   lv_pob_id  " Performance Obligation ID
            io_data_buffer  =   io_data_buffer  " Data Buffer For Claculate Liab Asset BAdI
          CHANGING
            cs_pob_data_amt =   ls_pob_data_amt  " POB master data with Invoice, revenue and Billable amount
        ).

      ELSE." all distinct POBs
        get_amt_for_liab_asst_calct(
          EXPORTING
            iv_pob_id         = lv_pob_id
            io_data_buffer    = io_data_buffer
          CHANGING
            cs_pob_data_amt   = ls_pob_data_amt
        ).
      ENDIF.

    ELSE.

      get_amt_for_liab_asst_calct(
        EXPORTING
          iv_pob_id         = lv_pob_id
          io_data_buffer    = io_data_buffer
        CHANGING
          cs_pob_data_amt   = ls_pob_data_amt
      ).

    ENDIF.

    " check whether the currency got from table is valid
    check_currency(
      EXPORTING
        iv_contract_id    = ls_contract_info-contract_id
        iv_company_code   = ls_contract_info-company_code
        is_currency_suite = ls_currency_suite
        io_msg_handler    = io_msg_handler
      IMPORTING
        ev_success        = lv_success
      CHANGING
        cs_pob_data_amt   = ls_pob_data_amt
    ).
*{Begin of RALVARADO-06072023 - Defect 1554
    DATA: lt_pob TYPE STANDARD TABLE OF farr_d_pob.
    DATA: ls_currency_suite_tmp TYPE ty_s_currency.
    FIELD-SYMBOLS <FS_lspob> LIKE LINE OF lt_pob.

    ls_currency_suite_tmp = ls_currency_suite.
    REFRESH lt_pob.
    IF lv_success = abap_false AND ls_contract_info-liability_post_mode = if_farrc_contr_mgmt=>co_cl_post_pob_level.
      SELECT * FROM farr_d_pob INTO TABLE lt_pob WHERE pob_id = ls_pob_data_amt-pob_id.

      LOOP AT lt_pob ASSIGNING <FS_lspob>.

        IF <FS_lspob>-prevent_alloc = abap_true.
          lv_success = abap_true.
          ls_currency_suite_tmp-waers = ls_pob_data_amt-waers.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF lv_success = abap_true.
      " we'are sure that those amount not equal to 0 must have correct currencies,
      " now we'll fill all currencies, in case those 0 values with no currency
      fill_all_currency(
        EXPORTING
          is_currency_suite = ls_currency_suite_tmp
        CHANGING
          cs_pob_data_amt   = ls_pob_data_amt
*}End of RALVARADO-06072023 - Defect 1554
          ).
    ELSE.
      " error on this pob's waers, skip the whole contract
      lv_contract_pob_success = abap_false.
      EXIT.
    ENDIF.

    " only do aggregation if necessary
    IF lv_need_aggregate_on_contr = abap_true.
      io_fx_calculator->aggregate_liab_asset_on_contr(
        EXPORTING
          is_pob_data_amt       = ls_pob_data_amt
        CHANGING
          cs_asset_contract     = es_asset_book
          cs_liability_contract = es_liab_book
      ).
    ENDIF.

    " store pob data
    INSERT ls_pob_data INTO TABLE ets_pob_data.

    IF ets_pob_data_amt IS REQUESTED.
      " store pob liability and assets
      MOVE-CORRESPONDING ls_pob_data TO ls_pob_data_amt.
      ls_pob_data_amt-contract_id    = iv_contract_id.
      ls_pob_data_amt-company_code   = iv_company_code.
      ls_pob_data_amt-acct_principle = iv_acct_principle.
      INSERT ls_pob_data_amt INTO TABLE ets_pob_data_amt.
    ENDIF.

  ENDLOOP. " end of pob

  IF lv_need_aggregate_on_contr = abap_true.
    " now we've got liability and assets on contract level, balance them
    " both POB level and contract level will have the chance to aggregate on contract level,
    " so this method must be called out side of diverse choice.
    io_fx_calculator->balance_contract_liab_asset(
      CHANGING
        cs_asset_contract     = es_asset_book
        cs_liability_contract = es_liab_book
    ).
  ENDIF.

  ev_success = lv_contract_pob_success.

ENDMETHOD.


  METHOD check_currency.
***************************************************************************
*& Date                : 10/09/2024                                       *
*& Ticket/Change Req.# : Defect 3060                                      *
*& Requested by        : Raghu Premchand Pillarisetti                     *
*& Developer(Company)  : Roger Alvarado - INFINITY                        *
*& Description         : Currency Check failures when running B job in RAR*
*Comments:  "RALVARADO-10092024 - Defect 3060                             *
***************************************************************************
*CALL METHOD SUPER->CHECK_CURRENCY
*  EXPORTING
*    IV_CONTRACT_ID    =
*    IV_COMPANY_CODE   =
*    IS_CURRENCY_SUITE =
*    IO_MSG_HANDLER    =
**  IMPORTING
**    ev_success        =
*  CHANGING
*    CS_POB_DATA_AMT   =
*    .

    DATA lv_err_pob_id      TYPE farr_pob_id.
    DATA lv_err_contract_id TYPE farr_contract_id.
    DATA lv_message         TYPE string.

    ev_success = abap_true.

    DO 1 TIMES.

      IF    cs_pob_data_amt-invoice_amount <> 0
        OR  cs_pob_data_amt-revenue_amount <> 0
        OR  cs_pob_data_amt-billable_amount <> 0.

        IF cs_pob_data_amt-waers <> is_currency_suite-waers.

          " error
          ev_success = abap_false.
          EXIT.

        ENDIF.
      ENDIF.

      " check local currency 1
      IF is_currency_suite-hwaer IS NOT INITIAL.
        IF   ( cs_pob_data_amt-invoice_amt_lc-betrh  <> 0 AND cs_pob_data_amt-invoice_amt_lc-hwaer <> is_currency_suite-hwaer )
          OR ( cs_pob_data_amt-revenue_amt_lc-betrh  <> 0 AND cs_pob_data_amt-revenue_amt_lc-hwaer <> is_currency_suite-hwaer )
          OR ( cs_pob_data_amt-billable_amt_lc-betrh <> 0 AND cs_pob_data_amt-billable_amt_lc-hwaer <> is_currency_suite-hwaer ).

          " error
          ev_success = abap_false.
          EXIT.

        ENDIF.
      ENDIF.

      " check local currency 2
      IF is_currency_suite-hwae2 IS NOT INITIAL.
        IF   ( cs_pob_data_amt-invoice_amt_lc-betr2  <> 0 AND cs_pob_data_amt-invoice_amt_lc-hwae2 <> is_currency_suite-hwae2 )
          OR ( cs_pob_data_amt-revenue_amt_lc-betr2  <> 0 AND cs_pob_data_amt-revenue_amt_lc-hwae2 <> is_currency_suite-hwae2 )
          OR ( cs_pob_data_amt-billable_amt_lc-betr2 <> 0 AND cs_pob_data_amt-billable_amt_lc-hwae2 <> is_currency_suite-hwae2 ) .

          " error
          ev_success = abap_false.
          EXIT.

        ENDIF.
      ENDIF.

      " check local currency 3
      IF is_currency_suite-hwae3 IS NOT INITIAL.
        IF   ( cs_pob_data_amt-invoice_amt_lc-betr3  <> 0 AND cs_pob_data_amt-invoice_amt_lc-hwae3 <> is_currency_suite-hwae3 )
          OR ( cs_pob_data_amt-revenue_amt_lc-betr3  <> 0 AND cs_pob_data_amt-revenue_amt_lc-hwae3 <> is_currency_suite-hwae3 )
          OR ( cs_pob_data_amt-billable_amt_lc-betr3 <> 0 AND cs_pob_data_amt-billable_amt_lc-hwae3 <> is_currency_suite-hwae3 ) .

          " error
          ev_success = abap_false.
          EXIT.

        ENDIF.
      ENDIF.
    ENDDO.

    IF ev_success = abap_false.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = iv_contract_id
        IMPORTING
          output = lv_err_contract_id.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = cs_pob_data_amt-pob_id
        IMPORTING
          output = lv_err_pob_id.

      IF 1 = 2.
        MESSAGE e417(farr_contract_main)
          WITH iv_contract_id lv_err_pob_id iv_company_code INTO lv_message.
      ENDIF.

      TRY .
          io_msg_handler->add_message(
            EXPORTING
              iv_msgid       =  'FARR_CONTRACT_MAIN'
              iv_msgty       =  if_farrc_msg_handler_cons=>co_msgty_w          "RALVARADO-10092024 - Defect 3060
              iv_msgno       =  '417'
              iv_msgv1       =  iv_contract_id
              iv_msgv2       =  lv_err_pob_id
              iv_msgv3       =  iv_company_code
              iv_ctx_type    =  if_farrc_msg_handler_cons=>co_ctx_contract_id
              iv_ctx_value   =  lv_err_contract_id
              iv_probcl      =  if_farrc_msg_handler_cons=>co_probclass_very_hi ).

        CATCH cx_farr_message.
          " dummy
      ENDTRY.

    ENDIF.

  ENDMETHOD.


  METHOD constructor.
    CALL METHOD super->constructor.

    CREATE OBJECT mo_fx1_ur_dr_calc
      TYPE cl_farr_fx1_unbil_defer_calct
      EXPORTING
        iv_ur_dr_calc_method = if_farrc_accrual_constants=>co_urdr_calc_method_absolute.

    CREATE OBJECT mo_fx2_ur_dr_calc
      TYPE cl_farr_fx2_unbil_defer_calct
      EXPORTING
        iv_ur_dr_calc_method = if_farrc_accrual_constants=>co_urdr_calc_method_absolute.

  ENDMETHOD.
ENDCLASS.
