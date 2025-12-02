class ZCL_FARR_IL_CONTRACT definition
  public
  inheriting from CL_WCF_GENIL_ABSTR_COMPONENT
  create public .

public section.

  types:
    BEGIN OF ty_s_reassign_handler,
                contract_id        TYPE farr_contract_id,
                temp_contract_idx  TYPE i,
             END OF ty_s_reassign_handler .
  types:
    ty_tt_reassign_handler TYPE STANDARD TABLE OF ty_s_reassign_handler WITH KEY contract_id temp_contract_idx .
  types:
    BEGIN OF ty_s_reassign_mapping,
                contract_id        TYPE farr_contract_id,
                temp_contract_idx  TYPE i,
                pob_id             TYPE farr_pob_id,
                source_contract_id TYPE farr_contract_id,
             END OF ty_s_reassign_mapping .
  types:
    ty_tt_reassign_mapping TYPE STANDARD TABLE OF ty_s_reassign_mapping WITH KEY contract_id temp_contract_idx .
  types:
    BEGIN OF ty_s_manual_fulfill_handler,
                contract_id        TYPE farr_contract_id,
                contract_mgmt      TYPE REF TO if_farr_contract_mgmt_bol,
             END OF ty_s_manual_fulfill_handler .
  types:
    ty_tt_manual_fulfill_handler TYPE STANDARD TABLE OF ty_s_manual_fulfill_handler .
  types:
    BEGIN OF ty_field_desc,
          table_name TYPE ddobjname,
          field_name TYPE dfies-fieldname,
          field_desc TYPE string,
        END OF ty_field_desc .
  types:
    ts_field_desc TYPE SORTED TABLE OF ty_field_desc WITH UNIQUE KEY table_name field_name .

  data IO_CHG_OBJ type CRMT_ATTR_NAME_TAB .
  data MO_CONFLICT_MGMT type ref to IF_FARR_CONFLICT_MGMT .
  data MV_CONTRACT_ID type FARR_CONTRACT_ID .
  data MO_CONTRACT_MGMT type ref to IF_FARR_CONTRACT_MGMT .
  data MO_MAN_CONTRACT_MGMT type ref to CL_FARR_MANUAL_CONTRACT_MGMT .
  data MO_REV_SPREADING type ref to IF_FARR_REV_SPREADING_BOL .
  data MTS_FIELD_DESC type TS_FIELD_DESC .
  data MT_CHANGEABLE_FIELD_CHG_TYPE type CRMT_ATTR_NAME_TAB .
  data MT_CHANGEABLE_FIELD_CONFLICT type CRMT_ATTR_NAME_TAB .
  data MT_CHANGEABLE_FIELD_CONTRACT type CRMT_ATTR_NAME_TAB .
  data MT_CHANGEABLE_FIELD_NEW_POB type CRMT_ATTR_NAME_TAB .
  data MT_CHANGEABLE_FIELD_NEW_POB_C type CRMT_ATTR_NAME_TAB .
  data MT_CHANGEABLE_FIELD_POB type CRMT_ATTR_NAME_TAB .
  data MT_CHANGEABLE_FIELD_SPREADING type CRMT_ATTR_NAME_TAB .
  data MT_MANUAL_FULFILL_HANDLER type TY_TT_MANUAL_FULFILL_HANDLER .
  data MT_REASSIGN_HANDLER type TY_TT_REASSIGN_HANDLER .
  data MT_REASSIGN_MAPPING type TY_TT_REASSIGN_MAPPING .
  data MV_CHANGE_MODE type FARR_CHANGE_MODE_EXTERNAL .
  data MV_FLG_MANUAL_FULFILL type ABAP_BOOL .
  data MV_FLG_REASSIGN type ABAP_BOOL .
  data MV_LAST_TEMP_CONTR_IDX type I .
  data MV_MSG_STR type BAPI_MSG .
  data MV_USE_IDX_AS_CONTR_ID type ABAP_BOOL value ABAP_FALSE ##NO_TEXT.
  data MV_VALIDITY_DATE type FARR_VALIDITY_DATE .
  data MV_MIG_PACKAGE type FARR_MIG_PACKAGE .

*"* public components of class ZCL_FARR_IL_CONTRACT
*"* do not include other source files here!!!
  methods CONSTRUCTOR
    importing
      !IV_MODE type CHAR1
      !IV_COMPONENT_NAME type CRMT_COMPONENT_NAME optional .
  methods CREATE_CONTRACT
    importing
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST .
  methods LOCK_CONTRACT
    importing
      !IO_MSG_CONTAINER type ref to CL_CRM_GENIL_GLOBAL_MESS_CONT
    changing
      !CS_OBJ type CRMT_GENIL_OBJ_INST_LINE .
  methods LOCK_REV_SPREADING
    importing
      !IO_MSG_CONTAINER type ref to CL_CRM_GENIL_GLOBAL_MESS_CONT
    changing
      !CS_OBJ type CRMT_GENIL_OBJ_INST_LINE .
  methods MANUAL_FULFILL_POB
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods SET_PRIC_ALLOC_SYS_DEFLT .
  methods GET_INVOICE_AMOUNT
    importing
      !IV_POB_ID type FARR_POB_ID
      !IV_COND_TYPE type KSCHA
    exporting
      !ES_RESULT type FARR_S_INVOICE_AMOUNT
    raising
      CX_FARR_MESSAGE .
  methods APPLY_CHANGE_TYPE
    importing
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB .
  methods SAVE_COMBINE_CONTRACTS
    importing
      !IO_MSG_CONT type ref to CL_CRM_GENIL_GLOBAL_MESS_CONT
    exporting
      !ETS_TEMP_CONTRACTS type FARR_TS_CONTRACT_BOL_INSTANCE
    changing
      !CS_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE
    raising
      CX_FARR_MESSAGE .
  methods BUILD_CHG_TYPE_ATTR_CHG_LIST
    importing
      !IS_CHANGE_TYPE type FARR_S_CHG_TYPE .
  methods BUILD_NEW_POB_CUST_FIELDS .
  methods BUILD_POB_ATTR_CHANGEABLE_LIST
    importing
      !IS_POB_DATA type FARR_S_POB_DATA
    raising
      CX_FARR_MESSAGE .
  methods BUILD_POB_CUSTOMIZING_FIELDS .
  methods BUILD_SPR_ATTR_CHANGEABLE_LIST .
  methods CALCULATE_POB_QTY
    changing
      !CS_POB_DATA type FARR_S_POB_DATA_UI .
  methods CHANGE_DISTINCT_TYPE
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IV_ROOTLIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods CHECK_AUTHORITY
    importing
      !IV_METHOD_NAME type CRMT_OBJ_METHOD_NAME
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !EV_CHECK_RESULT type BOOLEAN .
  methods CHECK_CONTRACT_CHANGED
    exporting
      !EV_CONTRACT_CHANGED type ABAP_BOOL .
  methods CHECK_CREATE_ADDITIONAL_POB
    importing
      !IO_ROOTLIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods COLLECT_ALLOC_CONDTYPE_CHANGED
    importing
      !IO_COND_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_COND_TYPE_CHG type FARR_TT_COND_TYPE_DATA .
  methods COLLECT_CHANGE_TYPE_CHANGED
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_CHANGE_TYPE_CHG type FARR_TT_CHG_TYPE_WITH_ATTR .
  methods COLLECT_CHANGE_TYPE_CREATED
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
      !IS_POB_KEY type FARR_S_POB_KEY
    changing
      !CT_CHANGE_TYPE_ADD type FARR_TT_CHG_TYPE
    raising
      CX_FARR_MESSAGE .
  methods COLLECT_CHANGE_TYPE_DELETED
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_CHANGE_TYPE_DEL type FARR_TT_CHG_TYPE_KEY .
  methods COLLECT_CONFLICT_CHANGED
    importing
      !IO_CONFLICT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CTS_CONFLICT_CHG type FARR_TS_MANL_CHNG_DATA .
  methods COLLECT_DEFERRAL_CREATED
    importing
      !IO_DEFERRAL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
      !IV_POB_ID type FARR_POB_ID
    changing
      !CT_DEFERRAL_ADD type FARR_TT_DEFERRAL_DATA .
  methods COLLECT_DEFERRAL_DELETED
    importing
      !IO_DEFERRAL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_DEFERRAL_DEL type FARR_TT_DEFERRAL_KEY .
  methods COLLECT_POB_CHANGED
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_POB_CHG type FARR_TT_POB_DATA_WITH_ATTR .
  methods COLLECT_POB_CREATED
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_POB_ADD type FARR_TT_POB_DATA .
  methods COLLECT_POB_DELETED
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_POB_DEL type FARR_TT_POB_ID .
  methods COLLECT_CONFLICT_DELETED
    importing
      !IO_CONFLICT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_CONFLICT_DEL type FARR_TT_MANL_CHNG_DATA .
  methods COMBINE_BACKEND_CALL
    importing
      !IT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB
      !IV_TARGET_CONTRACT_ID type FARR_CONTRACT_ID
      !IV_TARGET_DESCRIPTION type FARR_DESCRIPTION .
  methods COMBINE_CANCEL
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods COMBINE_COLLECT_CONTRACT_ID
    importing
      !IT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB
    exporting
      !ET_CONTRACT_ID type FARR_TT_CONTRACT_KEY .
  methods COMBINE_LOAD_AND_CHECK
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods COMBINE_LOAD_CHECK_CALL
    importing
      !IT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB
      !IV_TARGET_CONTRACT_ID type FARR_CONTRACT_ID
      !IV_TARGET_DESCRIPTION type FARR_DESCRIPTION
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
      !IV_VALIDITY_DATE type FARR_VALIDITY_DATE
      !IV_CHANGE_MODE type FARR_CHANGE_MODE_EXTERNAL .
  methods COMBINE_PERFORM
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods COMBINE_POB
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods CONVERT_MSG_FROM_T100_TO_BAPI
    importing
      !LX_FARR_MESSAGE type ref to CX_FARR_MESSAGE optional
      !IO_MSG_CONTAINER type ref to CL_CRM_GENIL_GLOBAL_MESS_CONT
      !IO_REV_SPREADING type ref to IF_FARR_REV_SPREADING_BOL optional
      !IO_COMBINE_CONTRACT type ref to IF_FARR_CONTRACT_MGMT_BOL optional .
  methods CONVERT_SEL_INTO_SEARCH_TABLE
    importing
      !IT_SEL_CRITERIA type RSDSFRANGE_T_SSEL
    exporting
      !IT_SEARCH_CRITERIA_CONTRACT type RSDSFRANGE_T_SSEL
      !IT_SEARCH_CRITERIA_POB type RSDSFRANGE_T_SSEL
      !IT_SEARCH_CRITERIA_MAPPING type RSDSFRANGE_T_SSEL .
  methods CONVERT_SEL_PARAM
    importing
      !IT_SEL_PARAM type GENILT_SELECTION_PARAMETER_TAB
    exporting
      !ET_SEL_CRITERIA type RSDSFRANGE_T_SSEL .
  methods CREATE_MANUAL_POB
    importing
      !IO_ROOTLIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods DELETE_MANUAL_CHANGE_VALUE
    importing
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods GET_CONTRACT
    importing
      !IV_CONTRACT_ID type FARR_CONTRACT_ID
      !IV_IS_TEMP_CONTRACT type BOOLEAN default ABAP_FALSE
      !IV_CREATE_IF_NOT_FOUND type BOOLEAN default ABAP_TRUE
    returning
      value(RO_CONTRACT) type ref to IF_FARR_CONTRACT_MGMT_BOL .
  methods DELETE_POB_CONVERT_PARAM
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
    exporting
      !ET_POB_ID type FARR_TT_POB_ID .
  methods DETERMINE_MAX_HITS
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
    returning
      value(RV_MAX_HITS) type BAPI_MAXHITS .
  methods DETER_CONTRACT_MGMT_FOR_LOAD
    returning
      value(RO_CONTRACT) type ref to IF_FARR_CONTRACT_MGMT_BOL .
  methods DETER_CONTRACT_MGMT_FOR_LOCK
    returning
      value(RO_CONTRACT) type ref to IF_FARR_CONTRACT_MGMT_BOL .
  methods EXECUTE_BOL_METHOD_CONTRACT_2
    importing
      !IV_METHOD_NAME type CRMT_OBJ_METHOD_NAME
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
      !IV_OBJECT_NAME type CRMT_OBJ_METHOD_NAME
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS optional
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
      !ET_RESULT type CRMT_GENIL_DATA_REF_4_INST_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods EXECUTE_BOL_METHOD_POB
    importing
      !IV_METHOD_NAME type CRMT_OBJ_METHOD_NAME
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
      !IO_ROOTLIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS optional
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods EXECUTE_BOL_METHOD_POB_2
    importing
      !IV_METHOD_NAME type CRMT_OBJ_METHOD_NAME
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
      !IV_OBJECT_NAME type CRMT_OBJ_METHOD_NAME
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS optional
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
      !ET_RESULT type CRMT_GENIL_DATA_REF_4_INST_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods EXECUTE_BOL_METHOD_REV_SCHE_2
    importing
      !IV_METHOD_NAME type CRMT_OBJ_METHOD_NAME
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
      !IV_OBJECT_NAME type CRMT_OBJ_METHOD_NAME
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS optional
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
      !ET_RESULT type CRMT_GENIL_DATA_REF_4_INST_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods FULFILL_CONTRACTS
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_ROOTLIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods GET_ALLOCATED_AMOUNT
    exporting
      !ET_RESULT type FARR_TT_ALLOCATED_AMOUNT .
  methods GET_CALCULATE_AMOUNT
    exporting
      !ET_RESULT type FARR_TT_CALCULATE_AMOUNT
    raising
      CX_FARR_MESSAGE .
  methods GET_CONFLICT_DESC
    changing
      !CS_CONFLICT_UI_DATA type FARR_S_CONFLICT_DATA_UI .
  methods GET_LATEST_COMPOUND_TEMP_ID
    exporting
      !EV_POB_TEMP_ID type FARR_POB_TEMP_ID .
  methods GET_POB_ORDER_INFO
    exporting
      !ET_RESULT type FARR_TT_POB_ORDER_INFO .
  methods GET_POSTED_POB
    exporting
      !ET_POSTED_POBS type FARR_TS_POB_ID .
  methods INIT .
  methods INIT_CHANGEABLE_FIELDS_CONFLIC .
  methods INIT_CHANGEABLE_FIELDS_CONTR .
  methods INIT_CHANGEABLE_FIELDS_POB .
  methods INIT_MSG_HANDLER .
  methods IS_CONTRACT_CHANGED
    exporting
      !EV_RESULT type BOOLE_D .
  methods LOAD_CONTRACT
    importing
      !IO_CONTRACT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    raising
      CX_FARR_MESSAGE .
  methods LOAD_CONTRACT_BY_OBJ_ID
    importing
      !IS_OBJ type CRMT_GENIL_OBJ_INST_LINE
    returning
      value(RV_SUCCESS) type ABAP_BOOL .
  methods LOAD_POB_UI_AMOUNT
    importing
      !IV_CONTRACT_ID type FARR_CONTRACT_ID
    changing
      !CT_POB_DATA_UI type FARR_TT_POB_DATA_UI .
  methods MANUAL_FULFILL_CHECK
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods MANUAL_FULFILL_CHECK_CONTRA
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods MODIFY_CHANGE_TYPE_LIST
    importing
      !IO_OBJ_LIST type ref to IF_GENIL_CONTAINER_OBJECTLIST
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    raising
      CX_FARR_MESSAGE .
  methods MODIFY_CHILDREN
    importing
      !IO_OBJECT type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    raising
      CX_FARR_MESSAGE .
  methods MODIFY_COND_ACCOUNT
    importing
      !IO_PARENT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
      !IO_OBJ_LIST type ref to IF_GENIL_CONTAINER_OBJECTLIST
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    raising
      CX_FARR_MESSAGE .
  methods MODIFY_CONFLICT
    importing
      !IO_OBJ_LIST type ref to IF_GENIL_CONTAINER_OBJECTLIST
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    raising
      CX_FARR_MESSAGE .
  methods MODIFY_CONTRACT
    importing
      !IO_CONTRACT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB .
  methods MODIFY_DEFERRAL_LIST
    importing
      !IO_OBJ_LIST type ref to IF_GENIL_CONTAINER_OBJECTLIST
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    raising
      CX_FARR_MESSAGE .
  methods MODIFY_POB_LIST
    importing
      !IO_PARENT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
      !IO_OBJ_LIST type ref to IF_GENIL_CONTAINER_OBJECTLIST
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    raising
      CX_FARR_MESSAGE .
  methods MODIFY_ROOT_OBJECT
    importing
      !IO_ROOT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB .
  methods MODIFY_SPREADING
    importing
      !IO_SPREADING_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB .
  methods MSG_CONTRACT_SELECTED
    importing
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_NUM_OF_CONTRACT type SYTABIX
      !IV_NUMBER_AFTER_CHECK type I
      !IV_NUMBER_BEFORE_CHECK type I
      !IV_CONTRACT_ARCHIVED type C optional .
  methods PEER_CREATE_COMPOUND_POB
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IV_CONTRACT_ID type FARR_CONTRACT_ID
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods READ_ADDITION_DEFERRAL
    importing
      !IO_DEFERRAL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_ADDITION_DEFERRAL_OF_POB
    importing
      !IO_DEFERRAL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_ADDITION_POB_OF_POB
    importing
      !IO_ADDI_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_ALLOC_CONDTYPE
    importing
      !IO_CONDTYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_CHANGE_TYPE_OF_POB
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_CHILDREN
    importing
      !IT_REQUEST_OBJECTS type CRMT_REQUEST_OBJ_TAB
      !IO_OBJECT type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_CONDTYPE
    importing
      !IO_CONDTYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_CONFLICT_OBJECT
    importing
      !IO_OBJECT type ref to IF_GENIL_CONTAINER_OBJECT
      !IT_REQUEST_OBJECTS type CRMT_REQUEST_OBJ_TAB
    exceptions
      CX_FARR_MESSAGE .
  methods READ_CONFLICT_UI
    importing
      !IO_CONFLICT_UI_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_CONTRACT_4_PROPOSAL
    importing
      !IO_CONTRACT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    raising
      CX_FARR_MESSAGE .
  methods READ_CONTRACT_OBJECT
    importing
      !IO_CONTRACT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    raising
      CX_FARR_MESSAGE .
  methods READ_CHANGE_TYPE_OF_CONTRACT
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_DEFITEM
    importing
      !IO_DEFITEM_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_DEFITEM_OF_POB
    importing
      !IO_DEFITEM_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_DOCUMENT
    importing
      !IO_DOCUMENT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_FULFILL_OF_DEFITEM
    importing
      !IO_FULFILL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_FULFILL_OF_POB
    importing
      !IO_FULFILL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_POB
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_POBUI
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_POB_ALL
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_POB_TYPE
    importing
      !IO_POB_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods READ_ROOT_OBJECT
    importing
      !IO_ROOT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    raising
      CX_FARR_MESSAGE .
  methods READ_SPREADING_OBJECT
    importing
      !IO_CONTAINER_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods REASSIGN_BACKEND_CALL
    importing
      !IS_REASSIGN_HEADER type FARR_S_REASSIGN_HEADER_FINAL
      !IT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !EV_REASSIGN_BACKEND_SUCCESS type ABAP_BOOL .
  methods REASSIGN_BACKEND_CALL_AFTER_WA
    importing
      !IS_REASSIGN_HEADER type FARR_S_REASSIGN_HEADER_FINAL
      !IT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !EV_REASSIGN_BACKEND_SUCCESS type ABAP_BOOL .
  methods REASSIGN_CLEAR_HANDLER .
  methods REASSIGN_COLLECT_POB_ID
    importing
      !IT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB
    exporting
      !ET_POB_ID type FARR_TT_POB_ID .
  methods REASSIGN_CONVERT_PARAM
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
    exporting
      !ES_REASSIGN_HEADER type FARR_S_REASSIGN_HEADER_FINAL .
  methods REASSIGN_DELETE_CONTRACT
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods REASSIGN_DEL_MULTI_CONTRACTS
    importing
      !IO_MSG_CONT type ref to CL_CRM_GENIL_GLOBAL_MESS_CONT .
  methods REASSIGN_DEL_SINGLE_CONTRACT
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_CONT type ref to CL_CRM_GENIL_GLOBAL_MESS_CONT .
  methods REASSIGN_DETERMINE_HANDLER
    importing
      !IV_CONTRACT_ID type FARR_CONTRACT_ID
      !IV_CONTR_IDX type I
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods REASSIGN_DETERMINE_SOURCE
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods REASSIGN_DETERMINE_TARGET
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods REASSIGN_GET_NEW_CONTRACT_ID
    exporting
      !ET_CONTRACT_ID type FARR_TT_CONTRACT_ID .
  methods REASSIGN_PEER_CREATE_COMP_POB
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IV_CONTRACT_ID type FARR_CONTRACT_ID
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods REASSIGN_PERFORM
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods REASSIGN_PERFORM_AFTER_WARNING
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods REASSIGN_PREPARE_HANDLER
    importing
      !IS_REASSIGN_HEADER type FARR_S_REASSIGN_HEADER
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !EV_LOCK_TARGET_SUCCESS type ABAP_BOOL .
  methods REASSIGN_REMOVE_FROM_HANDLER
    importing
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods REASSIGN_SET_USE_IDX
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS .
  methods REASSIGN_UNLOCK_CONTRACTS .
  methods REFRESH_CONTRACT .
  methods REMOVE_PENDING_CONFLICT
    importing
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
    raising
      CX_FARR_MESSAGE .
  methods COLLECT_DEFERRAL_CHANGED
    importing
      !IO_DEFERRAL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
    changing
      !CT_DEFERRAL_CHG type FARR_TT_DEFERRAL_DATA_WITH_ATT .
  methods EXECUTE_BOL_METHOD_CONTRACT
    importing
      !IV_METHOD_NAME type CRMT_OBJ_METHOD_NAME
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
      !IO_ROOTLIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS optional
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_CRM_GENIL_GENERAL_ERROR .
  methods REPROCESS_ACCT_DETERMINATION .
  methods SEARCH_CONTRACT
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_LOAD_SOFT_DEL type SYTABIX optional .
  methods SEARCH_CONTRACT_BY_OTHERFIELDS
    importing
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
    exporting
      !ET_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !ET_SEL_PARAM_CONTRACT_ID type GENILT_SELECTION_PARAMETER_TAB
      !EV_RESULT type BOOLEAN .
  methods SEARCH_CONTRACT_BY_RANGE_TAB
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_LOAD_SOFT_DEL type SYTABIX optional .
  methods SEARCH_CONTRACT_FOR_MANUAL
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_LOAD_SOFT_DEL type SYTABIX optional .
  methods SEARCH_POB
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_USE_FILTER type ABAP_BOOL optional .
  methods SEARCH_POB_ADV
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_USE_FILTER type ABAP_BOOL optional .
  methods SEARCH_POB_BY_TYPE
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST .
  methods SEARCH_REV_SCHEDULE
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST .
  methods SEARCH_REV_EXPLAIN
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST .
  methods SEARCH_REV_SPREADING
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST .
  methods SEARCH_REV_SUMMARY
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST .
  methods SEARCH_CONFLICT_UI
    importing
      !IS_QUERY_PARAMETERS type GENILT_QUERY_PARAMETERS
      !IT_SELECTION_PARAMETERS type GENILT_SELECTION_PARAMETER_TAB
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST .
  methods SET_ATTR_PROPERTY
    importing
      !IO_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
      !IT_CHANGEABLE_FIELD type CRMT_ATTR_NAME_TAB .
  methods SET_ATTR_PROPERTY_CHG_TYPE
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_ATTR_PROPERTY_CONTRACT
    importing
      !IO_CONTRACT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_ATTR_PROPERTY_DEFERRAL
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_ATTR_PROPERTY_NEW_POB
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT
      !IV_NEW_POB_KIND type STRING .
  methods SET_ATTR_PROPERTY_POB
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_ATTR_PROPERTY_SPREADING
    importing
      !IV_POST_REVENUE type FARR_AMOUNT
      !IO_CONTAINER_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_ADDI_POB_BY_POB
    importing
      !IO_ADDI_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_ALLOC_CONDTYPE
    importing
      !IO_CONDTYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_CHG_TYPE_BY_CONTR
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_CHG_TYPE_BY_POB
    importing
      !IO_CHG_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_CONDTYPE
    importing
      !IO_CONDTYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_CONFLICT_UI
    importing
      !IO_CONFLICT_UI_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_DEFERRAL
    importing
      !IO_DEFERRAL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_DEFERRAL_BY_POB
    importing
      !IO_DEFERRAL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_DEFITEM
    importing
      !IO_DEFITEM_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_DEFITEM_BY_POB
    importing
      !IO_DEFITEM_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_DOCUMENT
    importing
      !IO_DOCUMENT_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_FULFILL
    importing
      !IO_FULFILL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_FULFILL_BY_POB
    importing
      !IO_FULFILL_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_POB
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_POBTYPE
    importing
      !IO_POB_TYPE_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_BOL_KEYS_POB_ALL
    importing
      !IO_POB_OBJ type ref to IF_GENIL_CONTAINER_OBJECT .
  methods SET_CONTRACT_RESULTSET_2RTOBJ
    importing
      !IT_CONTRACT type FARR_TT_CONTRACT_DATA
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_LOAD_SOFT_DEL type SYTABIX optional
      !IV_NUMBER_BEFORE_CHECK type I
      !IV_CONTRACT_ARCHIVED type C optional .
  methods SET_CON_OPE_RESULTSET_2RTOBJ
    importing
      !IT_CONTRACT type FARR_TT_CONTRACT_DATA
      !IO_ROOT_LIST type ref to IF_GENIL_CONT_ROOT_OBJECTLIST
      !IV_OPE_BY_CONTRACT type BOOLE_D
      !IV_CONTRACT_BY_OPE type BOOLE_D
      !IV_LOAD_SOFT_DEL type SYTABIX
      !IV_NUMBER_BEFORE_CHECK type I
      !IV_CONTRACT_ARCHIVED type C optional .
  methods SET_MANUAL_FULFILL_FLG .
  methods SET_NEW_ALLOCATED_AMOUNT
    importing
      !IT_PARAMETERS type CRMT_NAME_VALUE_PAIR_TAB
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJECT_LIST type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods SET_SSP
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods SIMULATE_FULFILL_POB
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods SPLIT_POB
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB .
  methods START_REASSIGN_SIMULATION
    importing
      !IO_MSG_CONT type ref to CL_CRM_GENIL_GLOBAL_MESS_CONT
    exporting
      !EO_ALLOCATION_EXPLAINER type ref to CL_FARR_ALLOCATION_EXPLAINER .
  methods START_SIMULATION
    importing
      !IO_CONTRACT type ref to IF_FARR_CONTRACT_MGMT_BOL
    exporting
      !EO_ALLOCATION_EXPLAINER type ref to CL_FARR_ALLOCATION_EXPLAINER
      !ET_POB_DATA type FARR_TT_POB_DATA
      !ET_ADAPTOR_COND_TYPE type FARR_TT_COND_TYPE_DATA
      !ET_ALLOC_COND_TYPE type FARR_TT_COND_TYPE_DATA
      !ET_INTERMEDIATE_COND_TYPE type FARR_TT_COND_TYPE_DATA
      !ET_TRX_PRICE_COND_TYPE type FARR_TT_COND_TYPE_DATA
    raising
      CX_FARR_MESSAGE .
  methods BUILD_CONTR_CUSTOMIZING_FIELDS .
  methods SET_SPREADING_TO_SYS_DEFAULT
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
      !IO_MSG_SERVICE_ACCESS type ref to IF_GENIL_MSG_SERVICE_ACCESS
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB
    raising
      CX_FARR_MESSAGE .
  methods REMOVE_MANUAL_CHANGE_DATA
    importing
      !IT_PARAMETER type CRMT_NAME_VALUE_PAIR_TAB
    exporting
      !ET_CHANGED_OBJECTS type CRMT_GENIL_OBJ_INSTANCE_TAB
    changing
      !CT_POB_OBJ type CRMT_GENIL_OBJ_INST_LINE_TAB optional .

  methods IF_GENIL_APPL_ALTERNATIVE_DSIL~DELETE_OBJECTS
    redefinition .
  methods IF_GENIL_APPL_ALTERNATIVE_DSIL~INIT_OBJECTS
    redefinition .
  methods IF_GENIL_APPL_ALTERNATIVE_DSIL~LOCK_OBJECTS
    redefinition .
  methods IF_GENIL_APPL_ALTERNATIVE_DSIL~SAVE_OBJECTS
    redefinition .
  methods IF_GENIL_APPL_INTLAY~CREATE_OBJECTS
    redefinition .
  methods IF_GENIL_APPL_INTLAY~EXECUTE_OBJECT_METHOD
    redefinition .
  methods IF_GENIL_APPL_INTLAY~EXECUTE_OBJECT_METHOD2
    redefinition .
  methods IF_GENIL_APPL_INTLAY~GET_DYNAMIC_QUERY_RESULT
    redefinition .
  methods IF_GENIL_APPL_INTLAY~GET_OBJECTS
    redefinition .
  methods IF_GENIL_APPL_INTLAY~MODIFY_OBJECTS
    redefinition .
  PROTECTED SECTION.
*"* protected components of class ZCL_FARR_IL_CONTRACT
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS ZCL_FARR_IL_CONTRACT IMPLEMENTATION.


  METHOD APPLY_CHANGE_TYPE.
    DATA:
          ls_parameter             TYPE crmt_name_value_pair.

    LOOP AT it_parameters INTO ls_parameter.
      CASE ls_parameter-name.
        WHEN if_farrc_contr_mgmt=>co_an_contract_id.

        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.                    "apply_change_type


  METHOD BUILD_CHG_TYPE_ATTR_CHG_LIST.

    CLEAR mt_changeable_field_chg_type.

    APPEND if_farrc_contr_mgmt=>co_an_fiscal_year  TO mt_changeable_field_chg_type.
    APPEND if_farrc_contr_mgmt=>co_an_post_period  TO mt_changeable_field_chg_type.
    APPEND if_farrc_contr_mgmt=>co_an_change_mode  TO mt_changeable_field_chg_type.

  ENDMETHOD.                    "BUILD_CHANGE_TYPE_ATTR_CHANGEABLE_LIST


  METHOD BUILD_CONTR_CUSTOMIZING_FIELDS.
    DATA:lr_contr_descr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS:
         <ls_comp> TYPE LINE OF abap_compdescr_tab.

    lr_contr_descr ?= cl_abap_structdescr=>describe_by_name('INCL_EEW_FARR_CONTRACT').

    LOOP AT lr_contr_descr->components ASSIGNING <ls_comp>.
      APPEND <ls_comp>-name TO mt_changeable_field_contract.
    ENDLOOP.

  ENDMETHOD.                    "build_contr_customizing_fields


  METHOD BUILD_NEW_POB_CUST_FIELDS.

    DATA: lr_pob_descr TYPE REF TO cl_abap_structdescr,
          lr_rep_descr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS:
          <ls_comp>    TYPE LINE OF abap_compdescr_tab.

    lr_pob_descr ?= cl_abap_typedescr=>describe_by_name( 'INCL_EEW_FARR_POB' ).

    LOOP AT lr_pob_descr->components ASSIGNING <ls_comp>.
      APPEND <ls_comp>-name TO mt_changeable_field_new_pob.
      APPEND <ls_comp>-name TO mt_changeable_field_new_pob_c.
    ENDLOOP.

    lr_rep_descr ?= cl_abap_typedescr=>describe_by_name( 'INCL_EEW_FARR_REP' ).

    LOOP AT lr_rep_descr->components ASSIGNING <ls_comp>.
      APPEND <ls_comp>-name TO mt_changeable_field_new_pob.
      APPEND <ls_comp>-name TO mt_changeable_field_new_pob_c.
    ENDLOOP.

  ENDMETHOD.                    "build_new_pob_cust_fields


  METHOD BUILD_POB_ATTR_CHANGEABLE_LIST.
    DATA: lo_contract              TYPE REF TO if_farr_contract_mgmt_bol,
          lo_working_contract      TYPE REF TO if_farr_contract_mgmt_bol,
          lv_event_happened        TYPE boole_d,
          ls_leading_pob_data      TYPE farr_s_pob_data_buffer,
          lv_leading_pob_bom_exist TYPE abap_bool,
          lv_bom_pob_id            LIKE ls_leading_pob_data-bom_pob_id,
          lt_acct_principle        TYPE farr_tt_acct_principle,
          ls_acct_principle        TYPE farr_s_acct_principle.


    CLEAR mt_changeable_field_pob.

    lo_working_contract = get_contract( mv_contract_id ).

    lo_contract ?= lo_working_contract.
    CALL METHOD cl_farr_contract_utility=>check_pob_fulfilled
      EXPORTING
        iv_pob_id    = is_pob_data-pob_id
        io_contract  = lo_contract
      IMPORTING
        ev_fulfilled = lv_event_happened.

    IF is_pob_data-posted IS INITIAL AND is_pob_data-pob_role <> if_farrc_contr_mgmt=>co_pob_role_additional
      AND is_pob_data-pob_category <> if_farrc_contr_mgmt=>co_pob_category_coac.

      CALL METHOD cl_farr_fnd_cust_db_access=>read_acct_principles
        IMPORTING
          et_acct_principles = lt_acct_principle.

      READ TABLE lt_acct_principle INTO ls_acct_principle
        WITH KEY acct_principle = is_pob_data-acct_principle.

      IF ls_acct_principle-cost_recognition_setting = if_farrc_contr_mgmt=>co_cost_recognition.
        APPEND if_farrc_contr_mgmt=>co_an_cost_recognition  TO mt_changeable_field_pob.
      ENDIF.

    ENDIF.

    IF NOT ( is_pob_data-distinct_type = if_farrc_contr_mgmt=>co_distinct_type_compound
             AND is_pob_data-bom_pob_id IS INITIAL ).
      APPEND if_farrc_contr_mgmt=>co_an_fulfill_type  TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_event_type    TO mt_changeable_field_pob.
    ENDIF.

    APPEND if_farrc_contr_mgmt=>co_an_deferral_method   TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_text_def_method   TO mt_changeable_field_pob.

* Linked POB has different event type from its leading
    IF is_pob_data-pob_role = if_farrc_contr_mgmt=>co_pob_role_additional.
      APPEND if_farrc_contr_mgmt=>co_an_event_type TO mt_changeable_field_pob.
    ENDIF.

    IF is_pob_data-manual_created = abap_true.
      APPEND if_farrc_contr_mgmt=>co_an_paobjnr TO mt_changeable_field_pob.
    ENDIF.

* only brf+ linked pob cannot change pob name ---- by hao
    IF is_pob_data-pob_role <> if_farrc_contr_mgmt=>co_pob_role_additional.
      APPEND if_farrc_contr_mgmt=>co_an_pob_name TO mt_changeable_field_pob.
    ELSEIF is_pob_data-manual_created = abap_true.
      APPEND if_farrc_contr_mgmt=>co_an_pob_name TO mt_changeable_field_pob.
    ENDIF.

    IF is_pob_data-manual_created = abap_true OR is_pob_data-pob_role = if_farrc_contr_mgmt=>co_pob_role_additional.
* quantity and quantity unit of addtional POB can be changed if fulfill type is event based.
*      a manual-added linked time-based pob is not allowed to edit quantity
      IF NOT ( is_pob_data-manual_created = abap_true
               AND is_pob_data-pob_role = if_farrc_contr_mgmt=>co_pob_role_additional
               AND is_pob_data-fulfill_type = if_farrc_contr_mgmt=>co_fulfill_type_time_based ).
        APPEND if_farrc_contr_mgmt=>co_an_quantity        TO mt_changeable_field_pob.
        APPEND if_farrc_contr_mgmt=>co_an_quantity_unit   TO mt_changeable_field_pob.
      ENDIF.
    ENDIF.

* manually created POB( excluding additional pob) have change account asssiment
    IF is_pob_data-manual_created = abap_true AND is_pob_data-pob_role <> if_farrc_contr_mgmt=>co_pob_role_additional.
*    APPEND if_farrc_contr_mgmt=>co_an_paobjnr           TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_function_area       TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_business_area       TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_segment             TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_profit_center       TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_cost_center         TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_order_number        TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_activity            TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_network             TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_sales_order_number  TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_item_number         TO mt_changeable_field_pob.
      APPEND if_farrc_contr_mgmt=>co_an_wbs_element         TO mt_changeable_field_pob.
    ENDIF.

* linked pob: its leading pob is compound pob  and its leading pob isn't a part of bom.
    IF is_pob_data-pob_role = if_farrc_contr_mgmt=>co_pob_role_additional.
      CALL METHOD lo_working_contract->read_single_pob
        EXPORTING
          iv_pob_id          = is_pob_data-leading_pob_id
        IMPORTING
          es_pob_data_buffer = ls_leading_pob_data.
      IF ls_leading_pob_data-distinct_type = if_farrc_contr_mgmt=>co_distinct_type_compound.
        lv_leading_pob_bom_exist = abap_true.
        IF ls_leading_pob_data-bom_pob_id IS INITIAL.
          lv_leading_pob_bom_exist = abap_false.
        ELSE.
          lv_bom_pob_id = ls_leading_pob_data-bom_pob_id.
          SHIFT lv_bom_pob_id LEFT DELETING LEADING '0'.
          IF lv_bom_pob_id IS INITIAL.
            lv_leading_pob_bom_exist = abap_false.
          ENDIF.
        ENDIF.
        IF lv_leading_pob_bom_exist = abap_false.
          APPEND if_farrc_contr_mgmt=>co_an_function_area       TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_business_area       TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_segment             TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_profit_center       TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_cost_center         TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_order_number        TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_order_item_number   TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_network             TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_sales_order_number  TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_item_number         TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_wbs_element         TO mt_changeable_field_pob.
          APPEND if_farrc_contr_mgmt=>co_an_co_pa_change        TO mt_changeable_field_pob.
        ENDIF.
      ENDIF.
    ENDIF.


* below fields are always changeable
    APPEND if_farrc_contr_mgmt=>co_an_pob_type          TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_residual_pob      TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_prevent_alloc     TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_ssp               TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_ssp_curk          TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_ssp_range_amount  TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_ssp_range_perc    TO mt_changeable_field_pob.

    APPEND if_farrc_contr_mgmt=>co_an_end_date          TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_duration          TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_duration_unit     TO mt_changeable_field_pob.
*    APPEND if_farrc_contr_mgmt=>co_an_distinct_type     TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_start_date_type   TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_start_date        TO mt_changeable_field_pob.



    APPEND if_farrc_contr_mgmt=>co_an_status            TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_rev_rec_block     TO mt_changeable_field_pob.
    APPEND if_farrc_contr_mgmt=>co_an_review_reason     TO mt_changeable_field_pob.
    "APPEND if_farrc_contr_mgmt=>co_an_manual_rev_block  TO mt_changeable_field_pob.

    APPEND if_farrc_contr_mgmt=>co_an_distinct_fulfill  TO mt_changeable_field_pob.

    build_pob_customizing_fields( ).

  ENDMETHOD.                    "BUILD_POB_ATTR_CHANGEABLE_LIST


  METHOD BUILD_POB_CUSTOMIZING_FIELDS.

    DATA: lr_pob_descr TYPE REF TO cl_abap_structdescr,
          lr_rep_descr TYPE REF TO cl_abap_structdescr.

    FIELD-SYMBOLS:
          <ls_comp>    TYPE LINE OF abap_compdescr_tab.

    lr_pob_descr ?= cl_abap_typedescr=>describe_by_name( 'INCL_EEW_FARR_POB' ).

    LOOP AT lr_pob_descr->components ASSIGNING <ls_comp>.
      APPEND <ls_comp>-name TO mt_changeable_field_pob.
    ENDLOOP.

    lr_rep_descr ?= cl_abap_typedescr=>describe_by_name( 'INCL_EEW_FARR_REP' ).

    LOOP AT lr_rep_descr->components ASSIGNING <ls_comp>.
      APPEND <ls_comp>-name TO mt_changeable_field_pob.
    ENDLOOP.

  ENDMETHOD.                    "build_pob_customizing_fields


  METHOD BUILD_SPR_ATTR_CHANGEABLE_LIST.

    CHECK mt_changeable_field_spreading IS INITIAL.

    APPEND if_farrc_contr_mgmt=>co_an_new_rev_price TO mt_changeable_field_spreading.

  ENDMETHOD.                    "build_spr_attr_changeable_list


  METHOD CALCULATE_POB_QTY.
    DATA:
          lt_pob_fulfillments TYPE farr_tt_fulfill_data_buffer,
          lt_defitems         TYPE farr_tt_defitem_data_buffer,
          lv_actual_qty       TYPE farr_quantity,
          lv_reported_qty     TYPE farr_quantity,
          lo_contract         TYPE REF TO if_farr_contract_mgmt_bol,
          lv_needed_to_chg_eff_qty   TYPE boole_d,
          ls_pob_data         TYPE farr_s_pob_data.

    FIELD-SYMBOLS :
          <ls_pob_fulfillments> LIKE LINE OF lt_pob_fulfillments.

    lo_contract = get_contract( mv_contract_id ).

    lo_contract->read_fulfill_of_defitem(
      EXPORTING
        iv_pob_id              =    cs_pob_data-pob_id " Performance Obligation ID
      IMPORTING
        et_fulfill_data_buffer =    lt_pob_fulfillments " Table type of fulfillment buffer
    ).

    lo_contract->read_defitem_of_pob(
      EXPORTING
        iv_pob_id              =    cs_pob_data-pob_id " Performance Obligation ID
      IMPORTING
        et_defitem_data_buffer =    lt_defitems " Table type of defitem
    ).

    lv_actual_qty = 0.
    lv_reported_qty = 0.
    LOOP AT lt_pob_fulfillments ASSIGNING <ls_pob_fulfillments> .
      IF <ls_pob_fulfillments>-entry_category <> if_farrc_contr_mgmt=>co_fulfill_entry_cat_leading.
        lv_actual_qty = lv_actual_qty + <ls_pob_fulfillments>-actual_qty.
        lv_reported_qty = lv_reported_qty + <ls_pob_fulfillments>-reported_qty.
      ENDIF.
    ENDLOOP.

    IF cs_pob_data-effective_qty IS INITIAL.
      " Note 2528099
      " POB cancellation without invoice
      " effective_qty = 0
      MOVE-CORRESPONDING cs_pob_data TO ls_pob_data.
      CALL METHOD cl_farr_contract_utility=>is_needed_to_chg_eff_qty
        EXPORTING
          is_pob_data              = ls_pob_data
        IMPORTING
          ev_needed_to_chg_eff_qty = lv_needed_to_chg_eff_qty.

      IF lv_needed_to_chg_eff_qty = abap_true.
        cs_pob_data-effective_qty = cs_pob_data-quantity.
      ENDIF.
    ENDIF.

    IF lt_defitems IS NOT INITIAL.
      cs_pob_data-reported_not_deli_qty = cs_pob_data-effective_qty - lv_reported_qty.
      cs_pob_data-actual_not_deli_qty = cs_pob_data-effective_qty - lv_actual_qty.

      cs_pob_data-reported_fulfilled_qty = lv_reported_qty.
      cs_pob_data-actual_fulfilled_qty = lv_actual_qty.
    ENDIF.

    "calculate the poc of not delivered.
    IF cs_pob_data-fulfill_type = if_farrc_contr_mgmt=>co_fulfill_type_over_time.
      cs_pob_data-actual_not_deli_poc = cs_pob_data-actual_not_deli_qty * 100 / cs_pob_data-effective_qty.
      cs_pob_data-reported_not_deli_poc = cs_pob_data-reported_not_deli_qty * 100 / cs_pob_data-effective_qty.
    ENDIF.
  ENDMETHOD.                    "calculate_pob_qty


  METHOD CHANGE_DISTINCT_TYPE.
    DATA:
          ls_pob_key            TYPE farr_s_pob_key,
          ls_pob_changed        TYPE farr_s_pob_data_buffer,
          lt_pob_add            TYPE farr_tt_pob_data,
          lt_pob_chg            TYPE farr_tt_pob_data_with_attr,
          lt_pob_del            TYPE farr_tt_pob_id,
          lt_other_changed_pob  TYPE farr_tt_pob_id,
          lo_root_obj           TYPE REF TO if_genil_container_object,
          lt_changed_pob        TYPE crmt_genil_obj_instance_tab,
          lx_farr_message       TYPE REF TO cx_farr_message,
          lo_msg_cont           TYPE REF TO cl_crm_genil_global_mess_cont.

    FIELD-SYMBOLS:
          <ls_pob_obj>           LIKE LINE OF ct_pob_obj.

    lo_root_obj = iv_rootlist->get_first( ).

    IF lo_root_obj IS BOUND.
      TRY .
          CALL METHOD modify_children
            EXPORTING
              io_object          = lo_root_obj
            CHANGING
              ct_changed_objects = lt_changed_pob.
        CATCH cx_farr_message INTO lx_farr_message.
          lo_msg_cont = iv_rootlist->get_global_message_container( ).
          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
      ENDTRY.

      LOOP AT ct_pob_obj ASSIGNING <ls_pob_obj>.
        <ls_pob_obj>-success = abap_true.
      ENDLOOP.

    ENDIF.


  ENDMETHOD.                    "reassign_execute


  METHOD CHECK_AUTHORITY.
    DATA: lv_msg_str     TYPE string,
          mo_msg_handler TYPE REF TO cl_farr_message_handler,
          lo_msg_cont    TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_contract_id TYPE farr_contract_id.

    CALL METHOD cl_farr_message_handler=>get_instance
      RECEIVING
        ro_msg_handler = mo_msg_handler.

    CASE iv_method_name.
      WHEN if_farrc_contr_mgmt=>co_mn_check_contra_manual_ful OR
           if_farrc_contr_mgmt=>co_mn_manual_fulfill_pob.

        AUTHORITY-CHECK OBJECT 'F_RR_MFUFI'
          ID 'ACTVT' FIELD if_farrc_contr_mgmt=>co_auth_activity_execute.  "16

        IF sy-subrc <> 0.
          ev_check_result = abap_false.

          " Not authorized to execute manual fulfill (authorization object F_RR_MFUFI)
          MESSAGE e005(farr_contract_bol) INTO lv_msg_str.

          lv_contract_id = mv_contract_id.
          mo_msg_handler->add_symessage(
            EXPORTING
              iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
              iv_ctx_value = lv_contract_id
          ).

          lo_msg_cont = io_msg_service_access->get_global_message_container( ).
          lo_msg_cont->reset( ).

          IF 1 = 2.
            MESSAGE e005(farr_contract_bol).
          ENDIF.

          lo_msg_cont->add_message(
            EXPORTING
             iv_msg_type       = 'E'
             iv_msg_id         = 'FARR_CONTRACT_BOL'
             iv_msg_number     = '005'
             iv_show_only_once = abap_true
          ).
        ELSE.
          ev_check_result = abap_true.
        ENDIF.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "check_authority


  METHOD CHECK_CONTRACT_CHANGED.
    DATA:
       lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_contract_for_bol->check_contract_changed(
      IMPORTING
        ev_contract_changed = ev_contract_changed
    ).
  ENDMETHOD.                    "check_contract_changed


  METHOD CHECK_CREATE_ADDITIONAL_POB.
    DATA: lv_leading_pob_id   TYPE farr_pob_id,
          lo_checker          TYPE REF TO cl_farr_contract_checker,
          lo_msg_cont         TYPE REF TO cl_crm_genil_global_mess_cont,
          lx_crm_error        TYPE REF TO cx_crm_genil_general_error,
          ls_pob_key          TYPE farr_s_pob_key,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.
    FIELD-SYMBOLS:
          <ls_obj> TYPE crmt_genil_obj_inst_line.

    LOOP AT ct_object_list ASSIGNING <ls_obj>.
* Get leading POB ID.
      TRY.
          CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
            EXPORTING
              iv_object_name = <ls_obj>-object_name
              iv_object_id   = <ls_obj>-object_id
            IMPORTING
              es_key         = ls_pob_key.

          IF NOT ls_pob_key IS INITIAL.
            lv_leading_pob_id = ls_pob_key-pob_id.
          ENDIF.
        CATCH cx_crm_genil_general_error.
          <ls_obj>-success = abap_false.
          CONTINUE.
      ENDTRY.

      IF lv_leading_pob_id IS NOT INITIAL.
        TRY.
            lo_contract_for_bol = get_contract( mv_contract_id ).

            lo_checker = lo_contract_for_bol->get_contract_checker( ).
            lo_checker->check_create_addition_pob( iv_pob_id = lv_leading_pob_id ).

            <ls_obj>-success = abap_true.
          CATCH cx_farr_message.
            lo_msg_cont = io_rootlist->get_global_message_container( ).
            convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
            CREATE OBJECT lx_crm_error.
            RAISE EXCEPTION lx_crm_error.
        ENDTRY.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "execute_bol_method_pob


  METHOD COLLECT_ALLOC_CONDTYPE_CHANGED.

    DATA: lo_props_obj      TYPE REF TO if_genil_obj_attr_properties,
          lt_changed_attr   TYPE crmt_attr_name_tab,
          ls_cond_type_data TYPE farr_s_cond_type_data,
          ls_cond_type_key  TYPE farr_s_cond_type_key.

    lo_props_obj = io_cond_type_obj->get_attr_props_obj( ).
    CALL METHOD lo_props_obj->get_name_tab_4_property
      EXPORTING
        iv_property = if_genil_obj_attr_properties=>modified
      IMPORTING
        et_names    = lt_changed_attr.

    IF lt_changed_attr IS INITIAL.
      RETURN.
    ENDIF.

    CALL METHOD io_cond_type_obj->get_attributes
      IMPORTING
        es_attributes = ls_cond_type_data.

    CALL METHOD io_cond_type_obj->get_key
      IMPORTING
        es_key = ls_cond_type_key.

    MOVE-CORRESPONDING ls_cond_type_key TO ls_cond_type_data.

    APPEND ls_cond_type_data TO ct_cond_type_chg.

  ENDMETHOD.                    "collect_alloc_condtype_changed


  METHOD COLLECT_CHANGE_TYPE_CHANGED.
    DATA: lo_props_obj               TYPE REF TO if_genil_obj_attr_properties,
          lt_changed_attr            TYPE crmt_attr_name_tab,
          ls_change_type             TYPE farr_s_chg_type,
          ls_change_type_with_attr   TYPE farr_s_chg_type_with_attr,
          ls_change_type_key         TYPE farr_s_chg_type_key.

    lo_props_obj = io_chg_type_obj->get_attr_props_obj( ).
    CALL METHOD lo_props_obj->get_name_tab_4_property
      EXPORTING
        iv_property = if_genil_obj_attr_properties=>modified
      IMPORTING
        et_names    = lt_changed_attr.

    CALL METHOD io_chg_type_obj->get_attributes
      IMPORTING
        es_attributes = ls_change_type.

    CALL METHOD io_chg_type_obj->get_key
      IMPORTING
        es_key = ls_change_type_key.

    ls_change_type-contract_id = ls_change_type_key-contract_id.
    ls_change_type-pob_id      = ls_change_type_key-pob_id.
    ls_change_type-guid        = ls_change_type_key-guid.
    MOVE-CORRESPONDING ls_change_type  TO ls_change_type_with_attr.
    APPEND LINES OF lt_changed_attr TO ls_change_type_with_attr-tt_changed_attr.

    APPEND ls_change_type_with_attr TO ct_change_type_chg.
  ENDMETHOD.                    "collect_deferral_changed


  METHOD COLLECT_CHANGE_TYPE_CREATED.
    DATA: ls_change_type      TYPE farr_s_chg_type,
          ls_change_type_key  TYPE farr_s_chg_type_key.

    CALL METHOD io_chg_type_obj->get_attributes
      IMPORTING
        es_attributes = ls_change_type.

    ls_change_type-pob_id       = is_pob_key-pob_id.
    ls_change_type-contract_id  = mv_contract_id.
    ls_change_type-guid         = cl_farr_contract_utility=>generate_guid( ).
    ls_change_type-fiscal_year  = sy-datum+0(4).
    APPEND ls_change_type TO ct_change_type_add.

    MOVE-CORRESPONDING ls_change_type TO ls_change_type_key.
    io_chg_type_obj->set_key( ls_change_type_key ).
  ENDMETHOD.                    "collect_change_type_created


  METHOD COLLECT_CHANGE_TYPE_DELETED.
    DATA: ls_change_type_key            TYPE farr_s_chg_type_key.

    CALL METHOD io_chg_type_obj->get_key
      IMPORTING
        es_key = ls_change_type_key.

    APPEND ls_change_type_key TO ct_change_type_del.
  ENDMETHOD.                    "collect_deferral_deleted


  METHOD COLLECT_CONFLICT_CHANGED.

    DATA:
        lo_props_obj               TYPE REF TO if_genil_obj_attr_properties,
        lt_changed_attr            TYPE crmt_attr_name_tab,
        ls_conflict_data           TYPE farr_s_conflict_data_ui,
        ls_conflict_data_buffer    LIKE LINE OF cts_conflict_chg,
        ls_conflict_key            TYPE farr_s_conflict_manl_chng_key.

    lo_props_obj = io_conflict_obj->get_attr_props_obj( ).
    CALL METHOD lo_props_obj->get_name_tab_4_property
      EXPORTING
        iv_property = if_genil_obj_attr_properties=>modified
      IMPORTING
        et_names    = lt_changed_attr.

    CALL METHOD io_conflict_obj->get_attributes
      IMPORTING
        es_attributes = ls_conflict_data.

    CALL METHOD io_conflict_obj->get_key
      IMPORTING
        es_key = ls_conflict_key.

    MOVE-CORRESPONDING ls_conflict_key TO ls_conflict_data.
    MOVE-CORRESPONDING ls_conflict_data  TO ls_conflict_data_buffer.
*  APPEND LINES OF lt_changed_attr TO ls_conflict_data-tt_changed_attr.


    INSERT ls_conflict_data_buffer INTO TABLE cts_conflict_chg.

  ENDMETHOD.                    "collect_conflict_changed


  METHOD COLLECT_CONFLICT_DELETED.

    DATA: ls_conflict_key      TYPE farr_s_conflict_manl_chng_key.

*  DATA:
*    lo_props_obj               TYPE REF TO if_genil_obj_attr_properties,
*    lt_changed_attr            TYPE crmt_attr_name_tab,
*    ls_conflict_data           TYPE farr_s_conflict_data_ui,
*    ls_conflict_data_buffer    LIKE LINE OF cts_conflict_chg.

    FIELD-SYMBOLS:
      <ls_conflict_del>          LIKE LINE OF ct_conflict_del.

    CALL METHOD io_conflict_obj->get_key
      IMPORTING
        es_key = ls_conflict_key.

    APPEND INITIAL LINE TO ct_conflict_del ASSIGNING <ls_conflict_del>.
    MOVE-CORRESPONDING ls_conflict_key TO <ls_conflict_del>.

  ENDMETHOD.                    "COLLECT_CONFLICT_DELETED


  METHOD COLLECT_DEFERRAL_CHANGED.
    DATA: lo_props_obj               TYPE REF TO if_genil_obj_attr_properties,
          lt_changed_attr            TYPE crmt_attr_name_tab,
          ls_deferral_data           TYPE farr_s_deferral_data,
          ls_deferral_data_with_attr TYPE farr_s_deferral_data_with_attr,
          ls_deferral_key            TYPE farr_s_deferral_key.

    lo_props_obj = io_deferral_obj->get_attr_props_obj( ).
    CALL METHOD lo_props_obj->get_name_tab_4_property
      EXPORTING
        iv_property = if_genil_obj_attr_properties=>modified
      IMPORTING
        et_names    = lt_changed_attr.

    CALL METHOD io_deferral_obj->get_attributes
      IMPORTING
        es_attributes = ls_deferral_data.

    CALL METHOD io_deferral_obj->get_key
      IMPORTING
        es_key = ls_deferral_key.

    ls_deferral_data-pob_id       = ls_deferral_key-pob_id.
    ls_deferral_data-deferral_cat = ls_deferral_key-deferral_cat.
    MOVE-CORRESPONDING ls_deferral_data  TO ls_deferral_data_with_attr.
    APPEND LINES OF lt_changed_attr TO ls_deferral_data_with_attr-tt_changed_attr.

    APPEND ls_deferral_data_with_attr TO ct_deferral_chg.
  ENDMETHOD.                    "collect_deferral_changed


  METHOD COLLECT_DEFERRAL_CREATED.
    DATA: ls_deferral_data TYPE farr_s_deferral_data,
          ls_deferral_key  TYPE farr_s_deferral_key.

    CALL METHOD io_deferral_obj->get_attributes
      IMPORTING
        es_attributes = ls_deferral_data.

    ls_deferral_data-pob_id       = iv_pob_id.
    ls_deferral_data-deferral_cat = if_farrc_contr_mgmt=>co_deferral_cat_rr.
    APPEND ls_deferral_data TO ct_deferral_add.

    io_deferral_obj->set_key( ls_deferral_key ).
  ENDMETHOD.                    "collect_deferral_created


  METHOD COLLECT_DEFERRAL_DELETED.
    DATA: ls_deferral_key            TYPE farr_s_deferral_key.

    CALL METHOD io_deferral_obj->get_key
      IMPORTING
        es_key = ls_deferral_key.

    APPEND ls_deferral_key TO ct_deferral_del.
  ENDMETHOD.                    "collect_deferral_deleted


  METHOD COLLECT_POB_CHANGED.
    DATA: lo_props_obj          TYPE REF TO if_genil_obj_attr_properties,
          lt_changed_attr       TYPE crmt_attr_name_tab,
          ls_pob_data           TYPE farr_s_pob_data,
          ls_pob_data_with_attr TYPE farr_s_pob_data_with_attr,
          ls_pob_key            TYPE farr_s_pob_key.

    lo_props_obj = io_pob_obj->get_attr_props_obj( ).
    CALL METHOD lo_props_obj->get_name_tab_4_property
      EXPORTING
        iv_property = if_genil_obj_attr_properties=>modified
      IMPORTING
        et_names    = lt_changed_attr.

    CALL METHOD io_pob_obj->get_attributes
      IMPORTING
        es_attributes = ls_pob_data.

    CALL METHOD io_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    ls_pob_data-pob_id = ls_pob_key-pob_id.
    MOVE-CORRESPONDING ls_pob_data  TO ls_pob_data_with_attr.
    APPEND LINES OF lt_changed_attr TO ls_pob_data_with_attr-tt_changed_attr.

    APPEND ls_pob_data_with_attr TO ct_pob_chg.
  ENDMETHOD.                    "collect_pob_changed


  METHOD COLLECT_POB_CREATED.
    DATA: ls_pob_data TYPE farr_s_pob_data,
          ls_pob_key  TYPE farr_s_pob_key,
          lo_contract TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_pob_obj->get_attributes
      IMPORTING
        es_attributes = ls_pob_data.

    lo_contract = get_contract( mv_contract_id ).

    ls_pob_data-pob_id = lo_contract->get_new_temp_pob_id( ).
    " note 2547273
    " POB created from UI starts with $$
    " never use first 2 numbers or BOL can't get the right object
    ls_pob_data-pob_id+0(2) = 00.
    APPEND ls_pob_data TO ct_pob_add.

    ls_pob_key-pob_id = ls_pob_data-pob_id.
    io_pob_obj->set_key( ls_pob_key ).
  ENDMETHOD.                    "collect_pob_created


  METHOD COLLECT_POB_DELETED.
    DATA: ls_pob_key            TYPE farr_s_pob_key.

    CALL METHOD io_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    APPEND ls_pob_key-pob_id TO ct_pob_del.
  ENDMETHOD.                    "collect_pob_deleted


  METHOD COMBINE_BACKEND_CALL.
    DATA: lt_contract_id         TYPE farr_tt_contract_key,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol.
    FIELD-SYMBOLS:
                   <ls_contract_id> TYPE farr_contract_id.

    CALL METHOD combine_collect_contract_id
      EXPORTING
        it_obj         = it_obj
      IMPORTING
        et_contract_id = lt_contract_id.
    TRY.
        lo_contract = get_contract( mv_contract_id ).
        CALL METHOD lo_contract->combine_contracts.

        CALL METHOD mo_contract_mgmt->save_to_db.

      CATCH cx_farr_message.
        cl_farr_db_update=>rollback_work( ).
    ENDTRY.
  ENDMETHOD.                    "reassign_execute


  METHOD COMBINE_CANCEL.
    FIELD-SYMBOLS: <ls_obj>     LIKE LINE OF ct_obj.
    DATA: ls_parameter          TYPE crmt_name_value_pair,
          lv_target_contract_id TYPE farr_contract_id,
          lv_target_description TYPE farr_description,
          ls_changed_object     TYPE crmt_genil_obj_instance,
          lv_obj_id             TYPE crmt_genil_object_id,
          lo_contract           TYPE REF TO if_farr_contract_mgmt_bol.

    CLEAR et_changed_objects.

    lo_contract = get_contract( mv_contract_id ).

    TRY.
        CALL METHOD lo_contract->combine_contract_unlock( ).
      CATCH cx_farr_message.
    ENDTRY.

    LOOP AT ct_obj ASSIGNING <ls_obj>.
      <ls_obj>-success = abap_true.
      CLEAR ls_changed_object.
      ls_changed_object-namespace   = <ls_obj>-namespace.
      ls_changed_object-object_name = <ls_obj>-object_name.
      ls_changed_object-object_id   = <ls_obj>-object_id.
*      APPEND ls_changed_object TO et_changed_objects.
    ENDLOOP.

    CALL METHOD cl_crm_genil_container_tools=>build_object_id
      EXPORTING
        is_object_key = lv_target_contract_id
      RECEIVING
        rv_result     = lv_obj_id.
    ls_changed_object-object_id = lv_obj_id.
    APPEND ls_changed_object TO et_changed_objects.

  ENDMETHOD.                    "reassign_execute


  METHOD COMBINE_COLLECT_CONTRACT_ID.
    DATA: ls_contract_key   TYPE farr_s_contract_key.
    FIELD-SYMBOLS:
          <ls_obj>          TYPE crmt_genil_obj_inst_line.

    CLEAR et_contract_id.
    LOOP AT it_obj ASSIGNING <ls_obj>.
      CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
        EXPORTING
          iv_object_name = <ls_obj>-object_name
          iv_object_id   = <ls_obj>-object_id
        IMPORTING
          es_key         = ls_contract_key.

      APPEND ls_contract_key TO et_contract_id.
    ENDLOOP.

  ENDMETHOD.                    "reassign_collect_pob_id


  METHOD COMBINE_LOAD_AND_CHECK.
    FIELD-SYMBOLS: <ls_obj>       LIKE LINE OF ct_obj,
                   <ls_parameter> TYPE crmt_name_value_pair.
    DATA: lv_target_contract_id TYPE farr_contract_id,
          lv_target_description TYPE farr_description,
          ls_changed_object     TYPE crmt_genil_obj_instance,
          lv_obj_id             TYPE crmt_genil_object_id,
          lv_change_mode        TYPE farr_change_mode_external,
          lv_validity_date      TYPE farr_validity_date.

    CLEAR et_changed_objects.
    LOOP AT it_parameter ASSIGNING <ls_parameter>.
      CASE <ls_parameter>-name.
        WHEN if_farrc_contr_mgmt=>co_an_contract_id.
          lv_target_contract_id = <ls_parameter>-value.
        WHEN if_farrc_contr_mgmt=>co_an_description.
          lv_target_description = <ls_parameter>-value.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    " remove deprecated contract instance
    TRY .
        mo_contract_mgmt->remove_instance_for_bol(
          EXPORTING
            iv_contract_id      = mv_contract_id
            iv_is_temp_contract = abap_false
      ).
      CATCH cx_farr_message.
        " if not existed in the container, ignore
    ENDTRY.
    CLEAR mv_contract_id.

    combine_load_check_call(
      it_obj                = ct_obj
      iv_target_contract_id = lv_target_contract_id
      iv_target_description = lv_target_description
      io_msg_service_access = io_msg_service_access
      iv_validity_date      = lv_validity_date
      iv_change_mode        = lv_change_mode
    ).

    LOOP AT ct_obj ASSIGNING <ls_obj>.
      <ls_obj>-success = abap_true.
      CLEAR ls_changed_object.
      ls_changed_object-namespace   = <ls_obj>-namespace.
      ls_changed_object-object_name = <ls_obj>-object_name.
      ls_changed_object-object_id   = <ls_obj>-object_id.
*      APPEND ls_changed_object TO et_changed_objects.
    ENDLOOP.

    CALL METHOD cl_crm_genil_container_tools=>build_object_id
      EXPORTING
        is_object_key = lv_target_contract_id
      RECEIVING
        rv_result     = lv_obj_id.
    ls_changed_object-object_id = lv_obj_id.
    APPEND ls_changed_object TO et_changed_objects.

  ENDMETHOD.                    "reassign_execute


  METHOD COMBINE_LOAD_CHECK_CALL.

    DATA: lt_contract_id                TYPE farr_tt_contract_key,
          ls_contract_data_buffer       TYPE farr_s_contract_data_buffer,
          lt_pob_data_buffer            TYPE farr_tt_pob_data_buffer,
          lt_cond_type_buffer           TYPE farr_tt_cond_type_buffer,
          lt_invoiced_pob               TYPE farr_tt_invoiced_pob,
          lt_inv_cond_type_buffer       TYPE farr_tt_inv_cond_type_buffer,
          lt_org_cond_type_buffer       TYPE farr_tt_cond_type_buffer,
          lt_stored_cond_type_data      TYPE farr_tt_cond_type_data,
          lt_cond_type_finalize         TYPE farr_tt_cond_type_buffer,
          lt_diff_cond_type_data        TYPE farr_tt_cond_type_data,
          lt_def_item_data_buffer       TYPE farr_tt_defitem_data_buffer,
          lt_deferral_data_buffer       TYPE farr_tt_deferral_data_buffer,
          lt_fulfill_data_buffer        TYPE farr_tt_fulfill_data_buffer,
          lt_fulfill_data_old           TYPE farr_tt_fulfill_data_buffer,
          lt_chg_type_buffer            TYPE farr_tt_chg_type_buffer,
          lt_accum_contr_data_buffer    TYPE farr_tt_contract_data_buffer,
          lt_accum_pob_data_buffer      TYPE farr_tt_pob_data_buffer,
          lt_accum_cond_type_buffer     TYPE farr_tt_cond_type_buffer,
          lt_accum_invoiced_pob         TYPE farr_tt_invoiced_pob,
          lt_accum_inv_cond_type_buffer TYPE farr_tt_inv_cond_type_buffer,
          lt_accum_org_cond_type_buffer TYPE farr_tt_cond_type_buffer,
          lt_accum_stored_cond_type_data TYPE farr_tt_cond_type_data,
          lt_accum_cond_type_finalize   TYPE farr_tt_cond_type_buffer,
          lt_accum_diff_cond_type_data  TYPE farr_tt_cond_type_data,
          lt_accum_def_item_data_buffer TYPE farr_tt_defitem_data_buffer,
          lt_accum_deferral_data_buffer TYPE farr_tt_deferral_data_buffer,
          lt_accum_fulfill_data_buffer  TYPE farr_tt_fulfill_data_buffer,
          lt_accum_fulfill_data_old     TYPE farr_tt_fulfill_data_buffer,
          lt_accum_chg_type_buffer      TYPE farr_tt_chg_type_buffer,
          lx_farr_message               TYPE REF TO cx_farr_message,
          lo_msg_cont                   TYPE REF TO cl_crm_genil_global_mess_cont,
          lo_msg_t100                   TYPE REF TO cl_farr_message_handler,
          lo_contract                   TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_contract_id>      TYPE farr_s_contract_key.


* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    CALL METHOD combine_collect_contract_id
      EXPORTING
        it_obj         = it_obj
      IMPORTING
        et_contract_id = lt_contract_id.

    APPEND INITIAL LINE TO lt_contract_id ASSIGNING <ls_contract_id>. "so that all locks performed within a loop, and target is the last line
    <ls_contract_id>-contract_id = iv_target_contract_id.

* step 1: prepare data
    LOOP AT lt_contract_id ASSIGNING <ls_contract_id>.
      TRY .
          " lock before use
          cl_farr_contract_utility=>lock_contract_exclusive( <ls_contract_id>-contract_id ).

          lo_contract = get_contract( <ls_contract_id>-contract_id ).

          lo_contract->load_contract( ).  "data loading into contract mgmt instance
          mv_contract_id = <ls_contract_id>-contract_id.

          " the original logic will check both display and change authority, keep them in the new codes
          lo_contract->check_authority( if_farrc_contr_mgmt=>co_auth_activity_display ).
          lo_contract->check_authority( if_farrc_contr_mgmt=>co_auth_activity_change ).
        CATCH cx_farr_message INTO lx_farr_message.
          " call again in case exception thrown
          " it is safe to use mv_contract_id, for
          " 1. if the exception is raised by LOCK, the mv_contract_id represent the last success contract
          " 2. if the exception is raised by load or authority check, the mv_contract_id either represent the last success contract
          "    or is the newly working contract
          lo_contract = get_contract( mv_contract_id ).

          lo_msg_t100 = lo_contract->get_msg_handler( ).
          lo_msg_t100->add_symessage(
          EXPORTING
            iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
            iv_ctx_value = <ls_contract_id>-contract_id
        ).

          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

          "unlock the already locked contracts
          TRY.
              CALL METHOD lo_contract->combine_contract_unlock( lt_contract_id ).
            CATCH cx_farr_message.
          ENDTRY.

          RETURN.
      ENDTRY.

      IF <ls_contract_id>-contract_id  = iv_target_contract_id.
* combine data here, so that when warning occurs in later, don't need to reload and recombine
        TRY.
            lo_contract->combine_data_to_target( EXPORTING iv_target_description          = iv_target_description
                                                                it_pob_data_buffer             = lt_accum_pob_data_buffer
                                                                it_cond_type_buffer            = lt_accum_cond_type_buffer
                                                                it_invoiced_pob                = lt_accum_invoiced_pob
                                                                it_inv_cond_type_buffer        = lt_accum_inv_cond_type_buffer
                                                                it_org_cond_type_buffer        = lt_accum_org_cond_type_buffer
                                                                it_stored_cond_type_data       = lt_accum_stored_cond_type_data
                                                                it_cond_type_finalize          = lt_accum_cond_type_finalize
                                                                it_diff_cond_type_data         = lt_accum_diff_cond_type_data
                                                                it_def_item_data_buffer        = lt_accum_def_item_data_buffer
                                                                it_deferral_data_buffer        = lt_accum_deferral_data_buffer
                                                                it_fulfill_data_buffer         = lt_accum_fulfill_data_buffer
                                                                it_fulfill_data_old            = lt_accum_fulfill_data_old
                                                                it_chg_type_buffer             = lt_accum_chg_type_buffer
                                                                it_contract_data_buffer        = lt_accum_contr_data_buffer
                                                                iv_validity_date               = iv_validity_date
                                                                iv_change_mode                 = iv_change_mode
                                                                ).
          CATCH cx_farr_message.

            lo_msg_t100 = lo_contract->get_msg_handler( ).
            lo_msg_t100->add_symessage(
            EXPORTING
              iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
              iv_ctx_value = <ls_contract_id>-contract_id
          ).

            convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

            "unlock the already locked contracts
            TRY.
                CALL METHOD lo_contract->combine_contract_unlock( lt_contract_id ).
              CATCH cx_farr_message.
            ENDTRY.

            RETURN.
        ENDTRY.

      ELSE.
        lo_contract->combine_get_source_contr_data( IMPORTING es_contract_data_buffer  = ls_contract_data_buffer  "get all source data
                                                                   et_pob_data_buffer       = lt_pob_data_buffer
                                                                   et_cond_type_buffer      = lt_cond_type_buffer
                                                                   et_invoiced_pob          = lt_invoiced_pob
                                                                   et_inv_cond_type_buffer  = lt_inv_cond_type_buffer
                                                                   et_org_cond_type_buffer  = lt_org_cond_type_buffer
                                                                   et_stored_cond_type_data = lt_stored_cond_type_data
                                                                   et_cond_type_finalize    = lt_cond_type_finalize
                                                                   et_diff_cond_type_data   = lt_diff_cond_type_data
                                                                   et_def_item_data_buffer  = lt_def_item_data_buffer
                                                                   et_deferral_data_buffer  = lt_deferral_data_buffer
                                                                   et_fulfill_data_buffer   = lt_fulfill_data_buffer
                                                                   et_fulfill_data_old      = lt_fulfill_data_buffer
                                                                   et_chg_type_buffer       = lt_chg_type_buffer
                                                                   ).
        APPEND ls_contract_data_buffer           TO lt_accum_contr_data_buffer.
        APPEND LINES OF lt_pob_data_buffer       TO lt_accum_pob_data_buffer.
        APPEND LINES OF lt_cond_type_buffer      TO lt_accum_cond_type_buffer.
        APPEND LINES OF lt_invoiced_pob          TO lt_accum_invoiced_pob.
        APPEND LINES OF lt_inv_cond_type_buffer  TO lt_accum_inv_cond_type_buffer.
        APPEND LINES OF lt_org_cond_type_buffer  TO lt_accum_org_cond_type_buffer.
        APPEND LINES OF lt_def_item_data_buffer  TO lt_accum_def_item_data_buffer.
        APPEND LINES OF lt_deferral_data_buffer  TO lt_accum_deferral_data_buffer.
        APPEND LINES OF lt_fulfill_data_buffer   TO lt_accum_fulfill_data_buffer.
        APPEND LINES OF lt_fulfill_data_old      TO lt_accum_fulfill_data_old.
        APPEND LINES OF lt_stored_cond_type_data TO lt_accum_stored_cond_type_data.
        APPEND LINES OF lt_cond_type_finalize    TO lt_accum_cond_type_finalize.
        APPEND LINES OF lt_diff_cond_type_data   TO lt_accum_diff_cond_type_data.
        APPEND LINES OF lt_chg_type_buffer       TO lt_accum_chg_type_buffer.
      ENDIF.
    ENDLOOP.

* step 2: perform combine check; mo_contract_mgmt is the instance of target now
    lo_contract->combine_perform_check( EXPORTING it_contract_data_buffer   = lt_accum_contr_data_buffer ).

  ENDMETHOD.                    "combine_load_check_call


  METHOD COMBINE_PERFORM.
    FIELD-SYMBOLS: <ls_obj>     LIKE LINE OF ct_obj.
    DATA: ls_parameter          TYPE crmt_name_value_pair,
          lv_target_contract_id TYPE farr_contract_id,
          lv_target_description TYPE farr_description,
          ls_changed_object     TYPE crmt_genil_obj_instance,
          lv_obj_id             TYPE crmt_genil_object_id.

    CLEAR et_changed_objects.
    LOOP AT it_parameter INTO ls_parameter.
      CASE ls_parameter-name.
        WHEN if_farrc_contr_mgmt=>co_an_contract_id.
          lv_target_contract_id = ls_parameter-value.
        WHEN if_farrc_contr_mgmt=>co_an_description.
          lv_target_description = ls_parameter-value.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

    combine_backend_call(
      it_obj                = ct_obj
      iv_target_contract_id = lv_target_contract_id
      iv_target_description = lv_target_description
    ).

    LOOP AT ct_obj ASSIGNING <ls_obj>.
      <ls_obj>-success = abap_true.
      CLEAR ls_changed_object.
      ls_changed_object-namespace   = <ls_obj>-namespace.
      ls_changed_object-object_name = <ls_obj>-object_name.
      ls_changed_object-object_id   = <ls_obj>-object_id.
*      APPEND ls_changed_object TO et_changed_objects.
    ENDLOOP.

    CALL METHOD cl_crm_genil_container_tools=>build_object_id
      EXPORTING
        is_object_key = lv_target_contract_id
      RECEIVING
        rv_result     = lv_obj_id.
    ls_changed_object-object_id = lv_obj_id.
    APPEND ls_changed_object TO et_changed_objects.

  ENDMETHOD.                    "reassign_execute


  METHOD COMBINE_POB.

    DATA: lt_pob_id           TYPE farr_tt_pob_id,
          ls_changed_object   TYPE crmt_genil_obj_instance,
          lv_obj_id           TYPE crmt_genil_object_id,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.
    FIELD-SYMBOLS:
          <ls_obj>           TYPE crmt_genil_obj_inst_line.

    reassign_collect_pob_id( EXPORTING it_pob_obj = ct_obj
                             IMPORTING et_pob_id = lt_pob_id ).

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_contract_for_bol->combine_pob( EXPORTING it_pob_id = lt_pob_id ).

    LOOP AT ct_obj ASSIGNING <ls_obj>.
      <ls_obj>-success = abap_true.
      CLEAR ls_changed_object.
      ls_changed_object-namespace   = <ls_obj>-namespace.
      ls_changed_object-object_name = <ls_obj>-object_name.
      ls_changed_object-object_id   = <ls_obj>-object_id.
      APPEND ls_changed_object TO et_changed_objects.
    ENDLOOP.

  ENDMETHOD.                    "combine_pob


  METHOD CONSTRUCTOR.
    CALL METHOD super->constructor
      EXPORTING
        iv_mode           = iv_mode
        iv_component_name = iv_component_name.

    init( ).
  ENDMETHOD.                    "constructor


  METHOD CONVERT_MSG_FROM_T100_TO_BAPI.
    DATA: lo_msg_t100 TYPE REF TO cl_farr_message_handler,
          lt_msg_t100 TYPE farr_tt_t100_msg,
          lt_msg_bapi TYPE bapiret2_t,
          lo_contract TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_msg_t100> TYPE farr_s_t100_msg,
          <ls_msg_bapi> TYPE bapiret2.

    lo_msg_t100 = cl_farr_message_handler=>get_instance( ).
    IF lx_farr_message IS BOUND.

      CALL METHOD lo_msg_t100->add_exception_msg
        EXPORTING
          ix_exception = lx_farr_message
          iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_global.

    ENDIF.

    TRY .
        CALL METHOD lo_msg_t100->get_all_msgs
          IMPORTING
            ett_farr_msg = lt_msg_t100.
      CATCH cx_farr_message.

    ENDTRY.

    LOOP AT lt_msg_t100 ASSIGNING <ls_msg_t100>.
      APPEND INITIAL LINE TO lt_msg_bapi ASSIGNING <ls_msg_bapi>.
      <ls_msg_bapi>-type       = <ls_msg_t100>-msgty.
      <ls_msg_bapi>-id         = <ls_msg_t100>-msgid.
      <ls_msg_bapi>-number     = <ls_msg_t100>-msgno.
      <ls_msg_bapi>-message_v1 = <ls_msg_t100>-msgv1.
      <ls_msg_bapi>-message_v2 = <ls_msg_t100>-msgv2.
      <ls_msg_bapi>-message_v3 = <ls_msg_t100>-msgv3.
      <ls_msg_bapi>-message_v4 = <ls_msg_t100>-msgv4.
    ENDLOOP.

    io_msg_container->add_bapi_messages(
      it_bapi_messages = lt_msg_bapi
      iv_show_only_once = abap_false
      ).
  ENDMETHOD.                    "convert_msg_from_t100_to_bapi


  METHOD CONVERT_SEL_INTO_SEARCH_TABLE.
    DATA:
      lt_search_criteria          TYPE rsdsfrange_t_ssel,
      ls_search_criteria          TYPE rsdsfrange_s_ssel,
      ls_rsdsselopt               TYPE rsdsselopt,
      lv_len                      TYPE i,
      lo_contract_type_desc       TYPE REF TO cl_abap_structdescr,
      lo_pob_type_desc            TYPE REF TO cl_abap_structdescr,
      lt_contract_field_list      TYPE ddfields,
      lt_pob_field_list           TYPE ddfields,
      lo_items                    TYPE REF TO cl_abap_typedescr,
      lo_structdescr              TYPE REF TO cl_abap_structdescr,
      lt_ci_fieldlist             TYPE ddfields.

    CONSTANTS:
      c_con                       TYPE string VALUE 'CON_',
      c_pob                       TYPE string VALUE 'POB_'.

    FIELD-SYMBOLS:
        <ls_search_criteria> TYPE rsdsfrange_s_ssel,
        <ls_selopt>          TYPE rsdsselopt.

    lt_search_criteria[] = it_sel_criteria[].

* Build search criteria for multiple company code
    READ TABLE lt_search_criteria INTO ls_search_criteria WITH KEY fieldname = if_farrc_contr_mgmt=>co_an_multi_company_code. "#EC CI_STDSEQ
    IF sy-subrc = 0.
      READ TABLE ls_search_criteria-selopt_t INTO ls_rsdsselopt INDEX 1.
      IF sy-subrc = 0.
        APPEND INITIAL LINE TO it_search_criteria_contract ASSIGNING <ls_search_criteria>.
        <ls_search_criteria>-fieldname = if_farrc_contr_mgmt=>co_an_contract_id.
        APPEND INITIAL LINE TO <ls_search_criteria>-selopt_t ASSIGNING <ls_selopt>.
        IF ls_rsdsselopt-low      = abap_true.
          <ls_selopt>-option = if_farrc_contr_mgmt=>co_criteria_option_equal.
        ELSE.
          <ls_selopt>-option = if_farrc_contr_mgmt=>co_criteria_option_not_equal.
        ENDIF.
        <ls_selopt>-sign     = if_farrc_contr_mgmt=>co_criteria_include_sign.
      ENDIF.

      DELETE lt_search_criteria WHERE fieldname = if_farrc_contr_mgmt=>co_an_multi_company_code. "#EC CI_STDSEQ
    ENDIF.

    lo_contract_type_desc ?= cl_abap_typedescr=>describe_by_name( 'FARR_D_CONTRACT' ).
    lo_pob_type_desc ?= cl_abap_typedescr=>describe_by_name( 'FARR_D_POB' ).
    lt_contract_field_list = lo_contract_type_desc->get_ddic_field_list(
*        p_langu                  = sy-langu
         p_including_substructres = abap_true
     ).
    lt_pob_field_list = lo_pob_type_desc->get_ddic_field_list(
*        p_langu                  = sy-langu
         p_including_substructres = abap_true
     ).

    SORT lt_contract_field_list BY fieldname.
    SORT lt_pob_field_list BY fieldname.

*--------------------------------------------------------------------*
*   Get customer strcuture and field list
*--------------------------------------------------------------------*
    CALL METHOD cl_abap_structdescr=>describe_by_name
      EXPORTING
        p_name         = 'INCL_EEW_FARR_POB'   " Type name
      RECEIVING
        p_descr_ref    = lo_items     " Reference to description object
      EXCEPTIONS
        type_not_found = 1
        OTHERS         = 2.
    IF sy-subrc EQ 0.
      lo_structdescr  ?= lo_items.
      lt_ci_fieldlist = lo_structdescr->get_ddic_field_list( ).
    ENDIF.

* build search criteria
    LOOP AT lt_search_criteria INTO ls_search_criteria.

      " mapping selection criteria into API separatively
      CASE ls_search_criteria-fieldname(4).
        WHEN c_con.
          lv_len = strlen( ls_search_criteria-fieldname ).
          lv_len = lv_len - 4.
          ls_search_criteria-fieldname = ls_search_criteria-fieldname+4(lv_len).
          APPEND ls_search_criteria TO it_search_criteria_contract[].
          CONTINUE.
        WHEN c_pob.
          lv_len = strlen( ls_search_criteria-fieldname ).
          lv_len = lv_len - 4.
          ls_search_criteria-fieldname = ls_search_criteria-fieldname+4(lv_len).
          APPEND ls_search_criteria TO it_search_criteria_pob[].
          CONTINUE.
        WHEN OTHERS.
      ENDCASE.

      CASE ls_search_criteria-fieldname.
        WHEN if_farrc_contr_mgmt=>co_an_pob_id            OR if_farrc_contr_mgmt=>co_an_pob_name    OR if_farrc_contr_mgmt=>co_an_final_invoice     OR
             if_farrc_contr_mgmt=>co_an_rev_rec_block     OR if_farrc_contr_mgmt=>co_an_customer_id OR if_farrc_contr_mgmt=>co_an_function_area     OR
             if_farrc_contr_mgmt=>co_an_business_area     OR if_farrc_contr_mgmt=>co_an_segment     OR if_farrc_contr_mgmt=>co_an_profit_center .
          APPEND ls_search_criteria TO it_search_criteria_pob[].
          CONTINUE.

        WHEN if_farrc_contr_mgmt=>co_an_header_id   OR  if_farrc_contr_mgmt=>co_an_srcdoc_comp  OR  if_farrc_contr_mgmt=>co_an_srcdoc_logsys
          OR if_farrc_contr_mgmt=>co_an_reference_type OR if_farrc_contr_mgmt=>co_an_reference_id.
          APPEND ls_search_criteria TO it_search_criteria_mapping[].
          CONTINUE.
        WHEN OTHERS.
      ENDCASE.

      READ TABLE lt_contract_field_list TRANSPORTING NO FIELDS
        WITH KEY fieldname = ls_search_criteria-fieldname.
      IF sy-subrc EQ 0.
        APPEND ls_search_criteria TO it_search_criteria_contract[].
        CONTINUE.
      ENDIF.

      READ TABLE lt_pob_field_list TRANSPORTING NO FIELDS
        WITH KEY fieldname = ls_search_criteria-fieldname.
      IF sy-subrc EQ 0.
        APPEND ls_search_criteria TO it_search_criteria_pob[].
        CONTINUE.
      ENDIF.

      READ TABLE lt_ci_fieldlist TRANSPORTING NO FIELDS
        WITH KEY fieldname = ls_search_criteria-fieldname.
      IF sy-subrc EQ 0.
        APPEND ls_search_criteria TO it_search_criteria_pob[].
        CONTINUE.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.                    "convert_sel_into_search_table


  METHOD CONVERT_SEL_PARAM.
    DATA: ls_sel_criteria     TYPE rsdsfrange_s_ssel,
          ls_sel_option       TYPE rsdsselopt.
    FIELD-SYMBOLS:
          <ls_sel_param>      TYPE genilt_selection_parameter,
          <ls_sel_criteria>   TYPE rsdsfrange_s_ssel.

    CLEAR et_sel_criteria.

    LOOP AT it_sel_param ASSIGNING <ls_sel_param>.
      MOVE-CORRESPONDING <ls_sel_param> TO ls_sel_option.

      READ TABLE et_sel_criteria
           ASSIGNING <ls_sel_criteria>
           WITH KEY fieldname = <ls_sel_param>-attr_name.
      IF sy-subrc = 0.
* Exist, append the selection option
        APPEND ls_sel_option   TO <ls_sel_criteria>-selopt_t.
      ELSE.
* Does not exist, create a new entry
        CLEAR ls_sel_criteria.    " clear previous data firstly!
        ls_sel_criteria-fieldname = <ls_sel_param>-attr_name.
        APPEND ls_sel_option   TO ls_sel_criteria-selopt_t.

        APPEND ls_sel_criteria TO et_sel_criteria.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "convert_sel_param


  METHOD CREATE_CONTRACT.
    DATA: ls_contract_key   TYPE farr_s_contract_key,
          lo_root_object    TYPE REF TO if_genil_cont_root_object,
          ls_contract_data  TYPE farr_s_contract_data.
    FIELD-SYMBOLS:
          <ls_param>        TYPE crmt_name_value_pair.

    CLEAR ls_contract_key-contract_id. "no contract ID for new contract at first

    READ TABLE it_parameters ASSIGNING <ls_param>
         WITH KEY name = 'CONTR_IDX'.
    IF sy-subrc = 0.
      mv_last_temp_contr_idx = <ls_param>-value.
      ls_contract_key-contract_id = mv_last_temp_contr_idx. "use idx as the temp id for entity creation
    ENDIF.

* Add the object to root list
    lo_root_object = io_root_list->add_object(
        iv_object_name = if_farrc_contr_mgmt=>co_on_contract
        is_object_key  = ls_contract_key
        iv_attr_req    = abap_false
        iv_key_is_id   = abap_false
        ).

*    READ TABLE it_parameters ASSIGNING <ls_param>
*         WITH KEY name = if_farrc_contr_mgmt=>co_an_description.
*    IF sy-subrc = 0.
*      ls_contract_data-description = <ls_param>-value.
*    ENDIF.

    lo_root_object->set_attributes( ls_contract_data ).


  ENDMETHOD.                    "CREATE_CONTRACT


  METHOD CREATE_MANUAL_POB.
    DATA: lo_checker          TYPE REF TO cl_farr_contract_checker,
          lo_msg_cont         TYPE REF TO cl_crm_genil_global_mess_cont,
          lx_crm_error        TYPE REF TO cx_crm_genil_general_error,
          lo_contract_mgmt    TYPE REF TO if_farr_contract_mgmt,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj> TYPE crmt_genil_obj_inst_line.

    LOOP AT ct_object_list ASSIGNING <ls_obj>.
      "There is always only one line in 'CT_OBJECT_LIST'.
      lo_contract_for_bol = get_contract( mv_contract_id ).

      TRY.
          lo_contract_for_bol->set_manual_pob_creation_flag( ).

          <ls_obj>-success = abap_true.

        CATCH cx_farr_message.
          lo_msg_cont = io_rootlist->get_global_message_container( ).
          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
          CREATE OBJECT lx_crm_error.
          RAISE EXCEPTION lx_crm_error.

      ENDTRY.

    ENDLOOP.

  ENDMETHOD.                    "execute_bol_method_pob


  METHOD DELETE_MANUAL_CHANGE_VALUE.

    DATA: lv_contract_id      TYPE farr_contract_id.

    FIELD-SYMBOLS:
          <ls_obj>            TYPE crmt_genil_obj_inst_line,
          <ls_param>          TYPE crmt_name_value_pair.
    "Comment temperoray,
*  LOOP AT it_parameters ASSIGNING <ls_param>.
*    IF <ls_param>-name = if_farrc_contr_mgmt=>co_an_contract_id.
*      lv_contract_id = <ls_param>-value.
*    ENDIF.
*  ENDLOOP.
*
*  CHECK lv_contract_id IS NOT INITIAL.
*
*  TRY .
*      CALL METHOD mo_conflict_mgmt->delete_manual_change
*        EXPORTING
*          iv_contract_id = lv_contract_id.
*
    LOOP AT ct_object_list ASSIGNING <ls_obj>.
      <ls_obj>-success = abap_true.
    ENDLOOP.

*    CATCH cx_farr_message.
*
*  ENDTRY.


  ENDMETHOD.                    "delete_manual_change_value


  METHOD DELETE_POB_CONVERT_PARAM.
**********************************************************************
*parameter's structure like below:
*name, value
*POBID, 302323
**********************************************************************
    FIELD-SYMBOLS:
          <ls_param>          TYPE crmt_name_value_pair,
          <lv_pob_id>         LIKE LINE OF et_pob_id.

    LOOP AT it_parameter ASSIGNING <ls_param>.
      APPEND INITIAL LINE TO et_pob_id ASSIGNING <lv_pob_id>.
      <lv_pob_id> = <ls_param>-value.
    ENDLOOP.
  ENDMETHOD.                    "delete_pob_convert_param


  METHOD DETERMINE_MAX_HITS.
    rv_max_hits = is_query_parameters-max_hits.
    IF rv_max_hits <= 0.
      rv_max_hits = if_farrc_contr_mgmt=>co_max_hits.
    ENDIF.
  ENDMETHOD.                    "determine_max_hits


  METHOD DETER_CONTRACT_MGMT_FOR_LOAD.
    DATA:
         lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol,
         lv_tmp_contract_index TYPE farr_contract_id,
         lv_empty_contract_id  TYPE farr_contract_id VALUE '00000000000000'.

    FIELD-SYMBOLS:
          <ls_reassign_handler> LIKE LINE OF mt_reassign_handler.

    IF mv_flg_reassign = abap_true.
      ro_contract = get_contract( mv_contract_id ).

      IF mv_use_idx_as_contr_id = abap_false.
        " existing contract
        " if not existed, add it
        READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
          WITH KEY contract_id = mv_contract_id.

        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO mt_reassign_handler ASSIGNING <ls_reassign_handler>.
          <ls_reassign_handler>-contract_id   = mv_contract_id.
        ENDIF.
      ELSE.
        " temp contract
        " if not existed, add it
        READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
          WITH KEY contract_id = lv_empty_contract_id
                   temp_contract_idx = mv_last_temp_contr_idx.

        IF sy-subrc <> 0.
          APPEND INITIAL LINE TO mt_reassign_handler ASSIGNING <ls_reassign_handler>.
          <ls_reassign_handler>-contract_id       = lv_empty_contract_id.
          <ls_reassign_handler>-temp_contract_idx = mv_last_temp_contr_idx.
        ENDIF.

      ENDIF.

    ELSE.
      " manual fulfillment and other normal cases

      "Register contract to contract_mgmt.
      ro_contract = get_contract( mv_contract_id ).
    ENDIF.

  ENDMETHOD.                    "load_contract


  METHOD DETER_CONTRACT_MGMT_FOR_LOCK.
    DATA: lv_instance_not_found  TYPE boolean,
          lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol,
          lv_tmp_contract_index  TYPE farr_contract_id.

    FIELD-SYMBOLS:
          <ls_obj>               TYPE crmt_genil_obj_inst_line,
          <ls_reassign_handler>  LIKE LINE OF mt_reassign_handler.

    IF mv_flg_reassign = abap_true.
      " only for manual combine reassign case

      " the following calls ensure the CONTACT instance contained in the contract management for further consumption
      IF mv_use_idx_as_contr_id = abap_false.
        " only those contracts without id will use index

        " contracts needs to be locked must have contract id, for they are concrete ones
        ro_contract = get_contract( mv_contract_id ).
      ELSE.
        " does not need to be locked, just assign a mock one
        CLEAR ro_contract.
      ENDIF.
    ELSE.
      "    manual fulfill multiple contracts case
      " OR others normal cases

      " the following statement has two meanings:
      " 1. add the contract into contract mgmt if the contract is not in contract mgmt
      " 2. get the contract if it has already in contract mgmt

      ro_contract = get_contract( mv_contract_id ).
    ENDIF.

  ENDMETHOD.                    "if_genil_appl_alternative_dsil~lock_objects


  METHOD EXECUTE_BOL_METHOD_CONTRACT.
    DATA:
          lx_crm_error         TYPE REF TO cx_crm_genil_model_error,
          lo_root_obj          TYPE REF TO if_genil_container_object,
          lo_msg_cont          TYPE REF TO cl_crm_genil_global_mess_cont,
          ls_contract_key      TYPE farr_s_contract_key,
          lx_root              TYPE REF TO cx_farr_message,
          lv_msg               TYPE text255,
          ls_changed_obj       LIKE LINE OF et_changed_objects,
          lo_contract_for_bol  TYPE REF TO if_farr_contract_mgmt_bol.
    DATA lo_contract TYPE REF TO if_genil_cont_root_object.

    FIELD-SYMBOLS:
          <ls_obj> TYPE crmt_genil_obj_inst_line.

    CLEAR et_changed_objects.

    IF io_msg_service_access IS BOUND.
      lo_msg_cont = io_msg_service_access->get_global_message_container( ).
      lo_msg_cont->reset( ).
    ENDIF.

    CASE iv_method_name.
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_clear_handler.
        CALL METHOD reassign_clear_handler.

* Peer Create Compound POB
      WHEN if_farrc_contr_mgmt=>co_mn_peer_create_compound_pob.

        lo_contract = io_rootlist->get_first( ).
        IF lo_contract IS BOUND.
          lo_contract->get_key( IMPORTING es_key = ls_contract_key ).
        ELSE.
          CLEAR ls_contract_key-contract_id.
        ENDIF.
        CALL METHOD peer_create_compound_pob
          EXPORTING
            it_parameter          = it_parameters
            iv_contract_id        = ls_contract_key-contract_id
            io_msg_service_access = io_msg_service_access.

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

* Reassign Peer Create Compound POB
      WHEN if_farrc_contr_mgmt=>co_mn_reass_peer_cre_comp_pob.

        lo_contract = io_rootlist->get_first( ).
        IF lo_contract IS BOUND.
          lo_contract->get_key( IMPORTING es_key = ls_contract_key ).
        ELSE.
          CLEAR ls_contract_key-contract_id.
        ENDIF.
        CALL METHOD reassign_peer_create_comp_pob
          EXPORTING
            it_parameter          = it_parameters
            iv_contract_id        = ls_contract_key-contract_id
            io_msg_service_access = io_msg_service_access.

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_combine_pob.
        combine_pob( CHANGING ct_obj = ct_object_list ).

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

* Refresh Contract
      WHEN if_farrc_contr_mgmt=>co_mn_refresh_contract.
        "note 2826118: mv_contract_id is not set when refresh target contract
        "after successful quick combination by select all contract or when
        "remark as reviewed on regular monitor
        IF ct_object_list IS NOT INITIAL.
          READ TABLE ct_object_list ASSIGNING <ls_obj> INDEX 1.
            IF <ls_obj>-object_name = if_farrc_contr_mgmt=>co_on_contract.
              CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
                EXPORTING
                  iv_object_name = <ls_obj>-object_name
                  iv_object_id   = <ls_obj>-object_id
                IMPORTING
                  es_key         = ls_contract_key.

              mv_contract_id = ls_contract_key-contract_id.
            ENDIF.
        ENDIF.

        refresh_contract( ).

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* Always collect msg from BOL to FPM
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

* Check Contract
      WHEN if_farrc_contr_mgmt=>co_mn_check_contract.

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          TRY .
              lo_contract_for_bol = get_contract( mv_contract_id ).
              lo_contract_for_bol->check_contract( ).
            CATCH cx_farr_message.
              <ls_obj>-success = abap_false.

* Always collect msg from BOL to FPM
              convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

              CREATE OBJECT lx_crm_error.
              RAISE EXCEPTION lx_crm_error.
          ENDTRY.

          <ls_obj>-success = abap_true.

        ENDLOOP.

* load data to target and then check the contract
      WHEN if_farrc_contr_mgmt=>co_mn_combine_load_check.
        CALL METHOD combine_load_and_check
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
          CHANGING
            ct_obj                = ct_object_list.
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

* check combine contract
      WHEN if_farrc_contr_mgmt=>co_mn_combine_contract.

        CALL METHOD combine_perform
          EXPORTING
            it_parameter       = it_parameters
          IMPORTING
            et_changed_objects = et_changed_objects
          CHANGING
            ct_obj             = ct_object_list.

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

* unlock combine contract
      WHEN if_farrc_contr_mgmt=>co_mn_combine_unlock.

        CALL METHOD combine_cancel
          EXPORTING
            it_parameter       = it_parameters
          IMPORTING
            et_changed_objects = et_changed_objects
          CHANGING
            ct_obj             = ct_object_list.

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

* reassignment determine source contract instance
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_determine_src.
        CALL METHOD reassign_determine_source
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* reassignment determine target contract instance
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_determine_trg.
        CALL METHOD reassign_determine_target
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* reassignment set flag 'use index as contract id' & 'index'
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_flg_set_use_idx.
        CALL METHOD reassign_set_use_idx
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* reassignment unlock contracts
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_unlock_contr.
        CALL METHOD reassign_unlock_contracts.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* reassignment remove from work area
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_remove_from_hdl.
        CALL METHOD reassign_remove_from_handler
          EXPORTING
            it_parameters         = it_parameters
            io_msg_service_access = io_msg_service_access.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* reassignment delete contract
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_delete_contract.
        CALL METHOD reassign_delete_contract
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

      WHEN if_farrc_contr_mgmt=>co_mn_fulfill_ma_set_flg.
        CALL METHOD set_manual_fulfill_flg.

      WHEN if_farrc_contr_mgmt=>co_mn_fulfill_ma_pobs_of_ctrt.
        fulfill_contracts(
          EXPORTING
            it_parameter          =    it_parameters
            io_rootlist           =    io_rootlist " Data Container - Root Object List Interface
            io_msg_service_access =    io_msg_service_access " Interface for Simple Access to Generic IL Message Service
          IMPORTING
            et_changed_objects    =    et_changed_objects " Table of Object Instances in Generic IL
          CHANGING
            ct_object_list        =    ct_object_list " Object Instance List
        ).
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_check_contra_manual_ful.

        CALL METHOD manual_fulfill_check_contra
          EXPORTING
            io_msg_service_access = io_msg_service_access
            it_parameter          = it_parameters
          IMPORTING
            et_changed_objects    = et_changed_objects
          CHANGING
            ct_obj                = ct_object_list.

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).


      WHEN if_farrc_contr_mgmt=>co_mn_set_new_allocated_amount.
        CALL METHOD set_new_allocated_amount
          EXPORTING
            it_parameters      = it_parameters
          IMPORTING
            et_changed_objects = et_changed_objects
          CHANGING
            ct_object_list     = ct_object_list. " Object Instance List.

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_lock_contract.
        lo_contract_for_bol = get_contract( mv_contract_id ).
        TRY .
          cl_farr_contract_utility=>lock_contract_exclusive( lo_contract_for_bol->get_contract_id( ) ).
        CATCH cx_farr_message.
          LOOP AT ct_object_list ASSIGNING <ls_obj>.
            <ls_obj>-success = abap_false.
          ENDLOOP.
        ENDTRY.

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* Always collect msg from BOL to FPM
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_unlock_contract.
        lo_contract_for_bol = get_contract( mv_contract_id ).
        cl_farr_contract_utility=>unlock_contract_exclusive( lo_contract_for_bol->get_contract_id( ) ).

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* Always collect msg from BOL to FPM
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_create_manual_pob.
        CALL METHOD create_manual_pob
          EXPORTING
            io_rootlist    = io_rootlist
          CHANGING
            ct_object_list = ct_object_list.
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_resolved_conflict.
        delete_manual_change_value(
          EXPORTING
            it_parameters         = it_parameters
          CHANGING
            ct_object_list        = ct_object_list ).
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_remove_pending_conflict.

        TRY .
            CALL METHOD remove_pending_conflict
              EXPORTING
                it_parameters = it_parameters.   " Parameter Table of Name-Value Pairs

            LOOP AT ct_object_list ASSIGNING <ls_obj>.
              <ls_obj>-success = abap_true.
            ENDLOOP.
            convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

          CATCH cx_farr_message.
            LOOP AT ct_object_list ASSIGNING <ls_obj>.
              <ls_obj>-success = abap_false.
            ENDLOOP.
* Always collect msg from BOL to FPM
            convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
            CREATE OBJECT lx_crm_error.
            RAISE EXCEPTION lx_crm_error.
        ENDTRY.

      WHEN if_farrc_contr_mgmt=>co_mn_delete_manl_chng_data.
        CALL METHOD remove_manual_change_data
          EXPORTING
            it_parameter = it_parameters.    " Parameter Table of Name-Value Pairs
*            io_msg_service_access =     " Interface for Simple Access to Generic IL Message Service
**          IMPORTING
**            et_changed_objects    =     " Table of Object Instances in Generic IL
*          CHANGING
*            ct_pob_obj            =     " Table of Object Instances
*          .

      WHEN if_farrc_contr_mgmt=>co_mn_reprocess_acct.
        CALL METHOD reprocess_acct_determination.

*        LOOP AT ct_object_list ASSIGNING <ls_obj>.
*          <ls_obj>-success = abap_true.
*        ENDLOOP.

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN 'FarrSetSaveWithError'.
        lo_contract_for_bol = get_contract( mv_contract_id ).
        lo_contract_for_bol->set_save_with_error( ).
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

* apply change type
      WHEN if_farrc_contr_mgmt=>co_mn_apply_change_type.
        apply_change_type(
          EXPORTING
            it_parameters    = it_parameters
        ).

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_pric_alloc_sys_deflt.
        lo_contract_for_bol = get_contract( mv_contract_id ).
        lo_contract_for_bol->set_pric_alloc_sys_deflt( ).

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
        ENDLOOP.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.                    "execute_bol_method_contract


  METHOD EXECUTE_BOL_METHOD_CONTRACT_2.
    DATA: lx_crm_error            TYPE REF TO cx_crm_genil_general_error,
          lo_root_obj             TYPE REF TO if_genil_container_object,
          ls_result               TYPE crmt_genil_data_ref_4_inst,
          lo_msg_cont             TYPE REF TO cl_crm_genil_global_mess_cont,
          lo_allocation_explainer TYPE REF TO cl_farr_allocation_explainer,
          ls_contract_key         TYPE farr_s_contract_key,
          lv_is_contract_changed  TYPE boole_d,
          lv_contract_id          TYPE farr_contract_id,
          lt_allocated_amount     TYPE farr_tt_allocated_amount,
          lt_calculate_amount     TYPE farr_tt_calculate_amount,
          ls_invoice_amount       TYPE farr_s_invoice_amount,
          lv_contract_changed     TYPE abap_bool,
          lt_pob_order_info       TYPE farr_tt_pob_order_info,
          lv_contract_archived    TYPE abap_bool,
          ls_parameters           TYPE crmt_name_value_pair,
          lv_load_success         TYPE abap_bool,
          lt_posted_pobs          TYPE farr_ts_pob_id,
          lv_pob_id               TYPE farr_pob_id,
          lv_cond_type            TYPE kscha,
          lt_contract_id          TYPE farr_tt_contract_id,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj>                TYPE crmt_genil_obj_inst_line,
          <lo_explainer>          TYPE REF TO cl_farr_allocation_explainer,
          <lv_changed>            TYPE boole_d,
          <lv_contract_id>        TYPE farr_contract_id,
          <lt_contract_id>        TYPE farr_tt_contract_id,
          <lv_pob_currency>       TYPE waers,
          <lt_allocated_amount>   TYPE farr_tt_allocated_amount,
          <lt_calculate_amount>   TYPE farr_tt_calculate_amount,
          <lv_contract_changed>   TYPE abap_bool,
          <lv_contract_archived>  TYPE abap_bool,
          <lt_posted_pobs>        TYPE farr_ts_pob_id,
          <lt_pob_order_info>     TYPE farr_tt_pob_order_info,
          <ls_invoice_amount>     TYPE farr_s_invoice_amount.

    CLEAR et_changed_objects.
    CLEAR et_result.

    IF io_msg_service_access IS BOUND.
      lo_msg_cont = io_msg_service_access->get_global_message_container( ).
      lo_msg_cont->reset( ).
    ENDIF.

    CASE iv_method_name.
      WHEN if_farrc_contr_mgmt=>co_mn_reassign_get_contr_id.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            CALL METHOD reassign_get_new_contract_id
              IMPORTING
                et_contract_id = lt_contract_id.

            CLEAR ls_result.
            CREATE DATA ls_result-data TYPE farr_tt_contract_id.
            ASSIGN ls_result-data->* TO <lt_contract_id>.
            <lt_contract_id> = lt_contract_id.
            "GET REFERENCE OF lv_contract_id INTO ls_result-data.
            ls_result-namespace       = <ls_obj>-namespace.
            ls_result-object_name     = <ls_obj>-object_name.
            ls_result-object_id       = <ls_obj>-object_id.
            INSERT ls_result INTO TABLE et_result.
** set to success
            <ls_obj>-success = abap_true.
          ENDIF.
        ENDLOOP.
      WHEN if_farrc_contr_mgmt=>co_mn_get_simulation_result.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            IF mv_flg_reassign = abap_true.
              start_reassign_simulation( EXPORTING io_msg_cont = lo_msg_cont
                                         IMPORTING eo_allocation_explainer = lo_allocation_explainer ).
** assign explainer to result->data
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE REF TO cl_farr_allocation_explainer.
              ASSIGN ls_result-data->* TO <lo_explainer>.
              <lo_explainer> = lo_allocation_explainer.

** append result to et_result
              ls_result-namespace   = <ls_obj>-namespace.
              ls_result-object_name = <ls_obj>-object_name.
              ls_result-object_id   = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.

** set to success
              <ls_obj>-success = abap_true.
            ELSE.
              IF load_contract_by_obj_id( <ls_obj> ) = abap_true.
** start simulation
                TRY .
                    lo_contract = get_contract( mv_contract_id ).

                    CALL METHOD start_simulation
                      EXPORTING
                        io_contract             = lo_contract
                      IMPORTING
                        eo_allocation_explainer = lo_allocation_explainer.
                  CATCH cx_farr_message.
                    convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
                    RETURN.
                ENDTRY.

** assign explainer to result->data
                CLEAR ls_result.
                CREATE DATA ls_result-data TYPE REF TO cl_farr_allocation_explainer.
                ASSIGN ls_result-data->* TO <lo_explainer>.
                <lo_explainer> = lo_allocation_explainer.

** append result to et_result
                ls_result-namespace   = <ls_obj>-namespace.
                ls_result-object_name = <ls_obj>-object_name.
                ls_result-object_id   = <ls_obj>-object_id.
                INSERT ls_result INTO TABLE et_result.

** set to success
                <ls_obj>-success = abap_true.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
** check if contract if changed
      WHEN if_farrc_contr_mgmt=>co_mn_is_contract_changed.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            IF load_contract_by_obj_id( <ls_obj> ) = abap_true.
              CALL METHOD is_contract_changed
                IMPORTING
                  ev_result = lv_is_contract_changed.

** append result to et_result
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE boole_d.
              ASSIGN ls_result-data->* TO <lv_changed>.
              <lv_changed> = lv_is_contract_changed.
              "GET REFERENCE OF lv_is_contract_changed INTO ls_result-data.
              ls_result-namespace       = <ls_obj>-namespace.
              ls_result-object_name     = <ls_obj>-object_name.
              ls_result-object_id       = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.
** set to success
              <ls_obj>-success = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.

** get posted POB IDs
      WHEN if_farrc_contr_mgmt=>co_mn_get_posted_pob.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            IF load_contract_by_obj_id( <ls_obj> ) = abap_true.
              CALL METHOD get_posted_pob
                IMPORTING
                  et_posted_pobs = lt_posted_pobs.

** append result to et_result
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE farr_ts_pob_id.
              ASSIGN ls_result-data->* TO <lt_posted_pobs>.
              <lt_posted_pobs> = lt_posted_pobs.
              "GET REFERENCE OF lv_is_contract_changed INTO ls_result-data.
              ls_result-namespace       = <ls_obj>-namespace.
              ls_result-object_name     = <ls_obj>-object_name.
              ls_result-object_id       = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.
** set to success
              <ls_obj>-success = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.

      WHEN if_farrc_contr_mgmt=>co_mn_get_allocated_amount.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            IF load_contract_by_obj_id( <ls_obj> ) = abap_true.
              CALL METHOD get_allocated_amount
                IMPORTING
                  et_result = lt_allocated_amount.

** append result to et_result
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE farr_tt_allocated_amount.
              ASSIGN ls_result-data->* TO <lt_allocated_amount>.
              <lt_allocated_amount> = lt_allocated_amount.
              "GET REFERENCE OF lv_is_contract_changed INTO ls_result-data.
              ls_result-namespace       = <ls_obj>-namespace.
              ls_result-object_name     = <ls_obj>-object_name.
              ls_result-object_id       = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.
** set to success
              <ls_obj>-success = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.

      WHEN if_farrc_contr_mgmt=>co_mn_get_calculate_amount.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            IF load_contract_by_obj_id( <ls_obj> ) = abap_true.
              TRY .
                  CALL METHOD get_calculate_amount
                    IMPORTING
                      et_result = lt_calculate_amount.
                CATCH cx_farr_message.
                  CREATE OBJECT lx_crm_error TYPE cx_crm_genil_general_error.
                  RAISE EXCEPTION lx_crm_error.
              ENDTRY.

** append result to et_result
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE farr_tt_calculate_amount.
              ASSIGN ls_result-data->* TO <lt_calculate_amount>.
              <lt_calculate_amount> = lt_calculate_amount.
              "GET REFERENCE OF lv_is_contract_changed INTO ls_result-data.
              ls_result-namespace       = <ls_obj>-namespace.
              ls_result-object_name     = <ls_obj>-object_name.
              ls_result-object_id       = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.
** set to success
              <ls_obj>-success = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.

      WHEN if_farrc_contr_mgmt=>co_mn_get_pob_order_info.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            IF load_contract_by_obj_id( <ls_obj> ) = abap_true.
              CALL METHOD get_pob_order_info
                IMPORTING
                  et_result = lt_pob_order_info.

** append result to et_result
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE farr_tt_pob_order_info.
              ASSIGN ls_result-data->* TO <lt_pob_order_info>.
              <lt_pob_order_info> = lt_pob_order_info.
              "GET REFERENCE OF lv_is_contract_changed INTO ls_result-data.
              ls_result-namespace       = <ls_obj>-namespace.
              ls_result-object_name     = <ls_obj>-object_name.
              ls_result-object_id       = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.
** set to success
              <ls_obj>-success = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN if_farrc_contr_mgmt=>co_mn_check_contract_changed.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            IF load_contract_by_obj_id( <ls_obj> ) = abap_true.
              CALL METHOD check_contract_changed
                IMPORTING
                  ev_contract_changed = lv_contract_changed.

** append result to et_result
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE abap_bool.
              ASSIGN ls_result-data->* TO <lv_contract_changed>.
              <lv_contract_changed> = lv_contract_changed.
              "GET REFERENCE OF lv_is_contract_changed INTO ls_result-data.
              ls_result-namespace       = <ls_obj>-namespace.
              ls_result-object_name     = <ls_obj>-object_name.
              ls_result-object_id       = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.
** set to success
              <ls_obj>-success = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN if_farrc_contr_mgmt=>co_mn_check_contract_archived.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.
            READ TABLE it_parameters INTO ls_parameters INDEX 1.
            IF sy-subrc = 0 AND ls_parameters-name = 'CONTRACT_ID'.
              lv_contract_id = ls_parameters-value.
              TRY.
                  lo_contract = get_contract( lv_contract_id ).
                  IF lv_contract_id <> mv_contract_id.
                    lo_contract->load_contract( abap_true ).
                    mv_contract_id = lv_contract_id.
                  ENDIF.

                  lv_load_success = abap_true.
                CATCH cx_farr_message.
              ENDTRY.
            ELSE.
              lv_load_success = load_contract_by_obj_id( <ls_obj> ).
            ENDIF.

            IF lv_load_success = abap_true.

              TRY.
                  lo_contract = get_contract( mv_contract_id ).

                  lo_contract->check_if_archived(
                    IMPORTING
                      ev_archived = lv_contract_archived
                  ).
                CATCH cx_farr_message.
                  " dummy
              ENDTRY.

** append result to et_result
              CLEAR ls_result.
              CREATE DATA ls_result-data TYPE abap_bool.
              ASSIGN ls_result-data->* TO <lv_contract_archived>.
              <lv_contract_archived> = lv_contract_archived.

              ls_result-namespace       = <ls_obj>-namespace.
              ls_result-object_name     = <ls_obj>-object_name.
              ls_result-object_id       = <ls_obj>-object_id.
              INSERT ls_result INTO TABLE et_result.
** set to success
              <ls_obj>-success = abap_true.
            ENDIF.
          ENDIF.
        ENDLOOP.
      WHEN OTHERS.
* Do nothing
    ENDCASE.

  ENDMETHOD.                    "EXECUTE_BOL_METHOD_CONTRACT_2


  METHOD EXECUTE_BOL_METHOD_POB.
    DATA  lo_msg_cont         TYPE REF TO cl_crm_genil_global_mess_cont.
    DATA  lv_check_result     TYPE boole_d.
    DATA  lx_crm_error        TYPE REF TO cx_crm_genil_model_error.
    DATA  lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj> TYPE crmt_genil_obj_inst_line.

    CLEAR et_changed_objects.

    IF io_msg_service_access IS BOUND.
      lo_msg_cont = io_msg_service_access->get_global_message_container( ).
      lo_msg_cont->reset( ).
    ENDIF.

    CASE iv_method_name.
      WHEN if_farrc_contr_mgmt=>co_mn_chk_create_addition_pob.
        CALL METHOD check_create_additional_pob
          EXPORTING
            io_rootlist    = io_rootlist
          CHANGING
            ct_object_list = ct_object_list.
      WHEN if_farrc_contr_mgmt=>co_mn_perform_reassign.
        reassign_perform(
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
          CHANGING
            ct_pob_obj            = ct_object_list

        ).

      WHEN if_farrc_contr_mgmt=>co_mn_perf_reassign_after_wa.
        reassign_perform_after_warning(
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access
          CHANGING
            ct_pob_obj            = ct_object_list
            ).

      WHEN if_farrc_contr_mgmt=>co_mn_reassign_set_ssp.
        set_ssp(
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access
          CHANGING
            ct_pob_obj            = ct_object_list
            ).

      WHEN if_farrc_contr_mgmt=>co_mn_hrchy_set_ssp.
        set_ssp(
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access
          CHANGING
            ct_pob_obj            = ct_object_list
            ).

      WHEN if_farrc_contr_mgmt=>co_mn_check_manual_fulfill.

        CALL METHOD manual_fulfill_check
          EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
          CHANGING
            ct_pob_obj            = ct_object_list.
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

      WHEN if_farrc_contr_mgmt=>co_mn_manual_fulfill_pob.

        check_authority(
          EXPORTING
            iv_method_name        = if_farrc_contr_mgmt=>co_mn_manual_fulfill_pob
            io_msg_service_access = io_msg_service_access
          IMPORTING
            ev_check_result       = lv_check_result
        ).

        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

        IF lv_check_result = abap_true.
          manual_fulfill_pob(
           EXPORTING
              it_parameter          = it_parameters
              io_msg_service_access = io_msg_service_access
           IMPORTING
             et_changed_objects     = et_changed_objects
            CHANGING
              ct_pob_obj            = ct_object_list
           ).
        ENDIF.

      WHEN if_farrc_contr_mgmt=>co_mn_simulate_fulfill_pob.
        simulate_fulfill_pob(
         EXPORTING
            it_parameter          = it_parameters
            io_msg_service_access = io_msg_service_access
         IMPORTING
           et_changed_objects     = et_changed_objects
          CHANGING
            ct_pob_obj            = ct_object_list
        ).

      WHEN if_farrc_contr_mgmt=>co_mn_set_spd_to_sys_default.

        TRY.
            CALL METHOD set_spreading_to_sys_default
              EXPORTING
                it_parameter          = it_parameters
                io_msg_service_access = io_msg_service_access
              IMPORTING
                et_changed_objects    = et_changed_objects
              CHANGING
                ct_pob_obj            = ct_object_list.

          CATCH cx_farr_message.
            <ls_obj>-success = abap_false.
* Always collect msg from BOL to FPM
            convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
            CREATE OBJECT lx_crm_error.
            RAISE EXCEPTION lx_crm_error.
        ENDTRY.

      WHEN if_farrc_contr_mgmt=>co_mn_change_distinct_type.
        change_distinct_type(
          EXPORTING
            it_parameter          = it_parameters
            iv_rootlist           = io_rootlist
            io_msg_service_access = io_msg_service_access
          CHANGING
            ct_pob_obj            = ct_object_list
          ).

      WHEN if_farrc_contr_mgmt=>co_mn_combine_pob.
        combine_pob(
         IMPORTING
           et_changed_objects     = et_changed_objects
          CHANGING ct_obj = ct_object_list
          ).

      WHEN if_farrc_contr_mgmt=>co_mn_split_pob.
        split_pob(
         IMPORTING
           et_changed_objects     = et_changed_objects
          CHANGING ct_obj = ct_object_list ).
*     check contract
      WHEN if_farrc_contr_mgmt=>co_mn_check_contract.

        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          TRY .
              lo_contract_for_bol = get_contract( mv_contract_id ).
              lo_contract_for_bol->check_contract( ).
            CATCH cx_farr_message.
              <ls_obj>-success = abap_false.
* Always collect msg from BOL to FPM
              convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
              CREATE OBJECT lx_crm_error.
              RAISE EXCEPTION lx_crm_error.
          ENDTRY.

          <ls_obj>-success = abap_true.
        ENDLOOP.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "execute_bol_method_pob


  METHOD EXECUTE_BOL_METHOD_POB_2.
    DATA: lx_crm_error            TYPE REF TO cx_crm_genil_model_error,
          lo_root_obj             TYPE REF TO if_genil_container_object,
          ls_result               TYPE crmt_genil_data_ref_4_inst,
          lo_msg_cont             TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_is_contract_changed  TYPE boole_d,
          lv_pob_temp_id          TYPE farr_pob_temp_id,
          ls_parameters           TYPE crmt_name_value_pair,
          ls_invoice_amount       TYPE farr_s_invoice_amount,
          lv_contract_archived    TYPE abap_bool,
          lv_pob_id               TYPE farr_pob_id,
          lv_cond_type            TYPE kscha,
          lv_contract_id          TYPE farr_contract_id,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj>                TYPE crmt_genil_obj_inst_line,
          <lv_pob_temp_id>        TYPE farr_pob_temp_id,
          <lv_contract_archived>  TYPE abap_bool,
          <lv_pob_currency>       TYPE waers,
          <ls_invoice_amount>     TYPE farr_s_invoice_amount.

    CLEAR et_changed_objects.
    CLEAR et_result.

    IF io_msg_service_access IS BOUND.
      lo_msg_cont = io_msg_service_access->get_global_message_container( ).
      lo_msg_cont->reset( ).
    ENDIF.

    CASE iv_method_name.
      WHEN if_farrc_contr_mgmt=>co_mn_get_latest_comp_temp_id.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_pob.
            CALL METHOD get_latest_compound_temp_id
              IMPORTING
                ev_pob_temp_id = lv_pob_temp_id.
** append result to et_result
            CLEAR ls_result.
            CREATE DATA ls_result-data TYPE farr_pob_temp_id.
            ASSIGN ls_result-data->* TO <lv_pob_temp_id>.
            <lv_pob_temp_id> = lv_pob_temp_id.

            ls_result-namespace       = <ls_obj>-namespace.
            ls_result-object_name     = <ls_obj>-object_name.
            ls_result-object_id       = <ls_obj>-object_id.
            INSERT ls_result INTO TABLE et_result.
** set to success
            <ls_obj>-success = abap_true.
          ENDIF.
        ENDLOOP.

      WHEN if_farrc_contr_mgmt=>co_mn_check_contract_archived.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_pob.
            IF mv_contract_id IS NOT INITIAL.
              TRY.
                  lo_contract = get_contract( mv_contract_id ).
                  lo_contract->check_if_archived(
                    IMPORTING
                      ev_archived = lv_contract_archived
                  ).
                CATCH cx_farr_message.

              ENDTRY.
            ENDIF.
** append result to et_result
            CLEAR ls_result.
            CREATE DATA ls_result-data TYPE abap_bool.
            ASSIGN ls_result-data->* TO <lv_contract_archived>.
            <lv_contract_archived> = lv_contract_archived.

            ls_result-namespace       = <ls_obj>-namespace.
            ls_result-object_name     = <ls_obj>-object_name.
            ls_result-object_id       = <ls_obj>-object_id.
            INSERT ls_result INTO TABLE et_result.
** set to success
            <ls_obj>-success = abap_true.
          ENDIF.
        ENDLOOP.

      WHEN if_farrc_contr_mgmt=>co_mn_get_invoice_amount.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          TRY .
              READ TABLE it_parameters INTO ls_parameters
                                       WITH KEY name = if_farrc_contr_mgmt=>co_an_pob_id.
              CHECK sy-subrc = 0.
              lv_pob_id = ls_parameters-value.

              READ TABLE it_parameters INTO ls_parameters
                                       WITH KEY name = if_farrc_contr_mgmt=>co_an_cond_type.
              CHECK sy-subrc = 0.
              lv_cond_type = ls_parameters-value.

              CALL METHOD get_invoice_amount
                EXPORTING
                  iv_pob_id    = lv_pob_id
                  iv_cond_type = lv_cond_type
                IMPORTING
                  es_result    = ls_invoice_amount.
            CATCH cx_farr_message.
          ENDTRY.

** append result to et_result
          CLEAR ls_result.
          CREATE DATA ls_result-data TYPE farr_s_invoice_amount.
          ASSIGN ls_result-data->* TO <ls_invoice_amount>.
          <ls_invoice_amount> = ls_invoice_amount.

          ls_result-namespace       = <ls_obj>-namespace.
          ls_result-object_name     = <ls_obj>-object_name.
          ls_result-object_id       = <ls_obj>-object_id.
          INSERT ls_result INTO TABLE et_result.
** set to success
          <ls_obj>-success = abap_true.
        ENDLOOP.

      WHEN OTHERS.
* Do nothing
    ENDCASE.

  ENDMETHOD.                    "EXECUTE_BOL_METHOD_CONTRACT_2


  METHOD EXECUTE_BOL_METHOD_REV_SCHE_2.
    DATA: lx_crm_error            TYPE REF TO cx_crm_genil_model_error,
          ls_result               TYPE crmt_genil_data_ref_4_inst,
          lo_msg_cont             TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_contract_archived    TYPE abap_bool,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj>                TYPE crmt_genil_obj_inst_line,
          <lv_contract_archived>  TYPE abap_bool.

    CLEAR et_changed_objects.
    CLEAR et_result.

    IF io_msg_service_access IS BOUND.
      lo_msg_cont = io_msg_service_access->get_global_message_container( ).
      lo_msg_cont->reset( ).
    ENDIF.

    CASE iv_method_name.
      WHEN if_farrc_contr_mgmt=>co_mn_check_contract_archived.
        LOOP AT ct_object_list ASSIGNING <ls_obj>.
          IF  <ls_obj>-object_name EQ if_farrc_contr_mgmt=>co_on_rev_schedule.
            IF mv_contract_id IS NOT INITIAL.
              TRY.
                  lo_contract = get_contract( mv_contract_id ).

                  lo_contract->check_if_archived(
                    IMPORTING
                      ev_archived = lv_contract_archived
                  ).
                CATCH cx_farr_message.

              ENDTRY.
            ENDIF.
** append result to et_result
            CLEAR ls_result.
            CREATE DATA ls_result-data TYPE abap_bool.
            ASSIGN ls_result-data->* TO <lv_contract_archived>.
            <lv_contract_archived> = lv_contract_archived.

            ls_result-namespace       = <ls_obj>-namespace.
            ls_result-object_name     = <ls_obj>-object_name.
            ls_result-object_id       = <ls_obj>-object_id.
            INSERT ls_result INTO TABLE et_result.
** set to success
            <ls_obj>-success = abap_true.

          ENDIF.
        ENDLOOP.
      WHEN OTHERS.
* Do nothing
    ENDCASE.

  ENDMETHOD.                    "EXECUTE_BOL_METHOD_CONTRACT_2


  METHOD FULFILL_CONTRACTS.
    DATA:
          ls_contract_key      TYPE farr_s_contract_key,
          lx_farr_msg          TYPE REF TO cx_farr_message,
          lo_msg_handler       TYPE REF TO cl_farr_message_handler,
          ls_changed_object    LIKE LINE OF et_changed_objects,
          lo_man_contract_mgmt TYPE REF TO cl_farr_manual_contract_mgmt,
          lo_contract_for_bol  TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
         <ls_obj>                  LIKE LINE OF ct_object_list.

    CLEAR et_changed_objects.

    LOOP AT ct_object_list ASSIGNING <ls_obj>.
      CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
        EXPORTING
          iv_object_name = <ls_obj>-object_name
          iv_object_id   = <ls_obj>-object_id
        IMPORTING
          es_key         = ls_contract_key.

      " check whether the contract exist before
      CLEAR lo_contract_for_bol.
      CALL METHOD get_contract
        EXPORTING
          iv_contract_id         = ls_contract_key-contract_id
          iv_is_temp_contract    = abap_false
          iv_create_if_not_found = abap_false
        RECEIVING
          ro_contract            = lo_contract_for_bol.    " Interface of contract management BOL

      TRY .
          IF lo_contract_for_bol IS NOT BOUND.
            " create a contract in the contract mgmt
            CALL METHOD get_contract
              EXPORTING
                iv_contract_id      = ls_contract_key-contract_id
                iv_is_temp_contract = abap_false
              RECEIVING
                ro_contract         = lo_contract_for_bol.    " Interface of contract management BOL

            lo_contract_for_bol->load_contract( ).

            " the assignment is just to align with the original codes
            mv_contract_id = ls_contract_key-contract_id.
          ENDIF.
*        mo_contract_mgmt->lock_contract( ).

          lo_msg_handler = lo_contract_for_bol->get_msg_handler( ).

          TRY .
              lo_man_contract_mgmt = lo_contract_for_bol->get_man_contract_instance( ).
              lo_man_contract_mgmt->fulfill_ma_pobs_in_contract(
              EXPORTING
                it_parameter            =  it_parameter
                 ).

            CATCH cx_farr_message INTO lx_farr_msg.
              lo_msg_handler->add_exception_msg(
                EXPORTING
                  ix_exception = lx_farr_msg
                  iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
                  iv_ctx_value = ls_contract_key-contract_id
              ).
          ENDTRY.
*        mo_contract_mgmt->unlock_contract( ).
        CATCH cx_farr_message INTO lx_farr_msg.

          lo_msg_handler->add_exception_msg(
            EXPORTING
              ix_exception = lx_farr_msg
              iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
              iv_ctx_value = ls_contract_key-contract_id
          ).

      ENDTRY.

      ls_changed_object-namespace   = <ls_obj>-namespace.
      ls_changed_object-object_name = <ls_obj>-object_name.
      ls_changed_object-object_id   = <ls_obj>-object_id.
      APPEND ls_changed_object TO et_changed_objects.
      <ls_obj>-success = abap_true.
    ENDLOOP.

  ENDMETHOD.                    "fulfill_contracts


  METHOD GET_ALLOCATED_AMOUNT.

    DATA:
       lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).
    lo_contract_for_bol->get_allocated_amount(
    IMPORTING
      et_allocated_amount = et_result    " Table type of allocated amount
  ).

  ENDMETHOD.                    "get_allocated_amount


  METHOD GET_CALCULATE_AMOUNT.

    DATA:
       lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_contract_for_bol->get_calculate_amount(
      IMPORTING
        et_calculate_amount = et_result    " Table type of calculate amount
  ).

  ENDMETHOD.                    "get_calculate_amount


  METHOD GET_CONFLICT_DESC.
    DATA: lv_field_desc               TYPE string,
          lv_field_name               TYPE dfies-fieldname,
          lv_table_name               TYPE ddobjname,
          ls_field_desc               TYPE ty_field_desc.
    FIELD-SYMBOLS:
                   <ls_field_desc> TYPE ty_field_desc.

    IF cs_conflict_ui_data-deferral_cat IS INITIAL.
      lv_table_name = if_farrc_contr_mgmt=>co_table_pob.
    ELSE.
      lv_table_name = if_farrc_contr_mgmt=>co_table_deferral.
    ENDIF.
    lv_field_name = cs_conflict_ui_data-field_name.

    READ TABLE mts_field_desc WITH TABLE KEY
      table_name = lv_table_name
      field_name = lv_field_name
      ASSIGNING <ls_field_desc>.

    IF sy-subrc = 0.
      lv_field_desc = <ls_field_desc>-field_desc.
    ELSE.
*---- get field name description
      CALL FUNCTION 'DDIF_FIELDLABEL_GET'
        EXPORTING
          tabname        = lv_table_name
          fieldname      = lv_field_name
          langu          = sy-langu
          lfieldname     = ' '
        IMPORTING
          label          = lv_field_desc
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      ls_field_desc-table_name = lv_table_name.
      ls_field_desc-field_name = lv_field_name.
      ls_field_desc-field_desc = lv_field_desc.
      INSERT ls_field_desc INTO TABLE mts_field_desc.
    ENDIF.

    cs_conflict_ui_data-field_name_desc = lv_field_desc.
  ENDMETHOD.                    "get_conflict_desc


  METHOD GET_CONTRACT.

    " this method is used to return a contract instance from contract management.
    " there are two kinds of contracts existing in contract management, one with contract id and
    " another is temporary contract without contract id. The latter one is identified by a index
    " together with a temporary contract flag.
    "
    " As existing the reassign manaul combination case, we should not only rely on the input temporary
    " flag, but also the two internal flag ( mv_use_idx_as_contr_id, mv_last_temp_contr_idx ) to determine
    " temporary contract.
    "

    DATA lv_tem_contract TYPE farr_contract_id.

    CLEAR ro_contract.

    "If one of these two parameters is not default, we should use mo_contract_mgmt->get_instance_for_bol directly
    IF iv_is_temp_contract = abap_true.

      CALL METHOD mo_contract_mgmt->get_instance_for_bol
        EXPORTING
          iv_contract_id         = iv_contract_id
          iv_is_temp_contract    = abap_true
          iv_create_if_not_found = iv_create_if_not_found
        RECEIVING
          ro_contract_bol        = ro_contract.

    ELSE.
      " user does not explicitly identify this is a temporary contract,
      " check in case of reassign manual combination case

      IF mv_use_idx_as_contr_id = abap_false.

        IF iv_contract_id IS INITIAL.
          ASSERT iv_contract_id IS NOT INITIAL.
        ENDIF.

        CALL METHOD mo_contract_mgmt->get_instance_for_bol
          EXPORTING
            iv_contract_id         = iv_contract_id
            iv_is_temp_contract    = abap_false
            iv_create_if_not_found = iv_create_if_not_found
          RECEIVING
            ro_contract_bol        = ro_contract.
      ELSE.
        "If mv_use_idx_as_contr_id was set, then we need to used the index as mv_contract_id
        "mv_contract_id will be set to mv_last_temp_contr_idx in method REASSIGN_SET_USE_IDX
        IF iv_contract_id <> mv_last_temp_contr_idx.
          ASSERT iv_contract_id = mv_last_temp_contr_idx.
        ENDIF.

        lv_tem_contract = mv_last_temp_contr_idx.
        CALL METHOD mo_contract_mgmt->get_instance_for_bol
          EXPORTING
            iv_contract_id         = lv_tem_contract
            iv_is_temp_contract    = abap_true
            iv_create_if_not_found = iv_create_if_not_found
          RECEIVING
            ro_contract_bol        = ro_contract.
      ENDIF.

    ENDIF.

  ENDMETHOD.                    "deter_general_contract


  METHOD GET_INVOICE_AMOUNT.
    DATA:
     lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    CALL METHOD lo_contract_for_bol->get_invoice_amount
      EXPORTING
        iv_pob_id         = iv_pob_id
        iv_cond_type      = iv_cond_type
      IMPORTING
        es_invoice_amount = es_result.
  ENDMETHOD.                    "get_invoice_amount


  METHOD GET_LATEST_COMPOUND_TEMP_ID.
    DATA:
       lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_contract_for_bol->get_latest_compound_temp_id( IMPORTING ev_pob_temp_id = ev_pob_temp_id ).

  ENDMETHOD.                    "get_latest_compound_temp_id


  METHOD GET_POB_ORDER_INFO.

    DATA:
       lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_contract_for_bol->get_pob_order_info(
      IMPORTING
        et_pob_order_info = et_result
    ).
  ENDMETHOD.                    "get_pob_order_info


  METHOD GET_POSTED_POB.

    DATA:
        lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    CLEAR et_posted_pobs.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    CALL METHOD cl_farr_contract_utility=>get_posted_pob_by_contr
      EXPORTING
        io_contract_mgmt = lo_contract_for_bol
      IMPORTING
        et_posted_pobs   = et_posted_pobs.

  ENDMETHOD.                    "get_posted_pob


  METHOD IF_GENIL_APPL_ALTERNATIVE_DSIL~DELETE_OBJECTS.
    DATA: lo_msg_cont            TYPE REF TO   cl_crm_genil_global_mess_cont,
          lv_pob_size            TYPE          i,
          lv_success             TYPE          abap_bool VALUE abap_true,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_object_list>     TYPE crmt_genil_obj_inst_line.

* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = iv_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    LOOP AT ct_object_list ASSIGNING <ls_object_list>.
      IF <ls_object_list>-object_name EQ if_farrc_contr_mgmt=>co_on_contract.

        IF load_contract_by_obj_id( <ls_object_list> ) = abap_true.

          lo_contract = get_contract( mv_contract_id ).

          CALL METHOD lo_contract->delete_contract
            IMPORTING
              ev_result = lv_success.

          IF lv_success = abap_true.
            TRY.
                CALL METHOD lo_contract->save_contract( ).

                CALL METHOD mo_contract_mgmt->save_to_db( ).
                CALL METHOD cl_farr_contract_utility=>unlock_contract_exclusive( lo_contract->get_contract_id( ) ).
              CATCH cx_farr_message.
            ENDTRY.
          ENDIF.

          <ls_object_list>-success = lv_success.

* Always collect msg from BOL to FPM
          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "if_genil_appl_alternative_dsil~delete_objects


  METHOD IF_GENIL_APPL_ALTERNATIVE_DSIL~INIT_OBJECTS.

    DATA:
        lo_msg_cont         TYPE REF TO cl_crm_genil_global_mess_cont,
        lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj>   TYPE crmt_genil_obj_inst_line.

*  CHECK mo_contract IS BOUND.
    lo_msg_cont = iv_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    LOOP AT ct_object_list ASSIGNING <ls_obj>.
      CASE <ls_obj>-object_name.
        WHEN if_farrc_contr_mgmt=>co_on_contract.
          CHECK mv_contract_id IS NOT INITIAL.
          lo_contract_for_bol = get_contract( mv_contract_id ).

          " unlock the contract in case it still in lock status,
          " it does not matter unlock a single contract for more than once
          " Why EXCLUSIVE lock? the original logic in refresh contract contains an exclusive unlock.
          cl_farr_contract_utility=>unlock_contract_exclusive( lo_contract_for_bol->get_contract_id( ) ).
          lo_contract_for_bol->refresh_contract( ).
          <ls_obj>-success = abap_true.
        WHEN if_farrc_contr_mgmt=>co_on_rev_spreading.
          mo_rev_spreading->unlock_contract( ).
          <ls_obj>-success = abap_true.
          "for spreading unlock one time is enough
          EXIT.
      ENDCASE.
    ENDLOOP.

    convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

  ENDMETHOD.                    "if_genil_appl_alternative_dsil~init_objects


  METHOD IF_GENIL_APPL_ALTERNATIVE_DSIL~LOCK_OBJECTS.
    DATA lo_msg_container  TYPE REF TO cl_crm_genil_global_mess_cont.
    FIELD-SYMBOLS:
          <ls_obj>         TYPE crmt_genil_obj_inst_line.

* Clear old messages from the message handler
    init_msg_handler( ).
    lo_msg_container = iv_msg_service_access->get_global_message_container( ).
    lo_msg_container->reset( ).

    LOOP AT ct_object_list ASSIGNING <ls_obj>.
      CASE <ls_obj>-object_name.
        WHEN if_farrc_contr_mgmt=>co_on_contract.
          CALL METHOD lock_contract
            EXPORTING
              io_msg_container = lo_msg_container
            CHANGING
              cs_obj           = <ls_obj>.

        WHEN if_farrc_contr_mgmt=>co_on_rev_spreading.
          CALL METHOD lock_rev_spreading
            EXPORTING
              io_msg_container = lo_msg_container
            CHANGING
              cs_obj           = <ls_obj>.


      ENDCASE.
    ENDLOOP.
  ENDMETHOD.                    "if_genil_appl_alternative_dsil~lock_objects


  METHOD IF_GENIL_APPL_ALTERNATIVE_DSIL~SAVE_OBJECTS.
* Clear old messages from the message handler
    DATA: lo_msg_cont            TYPE REF TO cl_crm_genil_global_mess_cont,
          lx_farr_message        TYPE REF TO cx_farr_message,
          lo_msg_handler         TYPE REF TO cl_farr_message_handler,
          ls_contract_key        TYPE farr_s_contract_key,
          lv_loaded_contract_id  TYPE farr_contract_id,
          lv_total_handler       TYPE i,
          lv_total_exist_handler TYPE i,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol,
          lts_temp_contracts     TYPE farr_ts_contract_bol_instance,
          ls_temp_contract       LIKE LINE OF lts_temp_contracts.

    FIELD-SYMBOLS:
      <ls_reassign_handler> TYPE ty_s_reassign_handler,
      <ls_obj>              TYPE crmt_genil_obj_inst_line.

    CLEAR et_id_mapping.
    CLEAR lv_total_handler.
    CLEAR lv_total_exist_handler.

    init_msg_handler( ).

    lo_msg_cont = iv_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    LOOP AT ct_object_list ASSIGNING <ls_obj>.

      <ls_obj>-success = abap_true.
      CASE <ls_obj>-object_name.
        WHEN if_farrc_contr_mgmt=>co_on_contract.

          IF mv_flg_reassign = abap_true.
            " manual combination case

            LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>. "do this in a seperate loop as we will stop call saving
              IF sy-subrc = 0.                                           " if saving contract fails for 1st handler - this is to
                lv_total_handler = lv_total_handler + 1.                 " ensure error message to be displayed even user click 2
                IF <ls_reassign_handler>-contract_id <> 0.               " times 'save' button, regarding error message shown.
                  lv_total_exist_handler = lv_total_exist_handler + 1.
                ENDIF.
              ENDIF.
            ENDLOOP.

            TRY .
                save_combine_contracts(
                  EXPORTING
                    io_msg_cont        = lo_msg_cont
                  IMPORTING
                    ets_temp_contracts = lts_temp_contracts
                  CHANGING
                    cs_object_list     = <ls_obj>
                ).
              CATCH cx_farr_message INTO lx_farr_message.
                <ls_obj>-success = abap_false.

                convert_msg_from_t100_to_bapi(
                  EXPORTING
                    io_msg_container = lo_msg_cont
                    lx_farr_message  = lx_farr_message
                ).
                EXIT.
            ENDTRY.

            " After save succeeded, update the reassign handler by
            " 1. replacing temporary contracts with concrete ones
            " 2. removing those original existing contract
            LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>.
              IF <ls_reassign_handler>-contract_id = 0.
                READ TABLE lts_temp_contracts INTO ls_temp_contract
                  WITH TABLE KEY
                    contract_id  = <ls_reassign_handler>-temp_contract_idx
                    is_temporary = abap_true.

                ASSERT sy-subrc = 0.
                <ls_reassign_handler>-contract_id       = ls_temp_contract-contract->get_contract_id( ).
                <ls_reassign_handler>-temp_contract_idx = 0.
              ELSE.
                CLEAR <ls_reassign_handler>.
              ENDIF.
            ENDLOOP.

          ELSE.
            " normal case
            TRY .
                lo_contract = get_contract( mv_contract_id ).
                lo_contract->save_contract( ).
              CATCH cx_farr_message INTO lx_farr_message.
                <ls_obj>-success = abap_false.
*                cl_farr_contract_utility=>unlock_contract_exclusive( lo_contract->get_contract_id( ) ).

                " Always collect msg from BOL to FPM
                convert_msg_from_t100_to_bapi(
                  EXPORTING
                    io_msg_container = lo_msg_cont ).
                EXIT.
            ENDTRY.

            " Always collect msg from BOL to FPM
            convert_msg_from_t100_to_bapi(
              EXPORTING
                io_msg_container = lo_msg_cont ).

            mo_contract_mgmt->save_to_db(
            EXPORTING
              iv_reset_buffer = abap_false ).

            <ls_obj>-success = abap_true.
          ENDIF.

        WHEN if_farrc_contr_mgmt=>co_on_rev_spreading.
          TRY .
              mo_rev_spreading->save_rev_spreading( ).
            CATCH cx_farr_message INTO lx_farr_message.
              <ls_obj>-success = abap_false.
          ENDTRY.

          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont
                                         io_rev_spreading = mo_rev_spreading ).
          "for spreading call save one time is enough
          EXIT.
      ENDCASE.
    ENDLOOP.
    "Save to DB is the last step for a LUW, when save is conducted successfully.
    "MSG_HANDLER should be save and closed.

    " manually close the appl log handle in contr_mgmt(refresh mv_balloghndl),
    " or else same mv_balloghndl is resued every time SAVE_OBJECT is called,
    " error message is appended to same log handler in DB.
    TRY.
        lo_msg_handler = cl_farr_message_handler=>get_instance( ).
        lo_msg_handler->save_and_close_app_log( ).
      CATCH cx_farr_message.
    ENDTRY.
  ENDMETHOD.                    "if_genil_appl_alternative_dsil~save_objects


  METHOD IF_GENIL_APPL_INTLAY~CREATE_OBJECTS.

    CASE iv_object_name.
      WHEN if_farrc_contr_mgmt=>co_on_contract.
        CALL METHOD create_contract
          EXPORTING
            it_parameters = it_parameters
            io_root_list  = iv_root_list.

      WHEN OTHERS.

    ENDCASE.

  ENDMETHOD.                    "if_genil_appl_intlay~create_objects


  METHOD IF_GENIL_APPL_INTLAY~EXECUTE_OBJECT_METHOD.
    CLEAR et_changed_objects.

* Clear old messages from the message handler
    init_msg_handler( ).

    CASE iv_object_name.
      WHEN if_farrc_contr_mgmt=>co_on_contract.
        CALL METHOD me->execute_bol_method_contract
          EXPORTING
            iv_method_name        = iv_method_name
            it_parameters         = it_parameters
            io_rootlist           = iv_rootlist
            io_msg_service_access = iv_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
          CHANGING
            ct_object_list        = ct_object_list.

      WHEN if_farrc_contr_mgmt=>co_on_pob OR
        if_farrc_contr_mgmt=>co_on_pob_ui .
        CALL METHOD me->execute_bol_method_pob
          EXPORTING
            iv_method_name        = iv_method_name
            it_parameters         = it_parameters
            io_rootlist           = iv_rootlist
            io_msg_service_access = iv_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
          CHANGING
            ct_object_list        = ct_object_list.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "if_genil_appl_intlay~execute_object_method


  METHOD IF_GENIL_APPL_INTLAY~EXECUTE_OBJECT_METHOD2.
    CLEAR et_changed_objects.
    CLEAR et_result.
* Clear old messages from the message handler
    init_msg_handler( ).

    CASE iv_object_name.
      WHEN if_farrc_contr_mgmt=>co_on_contract.
        CALL METHOD me->execute_bol_method_contract_2
          EXPORTING
            iv_method_name        = iv_method_name
            iv_object_name        = iv_object_name
            it_parameters         = it_parameters
            io_msg_service_access = iv_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
            et_result             = et_result
          CHANGING
            ct_object_list        = ct_object_list.

      WHEN if_farrc_contr_mgmt=>co_on_pob.
        CALL METHOD me->execute_bol_method_pob_2
          EXPORTING
            iv_method_name        = iv_method_name
            iv_object_name        = iv_object_name
            it_parameters         = it_parameters
            io_msg_service_access = iv_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
            et_result             = et_result
          CHANGING
            ct_object_list        = ct_object_list.

      WHEN if_farrc_contr_mgmt=>co_on_rev_schedule.
        CALL METHOD me->execute_bol_method_rev_sche_2
          EXPORTING
            iv_method_name        = iv_method_name
            iv_object_name        = iv_object_name
            it_parameters         = it_parameters
            io_msg_service_access = iv_msg_service_access
          IMPORTING
            et_changed_objects    = et_changed_objects
            et_result             = et_result
          CHANGING
            ct_object_list        = ct_object_list.

      WHEN OTHERS.
    ENDCASE.

  ENDMETHOD.                    "if_genil_appl_intlay~execute_object_method2


  METHOD IF_GENIL_APPL_INTLAY~GET_DYNAMIC_QUERY_RESULT.

    DATA lv_use_filter TYPE abap_bool.

    CASE iv_query_name.
      WHEN if_farrc_contr_mgmt=>co_dq_contract.
        CALL METHOD search_contract
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN if_farrc_contr_mgmt=>co_dq_search_contract.
        CALL METHOD search_contract_by_range_tab
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN if_farrc_contr_mgmt=>co_dq_search_rev_spreading.
        CALL METHOD search_rev_spreading
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN if_farrc_contr_mgmt=>co_dq_manual_contract.
        CALL METHOD search_contract_for_manual
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN if_farrc_contr_mgmt=>co_dq_search_pob_by_type.
        CALL METHOD search_pob_by_type
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN if_farrc_contr_mgmt=>co_dq_search_pob.
        CALL METHOD search_pob
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN  if_farrc_contr_mgmt=>co_dq_search_pob_adv.

        READ TABLE is_query_parameters-selection_hints
              WITH KEY name = if_farrc_contr_mgmt=>co_powl_param_pob_filter              TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          lv_use_filter = abap_true.
        ENDIF.

        CALL METHOD search_pob_adv
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list
            iv_use_filter           = lv_use_filter.

      WHEN if_farrc_contr_mgmt=>co_dq_search_rev_sch.
        CALL METHOD search_rev_schedule
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN if_farrc_contr_mgmt=>co_dq_search_rev_summary.
        CALL METHOD search_rev_summary
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.
      WHEN if_farrc_contr_mgmt=>co_dq_search_rev_explain.
        CALL METHOD search_rev_explain
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.

      WHEN if_farrc_contr_mgmt=>co_dq_search_conflict_ui.
        CALL METHOD search_conflict_ui
          EXPORTING
            is_query_parameters     = is_query_parameters
            it_selection_parameters = it_selection_parameters
            io_root_list            = iv_root_list.
      WHEN OTHERS.
* Do nothing
    ENDCASE.
  ENDMETHOD.                    "if_genil_appl_intlay~get_dynamic_query_result


  METHOD IF_GENIL_APPL_INTLAY~GET_OBJECTS.
    DATA: lo_root_obj      TYPE REF TO if_genil_container_object,
          lv_obj_name      TYPE crmt_ext_obj_name,
          lx_farr_message  TYPE REF TO cx_farr_message,
          lo_msg_container TYPE REF TO cl_crm_genil_global_mess_cont.

    init_msg_handler( ).
    lo_msg_container = iv_root_list->get_global_message_container( ).
    lo_msg_container->reset( ).

    lo_root_obj = iv_root_list->get_first( ).
    WHILE lo_root_obj IS BOUND.
      TRY .
          read_root_object( lo_root_obj ).

          IF lo_root_obj->check_rels_requested( ) = abap_true.

            lv_obj_name = lo_root_obj->get_name( ).
            CASE lv_obj_name.
              WHEN if_farrc_contr_mgmt=>co_on_contract.
                read_children(
                  it_request_objects = it_request_objects
                  io_object          = lo_root_obj
                  ).

              WHEN OTHERS.
            ENDCASE.
          ENDIF.
        CATCH cx_farr_message.
          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_container ).
      ENDTRY.

      lo_root_obj = iv_root_list->get_next( ).
    ENDWHILE.
  ENDMETHOD.                    "if_genil_appl_intlay~get_objects


  METHOD IF_GENIL_APPL_INTLAY~MODIFY_OBJECTS.

    DATA: lo_root_obj     TYPE REF TO if_genil_container_object.
    DATA: lx_farr_message TYPE REF TO cx_farr_message.
    DATA: lo_msg_cont     TYPE REF TO cl_crm_genil_global_mess_cont.

    CLEAR et_changed_objects.

* Clear old messages from the message handler
    init_msg_handler( ).

    lo_root_obj = iv_root_list->get_first( ).
    WHILE lo_root_obj IS BOUND.
      TRY .
          CALL METHOD modify_root_object
            EXPORTING
              io_root_obj        = lo_root_obj
            CHANGING
              ct_changed_objects = et_changed_objects.

          CALL METHOD modify_children
            EXPORTING
              io_object          = lo_root_obj
            CHANGING
              ct_changed_objects = et_changed_objects.

          "collect warning messages
          lo_msg_cont = iv_root_list->get_global_message_container( ).
          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).

        CATCH cx_farr_message INTO lx_farr_message.
          lo_msg_cont = iv_root_list->get_global_message_container( ).
          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
      ENDTRY.

      lo_root_obj = iv_root_list->get_next( ).
    ENDWHILE.
  ENDMETHOD.                    "if_genil_appl_intlay~modify_objects


  METHOD INIT.

    CLEAR mv_contract_id.
    mo_rev_spreading = cl_farr_engine_factory=>get_instance_rev_spreading_bol( ).
    CREATE OBJECT mo_conflict_mgmt TYPE cl_farr_conflict_mgmt.

    mo_contract_mgmt = cl_farr_engine_factory=>get_instance_contract_mgmt( ).

    init_changeable_fields_contr( ).
    init_changeable_fields_pob( ).
    init_changeable_fields_conflic( ).
  ENDMETHOD.                    "init


  METHOD INIT_CHANGEABLE_FIELDS_CONFLIC.
    APPEND if_farrc_contr_mgmt=>co_an_use_value_from TO mt_changeable_field_conflict.
    APPEND if_farrc_contr_mgmt=>co_an_update_mode    TO mt_changeable_field_conflict.
  ENDMETHOD.                    "INIT_CHANGEABLE_FIELDS_CONFLIC


  METHOD INIT_CHANGEABLE_FIELDS_CONTR.
    APPEND if_farrc_contr_mgmt=>co_an_description   TO mt_changeable_field_contract.
*    APPEND if_farrc_contr_mgmt=>co_an_contract_status  TO mt_changeable_field_contract.

    build_contr_customizing_fields( ).

  ENDMETHOD.                    "init_changeable_fields_contr


  METHOD INIT_CHANGEABLE_FIELDS_POB.

* existed POB: changeable fields need to be set dynamically later according to if event happen/post

* newly created POB(additional):
    APPEND if_farrc_contr_mgmt=>co_an_pob_type        TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_event_type      TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_fulfill_type    TO mt_changeable_field_new_pob.
**    APPEND if_farrc_contr_mgmt=>co_an_distinct_type   TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_residual_pob    TO mt_changeable_field_new_pob.
**    APPEND if_farrc_contr_mgmt=>co_an_prevent_alloc   TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_ssp             TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_ssp_curk        TO mt_changeable_field_new_pob.

    APPEND if_farrc_contr_mgmt=>co_an_pob_name        TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_deferral_method TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_quantity        TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_quantity_unit   TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_duration        TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_duration_unit   TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_start_date      TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_end_date        TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_pob_type        TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_start_date_type TO mt_changeable_field_new_pob.

    APPEND if_farrc_contr_mgmt=>co_an_ssp_range_amount  TO mt_changeable_field_new_pob.
    APPEND if_farrc_contr_mgmt=>co_an_ssp_range_perc    TO mt_changeable_field_new_pob.

    APPEND if_farrc_contr_mgmt=>co_an_inception_date    TO mt_changeable_field_new_pob.
*    APPEND if_farrc_contr_mgmt=>co_an_paobjnr           TO mt_changeable_field_new_pob.
*    APPEND if_farrc_contr_mgmt=>co_an_function_area     TO mt_changeable_field_new_pob.
*    APPEND if_farrc_contr_mgmt=>co_an_business_area     TO mt_changeable_field_new_pob.
*    APPEND if_farrc_contr_mgmt=>co_an_segment           TO mt_changeable_field_new_pob.
*    APPEND if_farrc_contr_mgmt=>co_an_profit_center     TO mt_changeable_field_new_pob.

* newly created POB(compound):
    APPEND if_farrc_contr_mgmt=>co_an_pob_name          TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_pob_type          TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_ssp_range_amount  TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_ssp_range_perc    TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_residual_pob      TO mt_changeable_field_new_pob_c.

    APPEND if_farrc_contr_mgmt=>co_an_paobjnr           TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_function_area     TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_business_area     TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_segment           TO mt_changeable_field_new_pob_c.
    APPEND if_farrc_contr_mgmt=>co_an_profit_center     TO mt_changeable_field_new_pob_c.

    APPEND if_farrc_contr_mgmt=>co_an_inception_date    TO mt_changeable_field_new_pob_c.

    build_new_pob_cust_fields( ).

  ENDMETHOD.                    "init_changeable_fields_pob


  METHOD INIT_MSG_HANDLER.
    DATA lo_contract TYPE REF TO if_farr_contract_mgmt_bol.

    CHECK mv_contract_id IS NOT INITIAL.

    lo_contract = get_contract( mv_contract_id ).

    lo_contract->init_msg_handler( ).
  ENDMETHOD.                    "init_msg_handler


  METHOD IS_CONTRACT_CHANGED.

    DATA:
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    ev_result = lo_contract_for_bol->is_contract_changed( ).

  ENDMETHOD.                    "is_contract_changed


  METHOD LOAD_CONTRACT.
    DATA: ls_contract_key  TYPE farr_s_contract_key,
          lx_farr_message  TYPE REF TO cx_farr_message,
          lo_msg_container TYPE REF TO cl_crm_genil_global_mess_cont,
          lo_contract_for_bol  TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_contract_obj->get_key
      IMPORTING
        es_key = ls_contract_key.

    TRY.
        mv_contract_id = ls_contract_key-contract_id.
        lo_contract_for_bol = deter_contract_mgmt_for_load( ).
        "Only those existed contracts can be loaded.
        "ls_contract_key-contract_id  = 0 means the case :for combine: target_contract = 0
        "This case the target contract is not complet built, can not be loaded
*        IF ls_contract_key-contract_id IS NOT INITIAL.
        IF lo_contract_for_bol->get_contract_id( ) IS NOT INITIAL
          AND mv_flg_reassign = abap_false.

          lo_contract_for_bol->load_contract( ).

          IF  mv_flg_reassign       <> abap_true
          AND mv_flg_manual_fulfill <> abap_true.
            " Load conflict data
            CALL METHOD mo_conflict_mgmt->load_manual_change
              EXPORTING
                iv_contract_id = mv_contract_id.
          ENDIF.

        ENDIF.
      CATCH cx_farr_message INTO lx_farr_message.
        lo_msg_container
          = io_contract_obj->if_genil_cont_simple_object~get_global_message_container( ).

        lo_msg_container->add_message(
          EXPORTING
            iv_msg_type       = lx_farr_message->mv_msgty
            iv_msg_id         = lx_farr_message->mv_msgid
            iv_msg_number     = lx_farr_message->mv_msgno
            iv_msg_v1         = lx_farr_message->mv_msgv1
            iv_msg_v2         = lx_farr_message->mv_msgv2
            iv_msg_v3         = lx_farr_message->mv_msgv3
            iv_msg_v4         = lx_farr_message->mv_msgv4
            iv_show_only_once = abap_true
         ).

        RAISE EXCEPTION lx_farr_message.
    ENDTRY.
  ENDMETHOD.                    "load_contract


  METHOD LOAD_CONTRACT_BY_OBJ_ID.
    DATA: ls_contract_key  TYPE farr_s_contract_key,
          lo_contract      TYPE REF TO if_farr_contract_mgmt_bol.

    TRY.
* Retrieve the key
        CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
          EXPORTING
            iv_object_name = is_obj-object_name
            iv_object_id   = is_obj-object_id
          IMPORTING
            es_key         = ls_contract_key.

* load contract if new contract selected
        TRY.
            get_contract(
              EXPORTING
                iv_contract_id         = ls_contract_key-contract_id
                iv_is_temp_contract    = abap_false
              RECEIVING
                ro_contract            = lo_contract
            ).
            IF mv_contract_id <> ls_contract_key-contract_id.
              lo_contract->load_contract( abap_true ).
            ELSE.
              lo_contract->load_contract( ).
            ENDIF.
            mv_contract_id = ls_contract_key-contract_id.

            rv_success = abap_true.
          CATCH cx_farr_message.
            rv_success = abap_false.
        ENDTRY.
      CATCH cx_crm_genil_general_error.
        rv_success = abap_false.
    ENDTRY.
  ENDMETHOD.                    "load_contract_by_obj_id


  METHOD LOAD_POB_UI_AMOUNT.
    DATA: lt_pob_key               TYPE farr_tt_pob_key,
          ls_pob_key               TYPE farr_s_pob_key,
          lt_cond_type_data       TYPE farr_tt_cond_type_data,
          lv_price_amount         TYPE farr_amount,
          lv_diff_amount          TYPE farr_amount,
          lv_currency             TYPE waers,
          lt_defitem_data         TYPE farr_tt_defitem_data.

    FIELD-SYMBOLS:
          <ls_pob_data_ui>      TYPE farr_s_pob_data_ui,
          <ls_defitem_data>     TYPE farr_s_defitem_data,
          <ls_cond_data>        TYPE farr_s_cond_type_data.

    LOOP AT ct_pob_data_ui ASSIGNING <ls_pob_data_ui>.
      ls_pob_key-pob_id = <ls_pob_data_ui>-pob_id.
      APPEND ls_pob_key TO lt_pob_key.
    ENDLOOP.

    TRY.
        CALL METHOD cl_farr_defitem_db_access=>read_multiple_by_multi_pob
          EXPORTING
            it_pob_id  = lt_pob_key
          IMPORTING
            et_defitem = lt_defitem_data.
      CATCH cx_farr_not_found.
    ENDTRY.


    LOOP AT ct_pob_data_ui ASSIGNING <ls_pob_data_ui>.
      CLEAR lv_price_amount.
      CLEAR lv_diff_amount.

      LOOP AT lt_defitem_data ASSIGNING <ls_defitem_data>
        WHERE pob_id = <ls_pob_data_ui>-pob_id AND category = if_farrc_contr_mgmt=>co_cond_cat_price.

        " difference amount
        IF <ls_defitem_data>-spec_indicator = if_farrc_contr_mgmt=>co_indicator_alloc_diff.
          lv_diff_amount = lv_diff_amount + <ls_defitem_data>-doc_amt_cumulate + <ls_defitem_data>-pro_amt_cumulate.
        ENDIF.

        " price
        IF <ls_defitem_data>-statistic = abap_false
          AND <ls_defitem_data>-spec_indicator <> if_farrc_contr_mgmt=>co_indicator_alloc_diff.

          lv_price_amount = lv_price_amount + <ls_defitem_data>-doc_amt_cumulate + <ls_defitem_data>-pro_amt_cumulate.
        ENDIF.

        lv_currency = <ls_defitem_data>-amount_curk.

      ENDLOOP.

      IF lv_price_amount IS NOT INITIAL.
        <ls_pob_data_ui>-price           = lv_price_amount.
        <ls_pob_data_ui>-price_currency  = lv_currency.
      ENDIF.
      IF lv_diff_amount IS NOT INITIAL.
        <ls_pob_data_ui>-corr_amount     = lv_diff_amount.
        <ls_pob_data_ui>-corr_currency   = lv_currency.
      ENDIF.
      <ls_pob_data_ui>-alloc_amount    = lv_price_amount + lv_diff_amount.
      IF <ls_pob_data_ui>-alloc_amount IS NOT INITIAL.
        <ls_pob_data_ui>-alloc_currency  = lv_currency.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "load_pob_ui_amount


  METHOD LOCK_CONTRACT.
    DATA: ls_contract_key        TYPE farr_s_contract_key,
          lx_farr_message        TYPE REF TO cx_farr_message,
          lo_contract_mgmt       TYPE REF TO if_farr_contract_mgmt,
          lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol.

    TRY.
        CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
          EXPORTING
            iv_object_name = cs_obj-object_name
            iv_object_id   = cs_obj-object_id
          IMPORTING
            es_key         = ls_contract_key.
      CATCH cx_crm_genil_general_error.
        cs_obj-success = abap_false.

        RETURN.
    ENDTRY.

    IF ls_contract_key IS NOT INITIAL.
      " according to the BOL guide line, do lock, load and authority check.

      TRY.
          cl_farr_contract_utility=>lock_contract_exclusive( ls_contract_key-contract_id ).

          " it must be set before usage
          mv_contract_id = ls_contract_key-contract_id.

          lo_contract_for_bol = deter_contract_mgmt_for_lock( ).

          IF lo_contract_for_bol IS BOUND.
            " the contract needs to be loaded
            lo_contract_for_bol->load_contract( abap_true ).

            " as original logic, the display check is done after load, and the change check is done after lock
            lo_contract_for_bol->check_authority( if_farrc_contr_mgmt=>co_auth_activity_display ).
            lo_contract_for_bol->check_authority( if_farrc_contr_mgmt=>co_auth_activity_change ).
          ENDIF.

          cs_obj-success = abap_true.

        CATCH cx_farr_message INTO lx_farr_message.
          cs_obj-success = abap_false.
          io_msg_container->add_message(
            EXPORTING
              iv_msg_type       = lx_farr_message->mv_msgty
              iv_msg_id         = lx_farr_message->mv_msgid
              iv_msg_number     = lx_farr_message->mv_msgno
              iv_msg_v1         = lx_farr_message->mv_msgv1
              iv_msg_v2         = lx_farr_message->mv_msgv2
              iv_msg_v3         = lx_farr_message->mv_msgv3
              iv_msg_v4         = lx_farr_message->mv_msgv4
              iv_show_only_once = abap_true
           ).

          convert_msg_from_t100_to_bapi(
            EXPORTING
              io_msg_container = io_msg_container
          ).
      ENDTRY.
    ENDIF.

  ENDMETHOD.                    "if_genil_appl_alternative_dsil~lock_objects


  METHOD LOCK_REV_SPREADING.
    DATA: lx_farr_message TYPE REF TO cx_farr_message.

    TRY.
        mo_rev_spreading->lock_contract( ).

        cs_obj-success = abap_true.
      CATCH cx_farr_message INTO lx_farr_message.
        cs_obj-success = abap_false.
        io_msg_container->add_message(
          EXPORTING
            iv_msg_type       = lx_farr_message->mv_msgty
            iv_msg_id         = lx_farr_message->mv_msgid
            iv_msg_number     = lx_farr_message->mv_msgno
            iv_msg_v1         = lx_farr_message->mv_msgv1
            iv_msg_v2         = lx_farr_message->mv_msgv2
            iv_msg_v3         = lx_farr_message->mv_msgv3
            iv_msg_v4         = lx_farr_message->mv_msgv4
            iv_show_only_once =  abap_true
         ).
    ENDTRY.
  ENDMETHOD.                    "if_genil_appl_alternative_dsil~lock_objects


  METHOD MANUAL_FULFILL_CHECK.
    DATA:
          ls_pob_key            TYPE farr_s_pob_key,
          ls_changed_object     LIKE LINE OF et_changed_objects,
          lv_result             TYPE boolean,
          lo_man_contract_mgmt  TYPE REF TO cl_farr_manual_contract_mgmt,
          lo_contract_for_bol   TYPE REF TO if_farr_contract_mgmt_bol.
    FIELD-SYMBOLS:
          <ls_obj>              LIKE LINE OF ct_pob_obj.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    TRY .
        lo_man_contract_mgmt = lo_contract_for_bol->get_man_contract_instance( ).
        lo_man_contract_mgmt->check_manual_fulfill(
        EXPORTING
          it_parameter    =  it_parameter
        IMPORTING
          ev_result       =  lv_result
      ).
      CATCH cx_farr_message.
    ENDTRY.

    LOOP AT ct_pob_obj ASSIGNING <ls_obj>.
      CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
        EXPORTING
          iv_object_name = <ls_obj>-object_name
          iv_object_id   = <ls_obj>-object_id
        IMPORTING
          es_key         = ls_pob_key.

      IF lv_result = abap_true.
        <ls_obj>-success = abap_true.
*        CLEAR ls_changed_object.
*        ls_changed_object-namespace   = <ls_obj>-namespace.
*        ls_changed_object-object_name = <ls_obj>-object_name.
*        ls_changed_object-object_id   = <ls_obj>-object_id.
*        APPEND ls_changed_object TO et_changed_objects.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "simulate_fulfill_pob


  METHOD MANUAL_FULFILL_CHECK_CONTRA.
    DATA:
          ls_contract_key      TYPE farr_s_contract_key,
          lt_contract_key      TYPE farr_tt_contract_key,
          ls_changed_object    LIKE LINE OF et_changed_objects,
          lv_result            TYPE boolean,
          lo_man_contract_mgmt TYPE REF TO cl_farr_manual_contract_mgmt,
          lo_contract_for_bol  TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj>              LIKE LINE OF ct_obj.

    LOOP AT ct_obj ASSIGNING <ls_obj>.
      CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
        EXPORTING
          iv_object_name = <ls_obj>-object_name
          iv_object_id   = <ls_obj>-object_id
        IMPORTING
          es_key         = ls_contract_key.

      TRY .
          CALL METHOD get_contract
            EXPORTING
              iv_contract_id         = ls_contract_key-contract_id
              iv_is_temp_contract    = abap_false
              iv_create_if_not_found = abap_false
            RECEIVING
              ro_contract            = lo_contract_for_bol.    " Interface of contract management BOL

          " it could not been missed
          ASSERT lo_contract_for_bol IS BOUND.

          lo_contract_for_bol->load_contract( ).
          lo_man_contract_mgmt = lo_contract_for_bol->get_man_contract_instance( ).
          lo_man_contract_mgmt->check_manual_fulfill_contra(
          EXPORTING
            it_parameter    =  it_parameter
          IMPORTING
            ev_result       =  lv_result
        ).
        CATCH cx_farr_message.
      ENDTRY.
    ENDLOOP.

    LOOP AT ct_obj ASSIGNING <ls_obj>.
      IF lv_result = abap_true.
        <ls_obj>-success = abap_true.
        CLEAR ls_changed_object.
        ls_changed_object-namespace   = <ls_obj>-namespace.
        ls_changed_object-object_name = <ls_obj>-object_name.
        ls_changed_object-object_id   = <ls_obj>-object_id.
        APPEND ls_changed_object TO et_changed_objects.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "simulate_fulfill_pob


  METHOD MANUAL_FULFILL_POB.
    DATA:
          ls_changed_object     LIKE LINE OF et_changed_objects,
          lx_message            TYPE REF TO cx_farr_message,
          lo_msg_cont           TYPE REF TO cl_crm_genil_global_mess_cont,
          lo_man_contract_mgmt  TYPE REF TO cl_farr_manual_contract_mgmt,
          lo_contract_for_bol   TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS: <ls_obj>  LIKE LINE OF ct_pob_obj.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).
    TRY .
        lo_man_contract_mgmt = lo_contract_for_bol->get_man_contract_instance( ).
        lo_man_contract_mgmt->manual_fulfill_pob(
        EXPORTING
          it_parameter          =  it_parameter   " Parameter Table of Name-Value Pairs
      ).

        IF 1 = 2.
          MESSAGE s006(farr_contract_bol).
        ENDIF.
        lo_msg_cont->add_message(
          EXPORTING
           iv_msg_type       = 'S'
           iv_msg_id         = 'FARR_CONTRACT_BOL'  "TODO Use constant
           iv_msg_number     = '006'
           iv_show_only_once =  abap_true
        ).

        LOOP AT ct_pob_obj ASSIGNING <ls_obj>.
          <ls_obj>-success = abap_true.
          CLEAR ls_changed_object.
          ls_changed_object-namespace   = <ls_obj>-namespace.
          ls_changed_object-object_name = <ls_obj>-object_name.
          ls_changed_object-object_id   = <ls_obj>-object_id.
          APPEND ls_changed_object TO et_changed_objects.

        ENDLOOP.
      CATCH cx_farr_message INTO lx_message.
        lo_msg_cont->add_message(
          EXPORTING
            iv_msg_type       =    lx_message->mv_msgty
            iv_msg_id         =    lx_message->mv_msgid " Messages, Message Class
            iv_msg_number     =    lx_message->mv_msgno " Messages, Message Number
*            iv_msg_text       =     " Message Text
            iv_msg_v1         =   lx_message->mv_msgv1  " Messages, Message Variable
            iv_msg_v2         =   lx_message->mv_msgv2  " Messages, Message Variable
            iv_msg_v3         =   lx_message->mv_msgv3  " Messages, Message Variable
            iv_msg_v4         =   lx_message->mv_msgv4  " Messages, Message Variable
            iv_show_only_once =   abap_true
*            iv_msg_level      = '1'    " Message Level
        ).
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
    ENDTRY.
  ENDMETHOD.                    "manual_fulfill_pob


  METHOD MODIFY_CHANGE_TYPE_LIST.
    DATA: lo_obj                TYPE REF TO if_genil_container_object,
          lo_pob                TYPE REF TO if_genil_container_object,
          ls_pob_key            TYPE farr_s_pob_key,
          lx_farr_message       TYPE REF TO cx_farr_message,
          lv_delta_flag         TYPE crmt_delta,
          lt_change_type_add    TYPE farr_tt_chg_type,
          lt_change_type_chg    TYPE farr_tt_chg_type_with_attr,
          lt_change_type_del    TYPE farr_tt_chg_type_key,
          ls_changed_obj        TYPE crmt_genil_obj_instance,
          lv_obj_id             TYPE crmt_genil_object_id,
          lo_contract           TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_change_type_key>  TYPE farr_s_chg_type_key.

    lo_obj = io_obj_list->get_first( ).
* Get attributes of POB
    lo_pob = lo_obj->get_parent( ).
    IF lo_pob IS BOUND.
      CALL METHOD lo_pob->get_key
        IMPORTING
          es_key = ls_pob_key.

      IF lo_obj IS BOUND.
        WHILE lo_obj IS BOUND.
          IF lo_obj->get_name( ) = if_farrc_contr_mgmt=>co_on_chg_type.
            lv_delta_flag = lo_obj->get_delta_flag( ).
            CASE lv_delta_flag.
              WHEN if_genil_cont_simple_object=>delta_created.
                CALL METHOD collect_change_type_created
                  EXPORTING
                    io_chg_type_obj    = lo_obj
                    is_pob_key         = ls_pob_key
                  CHANGING
                    ct_change_type_add = lt_change_type_add.

              WHEN if_genil_cont_simple_object=>delta_changed.
                CALL METHOD collect_change_type_changed
                  EXPORTING
                    io_chg_type_obj    = lo_obj
                  CHANGING
                    ct_change_type_chg = lt_change_type_chg.

              WHEN if_genil_cont_simple_object=>delta_deleted.
                CALL METHOD collect_change_type_deleted
                  EXPORTING
                    io_chg_type_obj    = lo_obj
                  CHANGING
                    ct_change_type_del = lt_change_type_del.

              WHEN OTHERS.
            ENDCASE.

* Update changed object
            ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_chg_type.
            ls_changed_obj-object_id   = lo_obj->get_object_id( ).
            APPEND ls_changed_obj TO ct_changed_objects.
          ENDIF.

          lo_obj = io_obj_list->get_next( ).
        ENDWHILE.

        TRY .

            lo_contract = get_contract( mv_contract_id ).

            CALL METHOD lo_contract->modify_change_type
              EXPORTING
                it_change_type_add = lt_change_type_add    " Table type of POB data
                it_change_type_chg = lt_change_type_chg    " Table type of POB data with attribute
                it_change_type_del = lt_change_type_del.    " Table Type of POB ID
          CATCH cx_farr_message INTO lx_farr_message.
* Error happened:
* Remove the to-be-deleted Change Type out of Changed_Objects
* Otherwise, the Change Type will be deleted from the UI
            LOOP AT lt_change_type_del ASSIGNING <ls_change_type_key>.
              lv_obj_id = cl_crm_genil_container_tools=>build_object_id( <ls_change_type_key> ).

              DELETE ct_changed_objects WHERE object_id = lv_obj_id.
            ENDLOOP.
            RAISE EXCEPTION lx_farr_message.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "modify_change_type_list


  METHOD MODIFY_CHILDREN.
*--------------------------------------------------------------------*
* Process add/delete/change of the dependent objects
*--------------------------------------------------------------------*
    DATA: lo_children     TYPE REF TO if_genil_container_objectlist,
          lo_child        TYPE REF TO if_genil_container_object,
          lv_obj_name     TYPE crmt_ext_obj_name,
          ls_changed_obj  LIKE LINE OF ct_changed_objects,
          lo_pob_list     TYPE REF TO if_genil_container_objectlist.

    lo_children = io_object->get_children( iv_as_copy = abap_true ).

    lo_child = lo_children->get_first( ).
    WHILE lo_child IS BOUND.
      lv_obj_name = lo_child->get_name( ).
      CASE lv_obj_name.
        WHEN if_farrc_contr_mgmt=>co_on_pob .
          CALL METHOD modify_pob_list
            EXPORTING
              io_parent_obj      = io_object
              io_obj_list        = lo_children
            CHANGING
              ct_changed_objects = ct_changed_objects.
          EXIT.

        WHEN if_farrc_contr_mgmt=>co_on_add_deferral.
          CALL METHOD modify_deferral_list
            EXPORTING
              io_obj_list        = lo_children
            CHANGING
              ct_changed_objects = ct_changed_objects.
          EXIT.

        WHEN if_farrc_contr_mgmt=>co_on_chg_type.
          CALL METHOD modify_change_type_list
            EXPORTING
              io_obj_list        = lo_children
            CHANGING
              ct_changed_objects = ct_changed_objects.

* Manual Fulfillment, The code will be adjusted later
        WHEN if_farrc_contr_mgmt=>co_on_pob_ui.
          ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_pob_ui.
          ls_changed_obj-object_id   = lo_child->get_object_id( ).
          APPEND ls_changed_obj TO ct_changed_objects.

        WHEN if_farrc_contr_mgmt=>co_on_alloc_cond_type.
          CALL METHOD modify_cond_account
            EXPORTING
              io_parent_obj      = io_object
              io_obj_list        = lo_children
            CHANGING
              ct_changed_objects = ct_changed_objects.

        WHEN if_farrc_contr_mgmt=>co_on_conflict_ui.
          CALL METHOD modify_conflict
            EXPORTING
              io_obj_list        = lo_children   " Data Container: Object List Interface
            CHANGING
              ct_changed_objects = ct_changed_objects.   " Table of Object Instances in Generic IL
          .
*            CATCH cx_farr_message.    " Exception of FARR with message.

        WHEN OTHERS.

      ENDCASE.

      lo_child = lo_children->get_next( ).

    ENDWHILE.
  ENDMETHOD.                    "modify_children


  METHOD MODIFY_COND_ACCOUNT.

*--------------------------------------------------------------------*
*  Modify account in deferral item by condition type structure
*--------------------------------------------------------------------*
    DATA: lo_obj                 TYPE REF TO if_genil_container_object,
          lv_delta_flag          TYPE crmt_delta,
          ls_changed_obj         TYPE crmt_genil_obj_instance,
          lt_alloc_cond_type_chg TYPE farr_tt_cond_type_data,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol.

    lo_obj = io_obj_list->get_first( ).
    WHILE lo_obj IS BOUND.
      lv_delta_flag = lo_obj->get_delta_flag( ).
      IF lv_delta_flag = if_genil_cont_simple_object=>delta_changed.
        CALL METHOD collect_alloc_condtype_changed
          EXPORTING
            io_cond_type_obj = lo_obj
          CHANGING
            ct_cond_type_chg = lt_alloc_cond_type_chg.
      ENDIF.

      ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_alloc_cond_type.
      ls_changed_obj-object_id   = lo_obj->get_object_id( ).
      APPEND ls_changed_obj TO ct_changed_objects.

      lo_obj = io_obj_list->get_next( ).
    ENDWHILE.

    lo_contract = get_contract( mv_contract_id ).
    CALL METHOD lo_contract->modify_defitem_by_cond_type
      EXPORTING
        it_cond_type_chg = lt_alloc_cond_type_chg.

  ENDMETHOD.                    "modify_cond_account


  METHOD MODIFY_CONFLICT.

    DATA:
      lv_delta_flag         TYPE crmt_delta,
      lts_conflict_add      TYPE farr_ts_manl_chng_data,
      lts_conflict_chg      TYPE farr_ts_manl_chng_data,
      lo_obj                TYPE REF TO if_genil_container_object,
      ls_changed_obj        TYPE crmt_genil_obj_instance,
      lx_farr_message       TYPE REF TO cx_farr_message,
      lt_conflict_del       TYPE farr_tt_manl_chng_data,
      lo_contract           TYPE REF TO if_farr_contract_mgmt_bol.

    lo_obj = io_obj_list->get_first( ).
    WHILE lo_obj IS BOUND.
      IF lo_obj->get_name( ) = if_farrc_contr_mgmt=>co_on_conflict_ui. "'FarrConflictUI'.

        lv_delta_flag = lo_obj->get_delta_flag( ).
        CASE lv_delta_flag.

*        WHEN if_genil_cont_simple_object=>delta_created.
*
*          CALL METHOD collect_conflict_created
*            EXPORTING
*              io_conflict_obj = lo_obj
*              iv_pob_id       = ls_pob_key-pob_id
*            CHANGING
*              ct_conflict_add = lt_conflict_add.

          WHEN if_genil_cont_simple_object=>delta_changed.

            CALL METHOD collect_conflict_changed
              EXPORTING
                io_conflict_obj  = lo_obj
              CHANGING
                cts_conflict_chg = lts_conflict_chg.

          WHEN if_genil_cont_simple_object=>delta_deleted.

            CALL METHOD collect_conflict_deleted
              EXPORTING
                io_conflict_obj = lo_obj
              CHANGING
                ct_conflict_del = lt_conflict_del.

          WHEN OTHERS.

        ENDCASE.

        ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_conflict_ui.
        ls_changed_obj-object_id   = lo_obj->get_object_id( ).
        APPEND ls_changed_obj TO ct_changed_objects.

        lo_obj = io_obj_list->get_next( ).

      ENDIF.

    ENDWHILE.

    TRY .

        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->modify_conflict
          EXPORTING
            it_conflict_del         = lt_conflict_del
            its_conflict_buffer_chg = lts_conflict_chg.

      CATCH cx_farr_message INTO lx_farr_message.
        "TODO
        RAISE EXCEPTION lx_farr_message.
    ENDTRY.

  ENDMETHOD.                    "modify_conflict


  METHOD MODIFY_CONTRACT.
    DATA: lo_props_obj         TYPE REF TO if_genil_obj_attr_properties,
          lt_changed_attr      TYPE crmt_attr_name_tab,
          ls_contract_data_chg TYPE farr_s_contract_data,
          ls_changed_obj       TYPE crmt_genil_obj_instance,
          lo_contract          TYPE REF TO if_farr_contract_mgmt_bol.

    IF io_contract_obj->get_delta_flag( ) = if_genil_cont_simple_object=>delta_changed.
      lo_props_obj = io_contract_obj->get_attr_props_obj( ).
      CALL METHOD lo_props_obj->get_name_tab_4_property
        EXPORTING
          iv_property = if_genil_obj_attr_properties=>modified
        IMPORTING
          et_names    = lt_changed_attr.

      CALL METHOD io_contract_obj->get_attributes
        IMPORTING
          es_attributes = ls_contract_data_chg.

      lo_contract = get_contract( mv_contract_id ).

      CALL METHOD lo_contract->modify_contract
        EXPORTING
          is_contract_data_chg = ls_contract_data_chg
          it_changed_attr      = lt_changed_attr.

* Update changed object
      ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_contract.
      ls_changed_obj-object_id   = io_contract_obj->get_object_id( ).
      APPEND ls_changed_obj TO ct_changed_objects.
    ENDIF.

  ENDMETHOD.                    "modify_contract


  METHOD MODIFY_DEFERRAL_LIST.
    DATA: lo_obj                TYPE REF TO if_genil_container_object,
          lo_pob                TYPE REF TO if_genil_container_object,
          ls_pob_key            TYPE farr_s_pob_key,
          lx_farr_message       TYPE REF TO cx_farr_message,
          lv_delta_flag         TYPE crmt_delta,
          lt_deferral_add       TYPE farr_tt_deferral_data,
          lt_deferral_chg       TYPE farr_tt_deferral_data_with_att,
          lt_deferral_del       TYPE farr_tt_deferral_key,
          ls_changed_obj        TYPE crmt_genil_obj_instance,
          lv_obj_id             TYPE crmt_genil_object_id,
          lo_contract           TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
            <ls_deferral_key>    TYPE farr_s_deferral_key.

    lo_obj = io_obj_list->get_first( ).
* Get attributes of POB
    lo_pob = lo_obj->get_parent( ).
    IF lo_pob IS BOUND.
      CALL METHOD lo_pob->get_key
        IMPORTING
          es_key = ls_pob_key.

      IF lo_obj IS BOUND.
        WHILE lo_obj IS BOUND.
          IF lo_obj->get_name( ) = if_farrc_contr_mgmt=>co_on_add_deferral.
            lv_delta_flag = lo_obj->get_delta_flag( ).
            CASE lv_delta_flag.
              WHEN if_genil_cont_simple_object=>delta_created.
                CALL METHOD collect_deferral_created
                  EXPORTING
                    io_deferral_obj = lo_obj
                    iv_pob_id       = ls_pob_key-pob_id
                  CHANGING
                    ct_deferral_add = lt_deferral_add.

              WHEN if_genil_cont_simple_object=>delta_changed.
                CALL METHOD collect_deferral_changed
                  EXPORTING
                    io_deferral_obj = lo_obj
                  CHANGING
                    ct_deferral_chg = lt_deferral_chg.

              WHEN if_genil_cont_simple_object=>delta_deleted.
                CALL METHOD collect_deferral_deleted
                  EXPORTING
                    io_deferral_obj = lo_obj
                  CHANGING
                    ct_deferral_del = lt_deferral_del.

              WHEN OTHERS.
            ENDCASE.

* Update changed object
            ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_add_deferral.
            ls_changed_obj-object_id   = lo_obj->get_object_id( ).
            APPEND ls_changed_obj TO ct_changed_objects.
          ENDIF.

          lo_obj = io_obj_list->get_next( ).
        ENDWHILE.

        TRY .

            lo_contract = get_contract( mv_contract_id ).

            CALL METHOD lo_contract->modify_deferral
              EXPORTING
                it_deferral_add = lt_deferral_add
                it_deferral_chg = lt_deferral_chg
                it_deferral_del = lt_deferral_del.
          CATCH cx_farr_message INTO lx_farr_message.
* Error happened:
* Remove the to-be-deleted Deferral out of Changed_Objects
* Otherwise, the Deferral will be deleted from the UI
            LOOP AT lt_deferral_del ASSIGNING <ls_deferral_key>.
              lv_obj_id = cl_crm_genil_container_tools=>build_object_id( <ls_deferral_key> ).

              DELETE ct_changed_objects WHERE object_id = lv_obj_id.
            ENDLOOP.

            RAISE EXCEPTION lx_farr_message.
        ENDTRY.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "modify_deferral_list


  METHOD MODIFY_POB_LIST.
    DATA: lo_obj                TYPE REF TO if_genil_container_object,
          lx_farr_message       TYPE REF TO cx_farr_message,
          lv_delta_flag         TYPE crmt_delta,
          lt_pob_add            TYPE farr_tt_pob_data,
          lt_pob_chg            TYPE farr_tt_pob_data_with_attr,
          lt_pob_del            TYPE farr_tt_pob_id,
          ls_changed_obj        TYPE crmt_genil_obj_instance,
          lt_other_changed_pob  TYPE farr_tt_pob_id,
          ls_pob_key            TYPE farr_s_pob_key,
          ls_contract_key       TYPE farr_s_contract_key,
          lv_obj_id             TYPE crmt_genil_object_id,
          lo_contract     TYPE REF TO if_farr_contract_mgmt_bol.
    FIELD-SYMBOLS:
            <lv_pob_id>           TYPE farr_pob_id,
            <ls_reassign_handler> LIKE LINE OF mt_reassign_handler.

    lo_obj = io_obj_list->get_first( ).
    WHILE lo_obj IS BOUND.
      IF lo_obj->get_name( ) = if_farrc_contr_mgmt=>co_on_pob.
        lv_delta_flag = lo_obj->get_delta_flag( ).
        CASE lv_delta_flag.
          WHEN if_genil_cont_simple_object=>delta_created.
            CALL METHOD collect_pob_created
              EXPORTING
                io_pob_obj = lo_obj
              CHANGING
                ct_pob_add = lt_pob_add.

          WHEN if_genil_cont_simple_object=>delta_changed.
            CALL METHOD collect_pob_changed
              EXPORTING
                io_pob_obj = lo_obj
              CHANGING
                ct_pob_chg = lt_pob_chg.

          WHEN if_genil_cont_simple_object=>delta_deleted.
            CALL METHOD collect_pob_deleted
              EXPORTING
                io_pob_obj = lo_obj
              CHANGING
                ct_pob_del = lt_pob_del.

          WHEN OTHERS.
        ENDCASE.

* Update changed object
        ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_pob.
        ls_changed_obj-object_id   = lo_obj->get_object_id( ).
        APPEND ls_changed_obj TO ct_changed_objects.
      ENDIF.

* Recurrsive call to handle DeferralOfPOB
      TRY.
* Do not raise error message when create or delete RoR
          CALL METHOD modify_children
            EXPORTING
              io_object          = lo_obj
            CHANGING
              ct_changed_objects = ct_changed_objects.
        CATCH cx_farr_message INTO lx_farr_message.
          "Throw the exception of method CL_FARR_CONFLICT->CHECK_UPDATE_MODE_CONSISTENCY
          IF lx_farr_message->mv_msgid = 'FARR_CONTRACT_MAIN' AND lx_farr_message->mv_msgno = 250.
            RAISE EXCEPTION lx_farr_message.
          ENDIF.
      ENDTRY.

      lo_obj = io_obj_list->get_next( ).
    ENDWHILE.

    IF me->mv_flg_reassign = abap_true.
      io_parent_obj->get_key( IMPORTING es_key = ls_contract_key ).

      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY contract_id = ls_contract_key-contract_id.
      IF sy-subrc = 0.
        " the contract id comes from UI, it should not be anonymous one
        get_contract(
          EXPORTING
            iv_contract_id      = <ls_reassign_handler>-contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract     = lo_contract
        ).
      ENDIF.
    ELSE.
      lo_contract = get_contract( mv_contract_id ).
    ENDIF.

    TRY .
        CALL METHOD lo_contract->modify_pob
          EXPORTING
            it_pob_add           = lt_pob_add
            it_pob_chg           = lt_pob_chg
            it_pob_del           = lt_pob_del
          IMPORTING
            et_other_changed_pob = lt_other_changed_pob.
      CATCH cx_farr_message INTO lx_farr_message.
* Error happened:
* Remove the to-be-deleted POB out of Changed_Objects
* Otherwise, the POB will be deleted from the UI
        LOOP AT lt_pob_del ASSIGNING <lv_pob_id>.
          ls_pob_key-pob_id = <lv_pob_id>.
          lv_obj_id         = cl_crm_genil_container_tools=>build_object_id( ls_pob_key ).

          DELETE ct_changed_objects WHERE object_id = lv_obj_id.
        ENDLOOP.
    ENDTRY.

    LOOP AT lt_other_changed_pob ASSIGNING <lv_pob_id>.
      ls_pob_key-pob_id = <lv_pob_id>.

* Update changed object
      ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_pob.
      ls_changed_obj-object_id   = cl_crm_genil_container_tools=>build_object_id( ls_pob_key ).
      APPEND ls_changed_obj TO ct_changed_objects.
    ENDLOOP.

* raise exception at the end
    IF lx_farr_message IS BOUND.
      RAISE EXCEPTION lx_farr_message.
    ENDIF.

  ENDMETHOD.                    "modify_pob_list


  METHOD MODIFY_ROOT_OBJECT.
    DATA: lv_obj_name TYPE crmt_ext_obj_name.

    lv_obj_name = io_root_obj->get_name( ).
    CASE lv_obj_name.
      WHEN if_farrc_contr_mgmt=>co_on_contract.
        CALL METHOD modify_contract
          EXPORTING
            io_contract_obj    = io_root_obj
          CHANGING
            ct_changed_objects = ct_changed_objects.
      WHEN if_farrc_contr_mgmt=>co_on_rev_spreading.
        CALL METHOD modify_spreading
          EXPORTING
            io_spreading_obj   = io_root_obj
          CHANGING
            ct_changed_objects = ct_changed_objects.

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "modify_root_object


  METHOD MODIFY_SPREADING.
    DATA: lo_props_obj          TYPE REF TO if_genil_obj_attr_properties,
          lt_changed_attr       TYPE crmt_attr_name_tab,
          ls_spreading_data_chg TYPE farr_s_rev_spreading_data,
          ls_spreading_key      TYPE farr_s_rev_schedule_key,
          ls_changed_obj        TYPE crmt_genil_obj_instance.

    IF io_spreading_obj->get_delta_flag( ) = if_genil_cont_simple_object=>delta_changed.
      lo_props_obj = io_spreading_obj->get_attr_props_obj( ).
      CALL METHOD lo_props_obj->get_name_tab_4_property
        EXPORTING
          iv_property = if_genil_obj_attr_properties=>modified
        IMPORTING
          et_names    = lt_changed_attr.

      CALL METHOD io_spreading_obj->get_attributes
        IMPORTING
          es_attributes = ls_spreading_data_chg.

      CALL METHOD io_spreading_obj->get_key
        IMPORTING
          es_key = ls_spreading_key.
      MOVE-CORRESPONDING ls_spreading_key TO ls_spreading_data_chg.

      CALL METHOD mo_rev_spreading->modify_rev_spreading
        EXPORTING
          is_spreading_data_chg = ls_spreading_data_chg.

* Update changed object
      ls_changed_obj-object_name = if_farrc_contr_mgmt=>co_on_rev_spreading.
      ls_changed_obj-object_id   = io_spreading_obj->get_object_id( ).
      APPEND ls_changed_obj TO ct_changed_objects.
    ENDIF.

  ENDMETHOD.                    "modify_contract


  METHOD MSG_CONTRACT_SELECTED.
    DATA: lo_msg_cont TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_msgno    TYPE symsgno,
          lv_msgv1    TYPE sy-msgv1,
          lv_msgv2    TYPE sy-msgv2.

    lo_msg_cont = io_root_list->get_global_message_container( ).
    lo_msg_cont->reset( ).

    lv_msgv1 = iv_num_of_contract.

    IF iv_num_of_contract > 0.
* &1 contracts found
      MESSAGE s001(farr_contract_bol) WITH iv_num_of_contract INTO mv_msg_str.
      lv_msgno = 001.
      CALL METHOD lo_msg_cont->add_message
        EXPORTING
          iv_msg_type       = 'S'
          iv_msg_id         = 'FARR_CONTRACT_BOL'
          iv_msg_number     = lv_msgno
          iv_msg_text       = mv_msg_str
          iv_msg_v1         = lv_msgv1
          iv_show_only_once = abap_true.
    ELSEIF iv_contract_archived EQ abap_true.
      MESSAGE s002(farr_contract_bol) INTO mv_msg_str.
      lv_msgno = 002.
      CALL METHOD lo_msg_cont->add_message
        EXPORTING
          iv_msg_type       = 'S'
          iv_msg_id         = 'FARR_CONTRACT_BOL'
          iv_msg_number     = lv_msgno
          iv_msg_text       = mv_msg_str
          iv_show_only_once = abap_true.
    ELSEIF iv_contract_archived EQ abap_false.
      MESSAGE s008(farr_contract_bol) INTO mv_msg_str.
      lv_msgno = 008.
      CALL METHOD lo_msg_cont->add_message
        EXPORTING
          iv_msg_type       = 'S'
          iv_msg_id         = 'FARR_CONTRACT_BOL'
          iv_msg_number     = lv_msgno
          iv_msg_text       = mv_msg_str
          iv_show_only_once = abap_true.
    ENDIF.


    IF iv_number_after_check <> iv_number_before_check.
      MESSAGE w007(farr_contract_bol) INTO mv_msg_str.
      lv_msgno = 007.
      CALL METHOD lo_msg_cont->add_message
        EXPORTING
          iv_msg_type       = 'W'
          iv_msg_id         = 'FARR_CONTRACT_BOL'
          iv_msg_number     = lv_msgno
          iv_msg_text       = mv_msg_str
          iv_show_only_once = abap_true.
    ENDIF.

  ENDMETHOD.                    "msg_contract_selected


  METHOD PEER_CREATE_COMPOUND_POB.

    DATA: ls_new_compound_pob         TYPE farr_s_pob_data_buffer,
          ls_reassign_handler         TYPE ty_s_reassign_handler,
          lo_contract_for_bol         TYPE REF TO if_farr_contract_mgmt_bol,"Inorder to remove mo_contract_mgmt
          ls_reassign_header          TYPE farr_s_reassign_header,
          lx_farr_message             TYPE REF TO cx_farr_message,
          lo_msg_cont                 TYPE REF TO cl_crm_genil_global_mess_cont.


    FIELD-SYMBOLS:
          <ls_param>          TYPE crmt_name_value_pair.

* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    LOOP AT it_parameter ASSIGNING <ls_param>.
      CASE <ls_param>-name.
* compound pob information
        WHEN if_farrc_contr_mgmt=>co_an_target_new_compound_pob.
          cl_abap_container_utilities=>read_container_c(
         EXPORTING
           im_container = <ls_param>-value
         IMPORTING
           ex_value     = ls_new_compound_pob
       ).
      ENDCASE.

    ENDLOOP.

    ls_new_compound_pob-distinct_type = if_farrc_contr_mgmt=>co_distinct_type_compound.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_contract_for_bol->peer_build_new_compound_pob( is_new_compound_pob = ls_new_compound_pob ).

  ENDMETHOD.                    "peer_create_compound_pob


  METHOD READ_ADDITION_DEFERRAL.
    DATA: ls_deferral_key         TYPE farr_s_deferral_key,
          ls_deferral_data_buffer TYPE farr_s_deferral_data_buffer,
          ls_deferral_data        TYPE farr_s_deferral_data,
          lo_contract_for_bol     TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_pob>                  TYPE farr_s_deferral_data,
          <ls_deferral_data_buffer> TYPE farr_s_deferral_data_buffer.

    CALL METHOD io_deferral_obj->get_key
      IMPORTING
        es_key = ls_deferral_key.

    IF ls_deferral_key IS INITIAL.
* POB key initial: set POB keys for all POBs of the contract
      set_bol_keys_deferral( io_deferral_obj ).

* Re-read the new set key
      CALL METHOD io_deferral_obj->get_key
        IMPORTING
          es_key = ls_deferral_key.
    ENDIF.

    IF ls_deferral_key IS NOT INITIAL.
      IF io_deferral_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_deferral
          EXPORTING
            is_deferral_key         = ls_deferral_key
          IMPORTING
            es_deferral_data_buffer = ls_deferral_data_buffer.

        MOVE-CORRESPONDING ls_deferral_data_buffer TO ls_deferral_data.
        io_deferral_obj->set_attributes( ls_deferral_data ).

        set_attr_property_deferral( io_deferral_obj ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_addition_deferral


  METHOD READ_ADDITION_DEFERRAL_OF_POB.
    DATA: ls_deferral_key         TYPE farr_s_deferral_key,
          ls_deferral_data_buffer TYPE farr_s_deferral_data_buffer,
          ls_deferral_data        TYPE farr_s_deferral_data,
          lo_contract_for_bol     TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_pob>                  TYPE farr_s_deferral_data,
          <ls_deferral_data_buffer> TYPE farr_s_deferral_data_buffer.

    CALL METHOD io_deferral_obj->get_key
      IMPORTING
        es_key = ls_deferral_key.

    IF ls_deferral_key IS INITIAL.
* POB key initial: set POB keys for all POBs of the contract
      set_bol_keys_deferral_by_pob( io_deferral_obj ).

* Re-read the new set key
      CALL METHOD io_deferral_obj->get_key
        IMPORTING
          es_key = ls_deferral_key.
    ENDIF.

    IF ls_deferral_key IS NOT INITIAL.
      IF io_deferral_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_deferral
          EXPORTING
            is_deferral_key         = ls_deferral_key
          IMPORTING
            es_deferral_data_buffer = ls_deferral_data_buffer.

        MOVE-CORRESPONDING ls_deferral_data_buffer TO ls_deferral_data.
        io_deferral_obj->set_attributes( ls_deferral_data ).

        set_attr_property_deferral( io_deferral_obj ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_addition_deferral


  METHOD READ_ADDITION_POB_OF_POB.
    DATA: ls_addi_pob_key         TYPE farr_s_pob_key,
          ls_addi_pob_data_buffer TYPE farr_s_pob_data_buffer,
          ls_addi_pob_data        TYPE farr_s_pob_data,
          lo_contract_for_bol     TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_pob>                  TYPE farr_s_pob_data,
          <ls_addi_pob_data_buffer> TYPE farr_s_pob_data_buffer.

    CALL METHOD io_addi_pob_obj->get_key
      IMPORTING
        es_key = ls_addi_pob_key.

    IF ls_addi_pob_key IS INITIAL.
* POB key initial: set POB keys for all POBs of the contract
      set_bol_keys_addi_pob_by_pob( io_addi_pob_obj ).

* Re-read the new set key
      CALL METHOD io_addi_pob_obj->get_key
        IMPORTING
          es_key = ls_addi_pob_key.
    ENDIF.

    IF ls_addi_pob_key IS NOT INITIAL.
      IF io_addi_pob_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_pob
          EXPORTING
            iv_pob_id          = ls_addi_pob_key-pob_id
          IMPORTING
            es_pob_data_buffer = ls_addi_pob_data_buffer.

        MOVE-CORRESPONDING ls_addi_pob_data_buffer TO ls_addi_pob_data.
        IF ls_addi_pob_data_buffer-crt_flag IS INITIAL.
          TRY .
              build_pob_attr_changeable_list(
                EXPORTING
                  is_pob_data = ls_addi_pob_data
              ).
            CATCH cx_farr_message.
          ENDTRY.
          set_attr_property_pob( io_addi_pob_obj ).
        ELSE.
* New POB, clear the temp POB_ID for UI display
          CLEAR ls_addi_pob_data-pob_id.
          set_attr_property_new_pob( EXPORTING io_pob_obj = io_addi_pob_obj
                                               iv_new_pob_kind = 'A' ).
        ENDIF.

        io_addi_pob_obj->set_attributes( ls_addi_pob_data ).

      ENDIF.
    ENDIF.


  ENDMETHOD.                    "read_addition_deferral


  METHOD READ_ALLOC_CONDTYPE.

    DATA: ls_cond_type_key     TYPE farr_s_cond_type_key,
          ls_cond_type_data_ui TYPE farr_s_cond_type_data_ui,
          lt_changeable_field  TYPE crmt_attr_name_tab,
          lo_contract_for_bol  TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_condtype_obj->get_key
      IMPORTING
        es_key = ls_cond_type_key.

    IF ls_cond_type_key IS INITIAL.
* defitem key initial: set defitem keys for all defitems of the contract
      set_bol_keys_alloc_condtype( io_condtype_obj ).

* Re-read the new set key
      CALL METHOD io_condtype_obj->get_key
        IMPORTING
          es_key = ls_cond_type_key.
    ENDIF.

    IF ls_cond_type_key IS NOT INITIAL.
      IF io_condtype_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_alloc_condtype
          EXPORTING
            is_cond_type_key     = ls_cond_type_key
          IMPORTING
            es_cond_type_data_ui = ls_cond_type_data_ui.

        APPEND if_farrc_contr_mgmt=>co_an_source_account TO lt_changeable_field.

        CALL METHOD set_attr_property
          EXPORTING
            io_obj              = io_condtype_obj
            it_changeable_field = lt_changeable_field.

        io_condtype_obj->set_attributes( ls_cond_type_data_ui ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_condtype


  METHOD READ_CHANGE_TYPE_OF_CONTRACT.
    DATA: ls_chg_type_key         TYPE farr_s_chg_type_key,
          ls_chg_type             TYPE farr_s_chg_type,
          ls_chg_type_buffer      TYPE farr_s_chg_type_buffer,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_chg_type_obj->get_key
      IMPORTING
        es_key = ls_chg_type_key.

    IF ls_chg_type_key IS INITIAL.
* CHG_TYPE key initial: set change type keys for all change types of the pob
      set_bol_keys_chg_type_by_contr( io_chg_type_obj ).

* Re-read the new set key
      CALL METHOD io_chg_type_obj->get_key
        IMPORTING
          es_key = ls_chg_type_key.
    ENDIF.
*
    IF ls_chg_type_key IS NOT INITIAL.
      IF io_chg_type_obj->check_attr_requested( ) = abap_true.

        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_single_change_type
          EXPORTING
            is_change_type_key    = ls_chg_type_key
          IMPORTING
            es_change_type_buffer = ls_chg_type_buffer.

        MOVE-CORRESPONDING ls_chg_type_buffer TO ls_chg_type.

        build_chg_type_attr_chg_list(
          EXPORTING
                  is_change_type = ls_chg_type
              ).

        set_attr_property_chg_type( io_chg_type_obj ).

        io_chg_type_obj->set_attributes( ls_chg_type ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_change_type_of_contract only for allocation POBs


  METHOD READ_CHANGE_TYPE_OF_POB.
    DATA: ls_chg_type_key     TYPE farr_s_chg_type_key,
          ls_chg_type         TYPE farr_s_chg_type,
          ls_chg_type_buffer  TYPE farr_s_chg_type_buffer,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_chg_type_obj->get_key
      IMPORTING
        es_key = ls_chg_type_key.

    IF ls_chg_type_key IS INITIAL.
* CHG_TYPE key initial: set change type keys for all change types of the pob
      set_bol_keys_chg_type_by_pob( io_chg_type_obj ).

* Re-read the new set key
      CALL METHOD io_chg_type_obj->get_key
        IMPORTING
          es_key = ls_chg_type_key.
    ENDIF.
*
    IF ls_chg_type_key IS NOT INITIAL.
      IF io_chg_type_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_change_type
          EXPORTING
            is_change_type_key    = ls_chg_type_key
          IMPORTING
            es_change_type_buffer = ls_chg_type_buffer.

        MOVE-CORRESPONDING ls_chg_type_buffer TO ls_chg_type.

        build_chg_type_attr_chg_list(
          EXPORTING
                  is_change_type = ls_chg_type
              ).

        set_attr_property_chg_type( io_chg_type_obj ).

        io_chg_type_obj->set_attributes( ls_chg_type ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_addition_defitem


  METHOD READ_CHILDREN.


    DATA: lo_children     TYPE REF TO if_genil_container_objectlist,
          lo_child        TYPE REF TO if_genil_container_object,
          lv_obj_name     TYPE crmt_ext_obj_name,
          lv_rel_name     TYPE crmt_relation_name.

    lo_children = io_object->get_children( iv_as_copy = abap_false ).

    lv_obj_name = io_object->get_name( ).

    lo_child = lo_children->get_first( ).
    WHILE lo_child IS BOUND.

      lv_obj_name = lo_child->get_name( ).
      READ TABLE it_request_objects
           TRANSPORTING NO FIELDS
           WITH TABLE KEY object_name = lv_obj_name.
      IF sy-subrc = 0.
        CALL METHOD lo_child->get_parent_relation
          IMPORTING
            ev_relation_name = lv_rel_name.

        CASE lv_rel_name.
          WHEN if_farrc_contr_mgmt=>co_rel_contract_pob.
            read_pob( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_contract_pob_all.
            read_pob_all( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_contract_pobui.
            read_pobui( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_contract_adddefer.
            read_addition_deferral( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_contract_deferitem.
            read_defitem( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_pob_condtype.
            read_condtype( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_pob_allo_cond_type.
            read_alloc_condtype( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_pob_document.
            read_document( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_pob_type.
            read_pob_type( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_pob_fulfill.
            read_fulfill_of_pob( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_conflict_ui.
            read_conflict_ui( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_deferitem_fulfill.
            read_fulfill_of_defitem( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_addi_def_pob.
            read_addition_deferral_of_pob( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_addi_pob_pob.
            read_addition_pob_of_pob( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_defitem_pob.
            read_defitem_of_pob( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_conflict_of_pob.
            read_conflict_ui( lo_child ).

          WHEN if_farrc_contr_mgmt=>co_rel_chg_type_pob.
            read_change_type_of_pob( lo_child ).

*          WHEN if_farrc_contr_mgmt=>co_rel_contract_changetype.
*            read_change_type_of_contract( lo_child ).

          WHEN OTHERS.
        ENDCASE.
      ENDIF.

      IF lo_child->check_rels_requested( ) = abap_true.
        read_children(
          it_request_objects = it_request_objects
          io_object          = lo_child
        ).
      ENDIF.

      lo_child = lo_children->get_next( ).
    ENDWHILE.


  ENDMETHOD.                    "process_children


  METHOD READ_CONDTYPE.
    DATA: ls_cond_type_key         TYPE farr_s_cond_type_key,
          ls_cond_type_data_buffer TYPE farr_s_cond_type_buffer,
          ls_cond_type_data        TYPE farr_s_cond_type_data,
          lo_contract_for_bol      TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_condtype_obj->get_key
      IMPORTING
        es_key = ls_cond_type_key.

    IF ls_cond_type_key IS INITIAL.
* defitem key initial: set defitem keys for all defitems of the contract
      set_bol_keys_condtype( io_condtype_obj ).

* Re-read the new set key
      CALL METHOD io_condtype_obj->get_key
        IMPORTING
          es_key = ls_cond_type_key.
    ENDIF.

    IF ls_cond_type_key IS NOT INITIAL.
      IF io_condtype_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_condtype
          EXPORTING
            is_cond_type_key         = ls_cond_type_key
          IMPORTING
            es_cond_type_data_buffer = ls_cond_type_data_buffer.

        IF ls_cond_type_data_buffer-del_flag = abap_true.
          CLEAR ls_cond_type_data_buffer-betrw.
        ELSE.
          MOVE-CORRESPONDING ls_cond_type_data_buffer TO ls_cond_type_data.
        ENDIF.
        io_condtype_obj->set_attributes( ls_cond_type_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_condtype


  METHOD READ_CONFLICT_OBJECT.
    DATA: ls_conflict_key       TYPE farr_s_conflict_manl_chng_key,
          lo_conflict_mgmt      TYPE REF TO if_farr_conflict_mgmt.

    CALL METHOD io_object->get_key
      IMPORTING
        es_key = ls_conflict_key.

*  CREATE OBJECT lo_conflict_mgmt TYPE cl_farr_conflict_mgmt.

*  lo_conflict_mgmt->read_ui_data_by_contract_id(
*  EXPORTING
*    IV_CONTRACT_ID = ''
*  IMPORTING
*    et_conflict_data_ui = ''
*  ).

  ENDMETHOD.                    "read_conflict_object


  METHOD READ_CONFLICT_UI.
    DATA: ls_conflict_ui_key  TYPE farr_s_conflict_manl_chng_key,
          ls_manual_chng_data TYPE farr_s_manl_chng_data,
          ls_conflict_ui_data TYPE farr_s_conflict_data_ui,
          ls_pob_data_buffer  TYPE farr_s_pob_data_buffer,
          lv_field_desc       TYPE string,
          lv_field_name       TYPE dfies-fieldname,
          lv_table_name       TYPE ddobjname,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_conflict_ui_obj->get_key
      IMPORTING
        es_key = ls_conflict_ui_key.

    IF ls_conflict_ui_key IS INITIAL.
      set_bol_keys_conflict_ui( io_conflict_ui_obj ).

      CALL METHOD io_conflict_ui_obj->get_key
        IMPORTING
          es_key = ls_conflict_ui_key.
    ENDIF.

    IF ls_conflict_ui_key IS NOT INITIAL.
      IF io_conflict_ui_obj->check_attr_requested( ) = abap_true.
        CALL METHOD mo_conflict_mgmt->read_single_manual_change
          EXPORTING
            is_manual_change_key  = ls_conflict_ui_key    " Performance Obligation Type
          IMPORTING
            es_manual_change_data = ls_manual_chng_data.

        MOVE-CORRESPONDING ls_manual_chng_data TO ls_conflict_ui_data.
        ls_conflict_ui_data-rai_value = ls_manual_chng_data-org_value.

        CLEAR ls_pob_data_buffer.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_pob
          EXPORTING
            iv_pob_id          = ls_manual_chng_data-pob_id
          IMPORTING
            es_pob_data_buffer = ls_pob_data_buffer.

        ls_conflict_ui_data-pob_name = ls_pob_data_buffer-pob_name.

        get_conflict_desc( CHANGING cs_conflict_ui_data = ls_conflict_ui_data ).

        io_conflict_ui_obj->set_attributes( ls_conflict_ui_data ).

        CALL METHOD set_attr_property
          EXPORTING
            io_obj              = io_conflict_ui_obj
            it_changeable_field = mt_changeable_field_conflict.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "read_conflict_ui


  METHOD READ_CONTRACT_4_PROPOSAL.
    DATA: ls_contract_key         TYPE farr_s_contract_key,
          ls_contract_data        TYPE farr_s_contract_data,
          lt_contract_data        TYPE farr_tt_contract_data.

    CALL METHOD io_contract_obj->get_key
      IMPORTING
        es_key = ls_contract_key.

    IF ls_contract_key IS INITIAL.
*      CALL METHOD set_bol_key_for_contract
*        EXPORTING
*          io_contract_obj  = io_contract_obj
*        IMPORTING
*          et_contract_data = lt_contract_data.

      CALL METHOD io_contract_obj->get_key
        IMPORTING
          es_key = ls_contract_key.
    ENDIF.

    IF ls_contract_key IS NOT INITIAL.
      IF io_contract_obj->check_attr_requested( ) = abap_true.
        READ TABLE lt_contract_data
              INTO ls_contract_data
          WITH KEY contract_id = ls_contract_key-contract_id.
        io_contract_obj->set_attributes( ls_contract_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_contract_4_proposal


  METHOD READ_CONTRACT_OBJECT.
    DATA: ls_contract_data_buffer TYPE farr_s_contract_data_buffer,
          ls_contract_data        TYPE farr_s_contract_data,
          lt_contract_data        TYPE farr_tt_contract_data,
          ls_t001                 TYPE t001,
          lt_event_type           TYPE farr_tt_event_type_range,
          ls_event_type           LIKE LINE OF lt_event_type,
          lt_contract_id          TYPE farr_tt_contract_id_range,
          ls_contract_id          LIKE LINE OF lt_contract_id,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_contract_data>      LIKE LINE OF lt_contract_data.

*Load contract if it is not loaded yet
    load_contract( io_contract_obj ).

    IF io_contract_obj->check_attr_requested( ) = abap_true.

      lo_contract = get_contract( mv_contract_id ).
      CALL METHOD lo_contract->read_contract_header
        IMPORTING
          es_contract_data_buffer = ls_contract_data_buffer.

      MOVE-CORRESPONDING ls_contract_data_buffer TO ls_contract_data.

* Manual Fulfill Status
      CALL METHOD cl_farr_contract_db_access=>ma_status_of_contract
        CHANGING
          cs_contract_data = ls_contract_data.

      io_contract_obj->set_attributes( ls_contract_data ).

      set_attr_property_contract( io_contract_obj ).
    ENDIF.
  ENDMETHOD.                    "read_contract_object


  METHOD READ_DEFITEM.
    DATA: ls_defitem_key         TYPE farr_s_defitem_key,
          ls_defitem_data_buffer TYPE farr_s_defitem_data_buffer,
          ls_defitem_data        TYPE farr_s_defitem_data,
          lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_defitem_obj->get_key
      IMPORTING
        es_key = ls_defitem_key.

    IF ls_defitem_key IS INITIAL.
* defitem key initial: set defitem keys for all defitems of the contract
      set_bol_keys_defitem( io_defitem_obj ).

* Re-read the new set key
      CALL METHOD io_defitem_obj->get_key
        IMPORTING
          es_key = ls_defitem_key.
    ENDIF.

    IF ls_defitem_key IS NOT INITIAL.
      IF io_defitem_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_defitem
          EXPORTING
            is_defitem_key         = ls_defitem_key
          IMPORTING
            es_defitem_data_buffer = ls_defitem_data_buffer.

        MOVE-CORRESPONDING ls_defitem_data_buffer TO ls_defitem_data.
        io_defitem_obj->set_attributes( ls_defitem_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_defitem


  METHOD READ_DEFITEM_OF_POB.
    DATA: ls_defitem_key         TYPE farr_s_defitem_key,
          ls_defitem_data_buffer TYPE farr_s_defitem_data_buffer,
          ls_defitem_data        TYPE farr_s_defitem_data,
          lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_pob>                  TYPE farr_s_defitem_data,
          <ls_defitem_data_buffer> TYPE farr_s_defitem_data_buffer.

    CALL METHOD io_defitem_obj->get_key
      IMPORTING
        es_key = ls_defitem_key.

    IF ls_defitem_key IS INITIAL.
* POB key initial: set POB keys for all POBs of the contract
      set_bol_keys_defitem_by_pob( io_defitem_obj ).

* Re-read the new set key
      CALL METHOD io_defitem_obj->get_key
        IMPORTING
          es_key = ls_defitem_key.
    ENDIF.

    IF ls_defitem_key IS NOT INITIAL.
      IF io_defitem_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_defitem
          EXPORTING
            is_defitem_key         = ls_defitem_key
          IMPORTING
            es_defitem_data_buffer = ls_defitem_data_buffer.

        MOVE-CORRESPONDING ls_defitem_data_buffer TO ls_defitem_data.
        io_defitem_obj->set_attributes( ls_defitem_data ).

*        set_attr_property_defitem( io_defitem_obj ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_addition_defitem


  METHOD READ_DOCUMENT.
    DATA: ls_document_key         TYPE farr_s_document_key,
          ls_document_data_buffer TYPE farr_s_document_data,
          ls_document_data        TYPE farr_s_document_data,
          lo_contract_for_bol     TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_document_obj->get_key
      IMPORTING
        es_key = ls_document_key.

    IF ls_document_key IS INITIAL.
* document key initial: set document keys for all documents of the POB
      set_bol_keys_document( io_document_obj ).

* Re-read the new set key
      CALL METHOD io_document_obj->get_key
        IMPORTING
          es_key = ls_document_key.
    ENDIF.

    IF ls_document_key IS NOT INITIAL.
      IF io_document_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_document_of_pob
          EXPORTING
            iv_pob_id          = ls_document_key-pob_id
          IMPORTING
            es_document_buffer = ls_document_data_buffer.

        MOVE-CORRESPONDING ls_document_data_buffer TO ls_document_data.
        io_document_obj->set_attributes( ls_document_data ).
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "read_document


  METHOD READ_FULFILL_OF_DEFITEM.
    DATA: ls_fulfill_key         TYPE farr_s_fulfill_key,
          ls_fulfill_data_buffer TYPE farr_s_fulfill_data_buffer,
          ls_fulfill_data        TYPE farr_s_fulfill_data,
          lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_fulfill_obj->get_key
      IMPORTING
        es_key = ls_fulfill_key.

    IF ls_fulfill_key IS INITIAL.
* fulfill key initial: set fulfill keys for all fulfills of the contract
      set_bol_keys_fulfill( io_fulfill_obj ).

* Re-read the new set key
      CALL METHOD io_fulfill_obj->get_key
        IMPORTING
          es_key = ls_fulfill_key.
    ENDIF.

    IF ls_fulfill_key IS NOT INITIAL.
      IF io_fulfill_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_fulfill
          EXPORTING
            iv_fulfill_guid        = ls_fulfill_key-guid
          IMPORTING
            es_fulfill_data_buffer = ls_fulfill_data_buffer.

        MOVE-CORRESPONDING ls_fulfill_data_buffer TO ls_fulfill_data.
        io_fulfill_obj->set_attributes( ls_fulfill_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_fulfill_of_defitem


  METHOD READ_FULFILL_OF_POB.
    DATA: ls_fulfill_key         TYPE farr_s_fulfill_key,
          ls_fulfill_data_buffer TYPE farr_s_fulfill_data_buffer,
          ls_fulfill_data        TYPE farr_s_fulfill_data,
          lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_fulfill_obj->get_key
      IMPORTING
        es_key = ls_fulfill_key.

    IF ls_fulfill_key IS INITIAL.
* fulfill key initial: set fulfill keys for all fulfills of the contract
      set_bol_keys_fulfill_by_pob( io_fulfill_obj ).

* Re-read the new set key
      CALL METHOD io_fulfill_obj->get_key
        IMPORTING
          es_key = ls_fulfill_key.
    ENDIF.

    IF ls_fulfill_key IS NOT INITIAL.
      IF io_fulfill_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_fulfill
          EXPORTING
            iv_fulfill_guid        = ls_fulfill_key-guid
          IMPORTING
            es_fulfill_data_buffer = ls_fulfill_data_buffer.

        MOVE-CORRESPONDING ls_fulfill_data_buffer TO ls_fulfill_data.
        io_fulfill_obj->set_attributes( ls_fulfill_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_fulfill_of_defitem


  METHOD READ_POB.
    DATA: ls_pob_key          TYPE farr_s_pob_key,
          ls_pob_data_buffer  TYPE farr_s_pob_data_buffer,
          ls_pob_data         TYPE farr_s_pob_data,
          lo_attr_props       TYPE REF TO if_genil_obj_attr_properties,
          lv_new_pob_kind     TYPE string,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.


    lo_contract_for_bol = get_contract( mv_contract_id ).

    CHECK lo_contract_for_bol IS BOUND.

    CALL METHOD io_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    IF ls_pob_key IS INITIAL.
* POB key initial: set POB keys for all POBs of the contract
      set_bol_keys_pob( io_pob_obj ).

* Re-read the new set key
      CALL METHOD io_pob_obj->get_key
        IMPORTING
          es_key = ls_pob_key.
    ENDIF.

    IF ls_pob_key IS NOT INITIAL.
      IF io_pob_obj->check_attr_requested( ) = abap_true.
        CALL METHOD lo_contract_for_bol->read_single_pob
          EXPORTING
            iv_pob_id          = ls_pob_key-pob_id
            iv_include_deleted = abap_true
          IMPORTING
            es_pob_data_buffer = ls_pob_data_buffer.

        MOVE-CORRESPONDING ls_pob_data_buffer TO ls_pob_data.
        IF ls_pob_data_buffer-crt_flag IS INITIAL.
          TRY .
              build_pob_attr_changeable_list(
                EXPORTING
                  is_pob_data = ls_pob_data
              ).
            CATCH cx_farr_message.
          ENDTRY.
          set_attr_property_pob( io_pob_obj ).
        ELSE.
* New POB, clear the temp POB_ID for UI display (compound or additional)
          IF ls_pob_data_buffer-pob_id CS if_farrc_contr_mgmt=>co_pob_temp_id_prefix.
* The temp ID is not finalized yet, so clear it
            CLEAR ls_pob_data-pob_id.
          ELSE.
* Mark the POB ID as deactivated on UI as it is not saved in DB yet
* to disallow the link of the POB ID be clicked from POB list
            lo_attr_props = io_pob_obj->get_attr_props_obj( ).
            CALL METHOD lo_attr_props->set_property_by_name
              EXPORTING
                iv_name  = if_farrc_contr_mgmt=>co_an_pob_id
                iv_value = if_genil_obj_attr_properties=>deactivated.

          ENDIF.

          IF ls_pob_data-pob_role = if_farrc_contr_mgmt=>co_pob_role_additional.
            lv_new_pob_kind = 'A'.
          ELSE.
            IF ls_pob_data-distinct_type = if_farrc_contr_mgmt=>co_distinct_type_compound.
              lv_new_pob_kind = 'C'.
            ENDIF.
          ENDIF.
          set_attr_property_new_pob( EXPORTING io_pob_obj = io_pob_obj
                                               iv_new_pob_kind = lv_new_pob_kind ).
        ENDIF.

        IF ls_pob_data_buffer-soft_deleted IS INITIAL.
          ls_pob_data_buffer-del_flag = abap_true.
*          MESSAGE e003(farr_contract_bol) WITH lv_msgv_contract_id INTO mv_msg_str.
*          TRY.
*              CALL METHOD mo_msg_handler->add_symessage.
*            CATCH cx_farr_message .
*          ENDTRY.
        ENDIF.

        io_pob_obj->set_attributes( ls_pob_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_pob


  METHOD READ_POBUI.
    DATA: ls_pob_key           TYPE farr_s_pob_key,
          ls_pob_data_buffer   TYPE farr_s_pob_data_buffer,
          ls_pob_data          TYPE farr_s_pob_data_ui,
          lt_pob_fulfillmts    TYPE farr_tt_fulfill_data_buffer,
          lv_pob_fulfillable   TYPE abap_bool,
          lv_pob_id            TYPE farr_pob_id,
          lo_man_contract_mgmt TYPE REF TO cl_farr_manual_contract_mgmt,
          lo_contract_for_bol  TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_pob_fulfillmts> LIKE LINE OF lt_pob_fulfillmts,
          <ls_fulfill_data>   TYPE farr_tt_fulfill_data.

    CALL METHOD io_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    IF ls_pob_key IS INITIAL.
* POB key initial: set POB keys for all POBs of the contract
      set_bol_keys_pob( io_pob_obj ).

* Re-read the new set key
      CALL METHOD io_pob_obj->get_key
        IMPORTING
          es_key = ls_pob_key.
    ENDIF.

    IF ls_pob_key IS NOT INITIAL.
      IF io_pob_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        lo_man_contract_mgmt = lo_contract_for_bol->get_man_contract_instance( ).

        lo_man_contract_mgmt->read_pobui(
          EXPORTING
            iv_pob_id               =   ls_pob_key-pob_id  " Performance Obligation ID
          IMPORTING
            es_pob_data_ui          =   ls_pob_data  " POB data with amount from condition type
            ev_pob_man_fulfillable  =   lv_pob_fulfillable
        ).

        REFRESH mt_changeable_field_pob.
*       as we only support two level bom, so leaf is with BOM_ID, with HI_LEVEL_POB. else is not
        IF ls_pob_data-quantity <> 0
          AND lv_pob_fulfillable = abap_true. " leaf in bom.

          IF ls_pob_data-fulfill_type = if_farrc_contr_mgmt=>co_fulfill_type_over_time
            OR ls_pob_data-fulfill_type = if_farrc_contr_mgmt=>co_fulfill_type_time_based.
            APPEND 'TO_BE_DELI_POC'  TO mt_changeable_field_pob.
            APPEND 'POC_WITH_SIGN'   TO mt_changeable_field_pob.
            APPEND 'CUMULATIVE_POC'  TO mt_changeable_field_pob.
          ELSE.
            APPEND 'TO_BE_DELI_QTY'  TO mt_changeable_field_pob.
            APPEND 'QTY_WITH_SIGN'   TO mt_changeable_field_pob.
            APPEND 'CUMULATIVE_QTY'  TO mt_changeable_field_pob.
          ENDIF.
          APPEND 'EVENT_DATE'      TO mt_changeable_field_pob. " For new column event date, add by Jiawei
          IF ls_pob_data-event_date IS INITIAL .
            ls_pob_data-event_date = sy-datum.
          ENDIF.

        ENDIF.
        set_attr_property_pob( io_pob_obj ).
        io_pob_obj->set_attributes( ls_pob_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_pob


  METHOD READ_POB_ALL.

* read all POB, including soft deleted POB!

    DATA: ls_pob_key          TYPE farr_s_pob_key,
          ls_pob_data_buffer  TYPE farr_s_pob_data_buffer,
          ls_pob_data         TYPE farr_s_pob_data,
          lv_new_pob_kind     TYPE string,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.


    IF ls_pob_key IS INITIAL.
* POB key initial: set POB keys for all POBs of the contract
      set_bol_keys_pob_all( io_pob_obj ).

* Re-read the new set key
      CALL METHOD io_pob_obj->get_key
        IMPORTING
          es_key = ls_pob_key.
    ENDIF.

    IF ls_pob_key IS NOT INITIAL.
      IF io_pob_obj->check_attr_requested( ) = abap_true.

        lo_contract_for_bol = get_contract( mv_contract_id ).

        CALL METHOD lo_contract_for_bol->read_single_pob
          EXPORTING
            iv_pob_id          = ls_pob_key-pob_id
            iv_include_deleted = 'X'
          IMPORTING
            es_pob_data_buffer = ls_pob_data_buffer.

        MOVE-CORRESPONDING ls_pob_data_buffer TO ls_pob_data.

        io_pob_obj->set_attributes( ls_pob_data ).
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "read_pob


  METHOD READ_POB_TYPE.
    DATA: ls_pob_type_key         TYPE farr_s_pob_type_key,
          ls_pob_type_data_buffer TYPE farr_s_pob_type_data_buffer,
          ls_pob_type_data        TYPE farr_s_pob_type_data,
          lo_contract_for_bol     TYPE REF TO if_farr_contract_mgmt_bol.

    CALL METHOD io_pob_type_obj->get_key
      IMPORTING
        es_key = ls_pob_type_key.

    IF ls_pob_type_key IS INITIAL.
* pob type key initial: set document keys for all pob types of the POB
      set_bol_keys_pobtype( io_pob_type_obj ).

* Re-read the new set key
      CALL METHOD io_pob_type_obj->get_key
        IMPORTING
          es_key = ls_pob_type_key.
    ENDIF.

*  IF ls_pob_type_key IS NOT INITIAL.
    IF io_pob_type_obj->check_attr_requested( ) = abap_true.

      lo_contract_for_bol = get_contract( mv_contract_id ).

      CALL METHOD lo_contract_for_bol->read_single_pob_type
        EXPORTING
          iv_pob_type             = ls_pob_type_key-pob_type    " Performance Obligation Type
        IMPORTING
          es_pob_type_data_buffer = ls_pob_type_data_buffer.

      MOVE-CORRESPONDING ls_pob_type_data_buffer TO ls_pob_type_data.
      io_pob_type_obj->set_attributes( ls_pob_type_data ).
    ENDIF.
*  ENDIF.
  ENDMETHOD.                    "read_pob_type


  METHOD READ_ROOT_OBJECT.
    DATA: lv_obj_name TYPE crmt_ext_obj_name.

    lv_obj_name = io_root_obj->get_name( ).
    CASE lv_obj_name.
      WHEN if_farrc_contr_mgmt=>co_on_contract.
        read_contract_object( io_root_obj ).

      WHEN if_farrc_contr_mgmt=>co_on_rev_spreading.
        read_spreading_object( io_root_obj ).

      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "read_root_object


  METHOD READ_SPREADING_OBJECT.
    DATA: ls_spreading_key  TYPE farr_s_rev_schedule_key,
          ls_spreading_data TYPE farr_s_rev_spreading_data.

    IF io_container_obj->check_attr_requested( ) = abap_true.
      CALL METHOD io_container_obj->get_key
        IMPORTING
          es_key = ls_spreading_key.

      IF NOT ls_spreading_key IS INITIAL.
        CALL METHOD mo_rev_spreading->read_single_spreading
          EXPORTING
            is_spreading_key  = ls_spreading_key
          IMPORTING
            es_spreading_data = ls_spreading_data.

        io_container_obj->set_attributes( ls_spreading_data ).

        set_attr_property_spreading( iv_post_revenue  = ls_spreading_data-post_price
                                     io_container_obj = io_container_obj ).
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "read_contract_object


  METHOD REASSIGN_BACKEND_CALL.
    DATA: lt_pob_id                      TYPE farr_tt_pob_id,
          lt_accum_pob_data_buffer       TYPE farr_tt_pob_data_buffer,
          lt_accum_src_contr_data_buffer TYPE farr_tt_contract_data_buffer,
          lx_farr_message                TYPE REF TO cx_farr_message,
          lo_msg_cont                    TYPE REF TO cl_crm_genil_global_mess_cont,
*          lt_source_objs                 TYPE farr_tt_reassign_source_objs,
          ls_reassign_header             TYPE farr_s_reassign_header_final,
          lv_validity_date               TYPE farr_validity_date,
          lv_change_mode                 TYPE farr_change_mode_external,
          lo_contract                    TYPE REF TO if_farr_contract_mgmt_bol,
          lv_tmp_contract_index          TYPE farr_contract_id,
          lv_empty_contract_id           TYPE farr_contract_id VALUE '00000000000000',
          ls_acpr_bukr_data              TYPE farr_s_acpr_bukr_data,
          lt_accum_src_contr_data_tmp    TYPE farr_tt_contract_data_buffer,
          lt_accum_pob_data_tmp          TYPE farr_tt_pob_data_buffer,
          lt_accum_pob_data_tmp2         TYPE farr_tt_pob_data_buffer,
          ls_accum_src_contr_data        TYPE farr_s_contract_data_buffer,
          lv_selected                    TYPE abap_bool,
          lv_temp_contract               TYPE abap_bool.


    FIELD-SYMBOLS:
          <ls_reassign_handler>          TYPE ty_s_reassign_handler,
          <ls_source_obj>                TYPE farr_s_reassign_source_objs,
          <ls_source_obj_new>            TYPE farr_s_reassign_src_objs_new,
          <ls_pob_data_buffer>           TYPE farr_s_pob_data_buffer,
          <lv_pob_id>                    TYPE farr_pob_id.

* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    ls_reassign_header = is_reassign_header.

    " 2673933
    " check src contract compatibility first, then exit when reasign_check shows warning to avoid
    " multiple reassign_get_source_pob_info execution
    CLEAR: lt_accum_src_contr_data_tmp, lt_accum_pob_data_tmp.

    " read accumulated source contract and pob data
    LOOP AT ls_reassign_header-source_objects ASSIGNING <ls_source_obj>.
      READ TABLE mt_reassign_handler TRANSPORTING NO FIELDS
          WITH KEY contract_id = <ls_source_obj>-contract_id.

      IF sy-subrc = 0.
        get_contract(
              EXPORTING
                iv_contract_id      = <ls_source_obj>-contract_id
                iv_is_temp_contract = abap_false
              RECEIVING
                ro_contract     = lo_contract
            ).
        lo_contract->read_contract_header(
          importing
            es_contract_data_buffer = ls_accum_src_contr_data
        ).

        lo_contract->read_pob_of_contract(
          importing
            et_pob_data_buffer = lt_accum_pob_data_tmp2
        ).

        LOOP AT lt_accum_pob_data_tmp2 ASSIGNING <ls_pob_data_buffer>.
          lv_selected = abap_false.
          LOOP AT <ls_source_obj>-pob_ids ASSIGNING <lv_pob_id>.
            IF <lv_pob_id> = <ls_pob_data_buffer>-pob_id.
               lv_selected = abap_true.
               EXIT.
            ENDIF.
          ENDLOOP.
          IF lv_selected = abap_false.
            DELETE lt_accum_pob_data_tmp2.
          ENDIF.
        ENDLOOP.

        APPEND ls_accum_src_contr_data  TO lt_accum_src_contr_data_tmp.
        APPEND LINES OF lt_accum_pob_data_tmp2 TO lt_accum_pob_data_tmp.
      ENDIF.
    ENDLOOP.

    TRY.
      IF is_reassign_header-target_contract_id = 0.
        lv_temp_contract = abap_true.
      ELSE.
        lv_temp_contract = abap_false.
      ENDIF.

      get_contract(
        EXPORTING
          iv_contract_id      = is_reassign_header-target_contract_id
          iv_is_temp_contract = lv_temp_contract
        RECEIVING
          ro_contract     = lo_contract
        ).

      lo_contract->reassign_set_flag( ).

      " check reasign
      lo_contract->reassign_check( it_contract_data_buffer = lt_accum_src_contr_data_tmp
                                                             it_pob_data_buffer      = lt_accum_pob_data_tmp
                                                             iv_target_contract_id   = ls_reassign_header-target_contract_id
                                                             iv_reassign_flag        = ls_reassign_header-reassign_flag ).
      CATCH cx_farr_message INTO lx_farr_message.
        CALL METHOD convert_msg_from_t100_to_bapi
          EXPORTING
            io_msg_container = lo_msg_cont
            lx_farr_message  = lx_farr_message.
        ev_reassign_backend_success = abap_false.
        RETURN.
    ENDTRY.


*    lt_source_objs = is_reassign_header-source_objects.
* Get selected POB from source contract
    LOOP AT ls_reassign_header-source_objects ASSIGNING <ls_source_obj>.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY contract_id = <ls_source_obj>-contract_id.

      IF sy-subrc = 0.
        APPEND LINES OF <ls_source_obj>-pob_ids TO lt_pob_id.
* retrieve source data
        TRY.
            get_contract(
              EXPORTING
                iv_contract_id      = <ls_source_obj>-contract_id
                iv_is_temp_contract = abap_false
              RECEIVING
                ro_contract     = lo_contract
            ).
            lo_contract->reassign_get_source_pob_info(
              EXPORTING
                it_selected_pob         = <ls_source_obj>-pob_ids
                iv_validity_date        = mv_validity_date
                iv_change_mode          = mv_change_mode
              IMPORTING
                et_pob_data_buffer      = <ls_source_obj>-pob_data_buffer
                et_deferral_buffer      = <ls_source_obj>-deferral_data_buffer
                et_defitem_buffer       = <ls_source_obj>-defitem_data_buffer
                et_cond_type_buffer     = <ls_source_obj>-cond_type_buffer
                et_invoiced_pob         = <ls_source_obj>-invoiced_pob
                et_inv_cond_type_buffer = <ls_source_obj>-inv_cond_type_buffer
                et_org_cond_type_buffer = <ls_source_obj>-org_cond_type_buffer
                et_stored_cond_type_data = <ls_source_obj>-stored_cond_type_data
                et_cond_type_finalize   = <ls_source_obj>-cond_type_finalize
                et_diff_cond_type_data  = <ls_source_obj>-diff_cond_type_data
                es_contract_data_buffer = <ls_source_obj>-contract_data_buffer
                et_fulfill_buffer       = <ls_source_obj>-fulfill_data_buffer
                et_fulfill_data_old     = <ls_source_obj>-fulfill_data_old
                et_chg_type_buffer      = <ls_source_obj>-change_type_buffer
                ).
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.

        APPEND LINES OF <ls_source_obj>-pob_data_buffer      TO lt_accum_pob_data_buffer.
        APPEND <ls_source_obj>-contract_data_buffer          TO lt_accum_src_contr_data_buffer.
      ENDIF.
    ENDLOOP.

    LOOP AT ls_reassign_header-source_objects_new ASSIGNING <ls_source_obj_new>.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
      WITH KEY temp_contract_idx = <ls_source_obj_new>-contract_idx
               contract_id       = lv_empty_contract_id.
      IF sy-subrc = 0.
        APPEND LINES OF <ls_source_obj_new>-pob_ids TO lt_pob_id.
* retrieve source data
        TRY.
            lv_tmp_contract_index = <ls_source_obj_new>-contract_idx.
            get_contract(
              EXPORTING
                iv_contract_id      = lv_tmp_contract_index
                iv_is_temp_contract = abap_true
              RECEIVING
                ro_contract     = lo_contract
            ).

            lo_contract->reassign_get_source_pob_info(
              EXPORTING
                it_selected_pob         = <ls_source_obj_new>-pob_ids
                iv_validity_date        = mv_validity_date
                iv_change_mode          = mv_change_mode
              IMPORTING
                et_pob_data_buffer      = <ls_source_obj_new>-pob_data_buffer
                et_deferral_buffer      = <ls_source_obj_new>-deferral_data_buffer
                et_defitem_buffer       = <ls_source_obj_new>-defitem_data_buffer
                et_cond_type_buffer     = <ls_source_obj_new>-cond_type_buffer
                et_diff_cond_type_data  = <ls_source_obj_new>-diff_cond_type_data
                et_invoiced_pob         = <ls_source_obj_new>-invoiced_pob
                et_inv_cond_type_buffer = <ls_source_obj_new>-inv_cond_type_buffer
                et_org_cond_type_buffer = <ls_source_obj_new>-org_cond_type_buffer
                et_stored_cond_type_data = <ls_source_obj_new>-stored_cond_type_data
                et_cond_type_finalize   = <ls_source_obj_new>-cond_type_finalize
                es_contract_data_buffer = <ls_source_obj_new>-contract_data_buffer
                et_fulfill_buffer       = <ls_source_obj_new>-fulfill_data_buffer
                et_fulfill_data_old     = <ls_source_obj_new>-fulfill_data_old
                et_chg_type_buffer      = <ls_source_obj_new>-change_type_buffer
                ).
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.

        APPEND LINES OF <ls_source_obj_new>-pob_data_buffer      TO lt_accum_pob_data_buffer.
        APPEND <ls_source_obj_new>-contract_data_buffer          TO lt_accum_src_contr_data_buffer.
      ENDIF.
    ENDLOOP.

* Add selected POB to target contract
    IF is_reassign_header-target_contract_id = 0.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
           WITH KEY contract_id = lv_empty_contract_id
                    temp_contract_idx = is_reassign_header-contr_idx.
      IF sy-subrc = 0.
***** authority_check_new_contract
        TRY.
            CALL METHOD cl_farr_contract_utility=>authority_check_new_contract
              EXPORTING
                it_pob_data_buffer = lt_accum_pob_data_buffer.
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.

        lv_tmp_contract_index = is_reassign_header-contr_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_tmp_contract_index
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract     = lo_contract
        ).

        lo_contract->reassign_set_flag( ).
* check src contract data is compatible with target contract.
        TRY.
            lo_contract->reassign_check( it_contract_data_buffer = lt_accum_src_contr_data_buffer
                                                            it_pob_data_buffer      = lt_accum_pob_data_buffer
                                                            iv_target_contract_id   = ls_reassign_header-target_contract_id
                                                            iv_reassign_flag        = ls_reassign_header-reassign_flag ).
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.
*******************
        TRY.
            lo_contract->reassign_add_to_target(
              is_reassign_header      = ls_reassign_header
              it_src_contract_data    = lt_accum_src_contr_data_buffer
              it_selected_pob         = lt_pob_id
              iv_validity_date        = mv_validity_date
              iv_change_mode          = mv_change_mode
              ).
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.
      ENDIF.
    ELSE.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
           WITH KEY contract_id = is_reassign_header-target_contract_id.

      IF sy-subrc = 0.
        get_contract(
          EXPORTING
            iv_contract_id      = is_reassign_header-target_contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract     = lo_contract
        ).

        lo_contract->reassign_set_flag( ).

* check src contract data is compatible with target contract.
        TRY.
            lo_contract->reassign_check( it_contract_data_buffer = lt_accum_src_contr_data_buffer
                                         it_pob_data_buffer      = lt_accum_pob_data_buffer
                                         iv_target_contract_id   = ls_reassign_header-target_contract_id
                                         iv_reassign_flag        = ls_reassign_header-reassign_flag ).

* if compatible, then do reasignment.
            lo_contract->reassign_add_to_target(
              is_reassign_header      = ls_reassign_header
              it_src_contract_data    = lt_accum_src_contr_data_buffer
              it_selected_pob         = lt_pob_id
              iv_validity_date        = mv_validity_date
              iv_change_mode          = mv_change_mode
              ).
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.
      ENDIF.
    ENDIF.

* Remove selected POB from source contract
    LOOP AT ls_reassign_header-source_objects ASSIGNING <ls_source_obj>.
      IF <ls_source_obj>-contract_id <> is_reassign_header-target_contract_id.

        READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
          WITH KEY contract_id = <ls_source_obj>-contract_id.

        IF sy-subrc = 0.
* remove from source
          get_contract(
            EXPORTING
              iv_contract_id      = <ls_source_obj>-contract_id
              iv_is_temp_contract = abap_false
            RECEIVING
              ro_contract     = lo_contract
          ).

          lo_contract->reassign_del_from_source(
            it_selected_pob    = <ls_source_obj>-pob_ids
          ).
          lo_contract->reassign_set_flag( ).
        ENDIF.
      ENDIF.
    ENDLOOP.

* Remove selected POB from source contract
    LOOP AT ls_reassign_header-source_objects_new ASSIGNING <ls_source_obj_new>.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY temp_contract_idx = <ls_source_obj_new>-contract_idx
                 contract_id       = lv_empty_contract_id.

      IF sy-subrc = 0.
* remove from source
        lv_tmp_contract_index = <ls_source_obj_new>-contract_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_tmp_contract_index
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract     = lo_contract
        ).

        lo_contract->reassign_del_from_source(
          it_selected_pob    = <ls_source_obj_new>-pob_ids
        ).
        lo_contract->reassign_set_flag( ).
      ENDIF.
    ENDLOOP.

    ev_reassign_backend_success = abap_true.

    "for transition case, validity date should be the take over date
    SORT lt_accum_pob_data_buffer BY pob_id DESCENDING.
    READ TABLE lt_accum_pob_data_buffer INDEX 1 ASSIGNING <ls_pob_data_buffer>.
    IF sy-subrc = 0.
      mv_mig_package = <ls_pob_data_buffer>-mig_package.

      CALL METHOD cl_farr_fnd_cust_db_access=>read_acpr_bukr_single
        EXPORTING
          iv_acct_principle = <ls_pob_data_buffer>-acct_principle
          iv_company_code   = <ls_pob_data_buffer>-company_code
          iv_mig_package    = mv_mig_package
        IMPORTING
          es_acpr_bukr_data = ls_acpr_bukr_data.
    ENDIF.
    IF ls_acpr_bukr_data-mig_status = if_farrc_foundation=>co_mig_status_tr.
      mv_validity_date = ls_acpr_bukr_data-take_over_dat.
    ENDIF.

  ENDMETHOD.                    "reassign_execute


  METHOD REASSIGN_BACKEND_CALL_AFTER_WA.
    DATA: lt_pob_id                      TYPE farr_tt_pob_id,
          lt_accum_pob_data_buffer       TYPE farr_tt_pob_data_buffer,
          lt_accum_src_contr_data_buffer TYPE farr_tt_contract_data_buffer,
          lx_farr_message                TYPE REF TO cx_farr_message,
          lo_msg_cont                    TYPE REF TO cl_crm_genil_global_mess_cont,
          ls_reassign_header             TYPE farr_s_reassign_header_final,
          lo_msg_t100                    TYPE REF TO cl_farr_message_handler,
          lo_contract                    TYPE REF TO if_farr_contract_mgmt_bol,
          lv_empty_contract_id           TYPE farr_contract_id VALUE '00000000000000',
          lv_contract_ind                TYPE farr_contract_id.

    FIELD-SYMBOLS:
          <ls_reassign_handler>          TYPE ty_s_reassign_handler,
          <ls_source_obj>                TYPE farr_s_reassign_source_objs,
          <ls_source_obj_new>            TYPE farr_s_reassign_src_objs_new.

* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

*    CALL METHOD reassign_collect_pob_id
*      EXPORTING
*        it_pob_obj = it_pob_obj
*      IMPORTING
*        et_pob_id  = lt_pob_id.

    ls_reassign_header = is_reassign_header.
*    lt_source_objs = is_reassign_header-source_objects.
* Get selected POB from source contract
    LOOP AT ls_reassign_header-source_objects ASSIGNING <ls_source_obj>.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY contract_id = <ls_source_obj>-contract_id.

      IF sy-subrc = 0.
        APPEND LINES OF <ls_source_obj>-pob_ids TO lt_pob_id.
* retrieve source data
        TRY.
            get_contract(
              EXPORTING
                iv_contract_id      = <ls_source_obj>-contract_id
                iv_is_temp_contract = abap_false
              RECEIVING
                ro_contract     = lo_contract
            ).

            lo_contract->reassign_get_source_pob_info(
              EXPORTING
                it_selected_pob         = <ls_source_obj>-pob_ids
                iv_validity_date        = mv_validity_date
                iv_change_mode          = mv_change_mode
              IMPORTING
                et_pob_data_buffer      = <ls_source_obj>-pob_data_buffer
                et_deferral_buffer      = <ls_source_obj>-deferral_data_buffer
                et_defitem_buffer       = <ls_source_obj>-defitem_data_buffer
                et_fulfill_buffer       = <ls_source_obj>-fulfill_data_buffer
                et_fulfill_data_old     = <ls_source_obj>-fulfill_data_old
                et_cond_type_buffer     = <ls_source_obj>-cond_type_buffer
                et_invoiced_pob         = <ls_source_obj>-invoiced_pob
                et_inv_cond_type_buffer = <ls_source_obj>-inv_cond_type_buffer
                et_org_cond_type_buffer = <ls_source_obj>-org_cond_type_buffer
                et_stored_cond_type_data = <ls_source_obj>-stored_cond_type_data
                et_cond_type_finalize   = <ls_source_obj>-cond_type_finalize
                et_diff_cond_type_data  = <ls_source_obj>-diff_cond_type_data
                et_chg_type_buffer      = <ls_source_obj>-change_type_buffer
                es_contract_data_buffer = <ls_source_obj>-contract_data_buffer ).
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.

        APPEND LINES OF <ls_source_obj>-pob_data_buffer      TO lt_accum_pob_data_buffer.
        APPEND <ls_source_obj>-contract_data_buffer          TO lt_accum_src_contr_data_buffer.
      ENDIF.
    ENDLOOP.

*    lt_source_objs_new = is_reassign_header-source_objects_new.

    LOOP AT ls_reassign_header-source_objects_new ASSIGNING <ls_source_obj_new>.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY temp_contract_idx = <ls_source_obj_new>-contract_idx
                 contract_id       = lv_empty_contract_id.

      IF sy-subrc = 0.
        APPEND LINES OF <ls_source_obj_new>-pob_ids TO lt_pob_id.
* retrieve source data
        TRY.
            lv_contract_ind = <ls_source_obj_new>-contract_idx.
            get_contract(
              EXPORTING
                iv_contract_id      = lv_contract_ind
                iv_is_temp_contract = abap_true
              RECEIVING
                ro_contract     = lo_contract
            ).

            lo_contract->reassign_get_source_pob_info(
              EXPORTING
                it_selected_pob         = <ls_source_obj_new>-pob_ids
                iv_validity_date        = mv_validity_date
                iv_change_mode          = mv_change_mode
              IMPORTING
                et_pob_data_buffer      = <ls_source_obj_new>-pob_data_buffer
                et_deferral_buffer      = <ls_source_obj_new>-deferral_data_buffer
                et_defitem_buffer       = <ls_source_obj_new>-defitem_data_buffer
                et_fulfill_buffer       = <ls_source_obj_new>-fulfill_data_buffer
                et_fulfill_data_old     = <ls_source_obj_new>-fulfill_data_old
                et_cond_type_buffer     = <ls_source_obj_new>-cond_type_buffer
                et_invoiced_pob         = <ls_source_obj_new>-invoiced_pob
                et_inv_cond_type_buffer = <ls_source_obj_new>-inv_cond_type_buffer
                et_cond_type_finalize   = <ls_source_obj_new>-cond_type_finalize
                et_diff_cond_type_data  = <ls_source_obj_new>-diff_cond_type_data
                et_org_cond_type_buffer = <ls_source_obj_new>-org_cond_type_buffer
                et_stored_cond_type_data = <ls_source_obj_new>-stored_cond_type_data
                et_chg_type_buffer      = <ls_source_obj_new>-change_type_buffer
                es_contract_data_buffer = <ls_source_obj_new>-contract_data_buffer ).
          CATCH cx_farr_message INTO lx_farr_message.
            CALL METHOD convert_msg_from_t100_to_bapi
              EXPORTING
                io_msg_container = lo_msg_cont
                lx_farr_message  = lx_farr_message.
            ev_reassign_backend_success = abap_false.
            RETURN.
        ENDTRY.

        APPEND LINES OF <ls_source_obj_new>-pob_data_buffer      TO lt_accum_pob_data_buffer.
        APPEND <ls_source_obj_new>-contract_data_buffer          TO lt_accum_src_contr_data_buffer.
      ENDIF.
    ENDLOOP.

* Add selected POB to target contract
    READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
         WITH KEY contract_id = is_reassign_header-target_contract_id.

    IF sy-subrc = 0.
***** authority_check_new_contract
      TRY.
          CALL METHOD cl_farr_contract_utility=>authority_check_new_contract
            EXPORTING
              it_pob_data_buffer = lt_accum_pob_data_buffer.
        CATCH cx_farr_message INTO lx_farr_message.
          CALL METHOD convert_msg_from_t100_to_bapi
            EXPORTING
              io_msg_container = lo_msg_cont
              lx_farr_message  = lx_farr_message.
          ev_reassign_backend_success = abap_false.
          RETURN.
      ENDTRY.
* if compatible, then do reasignment.
      TRY.
          get_contract(
            EXPORTING
              iv_contract_id      = is_reassign_header-target_contract_id
              iv_is_temp_contract = abap_false
            RECEIVING
              ro_contract     = lo_contract
          ).

          lo_contract->reassign_add_to_target(
            is_reassign_header      = ls_reassign_header
            it_src_contract_data    = lt_accum_src_contr_data_buffer
            it_selected_pob         = lt_pob_id
            iv_validity_date        = mv_validity_date
            iv_change_mode          = mv_change_mode
            ).

          lo_contract->reassign_set_flag( ).
        CATCH cx_farr_message.

          lo_msg_t100 = lo_contract->get_msg_handler( ).
          lo_msg_t100->add_symessage(
          EXPORTING
            iv_ctx_type  = if_farrc_msg_handler_cons=>co_ctx_contract_id
            iv_ctx_value = is_reassign_header-target_contract_id
        ).

          convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
          ev_reassign_backend_success = abap_false.
      ENDTRY.
    ENDIF.

* Remove selected POB from source contract
    LOOP AT ls_reassign_header-source_objects ASSIGNING <ls_source_obj>.
      IF <ls_source_obj>-contract_id <> is_reassign_header-target_contract_id.
        READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
          WITH KEY contract_id = <ls_source_obj>-contract_id.

        IF sy-subrc = 0.
* remove from source
          get_contract(
            EXPORTING
              iv_contract_id      = <ls_source_obj>-contract_id
              iv_is_temp_contract = abap_false
            RECEIVING
              ro_contract     = lo_contract
          ).

          lo_contract->reassign_del_from_source(
            it_selected_pob    = <ls_source_obj>-pob_ids
          ).

          lo_contract->reassign_set_flag( ).
        ENDIF.
      ENDIF.
    ENDLOOP.

* Remove selected POB from source contract
    LOOP AT ls_reassign_header-source_objects_new ASSIGNING <ls_source_obj_new>.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY temp_contract_idx = <ls_source_obj_new>-contract_idx
                 contract_id       = lv_empty_contract_id.

      IF sy-subrc = 0.
* remove from source
        lv_contract_ind = <ls_source_obj_new>-contract_idx.

        get_contract(
          EXPORTING
            iv_contract_id      = lv_contract_ind
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract     = lo_contract
        ).

        lo_contract->reassign_del_from_source(
          it_selected_pob    = <ls_source_obj_new>-pob_ids
        ).

        lo_contract->reassign_set_flag( ).
      ENDIF.
    ENDLOOP.

    ev_reassign_backend_success = abap_true.

  ENDMETHOD.                    "reassign_execute


  METHOD REASSIGN_CLEAR_HANDLER.

    " contract instances in contract mgmt will be cleared by calling contract mgmt save
    CLEAR mt_reassign_handler.

    " TODO: should we clear all loaded contracts from contract mgmt?
    mo_contract_mgmt->reset( ).

    CLEAR mt_reassign_mapping.

  ENDMETHOD.                    "REASSIGN_CLEAR_HANDLER


  METHOD REASSIGN_COLLECT_POB_ID.
    DATA: ls_pob_key        TYPE farr_s_pob_key.
    FIELD-SYMBOLS:
          <ls_pob_obj>      TYPE crmt_genil_obj_inst_line.

    CLEAR et_pob_id.
    LOOP AT it_pob_obj ASSIGNING <ls_pob_obj>.
      CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
        EXPORTING
          iv_object_name = <ls_pob_obj>-object_name
          iv_object_id   = <ls_pob_obj>-object_id
        IMPORTING
          es_key         = ls_pob_key.

      APPEND ls_pob_key-pob_id TO et_pob_id.
    ENDLOOP.

    DELETE ADJACENT DUPLICATES FROM et_pob_id.


  ENDMETHOD.                    "reassign_collect_pob_id


  METHOD REASSIGN_CONVERT_PARAM.
**********************************************************************
* for it_paramenter, this method assumes contract id and its children pobs are sequentially
* passed in, if contract id changes, then its pobs and itself are following the last pob of
* last contract. if the source contract is a newly created one(without saving yet), the con
* -tract idx is used - instead of contract id
* so, in parameter, the data will likes below format:
* src contract 1,
* pob1.1,
* src contract 2,
* pob1.2,
* src new contract 3,
* pob1.3
* target contract,
* target pob,
* target contract description,
* new compound pob structure.
**********************************************************************

    DATA: lv_string            TYPE string,
*          lv_cnt               TYPE i,
*          lv_cnt_new           TYPE i,
          lv_prev_contract_id  TYPE farr_contract_id,
          lv_prev_contract_idx TYPE i,
          ls_source_objs       TYPE farr_s_reassign_source_objs,
          lt_source_objs       TYPE farr_tt_reassign_source_objs,
          ls_source_objs_new   TYPE farr_s_reassign_src_objs_new,
          lt_source_objs_new   TYPE farr_tt_reassign_src_objs_new,
          lv_use_idx           TYPE boole_d.

    FIELD-SYMBOLS:
          <ls_param>          TYPE crmt_name_value_pair,
          <lv_src_pob_id>     TYPE farr_pob_id.

    CLEAR es_reassign_header.

    LOOP AT it_parameter ASSIGNING <ls_param>.
      CASE <ls_param>-name.

* Source Contract ID
        WHEN if_farrc_contr_mgmt=>co_an_source_contract_id.
*          lv_cnt = lv_cnt + 1.

          IF <ls_param>-value <> lv_prev_contract_id.      "contract change,
            IF ls_source_objs IS NOT INITIAL.  " then save previous group data into table
              APPEND ls_source_objs TO lt_source_objs.
              CLEAR ls_source_objs.                          "a new line created
            ENDIF.
            lv_prev_contract_id = <ls_param>-value.
            ls_source_objs-contract_id = <ls_param>-value.
          ENDIF.

* Source Contract Index(from freshly created contract)
        WHEN if_farrc_contr_mgmt=>co_an_src_contract_index.
          lv_use_idx = abap_true.

*          lv_cnt_new = lv_cnt_new + 1.

          IF <ls_param>-value <> lv_prev_contract_idx.      "contract change,
            IF ls_source_objs_new IS NOT INITIAL.  " then save previous group data into table
              APPEND ls_source_objs_new TO lt_source_objs_new.
              CLEAR ls_source_objs_new.                          "a new line created
            ENDIF.
            lv_prev_contract_idx = <ls_param>-value.
            ls_source_objs_new-contract_idx = <ls_param>-value.
          ENDIF.

* source pob ID
        WHEN if_farrc_contr_mgmt=>co_an_source_pob_id.
          IF lv_use_idx = abap_false.
            APPEND INITIAL LINE TO ls_source_objs-pob_ids ASSIGNING <lv_src_pob_id>.
            <lv_src_pob_id> = <ls_param>-value.
          ELSE.
            APPEND INITIAL LINE TO ls_source_objs_new-pob_ids ASSIGNING <lv_src_pob_id>.
            <lv_src_pob_id> = <ls_param>-value.
          ENDIF.

* Target Contract ID
        WHEN if_farrc_contr_mgmt=>co_an_target_contract_id.
          IF ls_source_objs IS NOT INITIAL.  " then save previous group data into table
            APPEND ls_source_objs TO lt_source_objs.
            CLEAR ls_source_objs.
          ENDIF.
          IF ls_source_objs_new IS NOT INITIAL.  " then save previous group data into table
            APPEND ls_source_objs_new TO lt_source_objs_new.
            CLEAR ls_source_objs_new.
          ENDIF.
          es_reassign_header-target_contract_id = <ls_param>-value.

* Target POB ID
        WHEN if_farrc_contr_mgmt=>co_an_target_pob_id.
          es_reassign_header-target_pob_id = <ls_param>-value.

* Target Contract Description
        WHEN if_farrc_contr_mgmt=>co_an_target_contract_desc.
          es_reassign_header-target_contract_desc = <ls_param>-value.

* Target New Compound POB
        WHEN if_farrc_contr_mgmt=>co_an_target_new_compound_pob.
          cl_abap_container_utilities=>read_container_c(
          EXPORTING
            im_container = <ls_param>-value
          IMPORTING
            ex_value     = es_reassign_header-target_new_compound_pob
            ).

* Index for new contracts
        WHEN if_farrc_contr_mgmt=>co_an_contract_index.
          es_reassign_header-contr_idx = <ls_param>-value.

* Reassign flag to differeiciate reassignment and combination
        WHEN if_farrc_contr_mgmt=>co_an_reassign_flag.
          es_reassign_header-reassign_flag = <ls_param>-value.

        WHEN if_farrc_contr_mgmt=>co_an_change_mode.
          mv_change_mode = <ls_param>-value.

        WHEN if_farrc_contr_mgmt=>co_user_parm_id_validity_date.
          mv_validity_date = <ls_param>-value.

        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

*    IF lv_cnt = 1.
*      IF ls_source_objs IS NOT INITIAL.  " then save previous group data into table
*        APPEND ls_source_objs TO lt_source_objs.
*      ENDIF.
*    ENDIF.
*
*    IF lv_cnt_new = 1.
*      IF ls_source_objs_new IS NOT INITIAL.  " then save previous group data into table
*        APPEND ls_source_objs_new TO lt_source_objs_new.
*      ENDIF.
*    ENDIF.

    es_reassign_header-source_objects     = lt_source_objs.
    es_reassign_header-source_objects_new = lt_source_objs_new.

  ENDMETHOD.                    "reassign_convert_param


  METHOD REASSIGN_DELETE_CONTRACT.

    DATA: lo_msg_cont           TYPE REF TO cl_crm_genil_global_mess_cont.
* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    IF it_parameter IS NOT INITIAL.
      reassign_del_single_contract( it_parameter = it_parameter
                                    io_msg_cont  = lo_msg_cont ).
    ELSE.
      reassign_del_multi_contracts( io_msg_cont = lo_msg_cont ).
    ENDIF.


  ENDMETHOD.                    "reassign_delete_contract


  METHOD REASSIGN_DEL_MULTI_CONTRACTS.

    DATA: lv_current_contract_id TYPE farr_contract_id,
          lv_pob_size            TYPE i,
          lv_success             TYPE abap_bool,
          lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol,"Change name from lo_contract_mgmt to lo_contract_for_bol
          lx_farr_message        TYPE REF TO cx_farr_message,
          lt_reassign_hander_del LIKE mt_reassign_handler,
          lv_tmp_contr_ind       TYPE farr_contract_id.

    FIELD-SYMBOLS:
          <ls_param>             TYPE crmt_name_value_pair,
          <ls_reassign_handler>  LIKE LINE OF mt_reassign_handler.

    LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>.

      IF <ls_reassign_handler>-contract_id <> 0.
        " existing contract
        get_contract(
          EXPORTING
            iv_contract_id      = <ls_reassign_handler>-contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract     = lo_contract_for_bol
        ).
      ELSE.
        " contract indicated by index
        lv_tmp_contr_ind = <ls_reassign_handler>-temp_contract_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_tmp_contr_ind
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract     = lo_contract_for_bol
        ).
      ENDIF.

      IF lo_contract_for_bol IS NOT BOUND.
        CONTINUE.
      ENDIF.

      lv_pob_size = lo_contract_for_bol->get_pob_size( ).

      IF lv_pob_size > 0.
        CONTINUE.
      ENDIF.

      lv_current_contract_id = lo_contract_for_bol->get_contract_id( ).

      IF lv_current_contract_id IS INITIAL OR lv_current_contract_id = '00000000000000'.
        APPEND <ls_reassign_handler> TO lt_reassign_hander_del.
        CONTINUE.
      ENDIF.

      "lock must have been done in reassign feeder
      TRY.
          CALL METHOD lo_contract_for_bol->delete_contract
            IMPORTING
              ev_result = lv_success.
        CATCH cx_farr_message INTO lx_farr_message.
          io_msg_cont->add_message(
            EXPORTING
              iv_msg_type       = lx_farr_message->mv_msgty
              iv_msg_id         = lx_farr_message->mv_msgid
              iv_msg_number     = lx_farr_message->mv_msgno
              iv_msg_v1         = lx_farr_message->mv_msgv1
              iv_msg_v2         = lx_farr_message->mv_msgv2
              iv_msg_v3         = lx_farr_message->mv_msgv3
              iv_msg_v4         = lx_farr_message->mv_msgv4
              iv_show_only_once =  abap_true
           ).
      ENDTRY.

    ENDLOOP.


    LOOP AT lt_reassign_hander_del ASSIGNING <ls_reassign_handler>.
      DELETE TABLE mt_reassign_handler FROM <ls_reassign_handler>.

    ENDLOOP.

    mv_flg_reassign = abap_true.

* Always collect msg from BOL to FPM
    convert_msg_from_t100_to_bapi( io_msg_container = io_msg_cont ).

  ENDMETHOD.                    "reassign_del_multi_contracts


  METHOD REASSIGN_DEL_SINGLE_CONTRACT.

    DATA: lv_del_contract_id      TYPE farr_contract_id,
          lv_current_contract_id  TYPE farr_contract_id,
          lo_contract_for_bol     TYPE REF TO if_farr_contract_mgmt_bol,
          lx_farr_message         TYPE REF TO cx_farr_message,
*        lv_pob_size             TYPE i,
*          lo_msg_cont           TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_success              TYPE abap_bool,
          lv_tmp_subrc            LIKE sy-subrc,
          lv_tmp_contr_ind        TYPE farr_contract_id.

    FIELD-SYMBOLS:
          <ls_param>            TYPE crmt_name_value_pair,
          <ls_reassign_handler> LIKE LINE OF mt_reassign_handler.

    IF mv_use_idx_as_contr_id = abap_true.
      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY temp_contract_idx = mv_last_temp_contr_idx
                 contract_id       = 0.

      lv_tmp_subrc = sy-subrc.
      lv_del_contract_id = 0.
    ELSE.
* Contract ID which is to be deleted
      READ TABLE it_parameter ASSIGNING <ls_param>
           WITH KEY name = if_farrc_contr_mgmt=>co_an_contract_id.
      IF sy-subrc = 0.
        lv_del_contract_id = <ls_param>-value.
      ENDIF.

      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY contract_id = lv_del_contract_id.

      lv_tmp_subrc = sy-subrc.
    ENDIF.

    get_contract(
      EXPORTING
        iv_contract_id      = lv_del_contract_id
        iv_is_temp_contract = abap_false
      RECEIVING
        ro_contract         = lo_contract_for_bol
    ).

    IF lv_tmp_subrc <> 0.
      " the contract has not been inserted into the container, now add it
      CHECK lv_del_contract_id IS NOT INITIAL.

      TRY .
          lo_contract_for_bol->load_contract(  ).

        CATCH cx_farr_message.
          " dummy
      ENDTRY.

      "now need to insert the instance to reassign handler to keep deletion behaviour working identical for all reassinment
      APPEND INITIAL LINE TO mt_reassign_handler ASSIGNING <ls_reassign_handler>.
      <ls_reassign_handler>-contract_id   = lv_del_contract_id.
    ENDIF.

    mv_flg_reassign = abap_true.

    CHECK lo_contract_for_bol IS BOUND.

    "lock must have been done in reassign feeder
    TRY.
        CALL METHOD lo_contract_for_bol->delete_contract
          IMPORTING
            ev_result = lv_success.
      CATCH cx_farr_message INTO lx_farr_message.
        io_msg_cont->add_message(
          EXPORTING
            iv_msg_type       = lx_farr_message->mv_msgty
            iv_msg_id         = lx_farr_message->mv_msgid
            iv_msg_number     = lx_farr_message->mv_msgno
            iv_msg_v1         = lx_farr_message->mv_msgv1
            iv_msg_v2         = lx_farr_message->mv_msgv2
            iv_msg_v3         = lx_farr_message->mv_msgv3
            iv_msg_v4         = lx_farr_message->mv_msgv4
            iv_show_only_once =  abap_true
         ).
    ENDTRY.

* Always collect msg from BOL to FPM
    convert_msg_from_t100_to_bapi( io_msg_container = io_msg_cont ).

  ENDMETHOD.                    "reassign_del_single_contract


  METHOD REASSIGN_DETERMINE_HANDLER.
    DATA: lv_current_contract_id TYPE farr_contract_id,
          ls_reassign_handler    TYPE ty_s_reassign_handler,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol,
          lx_farr_message        TYPE REF TO cx_farr_message,
          lo_msg_cont            TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_tmp_contract_index  TYPE farr_contract_id.


* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    IF iv_contract_id <> 0.
      READ TABLE mt_reassign_handler TRANSPORTING NO FIELDS
           WITH KEY contract_id = iv_contract_id.

      IF sy-subrc <> 0.
        " get a new contract instance
        get_contract(
          EXPORTING
            iv_contract_id      = iv_contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract         = lo_contract
        ).

        " a normal contract should be loaded
        TRY .
            " force load in case of dirty buffer
            lo_contract->load_contract( abap_true ).
          CATCH cx_farr_message.
            " dummy
        ENDTRY.
      ENDIF.
    ELSE.
      " iv_contract_id = 0
      READ TABLE mt_reassign_handler TRANSPORTING NO FIELDS
           WITH KEY contract_id = iv_contract_id
                    temp_contract_idx = iv_contr_idx.

      IF sy-subrc <> 0.
        lv_tmp_contract_index = iv_contr_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_tmp_contract_index
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract         = lo_contract
        ).
      ENDIF.
    ENDIF.

    IF lo_contract IS BOUND.
      " append into mt_reassign_handler
      ls_reassign_handler-contract_id   = iv_contract_id.
      IF iv_contract_id = 0.
        ls_reassign_handler-temp_contract_idx = iv_contr_idx.
      ENDIF.
      APPEND ls_reassign_handler TO mt_reassign_handler.
    ENDIF.

  ENDMETHOD.                    "reassign_execute


  METHOD REASSIGN_DETERMINE_SOURCE.

    DATA: lv_src_contract_id    TYPE farr_contract_id,
          lv_src_contract_idx   TYPE i,
          lo_contract           TYPE REF TO if_farr_contract_mgmt_bol,
          lx_farr_message       TYPE REF TO cx_farr_message,
          lo_msg_cont           TYPE REF TO cl_crm_genil_global_mess_cont.

    FIELD-SYMBOLS:
          <ls_param>            TYPE crmt_name_value_pair,
          <ls_reassign_handler> LIKE LINE OF mt_reassign_handler.

* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

* Source Contract IDs
    LOOP AT it_parameter ASSIGNING <ls_param>.

      IF mv_use_idx_as_contr_id = abap_true.
        lv_src_contract_idx = mv_last_temp_contr_idx.
        READ TABLE mt_reassign_handler TRANSPORTING NO FIELDS
         WITH KEY temp_contract_idx = lv_src_contract_idx.
*        CLEAR: mv_use_idx_as_contr_id,
*               mv_last_temp_contr_idx.
        "do nothing
      ELSE.
        lv_src_contract_id = <ls_param>-value.
        READ TABLE mt_reassign_handler TRANSPORTING NO FIELDS
         WITH KEY contract_id = lv_src_contract_id.
        IF sy-subrc <> 0.
          get_contract(
            EXPORTING
              iv_contract_id      = lv_src_contract_id
              iv_is_temp_contract = abap_false
            RECEIVING
              ro_contract         = lo_contract
          ).

          IF NOT lv_src_contract_id IS INITIAL.
            TRY .
                lo_contract->load_contract( ).
              CATCH cx_farr_message.
                " dummy
            ENDTRY.
          ENDIF.

          APPEND INITIAL LINE TO mt_reassign_handler ASSIGNING <ls_reassign_handler>.
          <ls_reassign_handler>-contract_id   = lv_src_contract_id.
        ENDIF.
      ENDIF.

    ENDLOOP.

    mv_flg_reassign = abap_true.

  ENDMETHOD.                    "REASSIGN_DETERMINE_SOURCE


  METHOD REASSIGN_DETERMINE_TARGET.

    DATA lv_lock_target_success TYPE abap_bool.
    DATA: ls_reassign_header     TYPE farr_s_reassign_header_final,
          ls_reassign_mapping    TYPE ty_s_reassign_mapping.
    FIELD-SYMBOLS:
                   <ls_source_obj>        TYPE farr_s_reassign_source_objs,
                   <ls_src_objs_new>      TYPE farr_s_reassign_src_objs_new,
                   <lv_pob_id>            TYPE farr_pob_id,
                   <ls_reassign_mapping>  TYPE ty_s_reassign_mapping.

    mv_flg_reassign = abap_true.
    reassign_convert_param( EXPORTING it_parameter = it_parameter
                            IMPORTING es_reassign_header = ls_reassign_header ).

    reassign_determine_handler( EXPORTING iv_contract_id         = ls_reassign_header-target_contract_id
                                          iv_contr_idx           = ls_reassign_header-contr_idx
                                          io_msg_service_access  = io_msg_service_access ).

    LOOP AT ls_reassign_header-source_objects ASSIGNING <ls_source_obj>.
      ls_reassign_mapping-contract_id = ls_reassign_header-target_contract_id.
      ls_reassign_mapping-temp_contract_idx = ls_reassign_header-contr_idx.
      ls_reassign_mapping-source_contract_id = <ls_source_obj>-contract_id.
      LOOP AT <ls_source_obj>-pob_ids ASSIGNING <lv_pob_id>.
        READ TABLE mt_reassign_mapping ASSIGNING <ls_reassign_mapping>
          WITH KEY pob_id = <lv_pob_id>.
        IF sy-subrc = 0.
          <ls_reassign_mapping>-contract_id = ls_reassign_mapping-contract_id.
          <ls_reassign_mapping>-temp_contract_idx = ls_reassign_mapping-temp_contract_idx.
        ELSE.
          ls_reassign_mapping-pob_id = <lv_pob_id>.
          APPEND ls_reassign_mapping TO mt_reassign_mapping.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT ls_reassign_header-source_objects_new ASSIGNING <ls_src_objs_new>.
      ls_reassign_mapping-contract_id = ls_reassign_header-target_contract_id.
      ls_reassign_mapping-temp_contract_idx = ls_reassign_header-contr_idx.
      LOOP AT <ls_src_objs_new>-pob_ids ASSIGNING <lv_pob_id>.
        READ TABLE mt_reassign_mapping ASSIGNING <ls_reassign_mapping>
          WITH KEY pob_id = <lv_pob_id>.
        IF sy-subrc = 0.
          <ls_reassign_mapping>-contract_id = ls_reassign_mapping-contract_id.
          <ls_reassign_mapping>-temp_contract_idx = ls_reassign_mapping-temp_contract_idx.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.                    "reassign_determine_target


  METHOD REASSIGN_GET_NEW_CONTRACT_ID.

    DATA: lv_temp_contr_idx     TYPE i,
          lv_table_idx          TYPE sytabix.

    FIELD-SYMBOLS <ls_reassign_handler> LIKE LINE OF mt_reassign_handler.

    " the save method has ensure that the temporary contract has been assigned into the new handler
    LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>.
      IF    <ls_reassign_handler>-contract_id <> 0
        AND <ls_reassign_handler>-temp_contract_idx = 0.
        INSERT <ls_reassign_handler>-contract_id INTO TABLE et_contract_id.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "REASSIGN_GET_NEW_CONTRACT_ID


  METHOD REASSIGN_PEER_CREATE_COMP_POB.

    DATA: ls_new_compound_pob TYPE farr_s_pob_data_buffer,
          ls_reassign_handler TYPE ty_s_reassign_handler,
          lo_contract         TYPE REF TO if_farr_contract_mgmt_bol,
          ls_reassign_header  TYPE farr_s_reassign_header,
          lx_farr_message     TYPE REF TO cx_farr_message,
          lo_msg_cont         TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_temp_subrc       LIKE sy-subrc.

    FIELD-SYMBOLS:
          <ls_param>          TYPE crmt_name_value_pair,
          <ls_reassign_handler> LIKE LINE OF mt_reassign_handler.

* Clear old messages from the message handler
    init_msg_handler( ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    LOOP AT it_parameter ASSIGNING <ls_param>.
      CASE <ls_param>-name.
* compound pob information
        WHEN if_farrc_contr_mgmt=>co_an_target_new_compound_pob.
          cl_abap_container_utilities=>read_container_c(
         EXPORTING
           im_container = <ls_param>-value
         IMPORTING
           ex_value     = ls_new_compound_pob
       ).
      ENDCASE.

    ENDLOOP.

* determine contract instance
    READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
         WITH KEY contract_id = ls_new_compound_pob-contract_id.

    lv_temp_subrc = sy-subrc.

    get_contract(
        EXPORTING
          iv_contract_id      = ls_new_compound_pob-contract_id
          iv_is_temp_contract = abap_false
        RECEIVING
          ro_contract         = lo_contract
      ).

    IF lv_temp_subrc <> 0.
      " the above logic has produce a contract into the contract mgmt
      IF ls_new_compound_pob-contract_id IS NOT INITIAL.
        TRY .
            lo_contract->load_contract( ).
          CATCH cx_farr_message.
            " dummy
        ENDTRY.
      ENDIF.

      ls_reassign_handler-contract_id   = ls_new_compound_pob-contract_id.
      APPEND ls_reassign_handler TO mt_reassign_handler.

    ENDIF.

    lo_contract->peer_build_new_compound_pob( is_new_compound_pob = ls_new_compound_pob ).

    me->mv_flg_reassign = abap_true.

  ENDMETHOD.                    "peer_create_compound_pob


  METHOD REASSIGN_PERFORM.
    DATA: ls_reassign_header          TYPE farr_s_reassign_header_final,
          lv_lock_target_success      TYPE abap_bool,
          lv_reassign_backend_success TYPE abap_bool,
          lt_pob_id                   TYPE farr_tt_pob_id,
          ls_changed_object           TYPE crmt_genil_obj_instance,
          lv_obj_id                   TYPE crmt_genil_object_id,
          ls_pob_key                  TYPE farr_s_pob_key,
          ls_contract_key             TYPE farr_s_contract_key.

    FIELD-SYMBOLS:
          <lv_pob_id>            TYPE farr_pob_id,
          <ls_pob_obj>           LIKE LINE OF ct_pob_obj,
          <ls_source_obj>        TYPE farr_s_reassign_source_objs,
          <ls_source_obj_new>    TYPE farr_s_reassign_src_objs_new,
          <ls_changed_object>    LIKE LINE OF et_changed_objects.

    CLEAR et_changed_objects.

    CALL METHOD reassign_convert_param
      EXPORTING
        it_parameter       = it_parameter
      IMPORTING
        es_reassign_header = ls_reassign_header.

    lv_lock_target_success = abap_true.

    IF lv_lock_target_success = abap_true.
      reassign_backend_call(
      EXPORTING is_reassign_header    = ls_reassign_header
                it_pob_obj            = ct_pob_obj
                io_msg_service_access = io_msg_service_access
      IMPORTING ev_reassign_backend_success = lv_reassign_backend_success
      ).
    ENDIF.

    IF lv_reassign_backend_success = abap_true.
      LOOP AT ct_pob_obj ASSIGNING <ls_pob_obj>.
        <ls_pob_obj>-success = abap_true.
        ls_changed_object-namespace   = <ls_pob_obj>-namespace.
        ls_changed_object-object_name = <ls_pob_obj>-object_name.
        ls_changed_object-object_id   = <ls_pob_obj>-object_id.
      ENDLOOP.
    ENDIF.
*    at same time mark source contract haven been changed.
    LOOP AT ls_reassign_header-source_objects ASSIGNING <ls_source_obj>.
      ls_contract_key-contract_id = <ls_source_obj>-contract_id.
    ENDLOOP.
    LOOP AT ls_reassign_header-source_objects_new ASSIGNING <ls_source_obj_new>.
      ls_contract_key-contract_id = <ls_source_obj_new>-contract_idx.
    ENDLOOP.
    CALL METHOD cl_crm_genil_container_tools=>build_object_id
      EXPORTING
        is_object_key = ls_contract_key
      RECEIVING
        rv_result     = lv_obj_id.

    APPEND INITIAL LINE TO et_changed_objects ASSIGNING <ls_changed_object>.
    <ls_changed_object>-namespace   = ls_changed_object-namespace.
    <ls_changed_object>-object_name = if_farrc_contr_mgmt=>co_on_contract.
    <ls_changed_object>-object_id   = lv_obj_id.

  ENDMETHOD.                    "reassign_execute


  METHOD REASSIGN_PERFORM_AFTER_WARNING.
    " this method is very like 'REASSIGN_PERFORM', the only difference is NOT calling to 'REASSIGN_BACKEND_CALL',
    " but to 'REASSIGN_BACKEND_CALL_AFTER_WA' which skips the header check and directly does pasting.

    DATA: ls_reassign_header          TYPE farr_s_reassign_header_final,
          lv_lock_target_success      TYPE abap_bool,
          lv_reassign_backend_success TYPE abap_bool.

    FIELD-SYMBOLS:
          <ls_pob_obj>           LIKE LINE OF ct_pob_obj.

    mv_flg_reassign = abap_true.

    CALL METHOD reassign_convert_param
      EXPORTING
        it_parameter       = it_parameter
      IMPORTING
        es_reassign_header = ls_reassign_header.

    reassign_determine_handler( EXPORTING iv_contract_id         = ls_reassign_header-target_contract_id
                                          iv_contr_idx           = ls_reassign_header-contr_idx
                                          io_msg_service_access  = io_msg_service_access ).

    reassign_backend_call_after_wa(
    EXPORTING is_reassign_header    = ls_reassign_header
              it_pob_obj            = ct_pob_obj
              io_msg_service_access = io_msg_service_access
    IMPORTING ev_reassign_backend_success = lv_reassign_backend_success
    ).

    IF lv_reassign_backend_success = abap_true.
      LOOP AT ct_pob_obj ASSIGNING <ls_pob_obj>.
        <ls_pob_obj>-success = abap_true.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.                    "reassign_execute


  METHOD REASSIGN_PREPARE_HANDLER.

* Target Contract
    reassign_determine_handler( EXPORTING iv_contract_id         = is_reassign_header-target_contract_id
                                          iv_contr_idx           = is_reassign_header-contr_idx
                                          io_msg_service_access  = io_msg_service_access ).

  ENDMETHOD.                    "reassign_execute


  METHOD REASSIGN_REMOVE_FROM_HANDLER.

    DATA: lv_contract_id          TYPE farr_contract_id.

    FIELD-SYMBOLS:
          <ls_param>              TYPE crmt_name_value_pair,
          <ls_reassign_handler>   LIKE LINE OF mt_reassign_handler.

    LOOP AT it_parameters ASSIGNING <ls_param>.
      lv_contract_id = <ls_param>-value.

      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY contract_id = lv_contract_id.

      IF sy-subrc = 0.
        cl_farr_contract_utility=>unlock_contract_exclusive( lv_contract_id ).
      ENDIF.

      DELETE mt_reassign_handler WHERE contract_id = lv_contract_id.
      " call delete from contract mgmt
      TRY .
          mo_contract_mgmt->remove_instance_for_bol(
                EXPORTING
                  iv_contract_id      = lv_contract_id
                  iv_is_temp_contract = abap_false
              ).
        CATCH cx_farr_message.
          " ignore if delete failed
      ENDTRY.


    ENDLOOP.

  ENDMETHOD.                    "reassign_remove_from_handler


  METHOD REASSIGN_SET_USE_IDX.

    FIELD-SYMBOLS:
          <ls_param>           TYPE crmt_name_value_pair.

    LOOP AT it_parameter ASSIGNING <ls_param>.
      CASE <ls_param>-name.
        WHEN if_farrc_contr_mgmt=>co_an_use_idx.
          mv_use_idx_as_contr_id = <ls_param>-value.
        WHEN if_farrc_contr_mgmt=>co_an_contract_index.
          mv_last_temp_contr_idx = <ls_param>-value.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.
    "For reassign case, if mv_use_idx_as_contr_id = abap_true, it means will use index as contract id
    "mv_contract_id should be set to MV_LAST_TEMP_CONTR_IDX
    "In this case, mv_contract_id is the contract id of the new target_contract(contract_id == 0).
    IF mv_use_idx_as_contr_id EQ abap_true.
      mv_contract_id = mv_last_temp_contr_idx.
    ENDIF.

    CLEAR mv_contract_id.

  ENDMETHOD.                    "reassign_set_use_idx


  METHOD REASSIGN_UNLOCK_CONTRACTS.

    DATA: lv_contract_index     TYPE farr_contract_id,
          lo_contract           TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_param>            TYPE crmt_name_value_pair,
          <ls_reassign_handler> LIKE LINE OF mt_reassign_handler.

    LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>.

      IF <ls_reassign_handler>-contract_id <> 0.
        " normal contract
        get_contract(
          EXPORTING
            iv_contract_id      = <ls_reassign_handler>-contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract         = lo_contract
        ).
      ELSE.
        " newly created contract
        lv_contract_index = <ls_reassign_handler>-temp_contract_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_contract_index
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract         = lo_contract
        ).
      ENDIF.

      IF lo_contract IS BOUND.
        " unlock the contract in case it still in lock status,
        " it does not matter unlock a single contract for more than once
        " Why an exclusive lock? There originally is an exclusive lock in refresh
        cl_farr_contract_utility=>unlock_contract_exclusive( lo_contract->get_contract_id( ) ).
        lo_contract->refresh_contract( ).
      ENDIF.

    ENDLOOP.

    reassign_clear_handler( ).

    CLEAR mv_flg_reassign.
    CLEAR mv_last_temp_contr_idx.

  ENDMETHOD.                    "reassign_unlock_contracts


  METHOD REFRESH_CONTRACT.

    DATA:
      lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol."Inorder to remove mo_contract_mgmt

    lo_contract_for_bol = get_contract( mv_contract_id ).

    " unlock the contract in case it still in lock status,
    " it does not matter unlock a single contract for more than once.
    " Why EXCLUSIVE lock? the original logic in refresh contract contains an exclusive unlock.
    cl_farr_contract_utility=>unlock_contract_exclusive( lo_contract_for_bol->get_contract_id( ) ).
    lo_contract_for_bol->refresh_contract( ).

  ENDMETHOD.                    "refresh_contract


  METHOD REMOVE_MANUAL_CHANGE_DATA.

    DATA:
      ls_manl_chng_data     TYPE farr_s_manl_chng_data,
      lt_manl_chng_data     TYPE farr_tt_manl_chng_data,
      lo_contract_for_bol   TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
      <ls_param>            LIKE LINE OF it_parameter.

    LOOP AT it_parameter ASSIGNING <ls_param>.
      IF <ls_param>-name = if_farrc_contr_mgmt=>co_an_pob_id.
        ls_manl_chng_data-pob_id = <ls_param>-value.
      ENDIF.
      IF <ls_param>-name = if_farrc_contr_mgmt=>co_an_field_name.
        ls_manl_chng_data-field_name = <ls_param>-value.
      ENDIF.
    ENDLOOP.
    ls_manl_chng_data-db_action = if_farrc_contr_mgmt=>co_change_type_d.
    APPEND ls_manl_chng_data TO lt_manl_chng_data.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    CALL METHOD lo_contract_for_bol->remove_manual_change_data
      EXPORTING
        it_manl_chng_data = lt_manl_chng_data.

  ENDMETHOD.                    "remove_manual_change_data


  METHOD REMOVE_PENDING_CONFLICT.
    DATA:
         lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    CALL METHOD lo_contract_for_bol->remove_pending_conflict
      EXPORTING
        it_parameters = it_parameters.

  ENDMETHOD.                    "remove_pending_conflict


  METHOD REPROCESS_ACCT_DETERMINATION.
    DATA lx_farr_message TYPE REF TO cx_farr_message.
    DATA: lo_contract                 TYPE REF TO if_farr_contract_mgmt_bol,
          lo_reprocess_acct_assistant TYPE REF TO if_farr_reprocess_account.
    FIELD-SYMBOLS:
                   <ls_contract_id> TYPE farr_contract_id.

    TRY.
        lo_contract = get_contract( mv_contract_id ).
        CREATE OBJECT lo_reprocess_acct_assistant TYPE cl_farr_reprocess_account.
        CALL METHOD lo_contract->set_reprocessed_accounts( lo_reprocess_acct_assistant ).
      CATCH cx_farr_message INTO lx_farr_message.
        cl_farr_contract_utility=>unlock_contract_exclusive( mv_contract_id ).
        cl_farr_db_update=>commit_work( ).
        RETURN.
    ENDTRY.

    " save all succeeded contracts
    mo_contract_mgmt->save_to_db(
    EXPORTING
      iv_reset_buffer = abap_false ).

    cl_farr_db_update=>commit_work( ).

  ENDMETHOD.                    "reprocess_acct_determination


  METHOD SAVE_COMBINE_CONTRACTS.
    DATA: lx_farr_message         TYPE REF TO cx_farr_message,
          lo_posting_4_combi      TYPE REF TO if_farr_posting_item_4_combi,
          lt_posting_4_combi      LIKE STANDARD TABLE OF lo_posting_4_combi,
          lv_catchup_year         TYPE farr_fiscal_year,
          lv_catchup_period       TYPE farr_period,
          lt_source_contract_main TYPE farr_tt_contract,
          lo_contract_main        TYPE REF TO cl_farr_contract_old,
          ls_contract_header      TYPE farr_s_contract_data_buffer,
          ls_reassign_mapping     TYPE ty_s_reassign_mapping,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol,
          lv_tmp_contract_ind     TYPE farr_contract_id,
          lo_last_at_new_contract TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
      <ls_reassign_handler>   TYPE ty_s_reassign_handler,
      <ls_reassign_mapping>   TYPE ty_s_reassign_mapping,
      <lo_posting_4_combi>    TYPE REF TO if_farr_posting_item_4_combi,
      <lv_source_contract_id> TYPE farr_contract_id,
      <ls_contract_id>        TYPE farr_contract_id.

    CLEAR ets_temp_contracts.

    LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>.
      IF <ls_reassign_handler>-contract_id <> 0.
        get_contract(
          EXPORTING
            iv_contract_id      = <ls_reassign_handler>-contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract        = lo_contract
        ).
      ELSE.
        lv_tmp_contract_ind = <ls_reassign_handler>-temp_contract_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_tmp_contract_ind
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract        = lo_contract
        ).
      ENDIF.

      lo_contract->combine_check_before_save( ).
    ENDLOOP.

    cl_farr_db_update=>register_table_for_buffering( iv_dbname = if_farrc_db_update=>co_farr_d_recon_key ).

    CLEAR lt_posting_4_combi[].
    SORT mt_reassign_mapping BY contract_id temp_contract_idx.
    LOOP AT mt_reassign_mapping ASSIGNING <ls_reassign_mapping>.
      CHECK <ls_reassign_mapping>-contract_id <> <ls_reassign_mapping>-source_contract_id.
      ls_reassign_mapping = <ls_reassign_mapping>.

      AT NEW temp_contract_idx.
        READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
          WITH TABLE KEY contract_id = ls_reassign_mapping-contract_id
                         temp_contract_idx = ls_reassign_mapping-temp_contract_idx.
        IF sy-subrc = 0.

          IF <ls_reassign_handler>-contract_id <> 0.
            get_contract(
              EXPORTING
                iv_contract_id      = <ls_reassign_handler>-contract_id
                iv_is_temp_contract = abap_false
              RECEIVING
                ro_contract     = lo_last_at_new_contract
            ).
          ELSE.
            lv_tmp_contract_ind = <ls_reassign_handler>-temp_contract_idx.
            get_contract(
              EXPORTING
                iv_contract_id      = lv_tmp_contract_ind
                iv_is_temp_contract = abap_true
              RECEIVING
                ro_contract     = lo_last_at_new_contract
            ).
          ENDIF.

          CALL METHOD lo_last_at_new_contract->read_contract_header
            IMPORTING
              es_contract_data_buffer = ls_contract_header.

          CALL METHOD cl_farr_contract_utility=>determine_catchup_period
            EXPORTING
              iv_change_mode     = mv_change_mode
              is_contract_header = ls_contract_header
              iv_mig_package     = mv_mig_package
              iv_validity_date   = mv_validity_date
            IMPORTING
              ev_fiscal_year     = lv_catchup_year
              ev_period          = lv_catchup_period.
        ENDIF.
        CLEAR lt_source_contract_main.
      ENDAT.

      READ TABLE mt_reassign_handler ASSIGNING <ls_reassign_handler>
        WITH KEY contract_id = ls_reassign_mapping-source_contract_id.

      IF sy-subrc = 0.
        get_contract(
          EXPORTING
            iv_contract_id      = <ls_reassign_handler>-contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract     = lo_contract
        ).

        lo_contract_main ?= lo_contract.
        APPEND lo_contract_main TO lt_source_contract_main.
      ENDIF.

      AT END OF temp_contract_idx.
        IF lt_source_contract_main IS NOT INITIAL.
          lo_contract_main ?= lo_last_at_new_contract.

          CREATE OBJECT lo_posting_4_combi TYPE cl_farr_posting_item_4_combi.
          CALL METHOD lo_posting_4_combi->initialize
            EXPORTING
              it_src_contract   = lt_source_contract_main
              io_tgt_contract   = lo_contract_main
              iv_catchup_year   = lv_catchup_year
              iv_catchup_period = lv_catchup_period
              io_msg_handler    = lo_last_at_new_contract->get_msg_handler( ).

          CALL METHOD lo_posting_4_combi->process.

          APPEND lo_posting_4_combi TO lt_posting_4_combi.
        ENDIF.
      ENDAT.
    ENDLOOP.
    "Collect messages, under the benefit of single pattern used by message handler, we can get all messages
    "of all contracts directly
    "1. Collect messages: to generate 'create success' 'delete success' 'price allocation' message and so on
    LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>.
      IF <ls_reassign_handler>-contract_id <> 0.
        get_contract(
          EXPORTING
            iv_contract_id      = <ls_reassign_handler>-contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract        = lo_contract
        ).
      ELSE.
        lv_tmp_contract_ind = <ls_reassign_handler>-temp_contract_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_tmp_contract_ind
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract        = lo_contract
        ).
      ENDIF.

      lo_contract->collect_messages( ).
    ENDLOOP.
    "2. Add messages to io_msg_cont
    IF lo_contract IS BOUND.
      CALL METHOD convert_msg_from_t100_to_bapi(
        EXPORTING
          io_msg_container    = io_msg_cont
          io_combine_contract = lo_contract ).
    ENDIF.

    " get temporary contracts which does not have contract id,
    " this must be got before save
    ets_temp_contracts = mo_contract_mgmt->get_temp_instances_for_bol( ).

    " save to db
    " if the target contract is a temporary one, only save to db will give the contract id
    " to it. So we cannot remove it from buffer, for the buffer is the only one who knows
    " the contract id.
    mo_contract_mgmt->save_to_db(
    EXPORTING
      iv_reset_buffer = abap_false
).

    LOOP AT lt_posting_4_combi ASSIGNING <lo_posting_4_combi>.
      <lo_posting_4_combi>->save( ).
    ENDLOOP.

  ENDMETHOD.                    "save_combine_contracts


  METHOD SEARCH_CONFLICT_UI.


    DATA:
          ls_conflict_ui_key     TYPE farr_s_conflict_manl_chng_key,
          lo_root_object         TYPE REF TO if_genil_cont_root_object,
          lo_manl_chng_db_access TYPE REF TO if_farr_manl_chng_db_access,
          lt_manl_chng_data      TYPE farr_tt_manl_chng_data,
          ls_pob_id_range        TYPE farr_s_pob_id_range,
          lt_pob_id_range        TYPE farr_tt_pob_id_range,
          ls_manl_chng_key       TYPE farr_s_conflict_manl_chng_key.

    FIELD-SYMBOLS:
          <ls_selection_parameter>   LIKE LINE OF it_selection_parameters,
          <ls_manl_chng_data>        LIKE LINE OF lt_manl_chng_data.

    LOOP AT it_selection_parameters ASSIGNING <ls_selection_parameter>.
      IF <ls_selection_parameter>-attr_name = if_farrc_contr_mgmt=>co_an_pob_id.
        MOVE-CORRESPONDING <ls_selection_parameter> TO ls_pob_id_range.
        APPEND ls_pob_id_range TO lt_pob_id_range.
      ENDIF.
    ENDLOOP.

    TRY.
        CREATE OBJECT lo_manl_chng_db_access TYPE cl_farr_manl_chng_db_access.
        CALL METHOD lo_manl_chng_db_access->read_mutiple_by_pob_range
          EXPORTING
            it_pob_id_range   = lt_pob_id_range  " Range table for POB ID
          IMPORTING
            et_manl_chng_data = lt_manl_chng_data.
      CATCH cx_farr_not_found.
    ENDTRY.


* selection without range table
    LOOP AT lt_manl_chng_data ASSIGNING <ls_manl_chng_data>.
      MOVE-CORRESPONDING <ls_manl_chng_data> TO ls_manl_chng_key.
      lo_root_object = io_root_list->add_object(
          iv_object_name = if_farrc_contr_mgmt=>co_on_conflict_ui
          is_object_key  = ls_manl_chng_key
          iv_attr_req    = abap_false
          iv_key_is_id   = abap_false
          ).
* Add the object to root list
      lo_root_object->set_attributes( <ls_manl_chng_data> ).

    ENDLOOP.

  ENDMETHOD.                    "SEARCH_CONFLICT_UI


  METHOD SEARCH_CONTRACT.
    DATA: lt_sel_param                 TYPE genilt_selection_parameter_tab,
          lt_sel_param_contract_id     TYPE genilt_selection_parameter_tab,
          lt_sel_criteria              TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_contract_id  TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_contract     TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_pob          TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_mapping      TYPE rsdsfrange_t_ssel,
          lv_max_hits                  TYPE bapi_maxhits,
          lt_contract                  TYPE farr_tt_contract_data,
          lv_result                    TYPE boolean,
          lv_number_before_check       TYPE i.

    lv_max_hits = determine_max_hits( is_query_parameters ).

    CALL METHOD me->search_contract_by_otherfields
      EXPORTING
        it_selection_parameters  = it_selection_parameters
      IMPORTING
        et_selection_parameters  = lt_sel_param
        et_sel_param_contract_id = lt_sel_param_contract_id
        ev_result                = lv_result.

    IF lv_result = abap_true.

      CALL METHOD convert_sel_param
        EXPORTING
          it_sel_param    = lt_sel_param
        IMPORTING
          et_sel_criteria = lt_sel_criteria.

      IF NOT lt_sel_param_contract_id IS INITIAL.
        CALL METHOD convert_sel_param
          EXPORTING
            it_sel_param    = lt_sel_param_contract_id
          IMPORTING
            et_sel_criteria = lt_sel_criteria_contract_id.

* These Contract ID will have AND relation with the existing Contract ID in the search
        APPEND LINES OF lt_sel_criteria_contract_id TO lt_sel_criteria.
      ENDIF.

      CALL METHOD cl_farr_contract_query=>get_contracts
        EXPORTING
          it_search_criteria = lt_sel_criteria
          iv_max_hits        = lv_max_hits
        IMPORTING
          et_contract_data   = lt_contract.

      lv_number_before_check = lines( lt_contract ).
      IF lv_number_before_check = 0.
        CALL METHOD convert_sel_into_search_table
          EXPORTING
            it_sel_criteria             = lt_sel_criteria
          IMPORTING
            it_search_criteria_contract = lt_sel_criteria_contract
            it_search_criteria_pob      = lt_sel_criteria_pob
            it_search_criteria_mapping  = lt_sel_criteria_mapping.

        CALL METHOD cl_farr_contract_db_access=>get_contracts_from_archive
          EXPORTING
            it_search_criteria_contract = lt_sel_criteria_contract
            it_search_criteria_pob      = lt_sel_criteria_pob
            it_search_criteria_mapping  = lt_sel_criteria_mapping
            iv_max_hits                 = lv_max_hits
          IMPORTING
            et_contract_data            = lt_contract.

        lv_number_before_check = lines( lt_contract ).
      ENDIF.
      CALL METHOD cl_farr_contract_utility=>authority_check_contract_list
        CHANGING
          ct_contract_data = lt_contract.

      CALL METHOD set_contract_resultset_2rtobj
        EXPORTING
          it_contract            = lt_contract
          io_root_list           = io_root_list
          iv_load_soft_del       = iv_load_soft_del
          iv_number_before_check = lv_number_before_check.

    ENDIF.

  ENDMETHOD.                    "search_contract


  METHOD SEARCH_CONTRACT_BY_OTHERFIELDS.
    DATA: lt_cocode_range         TYPE RANGE OF bukrs,
          ls_cocode_range         LIKE LINE OF  lt_cocode_range,
          lt_pob_id_range         TYPE RANGE OF farr_pob_id,
          ls_pob_id_range         LIKE LINE OF  lt_pob_id_range,
          lt_pob_name_range       TYPE RANGE OF farr_pob_name,
          ls_pob_name_range       LIKE LINE OF  lt_pob_name_range,
          lt_customer_id_range    TYPE RANGE OF kunnr,
          ls_customer_id_range    LIKE LINE OF lt_customer_id_range,
          ls_selection_parameter  TYPE genilt_selection_parameter,
          lt_contract_id_result   TYPE farr_tt_contract_key.
    FIELD-SYMBOLS:
          <ls_select_param>       TYPE genilt_selection_parameter,
          <ls_contract_id_result> TYPE farr_s_contract_key.

    CLEAR et_selection_parameters.
    CLEAR et_sel_param_contract_id.
    ev_result = abap_true.

* check if there is any criteria not attaching to contract
    LOOP AT it_selection_parameters ASSIGNING <ls_select_param>.
      CASE <ls_select_param>-attr_name.
* company code
        WHEN if_farrc_contr_mgmt=>co_an_company_code.
          MOVE-CORRESPONDING <ls_select_param> TO ls_cocode_range.
          INSERT ls_cocode_range   INTO TABLE lt_cocode_range.

* pob id
        WHEN if_farrc_contr_mgmt=>co_an_pob_id.
          MOVE-CORRESPONDING <ls_select_param> TO ls_pob_id_range.
          INSERT ls_pob_id_range         INTO TABLE lt_pob_id_range.

* pob name
        WHEN if_farrc_contr_mgmt=>co_an_pob_name.
          MOVE-CORRESPONDING <ls_select_param> TO ls_pob_name_range.
          INSERT ls_pob_name_range       INTO TABLE lt_pob_name_range.

* customer id
        WHEN if_farrc_contr_mgmt=>co_an_customer_id.
          MOVE-CORRESPONDING <ls_select_param> TO ls_customer_id_range.
          INSERT ls_customer_id_range    INTO TABLE lt_customer_id_range.

* contract id from original UI input, which is now saved into a separate table
        WHEN if_farrc_contr_mgmt=>co_an_contract_id.
          APPEND <ls_select_param> TO et_sel_param_contract_id.

        WHEN OTHERS.
          INSERT <ls_select_param> INTO TABLE et_selection_parameters.
      ENDCASE.
    ENDLOOP.

    IF lines( lt_cocode_range )       > 0
    OR lines( lt_pob_id_range )       > 0
    OR lines( lt_pob_name_range )     > 0
    OR lines( lt_customer_id_range )  > 0.
      TRY.
          CALL METHOD cl_farr_pob_db_access=>read_contract_id_by_range_tab
            EXPORTING
              it_company_code = lt_cocode_range
              it_pob_id       = lt_pob_id_range
              it_pob_name     = lt_pob_name_range
              it_customer_id  = lt_customer_id_range
            IMPORTING
              et_contract_id  = lt_contract_id_result.
        CATCH cx_farr_not_found .
          ev_result = abap_false.
          RETURN.
      ENDTRY.

      LOOP AT lt_contract_id_result ASSIGNING <ls_contract_id_result>.
        CLEAR ls_selection_parameter.
        ls_selection_parameter-attr_name = if_farrc_contr_mgmt=>co_an_contract_id.
        ls_selection_parameter-sign      = 'I'.
        ls_selection_parameter-option    = 'EQ'.
        ls_selection_parameter-low       = <ls_contract_id_result>-contract_id.
        ls_selection_parameter-high      = space.
        INSERT ls_selection_parameter INTO TABLE et_selection_parameters.
      ENDLOOP.
    ELSE.
* no pob field is set as selection criteria, move back the contract id selection if any
      APPEND LINES OF et_sel_param_contract_id TO et_selection_parameters.
      CLEAR et_sel_param_contract_id.
    ENDIF.
  ENDMETHOD.                    "search_contract_by_otherfields


  METHOD SEARCH_CONTRACT_BY_RANGE_TAB.
    DATA: lt_sel_param                 TYPE genilt_selection_parameter_tab,
          lt_sel_param_contract_id     TYPE genilt_selection_parameter_tab,
          lt_sel_criteria              TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_contract     TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_pob          TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_mapping      TYPE rsdsfrange_t_ssel,
          lv_max_hits                  TYPE bapi_maxhits,
          lt_contract                  TYPE farr_tt_contract_data,
          lt_contract_temp             TYPE farr_tt_contract_data,
          ls_contract                  LIKE LINE OF lt_contract,
          lt_contract_key              TYPE farr_tt_contract_key,
          ls_contract_key              LIKE LINE OF lt_contract_key,
          lv_result                    TYPE boolean,
          lt_selection_parameters      TYPE genilt_selection_parameter_tab,
          ls_selection_parameters      LIKE LINE OF lt_selection_parameters,
          lv_number_before_check       TYPE i,
          lv_contract_archived         TYPE boolean.

    FIELD-SYMBOLS:
          <ls_select_param>       TYPE genilt_selection_parameter.

    CLEAR lv_contract_archived.
    lt_selection_parameters = it_selection_parameters.

    READ TABLE it_selection_parameters WITH KEY attr_name = if_farrc_contr_mgmt=>co_an_flag_with_doc INTO ls_selection_parameters.
    IF sy-subrc = 0.
      CASE ls_selection_parameters-low.
        WHEN if_farrc_contr_mgmt=>co_tab_contr_search_by_contr.
* View -- Operational Documents by Contract
          DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_flag_with_doc.
          lv_max_hits = determine_max_hits( is_query_parameters ).

          READ TABLE it_selection_parameters WITH KEY attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag INTO ls_selection_parameters.
          IF sy-subrc EQ 0
            AND ls_selection_parameters-low EQ abap_true.
            DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag.
            lv_contract_archived = abap_true.
            CALL METHOD convert_sel_param
              EXPORTING
                it_sel_param    = lt_selection_parameters
              IMPORTING
                et_sel_criteria = lt_sel_criteria.

* Archiving
            CALL METHOD convert_sel_into_search_table
              EXPORTING
                it_sel_criteria             = lt_sel_criteria
              IMPORTING
                it_search_criteria_contract = lt_sel_criteria_contract
                it_search_criteria_pob      = lt_sel_criteria_pob
                it_search_criteria_mapping  = lt_sel_criteria_mapping.


            CALL METHOD cl_farr_contract_db_access=>read_oper_doc_by_ar_contracts
              EXPORTING
                it_search_criteria_contract = lt_sel_criteria_contract
                it_search_criteria_pob      = lt_sel_criteria_pob
                it_search_criteria_mapping  = lt_sel_criteria_mapping
                iv_max_hits                 = lv_max_hits
              IMPORTING
                et_contract_data            = lt_contract.

          ELSEIF sy-subrc EQ 0
            AND ls_selection_parameters-low EQ abap_false.
            DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag.
            lv_contract_archived = abap_false.
* Normal Contracts
            CALL METHOD convert_sel_param
              EXPORTING
                it_sel_param    = lt_selection_parameters
              IMPORTING
                et_sel_criteria = lt_sel_criteria.

            CALL METHOD cl_farr_contract_db_access=>read_oper_doc_by_contract
              EXPORTING
                it_search_criteria = lt_sel_criteria
                iv_max_hits        = lv_max_hits
              IMPORTING
                et_contract_data   = lt_contract.
          ENDIF.

          lv_number_before_check = lines( lt_contract ).
          CALL METHOD cl_farr_contract_utility=>authority_check_contract_list
            CHANGING
              ct_contract_data = lt_contract.

          CALL METHOD set_con_ope_resultset_2rtobj
            EXPORTING
              it_contract            = lt_contract
              io_root_list           = io_root_list
              iv_ope_by_contract     = abap_true
              iv_contract_by_ope     = abap_false
              iv_load_soft_del       = iv_load_soft_del
              iv_number_before_check = lv_number_before_check
              iv_contract_archived   = lv_contract_archived.

          EXIT.
        WHEN if_farrc_contr_mgmt=>co_tab_contr_search_by_doc.
* View -- Contracts by Operational Document
          DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_flag_with_doc.
          lv_max_hits = determine_max_hits( is_query_parameters ).

          READ TABLE it_selection_parameters WITH KEY attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag INTO ls_selection_parameters.
          IF sy-subrc EQ 0
            AND ls_selection_parameters-low EQ abap_true.
            DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag.
            CALL METHOD convert_sel_param
              EXPORTING
                it_sel_param    = lt_selection_parameters
              IMPORTING
                et_sel_criteria = lt_sel_criteria.

* Archiving
            CALL METHOD convert_sel_into_search_table
              EXPORTING
                it_sel_criteria             = lt_sel_criteria
              IMPORTING
                it_search_criteria_contract = lt_sel_criteria_contract
                it_search_criteria_pob      = lt_sel_criteria_pob
                it_search_criteria_mapping  = lt_sel_criteria_mapping.

            CALL METHOD cl_farr_contract_db_access=>read_ar_contracts_by_oper_doc
              EXPORTING
                it_search_criteria_contract = lt_sel_criteria_contract
                it_search_criteria_pob      = lt_sel_criteria_pob
                it_search_criteria_mapping  = lt_sel_criteria_mapping
                iv_max_hits                 = lv_max_hits
              IMPORTING
                et_contract_data            = lt_contract.

          ELSEIF sy-subrc EQ 0
            AND ls_selection_parameters-low EQ abap_false.
            DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag.
* Normal Contracts
            CALL METHOD convert_sel_param
              EXPORTING
                it_sel_param    = lt_selection_parameters
              IMPORTING
                et_sel_criteria = lt_sel_criteria.

            CALL METHOD cl_farr_contract_db_access=>read_contract_by_oper_doc
              EXPORTING
                it_search_criteria = lt_sel_criteria
                iv_max_hits        = lv_max_hits
              IMPORTING
                et_contract_data   = lt_contract.
          ENDIF.

          lv_number_before_check = lines( lt_contract ).
          CALL METHOD cl_farr_contract_utility=>authority_check_contract_list
            CHANGING
              ct_contract_data = lt_contract.

          CALL METHOD set_con_ope_resultset_2rtobj
            EXPORTING
              it_contract            = lt_contract
              io_root_list           = io_root_list
              iv_ope_by_contract     = abap_false
              iv_contract_by_ope     = abap_true
              iv_load_soft_del       = iv_load_soft_del
              iv_number_before_check = lv_number_before_check.
          EXIT.
        WHEN OTHERS.
      ENDCASE.
    ELSE.
* General View by Contracts
      lv_max_hits = determine_max_hits( is_query_parameters ).

      READ TABLE it_selection_parameters WITH KEY attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag INTO ls_selection_parameters.
      IF sy-subrc EQ 0
        AND ls_selection_parameters-low EQ abap_true.
* Archiving Contracts
        DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag.
        lv_contract_archived = abap_true.
        CALL METHOD convert_sel_param
          EXPORTING
            it_sel_param    = lt_selection_parameters
          IMPORTING
            et_sel_criteria = lt_sel_criteria.

        CALL METHOD convert_sel_into_search_table
          EXPORTING
            it_sel_criteria             = lt_sel_criteria
          IMPORTING
            it_search_criteria_contract = lt_sel_criteria_contract
            it_search_criteria_pob      = lt_sel_criteria_pob
            it_search_criteria_mapping  = lt_sel_criteria_mapping.

        CALL METHOD cl_farr_contract_db_access=>get_contracts_from_archive
          EXPORTING
            it_search_criteria_contract = lt_sel_criteria_contract
            it_search_criteria_pob      = lt_sel_criteria_pob
            it_search_criteria_mapping  = lt_sel_criteria_mapping
            iv_max_hits                 = lv_max_hits
          IMPORTING
            et_contract_data            = lt_contract[].
      ELSEIF sy-subrc EQ 0
        AND ls_selection_parameters-low EQ abap_false.
        DELETE lt_selection_parameters WHERE attr_name = if_farrc_contr_mgmt=>co_an_archiving_flag.
        lv_contract_archived = abap_false.
        CALL METHOD convert_sel_param
          EXPORTING
            it_sel_param    = lt_selection_parameters
          IMPORTING
            et_sel_criteria = lt_sel_criteria.

        CALL METHOD cl_farr_contract_db_access=>read_multiple_by_range_tab
          EXPORTING
            it_search_criteria = lt_sel_criteria
            iv_max_hits        = lv_max_hits
          IMPORTING
            et_contract_data   = lt_contract.
      ELSEIF sy-subrc <> 0.
        CALL METHOD convert_sel_param
          EXPORTING
            it_sel_param    = lt_selection_parameters
          IMPORTING
            et_sel_criteria = lt_sel_criteria.

        CALL METHOD cl_farr_contract_db_access=>read_multiple_by_range_tab
          EXPORTING
            it_search_criteria = lt_sel_criteria
            iv_max_hits        = lv_max_hits
          IMPORTING
            et_contract_data   = lt_contract.
        IF lt_contract[] IS INITIAL.

          CALL METHOD convert_sel_into_search_table
            EXPORTING
              it_sel_criteria             = lt_sel_criteria
            IMPORTING
              it_search_criteria_contract = lt_sel_criteria_contract
              it_search_criteria_pob      = lt_sel_criteria_pob
              it_search_criteria_mapping  = lt_sel_criteria_mapping.

          CALL METHOD cl_farr_contract_db_access=>get_contracts_from_archive
            EXPORTING
              it_search_criteria_contract = lt_sel_criteria_contract
              it_search_criteria_pob      = lt_sel_criteria_pob
              it_search_criteria_mapping  = lt_sel_criteria_mapping
              iv_max_hits                 = lv_max_hits
            IMPORTING
              et_contract_data            = lt_contract[].
        ENDIF.

      ENDIF.

      lv_number_before_check = lines( lt_contract ).
      CALL METHOD cl_farr_contract_utility=>authority_check_contract_list
        CHANGING
          ct_contract_data = lt_contract.

      SORT lt_contract DESCENDING BY contract_id.
      CALL METHOD set_contract_resultset_2rtobj
        EXPORTING
          it_contract            = lt_contract
          io_root_list           = io_root_list
          iv_load_soft_del       = iv_load_soft_del
          iv_number_before_check = lv_number_before_check
          iv_contract_archived   = lv_contract_archived.
    ENDIF.

  ENDMETHOD.                    "search_contract_by_range_tab


  METHOD SEARCH_CONTRACT_FOR_MANUAL.
    DATA: lt_sel_param                 TYPE genilt_selection_parameter_tab,
          lt_sel_param_contract_id     TYPE genilt_selection_parameter_tab,
          lt_sel_criteria              TYPE rsdsfrange_t_ssel,
          lt_sel_criteria_contract_id  TYPE rsdsfrange_t_ssel,
          lv_max_hits                  TYPE bapi_maxhits,
          lt_contract                  TYPE farr_tt_contract_data,
          lv_result                    TYPE boolean,
          lv_number_before_check       TYPE i.
    FIELD-SYMBOLS:
          <ls_contract>                TYPE farr_s_contract_data.

    lv_max_hits = determine_max_hits( is_query_parameters ).

    CALL METHOD convert_sel_param
      EXPORTING
        it_sel_param    = it_selection_parameters
      IMPORTING
        et_sel_criteria = lt_sel_criteria.


    CALL METHOD cl_farr_manual_contract_mgmt=>search_contract
      EXPORTING
        iv_max_hits        = lv_max_hits    " Maximum no. of hits
        it_search_criteria = lt_sel_criteria
      IMPORTING
        et_contract_data   = lt_contract.    " Table Type of Contract Data

    lv_number_before_check = lines( lt_contract ).
    CALL METHOD cl_farr_contract_utility=>authority_check_contract_list
      CHANGING
        ct_contract_data = lt_contract.
    SORT lt_contract BY created_on DESCENDING.
    CALL METHOD set_contract_resultset_2rtobj
      EXPORTING
        it_contract            = lt_contract
        io_root_list           = io_root_list
        iv_load_soft_del       = iv_load_soft_del
        iv_number_before_check = lv_number_before_check.

  ENDMETHOD.                    "search_contract


  METHOD SEARCH_POB.
    DATA:
          ls_pob_key             TYPE farr_s_pob_key,
          lo_root_object         TYPE REF TO if_genil_cont_root_object,
          ls_pob_id_range        TYPE farr_s_pob_id_range,
          lt_pob_id_range        TYPE farr_tt_pob_id_range,
          lt_pob_data            TYPE farr_tt_pob_data.

    FIELD-SYMBOLS:
          <ls_selection_parameter>   LIKE LINE OF it_selection_parameters,
          <ls_pob_data>           TYPE farr_s_pob_data.

    LOOP AT it_selection_parameters ASSIGNING <ls_selection_parameter>.
      IF <ls_selection_parameter>-attr_name = if_farrc_contr_mgmt=>co_an_pob_id.
        MOVE-CORRESPONDING <ls_selection_parameter> TO ls_pob_id_range.
        APPEND ls_pob_id_range TO lt_pob_id_range.
      ENDIF.
    ENDLOOP.

    TRY.
        CALL METHOD cl_farr_pob_db_access=>read_multiple
          EXPORTING
            it_pob_id   = lt_pob_id_range
          IMPORTING
            et_pob_data = lt_pob_data.
      CATCH cx_farr_not_found.
    ENDTRY.


* selection without range table
    LOOP AT lt_pob_data ASSIGNING <ls_pob_data>.
      ls_pob_key-pob_id = <ls_pob_data>-pob_id.

      lo_root_object = io_root_list->add_object(
          iv_object_name = if_farrc_contr_mgmt=>co_on_pob
          is_object_key  = ls_pob_key
          iv_attr_req    = abap_false
          iv_key_is_id   = abap_false
          ).
* Add the object to root list
      lo_root_object->set_attributes( <ls_pob_data> ).

    ENDLOOP.

  ENDMETHOD.                    "search_pob


  METHOD SEARCH_POB_ADV.

    DATA:
         lt_sel_param               TYPE genilt_selection_parameter_tab,
         lt_sel_param_contract_id   TYPE genilt_selection_parameter_tab,
         lt_sel_criteria            TYPE rsdsfrange_t_ssel,
         lv_max_hits                TYPE bapi_maxhits,
         lt_pob                     TYPE farr_tt_pob_data,
         ls_pob_key                 TYPE farr_s_pob_key,
         lo_root_object             TYPE REF TO if_genil_cont_root_object,
         lo_root                    TYPE REF TO cl_crm_genil_container_object.

    FIELD-SYMBOLS:
          <ls_selection_parameter>   LIKE LINE OF it_selection_parameters,
          <ls_pob_data>           TYPE farr_s_pob_data.



    lv_max_hits = determine_max_hits( is_query_parameters ).

    CALL METHOD convert_sel_param
      EXPORTING
        it_sel_param    = it_selection_parameters
      IMPORTING
        et_sel_criteria = lt_sel_criteria.


    CALL METHOD cl_farr_pob_db_access=>read_multiple_by_range_tab
      EXPORTING
        it_search_criteria = lt_sel_criteria
        iv_max_hits        = lv_max_hits
        iv_use_filter      = iv_use_filter
      IMPORTING
        et_pob_data        = lt_pob.


* selection without range table
    LOOP AT lt_pob ASSIGNING <ls_pob_data>.
      ls_pob_key-pob_id = <ls_pob_data>-pob_id.

      lo_root_object = io_root_list->add_object(
          iv_object_name = if_farrc_contr_mgmt=>co_on_pob
          is_object_key  = ls_pob_key
          iv_attr_req    = abap_false
          iv_key_is_id   = abap_false
      ).
      lo_root_object->set_attributes( <ls_pob_data> ).

*    lo_root_object->set_query_root( abap_true ).
*      lo_root ?= lo_root_object.
*      lo_root->set_parent_relation(
*        EXPORTING
*          iv_relation_name  =    'FarrPOBofContract'  " Relation Name
*          iv_relation_is_11 =  abap_false   " Logical Variable
**          iv_parent         =     " Data Container - Object Interface
*      ).

    ENDLOOP.

  ENDMETHOD.                    "search_pob


  METHOD SEARCH_POB_BY_TYPE.
    DATA:
          lt_pob_type_range      TYPE farr_tt_pob_type_range,
          ls_pob_type_range      TYPE farr_s_pob_type_range,
          lt_pob_data_ui         TYPE farr_tt_pob_data_ui,
          ls_pob_data_ui         TYPE farr_s_pob_data_ui,
          ls_pob_key             TYPE farr_s_pob_key,
          lv_contract_id         TYPE farr_contract_id,
          lo_root_object         TYPE REF TO if_genil_cont_root_object,
          lt_pob_id              TYPE farr_tt_pob_id.

    FIELD-SYMBOLS:
          <ls_selection_parameter>   LIKE LINE OF it_selection_parameters,
          <ls_pob_data_ui>           TYPE farr_s_pob_data_ui.

    LOOP AT it_selection_parameters ASSIGNING <ls_selection_parameter>.
      IF <ls_selection_parameter>-attr_name = if_farrc_contr_mgmt=>co_an_contract_id.
        lv_contract_id = <ls_selection_parameter>-low.
        CHECK lv_contract_id IS NOT INITIAL.
      ELSEIF <ls_selection_parameter>-attr_name = if_farrc_contr_mgmt=>co_an_pob_type.
        IF <ls_selection_parameter>-low = if_farrc_contr_mgmt=>co_pob_type_blank.
          ls_pob_type_range-low  = ''.
        ELSE.
          ls_pob_type_range-low  = <ls_selection_parameter>-low.
        ENDIF.
        ls_pob_type_range-sign   = <ls_selection_parameter>-sign.
        ls_pob_type_range-option = <ls_selection_parameter>-option.
        APPEND ls_pob_type_range TO lt_pob_type_range.
      ENDIF.
    ENDLOOP.

    TRY.
        CALL METHOD cl_farr_pob_db_access=>read_multi_per_contr_pob_types
          EXPORTING
            iv_contract_id    = lv_contract_id
            it_pob_type_range = lt_pob_type_range
          IMPORTING
            et_pob_data_ui    = lt_pob_data_ui.
      CATCH cx_farr_not_found.
    ENDTRY.

    load_pob_ui_amount(
      EXPORTING
        iv_contract_id = lv_contract_id
      CHANGING
        ct_pob_data_ui = lt_pob_data_ui    " Table type for POB UI
    ).

    LOOP AT lt_pob_data_ui ASSIGNING <ls_pob_data_ui>.

      CLEAR ls_pob_data_ui.
      MOVE-CORRESPONDING <ls_pob_data_ui> TO ls_pob_data_ui.
      ls_pob_key-pob_id = ls_pob_data_ui-pob_id.
      lo_root_object = io_root_list->add_object(
            iv_object_name = if_farrc_contr_mgmt=>co_on_pob_ui
            is_object_key  = ls_pob_key
            iv_attr_req    = abap_false
            iv_key_is_id   = abap_false
            ).
      lo_root_object->set_attributes( ls_pob_data_ui ).
    ENDLOOP.


  ENDMETHOD.                    "SEARCH_POB_BY_TYPE


  METHOD SEARCH_REV_EXPLAIN.
    DATA:
          ls_rev_sch_key            TYPE farr_s_rev_schedule_key,
          lo_root_object            TYPE REF TO if_genil_cont_root_object,
          ls_pob_id_range           TYPE farr_s_pob_id_range,
          lt_pob_id                 TYPE farr_tt_pob_id,
          lv_contract_id            TYPE farr_contract_id,
          lt_rev_explain_data       TYPE farr_tt_rev_explain_data,
          lv_non_distinct_only      TYPE abap_bool VALUE abap_false,
          lo_contract               TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_selection_parameter>  LIKE LINE OF it_selection_parameters,
          <ls_rev_explain_data>     TYPE farr_s_rev_explain_data.

    READ TABLE it_selection_parameters ASSIGNING <ls_selection_parameter>
                                       WITH KEY attr_name = if_farrc_contr_mgmt=>co_an_contract_id.
    IF sy-subrc = 0.
      lv_contract_id = <ls_selection_parameter>-low.
    ENDIF.

    TRY.
        get_contract(
          EXPORTING
            iv_contract_id         = lv_contract_id
            iv_is_temp_contract    = abap_false
          RECEIVING
            ro_contract            = lo_contract
        ).
        lo_contract->load_contract( ). "incase contract has not been loaded
        mv_contract_id = lv_contract_id.

        CALL METHOD lo_contract->get_rev_explain
          EXPORTING
            iv_contract_id = lv_contract_id
          IMPORTING
            et_rev_explain = lt_rev_explain_data.

        LOOP AT lt_rev_explain_data ASSIGNING <ls_rev_explain_data>.
          ls_rev_sch_key-pob_id       = <ls_rev_explain_data>-pob_id.
          ls_rev_sch_key-acct_period  = <ls_rev_explain_data>-acct_period.

          lo_root_object = io_root_list->add_object(
              iv_object_name = if_farrc_contr_mgmt=>co_on_rev_explain
              is_object_key  = ls_rev_sch_key
              iv_attr_req    = abap_false
              iv_key_is_id   = abap_false
              ).
* Add the object to root list
          lo_root_object->set_attributes( <ls_rev_explain_data> ).
        ENDLOOP.
      CATCH cx_farr_message.

    ENDTRY.
  ENDMETHOD.                    "SEARCH_REV_EXPLAIN


  METHOD SEARCH_REV_SCHEDULE.
    DATA:
          ls_rev_sch_key            TYPE farr_s_rev_schedule_key,
          lo_root_object            TYPE REF TO if_genil_cont_root_object,
          ls_pob_id_range           TYPE farr_s_pob_id_range,
          lt_pob_id                 TYPE farr_tt_pob_id,
          lv_contract_id            TYPE farr_contract_id,
          lt_rev_sch_data           TYPE farr_ts_rev_schedule,
          lv_non_distinct_only      TYPE abap_bool VALUE abap_false,
          lo_contract               TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_selection_parameter>  LIKE LINE OF it_selection_parameters,
          <ls_rev_sch_data>         TYPE farr_s_rev_schedule_data.

* prepare parameter
    LOOP AT it_selection_parameters ASSIGNING <ls_selection_parameter>.
      IF <ls_selection_parameter>-attr_name = if_farrc_contr_mgmt=>co_an_pob_id.
        MOVE-CORRESPONDING <ls_selection_parameter> TO ls_pob_id_range.
        APPEND ls_pob_id_range-low TO lt_pob_id.
      ELSEIF <ls_selection_parameter>-attr_name = if_farrc_contr_mgmt=>co_an_contract_id.
        lv_contract_id = <ls_selection_parameter>-low.
      ELSEIF <ls_selection_parameter>-attr_name = if_farrc_contr_mgmt=>co_an_non_distinct_only.
        lv_non_distinct_only = abap_true.
      ENDIF.
    ENDLOOP.

    TRY.
        get_contract(
          EXPORTING
            iv_contract_id         = lv_contract_id
            iv_is_temp_contract    = abap_false
          RECEIVING
            ro_contract            = lo_contract
        ).
        lo_contract->load_contract( ). "incase contract has not been loaded
        mv_contract_id = lv_contract_id.

* query revenue schedule
        CALL METHOD lo_contract->get_rev_schedule
          EXPORTING
            iv_contract_id       = lv_contract_id
            it_pob_id            = lt_pob_id
            iv_non_distinct_only = lv_non_distinct_only
          IMPORTING
            et_rev_schedule      = lt_rev_sch_data.

        LOOP AT lt_rev_sch_data ASSIGNING <ls_rev_sch_data>.
          ls_rev_sch_key-pob_id       = <ls_rev_sch_data>-pob_id.
          ls_rev_sch_key-acct_period  = <ls_rev_sch_data>-acct_period.

          lo_root_object = io_root_list->add_object(
              iv_object_name = if_farrc_contr_mgmt=>co_on_rev_schedule
              is_object_key  = ls_rev_sch_key
              iv_attr_req    = abap_false
              iv_key_is_id   = abap_false
              ).
* Add the object to root list
          lo_root_object->set_attributes( <ls_rev_sch_data> ).
        ENDLOOP.
      CATCH cx_farr_message.
    ENDTRY.
  ENDMETHOD.                    "search_rev_schedule


  METHOD SEARCH_REV_SPREADING.

    DATA lt_rev_spreading_data TYPE farr_tt_rev_spreading_data.
    DATA ls_rev_spreading_key  TYPE farr_s_rev_schedule_key.
    DATA lo_root_object        TYPE REF TO if_genil_cont_root_object.

    FIELD-SYMBOLS <ls_rev_spreading_data> LIKE LINE OF lt_rev_spreading_data.

    CALL METHOD mo_rev_spreading->get_rev_spreading
      IMPORTING
        et_rev_spreading_data = lt_rev_spreading_data.

    build_spr_attr_changeable_list( ).

    LOOP AT lt_rev_spreading_data ASSIGNING <ls_rev_spreading_data>.
      ls_rev_spreading_key-pob_id       = <ls_rev_spreading_data>-pob_id.
      ls_rev_spreading_key-acct_period  = <ls_rev_spreading_data>-acct_period.

      lo_root_object = io_root_list->add_object(
          iv_object_name = if_farrc_contr_mgmt=>co_on_rev_spreading
          is_object_key  = ls_rev_spreading_key
          iv_attr_req    = abap_false
          iv_key_is_id   = abap_false
          ).
* Add the object to root list
      lo_root_object->set_attributes( <ls_rev_spreading_data> ).

      set_attr_property( EXPORTING io_obj              = lo_root_object
                                   it_changeable_field = mt_changeable_field_spreading ).

    ENDLOOP.

  ENDMETHOD.                    "search_rev_spreading


  METHOD SEARCH_REV_SUMMARY.
    DATA:
          ls_rev_sum_key            TYPE farr_s_rev_sum_key,
          lo_root_object            TYPE REF TO if_genil_cont_root_object,
          lv_contract_id            TYPE farr_contract_id,
          ls_rev_summary            TYPE farr_s_rev_summary,
          lo_contract TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_selection_parameter>  LIKE LINE OF it_selection_parameters.

* query revenue schedule summary

    lo_contract = get_contract( mv_contract_id ).

    CALL METHOD lo_contract->get_rev_summary
      IMPORTING
        es_rev_summary = ls_rev_summary.

    ls_rev_sum_key-contract_id = ls_rev_summary-contract_id.

    lo_root_object = io_root_list->add_object(
        iv_object_name = if_farrc_contr_mgmt=>co_on_rev_summary
        is_object_key  = ls_rev_sum_key
        iv_attr_req    = abap_false
        iv_key_is_id   = abap_false
        ).
* Add the object to root list
    lo_root_object->set_attributes( ls_rev_summary ).
  ENDMETHOD.                    "search_rev_summary


  METHOD SET_ATTR_PROPERTY.
    DATA: lo_attr_props       TYPE REF TO if_genil_obj_attr_properties.
    FIELD-SYMBOLS:
          <lv_attr_name>      TYPE name_komp.

    lo_attr_props = io_obj->get_attr_props_obj( ).
    LOOP AT it_changeable_field ASSIGNING <lv_attr_name>.
      CALL METHOD lo_attr_props->set_property_by_name
        EXPORTING
          iv_name  = <lv_attr_name>
          iv_value = if_genil_obj_attr_properties=>changeable.
    ENDLOOP.
  ENDMETHOD.                    "set_attr_property


  METHOD SET_ATTR_PROPERTY_CHG_TYPE.
    CALL METHOD set_attr_property
      EXPORTING
        io_obj              = io_chg_type_obj
        it_changeable_field = mt_changeable_field_chg_type.
  ENDMETHOD.                    "set_attr_property_change_type


  METHOD SET_ATTR_PROPERTY_CONTRACT.
    CALL METHOD set_attr_property
      EXPORTING
        io_obj              = io_contract_obj
        it_changeable_field = mt_changeable_field_contract.

  ENDMETHOD.                    "set_attr_property_contract


  METHOD SET_ATTR_PROPERTY_DEFERRAL.                        "#EC NEEDED
  ENDMETHOD.                    "set_attr_property_deferral


  METHOD SET_ATTR_PROPERTY_NEW_POB.
    CASE iv_new_pob_kind.
      WHEN 'A'.
        CALL METHOD set_attr_property
          EXPORTING
            io_obj              = io_pob_obj
            it_changeable_field = mt_changeable_field_new_pob.
      WHEN 'C'.
        CALL METHOD set_attr_property
          EXPORTING
            io_obj              = io_pob_obj
            it_changeable_field = mt_changeable_field_new_pob_c.
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.                    "set_attr_property_new_pob


  METHOD SET_ATTR_PROPERTY_POB.
    CALL METHOD set_attr_property
      EXPORTING
        io_obj              = io_pob_obj
        it_changeable_field = mt_changeable_field_pob.
  ENDMETHOD.                    "set_attr_property_pob


  METHOD SET_ATTR_PROPERTY_SPREADING.
    DATA lt_changeable_fileds_empty LIKE mt_changeable_field_spreading.

    IF iv_post_revenue = 0.
      CALL METHOD set_attr_property
        EXPORTING
          io_obj              = io_container_obj
          it_changeable_field = mt_changeable_field_spreading.
    ELSE.
      CALL METHOD set_attr_property
        EXPORTING
          io_obj              = io_container_obj
          it_changeable_field = lt_changeable_fileds_empty.
    ENDIF.

  ENDMETHOD.                    "set_attr_property_pob


  METHOD SET_BOL_KEYS_ADDI_POB_BY_POB.
    DATA: lt_addi_pob_data_buffer TYPE farr_tt_pob_data_buffer,
          ls_addi_pob_key         TYPE farr_s_pob_key,
          ls_pob_key              TYPE farr_s_pob_key,
          lv_flg_first            TYPE abap_bool,
          lo_pob_obj              TYPE REF TO if_genil_container_object,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_addi_pob_data_buffer> TYPE farr_s_pob_data_buffer.

    lo_pob_obj = io_addi_pob_obj->get_parent( ).

    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_addition_pob_of_pob
          EXPORTING
            iv_pob_id               = ls_pob_key-pob_id
          IMPORTING
            et_addi_pob_data_buffer = lt_addi_pob_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_addi_pob_data_buffer ASSIGNING <ls_addi_pob_data_buffer>
         WHERE del_flag IS INITIAL.

      MOVE-CORRESPONDING <ls_addi_pob_data_buffer> TO ls_addi_pob_key.
      IF lv_flg_first IS INITIAL.
        io_addi_pob_obj->set_key( ls_addi_pob_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_addi_pob_obj->copy_self_with_structure( is_object_key = ls_addi_pob_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_deferral


  METHOD SET_BOL_KEYS_ALLOC_CONDTYPE.
    DATA: lo_pob_obj                 TYPE REF TO if_genil_container_object,
          lt_cond_type_data_buffer   TYPE farr_tt_cond_type_buffer,
          ls_cond_type_key           TYPE farr_s_cond_type_key,
          ls_pob_key                 TYPE farr_s_pob_key,
          lv_flg_first               TYPE abap_bool,
          lo_contract                TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_cond_type_data_buffer> TYPE farr_s_cond_type_buffer.

    lo_pob_obj = io_condtype_obj->get_parent( ).
    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.
    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_alloc_condtype_of_pob
          EXPORTING
            iv_pob_id           = ls_pob_key-pob_id
          IMPORTING
            et_cond_type_buffer = lt_cond_type_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_cond_type_data_buffer ASSIGNING <ls_cond_type_data_buffer>.

      MOVE-CORRESPONDING <ls_cond_type_data_buffer> TO ls_cond_type_key.
      IF lv_flg_first IS INITIAL.
        io_condtype_obj->set_key( ls_cond_type_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_condtype_obj->copy_self_with_structure( is_object_key = ls_cond_type_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_condtype


  METHOD SET_BOL_KEYS_CHG_TYPE_BY_CONTR.
    DATA: lt_change_type_buffer   TYPE farr_tt_chg_type_buffer,
          ls_change_type_key      TYPE farr_s_chg_type_key,
          lv_flg_first            TYPE abap_bool,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_change_type_buffer> TYPE farr_s_chg_type_buffer.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_change_type_of_contract
          IMPORTING
            et_change_type_buffer = lt_change_type_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_change_type_buffer ASSIGNING <ls_change_type_buffer>.

      MOVE-CORRESPONDING <ls_change_type_buffer> TO ls_change_type_key.
      IF lv_flg_first IS INITIAL.
        io_chg_type_obj->set_key( ls_change_type_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_chg_type_obj->copy_self_with_structure( is_object_key = ls_change_type_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_chg_type


  METHOD SET_BOL_KEYS_CHG_TYPE_BY_POB.
    DATA: lt_change_type_buffer   TYPE farr_tt_chg_type_buffer,
          ls_change_type_key      TYPE farr_s_chg_type_key,
          ls_pob_key              TYPE farr_s_pob_key,
          lv_flg_first            TYPE abap_bool,
          lo_pob_obj              TYPE REF TO if_genil_container_object,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_change_type_buffer> TYPE farr_s_chg_type_buffer.

    lo_pob_obj = io_chg_type_obj->get_parent( ).

    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_change_type_of_pob
          EXPORTING
            iv_pob_id             = ls_pob_key-pob_id
          IMPORTING
            et_change_type_buffer = lt_change_type_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_change_type_buffer ASSIGNING <ls_change_type_buffer>
      WHERE del_flag IS INITIAL.

      MOVE-CORRESPONDING <ls_change_type_buffer> TO ls_change_type_key.
      IF lv_flg_first IS INITIAL.
        io_chg_type_obj->set_key( ls_change_type_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_chg_type_obj->copy_self_with_structure( is_object_key = ls_change_type_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_chg_type


  METHOD SET_BOL_KEYS_CONDTYPE.
    DATA: lo_pob_obj                 TYPE REF TO if_genil_container_object,
          lt_cond_type_data_buffer   TYPE farr_tt_cond_type_buffer,
          ls_cond_type_key           TYPE farr_s_cond_type_key,
          ls_pob_key                 TYPE farr_s_pob_key,
          lv_flg_first               TYPE abap_bool,
          lo_contract                TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_cond_type_data_buffer> TYPE farr_s_cond_type_buffer.

    lo_pob_obj = io_condtype_obj->get_parent( ).
    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.
    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_condtype_of_pob
          EXPORTING
            iv_pob_id           = ls_pob_key-pob_id
          IMPORTING
            et_cond_type_buffer = lt_cond_type_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_cond_type_data_buffer ASSIGNING <ls_cond_type_data_buffer>.

      MOVE-CORRESPONDING <ls_cond_type_data_buffer> TO ls_cond_type_key.
      IF lv_flg_first IS INITIAL.
        io_condtype_obj->set_key( ls_cond_type_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_condtype_obj->copy_self_with_structure( is_object_key = ls_cond_type_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_condtype


  METHOD SET_BOL_KEYS_CONFLICT_UI.
    DATA: lo_parent_obj         TYPE REF TO if_genil_container_object,
          lv_parent_name        TYPE crmt_ext_obj_name,
          lt_conflict_ui_data   TYPE farr_tt_manl_chng_data,
          ls_conflict_ui_key    TYPE farr_s_conflict_manl_chng_key,
          ls_pob_key            TYPE farr_s_pob_key,
          ls_contract_key       TYPE farr_s_contract_key,
          lv_flg_first          TYPE abap_bool.
    FIELD-SYMBOLS
          <ls_conflict_ui_data> TYPE farr_s_manl_chng_data.

    lo_parent_obj = io_conflict_ui_obj->get_parent( ).
    lv_parent_name = lo_parent_obj->get_name( ).

    IF lv_parent_name = if_farrc_contr_mgmt=>co_on_pob.
      CALL METHOD lo_parent_obj->get_key
        IMPORTING
          es_key = ls_pob_key.

    ELSEIF lv_parent_name = if_farrc_contr_mgmt=>co_on_contract.
      CALL METHOD lo_parent_obj->get_key
        IMPORTING
          es_key = ls_contract_key.
    ENDIF.

    TRY.
        CALL METHOD mo_conflict_mgmt->read_manual_change
          IMPORTING
            et_manual_change_data = lt_conflict_ui_data.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_conflict_ui_data ASSIGNING <ls_conflict_ui_data>.

      IF ls_pob_key-pob_id IS NOT INITIAL.
        IF <ls_conflict_ui_data>-pob_id <> ls_pob_key-pob_id.
          CONTINUE.
        ENDIF.
      ENDIF.

      MOVE-CORRESPONDING <ls_conflict_ui_data> TO ls_conflict_ui_key.

      IF lv_flg_first IS INITIAL.
        io_conflict_ui_obj->set_key( ls_conflict_ui_key ).
        lv_flg_first = abap_true.
      ELSE.
        io_conflict_ui_obj->copy_self_with_structure( is_object_key = ls_conflict_ui_key ).
      ENDIF.

    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_conflict_ui


  METHOD SET_BOL_KEYS_DEFERRAL.
    DATA: lt_deferral_data_buffer TYPE farr_tt_deferral_data_buffer,
          ls_deferral_key         TYPE farr_s_deferral_key,
          lv_flg_first            TYPE abap_bool,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_deferral_data_buffer> TYPE farr_s_deferral_data_buffer.

    lo_contract = get_contract( mv_contract_id ).

    TRY.
        CALL METHOD lo_contract->read_addition_defer_of_contrct
          IMPORTING
            et_deferral_data_buffer = lt_deferral_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_deferral_data_buffer ASSIGNING <ls_deferral_data_buffer>
         WHERE del_flag IS INITIAL.

      MOVE-CORRESPONDING <ls_deferral_data_buffer> TO ls_deferral_key.
      IF lv_flg_first IS INITIAL.
        io_deferral_obj->set_key( ls_deferral_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_deferral_obj->copy_self_with_structure( is_object_key = ls_deferral_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_deferral


  METHOD SET_BOL_KEYS_DEFERRAL_BY_POB.
    DATA: lt_deferral_data_buffer TYPE farr_tt_deferral_data_buffer,
          ls_deferral_key         TYPE farr_s_deferral_key,
          ls_pob_key              TYPE farr_s_pob_key,
          lv_flg_first            TYPE abap_bool,
          lo_pob_obj              TYPE REF TO if_genil_container_object,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_deferral_data_buffer> TYPE farr_s_deferral_data_buffer.

    lo_pob_obj = io_deferral_obj->get_parent( ).

    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_addition_defer_of_pob
          EXPORTING
            iv_pob_id               = ls_pob_key-pob_id
          IMPORTING
            et_deferral_data_buffer = lt_deferral_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_deferral_data_buffer ASSIGNING <ls_deferral_data_buffer>
         WHERE del_flag IS INITIAL.

      MOVE-CORRESPONDING <ls_deferral_data_buffer> TO ls_deferral_key.
      IF lv_flg_first IS INITIAL.
        io_deferral_obj->set_key( ls_deferral_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_deferral_obj->copy_self_with_structure( is_object_key = ls_deferral_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_deferral


  METHOD SET_BOL_KEYS_DEFITEM.
    DATA: lt_defitem_data_buffer TYPE farr_tt_defitem_data_buffer,
          ls_defitem_key         TYPE farr_s_defitem_key,
          lv_flg_first           TYPE abap_bool,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_defitem_data_buffer> TYPE farr_s_defitem_data_buffer.

    lo_contract = get_contract( mv_contract_id ).

    TRY.
        CALL METHOD lo_contract->read_defitem_of_contract
          IMPORTING
            et_defitem_data_buffer = lt_defitem_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_defitem_data_buffer ASSIGNING <ls_defitem_data_buffer>
         WHERE del_flag IS INITIAL.

      MOVE-CORRESPONDING <ls_defitem_data_buffer> TO ls_defitem_key.
      IF lv_flg_first IS INITIAL.
        io_defitem_obj->set_key( ls_defitem_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_defitem_obj->copy_self_with_structure( is_object_key = ls_defitem_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_defitem


  METHOD SET_BOL_KEYS_DEFITEM_BY_POB.
    DATA: lt_defitem_data_buffer TYPE farr_tt_defitem_data_buffer,
          ls_defitem_key         TYPE farr_s_defitem_key,
          ls_pob_key             TYPE farr_s_pob_key,
          lv_flg_first           TYPE abap_bool,
          lo_pob_obj             TYPE REF TO if_genil_container_object,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_defitem_data_buffer> TYPE farr_s_defitem_data_buffer.

    lo_pob_obj = io_defitem_obj->get_parent( ).

    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_defitem_of_pob
          EXPORTING
            iv_pob_id              = ls_pob_key-pob_id
          IMPORTING
            et_defitem_data_buffer = lt_defitem_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_defitem_data_buffer ASSIGNING <ls_defitem_data_buffer>
         WHERE del_flag IS INITIAL.

      MOVE-CORRESPONDING <ls_defitem_data_buffer> TO ls_defitem_key.
      IF lv_flg_first IS INITIAL.
        io_defitem_obj->set_key( ls_defitem_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_defitem_obj->copy_self_with_structure( is_object_key = ls_defitem_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_defitem


  METHOD SET_BOL_KEYS_DOCUMENT.
    DATA: lo_pob_obj              TYPE REF TO if_genil_container_object,
          ls_document_data_buffer TYPE farr_s_document_data,
          ls_document_key         TYPE farr_s_document_key,
          ls_pob_key              TYPE farr_s_pob_key,
          lv_flg_first            TYPE abap_bool,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    lo_pob_obj = io_document_obj->get_parent( ).
    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_document_of_pob
          EXPORTING
            iv_pob_id          = ls_pob_key-pob_id
          IMPORTING
            es_document_buffer = ls_document_data_buffer.
      CATCH cx_farr_not_found.
        " dummy
    ENDTRY.

    IF ls_document_data_buffer IS NOT INITIAL.
      MOVE-CORRESPONDING ls_document_data_buffer TO ls_document_key.
      IF lv_flg_first IS INITIAL.
        io_document_obj->set_key( ls_document_key ).
        lv_flg_first = abap_true.
      ENDIF.
    ENDIF.

  ENDMETHOD.                    "set_bol_keys_document


  METHOD SET_BOL_KEYS_FULFILL.
    DATA: lo_defitem_obj         TYPE REF TO if_genil_container_object,
          ls_defitem_key         TYPE farr_s_defitem_key,
          ls_fulfill_key         TYPE farr_s_fulfill_key,
          lt_fulfill_data_buffer TYPE farr_tt_fulfill_data_buffer,
          lv_flg_first           TYPE abap_bool,
          lo_contract            TYPE REF TO if_farr_contract_mgmt_bol.
    FIELD-SYMBOLS:
          <ls_fulfill_data_buffer> TYPE farr_s_fulfill_data_buffer.

    lo_defitem_obj = io_fulfill_obj->get_parent( ).

    CALL METHOD lo_defitem_obj->get_key
      IMPORTING
        es_key = ls_defitem_key.
    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_fulfill_of_defitem
          EXPORTING
            iv_pob_id              = ls_defitem_key-pob_id
          IMPORTING
            et_fulfill_data_buffer = lt_fulfill_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_fulfill_data_buffer ASSIGNING <ls_fulfill_data_buffer>
         WHERE del_flag IS INITIAL.

      IF lv_flg_first IS INITIAL.
        TRY.
            ls_fulfill_key-guid = <ls_fulfill_data_buffer>-guid.
            io_fulfill_obj->set_key( ls_fulfill_key ).
          CATCH cx_crm_genil_duplicate_key.
* The fulfillment already exist, do not retrieve again
            RETURN.
        ENDTRY.

        lv_flg_first = abap_true.
      ELSE.
        ls_fulfill_key-guid = <ls_fulfill_data_buffer>-guid.
        io_fulfill_obj->copy_self_with_structure( is_object_key = ls_fulfill_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "set_bol_keys_fulfill


  METHOD SET_BOL_KEYS_FULFILL_BY_POB.
    DATA: lt_fulfill_data_buffer  TYPE farr_tt_fulfill_data_buffer,
          ls_fulfill_key          TYPE farr_s_fulfill_key,
          ls_pob_key              TYPE farr_s_pob_key,
          lv_flg_first            TYPE abap_bool,
          lo_pob_obj              TYPE REF TO if_genil_container_object,
          lo_contract             TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_fulfill_data_buffer> TYPE farr_s_fulfill_data_buffer.

    lo_pob_obj = io_fulfill_obj->get_parent( ).

    CALL METHOD lo_pob_obj->get_key
      IMPORTING
        es_key = ls_pob_key.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_fulfill_of_pob
          EXPORTING
            iv_pob_id              = ls_pob_key-pob_id
          IMPORTING
            et_fulfill_data_buffer = lt_fulfill_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_fulfill_data_buffer ASSIGNING <ls_fulfill_data_buffer>
         WHERE del_flag IS INITIAL.

      MOVE-CORRESPONDING <ls_fulfill_data_buffer> TO ls_fulfill_key.
      IF lv_flg_first IS INITIAL.
        io_fulfill_obj->set_key( ls_fulfill_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_fulfill_obj->copy_self_with_structure( is_object_key = ls_fulfill_key ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "set_bol_keys_fulfill_by_pob


  METHOD SET_BOL_KEYS_POB.
    DATA: lt_pob_data_buffer TYPE farr_tt_pob_data_buffer,
          ls_pob_key         TYPE farr_s_pob_key,
          lv_flg_first       TYPE abap_bool,
          lo_contract        TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_pob_data_buffer> TYPE farr_s_pob_data_buffer.

    TRY.
        lo_contract = get_contract( mv_contract_id ).
        CALL METHOD lo_contract->read_pob_of_contract
          IMPORTING
            et_pob_data_buffer = lt_pob_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_pob_data_buffer ASSIGNING <ls_pob_data_buffer>. " SOFT_DELETE WANGKU

      MOVE-CORRESPONDING <ls_pob_data_buffer> TO ls_pob_key.
      IF lv_flg_first IS INITIAL.
        io_pob_obj->set_key( ls_pob_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_pob_obj->copy_self_with_structure( is_object_key = ls_pob_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "SET_BOL_KEYS_POB


  METHOD SET_BOL_KEYS_POBTYPE.
    DATA:
          lt_pob_type_data_buffer   TYPE farr_tt_pob_type_data_buffer,
          ls_pob_type_key           TYPE farr_s_pob_type_key,
          lv_flg_first              TYPE abap_bool,
          lo_contract               TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS
          <ls_pob_type_data_buffer> TYPE farr_s_pob_type_data_buffer.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_pob_by_type_of_contract
          IMPORTING
            et_pob_type_data_buffer = lt_pob_type_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_pob_type_data_buffer ASSIGNING <ls_pob_type_data_buffer>.
      MOVE-CORRESPONDING <ls_pob_type_data_buffer> TO ls_pob_type_key.
      IF lv_flg_first IS INITIAL.
        io_pob_type_obj->set_key( ls_pob_type_key ).
        lv_flg_first = abap_true.
      ELSE.
        io_pob_type_obj->copy_self_with_structure( is_object_key = ls_pob_type_key ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "set_bol_keys_pobtype


  METHOD SET_BOL_KEYS_POB_ALL.
    DATA: lt_pob_data_buffer TYPE farr_tt_pob_data_buffer,
          ls_pob_key         TYPE farr_s_pob_key,
          lv_flg_first       TYPE abap_bool,
          lo_contract        TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_pob_data_buffer> TYPE farr_s_pob_data_buffer.

    TRY.
        lo_contract = get_contract( mv_contract_id ).

        CALL METHOD lo_contract->read_pob_of_contract
          IMPORTING
            et_pob_data_buffer = lt_pob_data_buffer.
      CATCH cx_farr_not_found.
    ENDTRY.

    LOOP AT lt_pob_data_buffer ASSIGNING <ls_pob_data_buffer>.

      MOVE-CORRESPONDING <ls_pob_data_buffer> TO ls_pob_key.
      IF lv_flg_first IS INITIAL.
        io_pob_obj->set_key( ls_pob_key ).

        lv_flg_first = abap_true.
      ELSE.
        io_pob_obj->copy_self_with_structure( is_object_key = ls_pob_key ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "SET_BOL_KEYS_POB


  METHOD SET_CONTRACT_RESULTSET_2RTOBJ.

*--------------------------------------------------------------------*
* Contract resultset to root object
*--------------------------------------------------------------------*
    DATA: ls_contract_key    TYPE farr_s_contract_key,
          lo_root_object     TYPE REF TO if_genil_cont_root_object,
          lv_num_of_contract TYPE sytabix.
    FIELD-SYMBOLS
          <ls_contract>      TYPE farr_s_contract_data.

* selection without range table
    LOOP AT it_contract ASSIGNING <ls_contract>.

      CASE iv_load_soft_del.

        WHEN 2. " Load not soft deleted contract only ( Default )
          IF <ls_contract>-soft_deleted = abap_false.
            lv_num_of_contract = lv_num_of_contract + 1.
            ls_contract_key-contract_id = <ls_contract>-contract_id.
            lo_root_object = io_root_list->add_object(
                iv_object_name = if_farrc_contr_mgmt=>co_on_contract
                is_object_key  = ls_contract_key
                iv_attr_req    = abap_false
                iv_key_is_id   = abap_false ).
            lo_root_object->set_attributes( <ls_contract> ).
          ENDIF.

        WHEN 1. " Load soft deleted contract only
          IF <ls_contract>-soft_deleted = abap_true.
            lv_num_of_contract = lv_num_of_contract + 1.
            ls_contract_key-contract_id = <ls_contract>-contract_id.
            lo_root_object = io_root_list->add_object(
                iv_object_name = if_farrc_contr_mgmt=>co_on_contract
                is_object_key  = ls_contract_key
                iv_attr_req    = abap_false
                iv_key_is_id   = abap_false ).
            lo_root_object->set_attributes( <ls_contract> ).
          ENDIF.

        WHEN 0. " Load all contract
          lv_num_of_contract = lv_num_of_contract + 1.
          ls_contract_key-contract_id = <ls_contract>-contract_id.
          lo_root_object = io_root_list->add_object(
              iv_object_name = if_farrc_contr_mgmt=>co_on_contract
              is_object_key  = ls_contract_key
              iv_attr_req    = abap_false
              iv_key_is_id   = abap_false ).
          lo_root_object->set_attributes( <ls_contract> ).
      ENDCASE.

    ENDLOOP.

    CALL METHOD msg_contract_selected
      EXPORTING
        io_root_list           = io_root_list
        iv_num_of_contract     = lv_num_of_contract
        iv_number_after_check  = lines( it_contract )
        iv_number_before_check = iv_number_before_check
        iv_contract_archived   = iv_contract_archived.

  ENDMETHOD.                    "set_contract_resultset_2rtobj


  METHOD SET_CON_OPE_RESULTSET_2RTOBJ.

*--------------------------------------------------------------------*
* Contract resultset to root object
*--------------------------------------------------------------------*
    DATA: ls_contract_doc_key    TYPE farr_s_contract_doc_key,
          lt_contract            TYPE farr_tt_contract_data,
          lo_root_object         TYPE REF TO if_genil_cont_root_object,
          lv_num                 TYPE sytabix,
          lo_msg_cont            TYPE REF TO cl_crm_genil_global_mess_cont,
          lv_msgno               TYPE symsgno,
          lv_msgv1               TYPE sy-msgv1,
          lv_msgv2               TYPE sy-msgv2,
          lv_number_after_check  TYPE i.

    FIELD-SYMBOLS
          <ls_contract>      TYPE farr_s_contract_data.

* selection without range table
    LOOP AT it_contract ASSIGNING <ls_contract>.

      CASE iv_load_soft_del.

        WHEN 2. " Load not soft deleted contract only ( Default )
          IF <ls_contract>-soft_deleted = abap_false.
            ls_contract_doc_key-contract_id = <ls_contract>-contract_id.
            ls_contract_doc_key-header_id   = <ls_contract>-header_id.
            lo_root_object = io_root_list->add_object(
                iv_object_name = if_farrc_contr_mgmt=>co_on_contract
                is_object_key  = ls_contract_doc_key
                iv_attr_req    = abap_false
                iv_key_is_id   = abap_false ).
            lo_root_object->set_attributes( <ls_contract> ).
          ENDIF.

        WHEN 1. " Load soft deleted contract only
          IF <ls_contract>-soft_deleted = abap_true.
            ls_contract_doc_key-contract_id = <ls_contract>-contract_id.
            ls_contract_doc_key-header_id   = <ls_contract>-header_id.
            lo_root_object = io_root_list->add_object(
                iv_object_name = if_farrc_contr_mgmt=>co_on_contract
                is_object_key  = ls_contract_doc_key
                iv_attr_req    = abap_false
                iv_key_is_id   = abap_false ).
            lo_root_object->set_attributes( <ls_contract> ).
          ENDIF.

        WHEN 0. " Load all contract
          ls_contract_doc_key-contract_id = <ls_contract>-contract_id.
          ls_contract_doc_key-header_id   = <ls_contract>-header_id.
          lo_root_object = io_root_list->add_object(
              iv_object_name = if_farrc_contr_mgmt=>co_on_contract
              is_object_key  = ls_contract_doc_key
              iv_attr_req    = abap_false
              iv_key_is_id   = abap_false ).
          lo_root_object->set_attributes( <ls_contract> ).
      ENDCASE.

    ENDLOOP.

    lt_contract = it_contract.
    lv_number_after_check = lines( it_contract ).
    IF iv_ope_by_contract EQ abap_true.
* Contract View - Operational Document by Contract
      SORT lt_contract ASCENDING BY contract_id.
      DELETE ADJACENT DUPLICATES FROM lt_contract COMPARING contract_id.
      DESCRIBE TABLE lt_contract LINES lv_num.

      lo_msg_cont = io_root_list->get_global_message_container( ).
      lo_msg_cont->reset( ).

      lv_msgv1 = lv_num.

      IF lv_num > 0.
* &1 contracts found
        MESSAGE s001(farr_contract_bol) WITH lv_num INTO mv_msg_str.
        lv_msgno = 001.
        CALL METHOD lo_msg_cont->add_message
          EXPORTING
            iv_msg_type       = 'S'
            iv_msg_id         = 'FARR_CONTRACT_BOL'
            iv_msg_number     = lv_msgno
            iv_msg_text       = mv_msg_str
            iv_msg_v1         = lv_msgv1
            iv_show_only_once = abap_true.
      ELSEIF iv_contract_archived EQ abap_true.
        MESSAGE s002(farr_contract_bol) INTO mv_msg_str.
        lv_msgno = 002.
        CALL METHOD lo_msg_cont->add_message
          EXPORTING
            iv_msg_type       = 'S'
            iv_msg_id         = 'FARR_CONTRACT_BOL'
            iv_msg_number     = lv_msgno
            iv_msg_text       = mv_msg_str
            iv_show_only_once = abap_true.
      ELSEIF iv_contract_archived EQ abap_false.
        MESSAGE s008(farr_contract_bol) INTO mv_msg_str.
        lv_msgno = 008.
        CALL METHOD lo_msg_cont->add_message
          EXPORTING
            iv_msg_type       = 'S'
            iv_msg_id         = 'FARR_CONTRACT_BOL'
            iv_msg_number     = lv_msgno
            iv_msg_text       = mv_msg_str
            iv_show_only_once = abap_true.
      ENDIF.

      IF lv_number_after_check <> iv_number_before_check.
        MESSAGE w007(farr_contract_bol) INTO mv_msg_str.
        lv_msgno = 007.
        CALL METHOD lo_msg_cont->add_message
          EXPORTING
            iv_msg_type       = 'W'
            iv_msg_id         = 'FARR_CONTRACT_BOL'
            iv_msg_number     = lv_msgno
            iv_msg_text       = mv_msg_str
            iv_show_only_once = abap_true.
      ENDIF.

    ELSEIF iv_contract_by_ope EQ abap_true.
* Contract View - Contract by Opertional Document
      SORT lt_contract ASCENDING BY header_id.
      DELETE ADJACENT DUPLICATES FROM lt_contract COMPARING header_id.
      DESCRIBE TABLE lt_contract LINES lv_num.

      lo_msg_cont = io_root_list->get_global_message_container( ).
      lo_msg_cont->reset( ).

      lv_msgv1 = lv_num.

      IF lv_num > 0.
* &1 operational Documents found
        MESSAGE s003(farr_contract_bol) WITH lv_num INTO mv_msg_str.
        lv_msgno = 003.
        CALL METHOD lo_msg_cont->add_message
          EXPORTING
            iv_msg_type       = 'S'
            iv_msg_id         = 'FARR_CONTRACT_BOL'
            iv_msg_number     = lv_msgno
            iv_msg_text       = mv_msg_str
            iv_msg_v1         = lv_msgv1
            iv_show_only_once = abap_true.
      ELSE.
        MESSAGE s004(farr_contract_bol) INTO mv_msg_str.
        lv_msgno = 004.
        CALL METHOD lo_msg_cont->add_message
          EXPORTING
            iv_msg_type       = 'S'
            iv_msg_id         = 'FARR_CONTRACT_BOL'
            iv_msg_number     = lv_msgno
            iv_msg_text       = mv_msg_str
            iv_show_only_once = abap_true.
      ENDIF.

      IF lv_number_after_check <> iv_number_before_check.
        MESSAGE w007(farr_contract_bol) INTO mv_msg_str.
        lv_msgno = 007.
        CALL METHOD lo_msg_cont->add_message
          EXPORTING
            iv_msg_type       = 'W'
            iv_msg_id         = 'FARR_CONTRACT_BOL'
            iv_msg_number     = lv_msgno
            iv_msg_text       = mv_msg_str
            iv_show_only_once = abap_true.
      ENDIF.

    ENDIF.

  ENDMETHOD.                    "set_con_ope_resultset_2rtobj


  METHOD SET_MANUAL_FULFILL_FLG.
    mv_flg_manual_fulfill = abap_true.
  ENDMETHOD.                    "set_manual_fulfill_flg


  METHOD SET_NEW_ALLOCATED_AMOUNT.
    DATA lt_pob_new_corr_amount TYPE farr_tt_pob_amount.
    DATA ls_pob_new_corr_amount LIKE LINE OF lt_pob_new_corr_amount.
    DATA ls_changed_object      LIKE LINE OF et_changed_objects.
    DATA ls_pob_key             TYPE farr_s_pob_key.
    DATA lv_object_id           TYPE crmt_genil_object_id.

    DATA lo_contract_for_bol    TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS <ls_parameter> LIKE LINE OF it_parameters.
    FIELD-SYMBOLS <ls_obj>       LIKE LINE OF ct_object_list.

    ls_changed_object-object_name = if_farrc_contr_mgmt=>co_on_pob.

    LOOP AT it_parameters ASSIGNING <ls_parameter>.
      IF  <ls_parameter>-name = if_farrc_contr_mgmt=>co_an_pob_id.
        ls_pob_new_corr_amount-pob_id = <ls_parameter>-value.
        ls_pob_key-pob_id = <ls_parameter>-value.
        lv_object_id = cl_crm_genil_container_tools=>build_object_id( ls_pob_key ).
        ls_changed_object-object_id = lv_object_id.
        APPEND ls_changed_object TO et_changed_objects.
      ELSE.
        IF <ls_parameter>-name = if_farrc_contr_mgmt=>co_an_diff_amount.
          ls_pob_new_corr_amount-diff_amount = <ls_parameter>-value.
          APPEND ls_pob_new_corr_amount TO lt_pob_new_corr_amount.
        ENDIF.
      ENDIF.
    ENDLOOP.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    TRY .
        CALL METHOD lo_contract_for_bol->set_new_allocated_amount(
          EXPORTING
            it_pob_new_corr_amount = lt_pob_new_corr_amount ).
      CATCH cx_farr_message.

    ENDTRY.

    LOOP AT ct_object_list ASSIGNING <ls_obj>.
      <ls_obj>-success = abap_true.
*      CLEAR ls_changed_object.
*      CLEAR et_changed_objects.
*      ls_changed_object-namespace   = <ls_obj>-namespace.
*      ls_changed_object-object_name = <ls_obj>-object_name.
*      ls_changed_object-object_id   = <ls_obj>-object_id.
*      APPEND ls_changed_object TO et_changed_objects.
    ENDLOOP.


  ENDMETHOD.                    "set_new_allocated_amount


  METHOD SET_PRIC_ALLOC_SYS_DEFLT.



  ENDMETHOD.                    "set_pric_alloc_sys_deflt


  METHOD SET_SPREADING_TO_SYS_DEFAULT.

    DATA:
      lv_pob_id                   TYPE farr_pob_id.

    FIELD-SYMBOLS:
      <ls_it_parameter>            LIKE LINE OF it_parameter.

    LOOP AT it_parameter ASSIGNING <ls_it_parameter>.
      IF <ls_it_parameter>-name = if_farrc_contr_mgmt=>co_an_pob_id.
        CALL METHOD mo_rev_spreading->set_to_sys_default.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "set_spreading_to_sys_default


  METHOD SET_SSP.

    DATA: lt_set_ssp       TYPE TABLE OF farr_s_set_ssp,
          ls_set_ssp       TYPE farr_s_set_ssp,
          lv_contract_id   TYPE farr_contract_id,
          lo_contract      TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_parameter>        LIKE LINE OF it_parameter,
          <ls_reassign_handler> LIKE LINE OF mt_reassign_handler,
          <ls_pob_obj>          LIKE LINE OF ct_pob_obj.

    LOOP AT it_parameter ASSIGNING <ls_parameter>.
      CASE <ls_parameter>-name.
        WHEN if_farrc_contr_mgmt=>co_an_contract_id.
          ls_set_ssp-contract_id      = <ls_parameter>-value.
          IF lv_contract_id IS INITIAL.
            lv_contract_id = <ls_parameter>-value.
          ENDIF.
        WHEN if_farrc_contr_mgmt=>co_an_pob_id.
          ls_set_ssp-pob_id           = <ls_parameter>-value.
        WHEN if_farrc_contr_mgmt=>co_an_ssp.
          ls_set_ssp-ssp              = <ls_parameter>-value.
        WHEN if_farrc_contr_mgmt=>co_an_ssp_range_amount.
          ls_set_ssp-ssp_range_amount = <ls_parameter>-value.
        WHEN if_farrc_contr_mgmt=>co_an_ssp_range_perc.
          ls_set_ssp-ssp_range_perc   = <ls_parameter>-value.
        WHEN if_farrc_contr_mgmt=>co_an_ssp_curk.
          ls_set_ssp-ssp_curk         = <ls_parameter>-value.
          APPEND ls_set_ssp           TO lt_set_ssp.
      ENDCASE.
    ENDLOOP.

    IF mv_flg_reassign = abap_true.

      READ TABLE mt_reassign_handler TRANSPORTING NO FIELDS
        WITH KEY contract_id = lv_contract_id.
      IF sy-subrc = 0.
        lo_contract = get_contract( lv_contract_id ).
        lo_contract->set_ssp( lt_set_ssp ).
      ENDIF.

    ELSE.
      " normal case
      lo_contract = get_contract( mv_contract_id ).

      lo_contract->set_ssp( lt_set_ssp ).
    ENDIF.

    LOOP AT ct_pob_obj ASSIGNING <ls_pob_obj>.
      <ls_pob_obj>-success = abap_true.
    ENDLOOP.

  ENDMETHOD.                    "SET_SSP


  METHOD SIMULATE_FULFILL_POB.
    DATA:
          lo_msg_cont           TYPE REF TO cl_crm_genil_global_mess_cont,
          ls_pob_key            TYPE farr_s_pob_key,
          lt_fulfill_data       TYPE farr_tt_fulfill_data,
          ls_changed_object     LIKE LINE OF et_changed_objects,
          lo_man_contract_mgmt  TYPE REF TO cl_farr_manual_contract_mgmt,
          lo_contract_for_bol   TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj>              LIKE LINE OF ct_pob_obj.

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_msg_cont = io_msg_service_access->get_global_message_container( ).
    lo_msg_cont->reset( ).

    TRY .
        lo_man_contract_mgmt = lo_contract_for_bol->get_man_contract_instance( ).
        lo_man_contract_mgmt->simulate_fulfill_pob(
        EXPORTING
          it_parameter          =  it_parameter
        IMPORTING
          et_fulfill_data       =  lt_fulfill_data
      ).
      CATCH cx_farr_message.
        lo_msg_cont = io_msg_service_access->get_global_message_container( ).
        convert_msg_from_t100_to_bapi( io_msg_container = lo_msg_cont ).
    ENDTRY.

    LOOP AT ct_pob_obj ASSIGNING <ls_obj>.
      CALL METHOD cl_crm_genil_container_tools=>get_key_from_object_id
        EXPORTING
          iv_object_name = <ls_obj>-object_name
          iv_object_id   = <ls_obj>-object_id
        IMPORTING
          es_key         = ls_pob_key.
      READ TABLE lt_fulfill_data TRANSPORTING NO FIELDS WITH KEY pob_id = ls_pob_key-pob_id.
      IF sy-subrc EQ 0.
        <ls_obj>-success = abap_true.
        CLEAR ls_changed_object.
        ls_changed_object-namespace   = <ls_obj>-namespace.
        ls_changed_object-object_name = <ls_obj>-object_name.
        ls_changed_object-object_id   = <ls_obj>-object_id.
        APPEND ls_changed_object TO et_changed_objects.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.                    "simulate_fulfill_pob


  METHOD SPLIT_POB.

    DATA: lt_pob_id           TYPE farr_tt_pob_id,
          ls_changed_object   LIKE LINE OF et_changed_objects,
          lo_contract_for_bol TYPE REF TO if_farr_contract_mgmt_bol.

    FIELD-SYMBOLS:
          <ls_obj>           TYPE crmt_genil_obj_inst_line.

    reassign_collect_pob_id( EXPORTING it_pob_obj = ct_obj
                             IMPORTING et_pob_id = lt_pob_id ).

    lo_contract_for_bol = get_contract( mv_contract_id ).

    lo_contract_for_bol->split_pob( EXPORTING it_pob_id = lt_pob_id ).

*  LOOP AT ct_obj ASSIGNING <ls_obj>.
*    <ls_obj>-success = abap_true.
*  ENDLOOP.

    LOOP AT ct_obj ASSIGNING <ls_obj>.
      <ls_obj>-success = abap_true.
      CLEAR ls_changed_object.
      ls_changed_object-namespace   = <ls_obj>-namespace.
      ls_changed_object-object_name = <ls_obj>-object_name.
      ls_changed_object-object_id   = <ls_obj>-object_id.
      APPEND ls_changed_object TO et_changed_objects.
    ENDLOOP.

  ENDMETHOD.                    "split_pob


  METHOD START_REASSIGN_SIMULATION.
    DATA: lt_pob_data                     TYPE farr_tt_pob_data,
          lt_adaptor_cond_type            TYPE farr_tt_cond_type_data,
          lt_alloc_cond_type              TYPE farr_tt_cond_type_data,
          lt_intermediate_cond_type       TYPE farr_tt_cond_type_data,
          lt_trx_price_cond_type          TYPE farr_tt_cond_type_data,
          lt_accum_pob_data               TYPE farr_tt_pob_data,
          lt_accum_adaptor_cond_type      TYPE farr_tt_cond_type_data,
          lt_accum_alloc_cond_type        TYPE farr_tt_cond_type_data,
          lt_accum_inter_cond_type        TYPE farr_tt_cond_type_data,
          lt_accum_trx_price_cond_type    TYPE farr_tt_cond_type_data,
          lo_allocation_explainer         TYPE REF TO cl_farr_allocation_explainer,
          lo_contract                     TYPE REF TO if_farr_contract_mgmt_bol,
          lv_tmp_contr_ind                TYPE farr_contract_id.

    FIELD-SYMBOLS:
          <ls_reassign_handler>           LIKE LINE OF mt_reassign_handler.

    LOOP AT mt_reassign_handler ASSIGNING <ls_reassign_handler>.

      IF <ls_reassign_handler>-contract_id <> 0.
        get_contract(
          EXPORTING
            iv_contract_id      = <ls_reassign_handler>-contract_id
            iv_is_temp_contract = abap_false
          RECEIVING
            ro_contract         = lo_contract
        ).
      ELSE.
        lv_tmp_contr_ind = <ls_reassign_handler>-temp_contract_idx.
        get_contract(
          EXPORTING
            iv_contract_id      = lv_tmp_contr_ind
            iv_is_temp_contract = abap_true
          RECEIVING
            ro_contract        = lo_contract
        ).
      ENDIF.

      CLEAR: lt_pob_data,
             lt_adaptor_cond_type,
             lt_alloc_cond_type,
             lt_intermediate_cond_type,
             lt_trx_price_cond_type.
** start simulation
      TRY .
          CALL METHOD start_simulation
            EXPORTING
              io_contract               = lo_contract
            IMPORTING
              et_pob_data               = lt_pob_data
              et_adaptor_cond_type      = lt_adaptor_cond_type
              et_alloc_cond_type        = lt_alloc_cond_type
              et_intermediate_cond_type = lt_intermediate_cond_type
              et_trx_price_cond_type    = lt_trx_price_cond_type.

          APPEND LINES OF lt_pob_data               TO lt_accum_pob_data.
          APPEND LINES OF lt_adaptor_cond_type      TO lt_accum_adaptor_cond_type.
          APPEND LINES OF lt_alloc_cond_type        TO lt_accum_alloc_cond_type.
          APPEND LINES OF lt_intermediate_cond_type TO lt_accum_inter_cond_type.
          APPEND LINES OF lt_trx_price_cond_type    TO lt_accum_trx_price_cond_type.

        CATCH cx_farr_message.
          convert_msg_from_t100_to_bapi( io_msg_container = io_msg_cont ).
          RETURN.
      ENDTRY.
    ENDLOOP.

** return allocation explainer
    TRY.
        CREATE OBJECT lo_allocation_explainer
          EXPORTING
            it_pob_data               = lt_accum_pob_data
            it_adaptor_cond_type      = lt_accum_adaptor_cond_type
            it_alloc_cond_type        = lt_accum_alloc_cond_type
            it_intermediate_cond_type = lt_accum_inter_cond_type
            it_trx_price_cond_type    = lt_accum_trx_price_cond_type.
      CATCH cx_farr_message.
        convert_msg_from_t100_to_bapi( io_msg_container = io_msg_cont ).
        RETURN.
    ENDTRY.

    eo_allocation_explainer = lo_allocation_explainer.

  ENDMETHOD.                    "start_simulation


  METHOD START_SIMULATION.
    DATA: lt_pob_data               TYPE farr_tt_pob_data,
          lt_adaptor_cond_type      TYPE farr_tt_cond_type_data,
          lt_alloc_cond_type        TYPE farr_tt_cond_type_data,
          lt_intermediate_cond_type TYPE farr_tt_cond_type_data,
          lt_trx_price_cond_type    TYPE farr_tt_cond_type_data,
          lo_allocation_explainer   TYPE REF TO cl_farr_allocation_explainer.

** start calculation of allocation
    CALL METHOD io_contract->simulate_allocation
      IMPORTING
        et_pob_data               = lt_pob_data
        et_adaptor_cond_type      = lt_adaptor_cond_type
        et_allocated_cond_type    = lt_alloc_cond_type
        et_intermediate_cond_type = lt_intermediate_cond_type
        et_trx_price_cond_type    = lt_trx_price_cond_type.

    IF mv_flg_reassign = abap_true.
      et_pob_data               = lt_pob_data.
      et_adaptor_cond_type      = lt_adaptor_cond_type.
      et_alloc_cond_type        = lt_alloc_cond_type.
      et_intermediate_cond_type = lt_intermediate_cond_type.
      et_trx_price_cond_type    = lt_trx_price_cond_type.
    ELSE.
** return allocation explainer
      CREATE OBJECT lo_allocation_explainer
        EXPORTING
          it_pob_data               = lt_pob_data
          it_adaptor_cond_type      = lt_adaptor_cond_type
          it_alloc_cond_type        = lt_alloc_cond_type
          it_intermediate_cond_type = lt_intermediate_cond_type
          it_trx_price_cond_type    = lt_trx_price_cond_type.

      eo_allocation_explainer = lo_allocation_explainer.
    ENDIF.

  ENDMETHOD.                    "start_simulation
ENDCLASS.
