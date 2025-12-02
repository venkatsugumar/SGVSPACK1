"Name: \TY:CL_FARR_CONTRACT_DB_ACCESS\ME:READ_MULTIPLE_BY_RANGE_TAB\SE:END\EI
ENHANCEMENT 0 ZZ_FIN_PROFIT_CENTER_FILTER.
** ELWRIGHT Defect 15941 -> ilter RAR Contracts by Profit Center 05/23/2021
*
*  types: r_ZZSDDOC type range of farr_d_pob-ZZSDDOC,
*         t_ZZSDDOC type line of r_ZZSDDOC,
*         r_ZZRAVBELN type range of farr_d_pob-ZZRAVBELN,
*         t_ZZRAVBELN type line of r_ZZRAVBELN,
*         r_ZZAPPIND type range of farr_d_pob-ZZAPPIND,
*         t_ZZAPPIND type line of r_ZZAPPIND,
*         r_ZZSTART_DATE type range of farr_d_pob-START_DATE,
*         t_ZZSTART_DATE type line of r_ZZSTART_DATE.
*
*  data: wa_ZZSDDOC type t_ZZSDDOC,
*        i_ZZSDDOC type r_ZZSDDOC,
*        wa_ZZRAVBELN type t_ZZRAVBELN,
*        i_ZZRAVBELN type r_ZZRAVBELN,
*        wa_ZZAPPIND type t_ZZAPPIND,
*        i_ZZAPPIND type r_ZZAPPIND,
*        wa_ZZSTART_DATE type t_ZZSTART_DATE,
*        i_ZZSTART_DATE type r_ZZSTART_DATE.
*
*  data: begin of wa_fields,
*          fld1 type char25,
*          fld2 type char25,
*          fld3 type char25,
*          fld4 type char25,
*          fld5 type char25,
*          fld6 type char25,
*         end of wa_fields.
*
  data: wa_contract_id type FARR_D_POB-pob_id,
        wa_tab type RSDSWHERE,
        wa_contract_data type FARR_S_CONTRACT_DATA.

** Loop at dynamic selection
*  loop at LS_WHERE_CLAUSE-WHERE_TAB into wa_tab.
*    if wa_tab cs 'C~ZZSDDOC'.
*      condense wa_tab-line.
*      replace all occurrences of '''' in wa_tab-line with ''.
*      replace all occurrences of '(' in wa_tab-line with ''.
*      replace all occurrences of ')' in wa_tab-line with ''.
*      replace all occurrences of 'C~ZZSDDOC' in wa_tab-line with ''.
*      condense wa_tab-line.
*      split wa_tab at space into: wa_fields-fld1 wa_fields-fld2 wa_fields-fld3
*                                  wa_fields-fld4 wa_fields-fld5 wa_fields-fld6.
*      wa_ZZSDDOC-sign = 'I'.
*      wa_ZZSDDOC-option = wa_fields-fld1.
*      wa_ZZSDDOC-low    = wa_fields-fld2.
*      wa_ZZSDDOC-high   = wa_fields-fld3.
*      append wa_ZZSDDOC to i_ZZSDDOC.
*    endif.
*    if wa_tab cs 'C~ZZRAVBELN'.
*      condense wa_tab-line.
*      replace all occurrences of '''' in wa_tab-line with ''.
*      replace all occurrences of '(' in wa_tab-line with ''.
*      replace all occurrences of ')' in wa_tab-line with ''.
*      replace all occurrences of 'C~ZZRAVBELN' in wa_tab-line with ''.
*      condense wa_tab-line.
*      split wa_tab at space into: wa_fields-fld1 wa_fields-fld2 wa_fields-fld3
*                                  wa_fields-fld4 wa_fields-fld5 wa_fields-fld6.
*      wa_ZZRAVBELN-sign = 'I'.
*      wa_ZZRAVBELN-option = wa_fields-fld1.
*      wa_ZZRAVBELN-low    = wa_fields-fld2.
*      wa_ZZRAVBELN-high   = wa_fields-fld3.
*      append wa_ZZRAVBELN to i_ZZRAVBELN.
*    endif.
*    if wa_tab cs 'C~ZZAPPIND'.
*      condense wa_tab-line.
*      replace all occurrences of '''' in wa_tab-line with ''.
*      replace all occurrences of '(' in wa_tab-line with ''.
*      replace all occurrences of ')' in wa_tab-line with ''.
*      replace all occurrences of 'C~ZZAPPIND' in wa_tab-line with ''.
*      condense wa_tab-line.
*      split wa_tab at space into: wa_fields-fld1 wa_fields-fld2 wa_fields-fld3
*                                  wa_fields-fld4 wa_fields-fld5 wa_fields-fld6.
*      wa_ZZAPPIND-sign = 'I'.
*      wa_ZZAPPIND-option = wa_fields-fld1.
*      wa_ZZAPPIND-low    = wa_fields-fld2.
*      wa_ZZAPPIND-high   = wa_fields-fld3.
*      append wa_ZZAPPIND to i_ZZAPPIND.
*    endif.
*    if wa_tab cs 'ZZSTART_DATE'.
*      condense wa_tab-line.
*      replace all occurrences of '''' in wa_tab-line with ''.
*      replace all occurrences of '(' in wa_tab-line with ''.
*      replace all occurrences of ')' in wa_tab-line with ''.
*      replace all occurrences of 'C~ZZSTART_DATE' in wa_tab-line with ''.
*      condense wa_tab-line.
*      split wa_tab at space into: wa_fields-fld1 wa_fields-fld2 wa_fields-fld3
*                                  wa_fields-fld4 wa_fields-fld5 wa_fields-fld6.
*      wa_ZZSTART_DATE-sign = 'I'.
*      wa_ZZSTART_DATE-option = wa_fields-fld1.
*      wa_ZZSTART_DATE-low    = wa_fields-fld2.
*      wa_ZZSTART_DATE-high   = wa_fields-fld3.
*      append wa_ZZSTART_DATE to i_ZZSTART_DATE.
*    endif.
*   endloop.
*
**   check not i_ZZSDDOC[] is initial or not i_ZZRAVBELN[] is initial
**      or not i_ZZAPPIND[] is initial or not i_ZZSTART_DATE[] is initial.
*
**  if the search criteria has pob condition.
*   IF lv_where_clause CS lv_pob
*   OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_event_type
*   OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_fulfill_type
*   OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_pob_type
*   OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_pob_name
*   OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_review_date
*   OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_review_reason.
*
    loop at LS_WHERE_CLAUSE-where_tab into wa_tab.
      if wa_tab cs 'C~ZZSDDOC'.
        replace all occurrences of 'C~ZZSDDOC' in wa_tab-line with 'P~ZZSDDOC'.
        replace all occurrences of 'C~ZZSDDOC' in LV_WHERE_CLAUSE with 'P~ZZSDDOC'.
        modify LS_WHERE_CLAUSE-WHERE_TAB from wa_tab-line.
      endif.
      if wa_tab cs 'C~ZZRAVBELN'.
        replace all occurrences of 'C~ZZRAVBELN' in wa_tab-line with 'P~ZZRAVBELN'.
        replace all occurrences of 'C~ZZRAVBELN' in LV_WHERE_CLAUSE with 'P~ZZRAVBELN'.
        modify LS_WHERE_CLAUSE-WHERE_TAB from wa_tab-line.
      endif.
      if wa_tab cs 'C~ZZAPPIND'.
        replace all occurrences of 'C~ZZAPPIND' in wa_tab-line with 'P~ZZAPPIND'.
        replace all occurrences of 'C~ZZAPPIND' in LV_WHERE_CLAUSE with 'P~ZZAPPIND'.
        modify LS_WHERE_CLAUSE-WHERE_TAB from wa_tab-line.
      endif.
      if wa_tab cs 'ZZSTART_DATE'.
        replace all occurrences of 'ZZSTART_DATE' in wa_tab-line with 'P~START_DATE'.
        replace all occurrences of 'ZZSTART_DATE' in LV_WHERE_CLAUSE with 'P~START_DATE'.
        modify LS_WHERE_CLAUSE-WHERE_TAB from wa_tab-line.
      endif.
      if wa_tab cs 'C~ZZSDDITM'.
        replace all occurrences of 'C~ZZSDDITM' in wa_tab-line with 'P~ZZSDDITM'.
        replace all occurrences of 'C~ZZSDDITM' in LV_WHERE_CLAUSE with 'P~ZZSDDITM'.
        modify LS_WHERE_CLAUSE-WHERE_TAB from wa_tab-line.
      endif.
    endloop.
*
*    SELECT  DISTINCT
*      (lt_selclause)
*      FROM farr_d_contract AS c
*      JOIN farr_d_pob AS p
*        ON c~contract_id = p~contract_id
*      INTO CORRESPONDING FIELDS OF TABLE et_pob_data
*     UP TO iv_max_hits ROWS
*     WHERE (ls_where_clause-where_tab)              "#EC CI_DYNWHERE
*       AND   c~contract_id IN (
*     SELECT DISTINCT contract_id
*        FROM farr_d_mapping AS m
*       WHERE m~header_id      IN lt_header_id
*         AND   m~srcdoc_comp    IN lt_srcdoc_comp
*         AND   m~srcdoc_logsys  IN lt_srcdoc_logsys
*         AND   m~reference_type IN lt_reference_type
*         AND   m~reference_id   IN lt_reference_id
*         AND ( m~archiving_date     = '00000000' OR m~archiving_date     IS NULL ) " iv_without_archived = abap_true
*         AND ( m~archiving_date_rai = '00000000' OR m~archiving_date_rai IS NULL ) ).
*
*   else.
**  if the search criteria only has contract condition.
*      SELECT  DISTINCT (lt_selclause)               "#EC CI_DYNWHERE.
*      FROM farr_d_contract AS c
*      JOIN farr_d_pob AS p
*        ON c~contract_id = p~contract_id
*      INTO CORRESPONDING FIELDS OF TABLE et_contract_data
*      UP TO iv_max_hits ROWS
*      WHERE p~ZZSDDOC in i_ZZSDDOC
*        and p~ZZRAVBELN in i_ZZRAVBELN
*        and p~ZZAPPIND in i_ZZAPPIND
*        and p~START_DATE in i_ZZSTART_DATE
*        and c~contract_id IN (
*        SELECT DISTINCT contract_id
*        FROM farr_d_mapping AS m
*        WHERE m~header_id      IN lt_header_id
*        AND   m~srcdoc_comp    IN lt_srcdoc_comp
*        AND   m~srcdoc_logsys  IN lt_srcdoc_logsys
*        AND   m~reference_type IN lt_reference_type
*        AND   m~reference_id   IN lt_reference_id
*        AND ( m~archiving_date     = '00000000' OR m~archiving_date     IS NULL ) " iv_without_archived = abap_true
*        AND ( m~archiving_date_rai = '00000000' OR m~archiving_date_rai IS NULL ) )
*      ORDER BY c~contract_id DESCENDING.
*   endif.
*
** SD Document Item -> get from POB
*   loop at et_contract_data into wa_contract_data.
*     select single ZZSDDITM from FARR_D_POB into wa_contract_data-ZZSDDITM
*       where contract_ID = wa_contract_data-contract_ID.
*     if sy-subrc = 0.
*       modify et_contract_data from wa_contract_data.
*     endif.
*   endloop.
*

*  if the search criteria has pob condition.
    IF   lv_where_clause CS lv_pob
    OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_event_type
    OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_fulfill_type
    OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_pob_type
    OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_pob_name
    OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_review_date
    OR lv_where_clause CS if_farrc_contr_mgmt=>co_an_review_reason.
      IF lv_search_header = abap_true.

        IF lv_query_pob_data = abap_false.
          "The lt_selclause only contains the contract fields
          SELECT  DISTINCT
          (lt_selclause)
          FROM farr_d_contract AS c
          JOIN farr_d_pob AS p
          ON c~contract_id = p~contract_id
          INTO CORRESPONDING FIELDS OF TABLE et_contract_data
          UP TO iv_max_hits ROWS
          WHERE (ls_where_clause-where_tab)              "#EC CI_DYNWHERE
          AND   c~contract_id IN (
            SELECT DISTINCT contract_id
            FROM farr_d_mapping AS m
            WHERE m~header_id      IN lt_header_id
            AND   m~srcdoc_comp    IN lt_srcdoc_comp
            AND   m~srcdoc_logsys  IN lt_srcdoc_logsys
            AND   m~reference_type IN lt_reference_type
            AND   m~reference_id   IN lt_reference_id
            AND ( m~archiving_date     = '00000000' OR m~archiving_date     IS NULL ) " iv_without_archived = abap_true
            AND ( m~archiving_date_rai = '00000000' OR m~archiving_date_rai IS NULL ) )
          ORDER BY c~contract_id DESCENDING
          .

        ELSE.
            "The lt_selclause only contains the POB fields
            SELECT  DISTINCT
            (lt_selclause)
            FROM farr_d_contract AS c
            JOIN farr_d_pob AS p
            ON c~contract_id = p~contract_id
            INTO CORRESPONDING FIELDS OF TABLE et_pob_data
            UP TO iv_max_hits ROWS
            WHERE (ls_where_clause-where_tab)              "#EC CI_DYNWHERE
            AND   c~contract_id IN (
              SELECT DISTINCT contract_id
              FROM farr_d_mapping AS m
              WHERE m~header_id      IN lt_header_id
              AND   m~srcdoc_comp    IN lt_srcdoc_comp
              AND   m~srcdoc_logsys  IN lt_srcdoc_logsys
              AND   m~reference_type IN lt_reference_type
              AND   m~reference_id   IN lt_reference_id
              AND ( m~archiving_date     = '00000000' OR m~archiving_date     IS NULL ) " iv_without_archived = abap_true
              AND ( m~archiving_date_rai = '00000000' OR m~archiving_date_rai IS NULL ) )
            ORDER BY p~contract_id DESCENDING
            .

        ENDIF.

      ELSE.

        IF lv_query_pob_data = abap_false.
          "The lt_selclause only contains the contract fields
          SELECT  DISTINCT (lt_selclause)
          FROM farr_d_contract AS c
          JOIN farr_d_pob AS p
          ON c~contract_id = p~contract_id
          INTO CORRESPONDING FIELDS OF TABLE et_contract_data
          UP TO iv_max_hits ROWS
          WHERE (ls_where_clause-where_tab)              "#EC CI_DYNWHERE
*             GROUP BY (lv_group_clause)
          ORDER BY c~contract_id DESCENDING.

        ELSE.
          "The lt_selclause only contains the POB fields
          SELECT  DISTINCT (lt_selclause)
          FROM farr_d_contract AS c
          JOIN farr_d_pob AS p
          ON c~contract_id = p~contract_id
          INTO CORRESPONDING FIELDS OF TABLE et_pob_data
          UP TO iv_max_hits ROWS
          WHERE (ls_where_clause-where_tab)              "#EC CI_DYNWHERE
*             GROUP BY (lv_group_clause)
          ORDER BY p~contract_id DESCENDING.

        ENDIF.
      ENDIF.
*  if the search criteria only has contract condition.
    ELSE.
      IF lv_search_header = abap_true.
        SELECT  DISTINCT (lt_selclause)               "#EC CI_DYNWHERE.
        FROM farr_d_contract AS c
        INTO CORRESPONDING FIELDS OF TABLE et_contract_data
        UP TO iv_max_hits ROWS
        WHERE (ls_where_clause-where_tab)
        AND c~contract_id IN (
          SELECT DISTINCT contract_id
          FROM farr_d_mapping AS m
          WHERE m~header_id      IN lt_header_id
          AND   m~srcdoc_comp    IN lt_srcdoc_comp
          AND   m~srcdoc_logsys  IN lt_srcdoc_logsys
          AND   m~reference_type IN lt_reference_type
          AND   m~reference_id   IN lt_reference_id
          AND ( m~archiving_date     = '00000000' OR m~archiving_date     IS NULL ) " iv_without_archived = abap_true
          AND ( m~archiving_date_rai = '00000000' OR m~archiving_date_rai IS NULL ) )
        ORDER BY c~contract_id DESCENDING
        .

      ELSE.
        SELECT  DISTINCT (lt_selclause)
        FROM farr_d_contract AS c
        INTO CORRESPONDING FIELDS OF TABLE et_contract_data
        UP TO iv_max_hits ROWS
        WHERE (ls_where_clause-where_tab)              "#EC CI_DYNWHERE
*           GROUP BY (lv_group_clause)
        ORDER BY c~contract_id DESCENDING.
      ENDIF.
    ENDIF.

   loop at et_contract_data into wa_contract_data.
     select single ZZSDDOC from FARR_D_POB into wa_contract_data-ZZSDDOC
       where contract_ID = wa_contract_data-contract_ID.
     if sy-subrc = 0.
       modify et_contract_data from wa_contract_data.
     endif.
     select single ZZRAVBELN from FARR_D_POB into wa_contract_data-ZZRAVBELN
       where contract_ID = wa_contract_data-contract_ID.
     if sy-subrc = 0.
       modify et_contract_data from wa_contract_data.
     endif.
     select single ZZAPPIND from FARR_D_POB into wa_contract_data-ZZAPPIND
       where contract_ID = wa_contract_data-contract_ID.
     if sy-subrc = 0.
       modify et_contract_data from wa_contract_data.
     endif.
     select single START_DATE from FARR_D_POB into wa_contract_data-ZZSTART_DATE
       where contract_ID = wa_contract_data-contract_ID.
     if sy-subrc = 0.
       modify et_contract_data from wa_contract_data.
     endif.
     select single ZZSDDITM from FARR_D_POB into wa_contract_data-ZZSDDITM
       where contract_ID = wa_contract_data-contract_ID.
     if sy-subrc = 0.
       modify et_contract_data from wa_contract_data.
     endif.
   endloop.

** ELWRIGHT Defect 15941 -> Filter RAR Contracts by Profit Center 05/23/2021
ENDENHANCEMENT.
