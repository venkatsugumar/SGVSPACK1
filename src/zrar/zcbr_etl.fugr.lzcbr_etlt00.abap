*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZETL_CBR_RULE1..................................*
DATA:  BEGIN OF STATUS_ZETL_CBR_RULE1                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZETL_CBR_RULE1                .
CONTROLS: TCTRL_ZETL_CBR_RULE1
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZETL_CBR_RULE2..................................*
DATA:  BEGIN OF STATUS_ZETL_CBR_RULE2                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZETL_CBR_RULE2                .
CONTROLS: TCTRL_ZETL_CBR_RULE2
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZETL_CBR_RULE1                .
TABLES: *ZETL_CBR_RULE2                .
TABLES: ZETL_CBR_RULE1                 .
TABLES: ZETL_CBR_RULE2                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
