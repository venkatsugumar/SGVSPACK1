*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZRAR_ENRICH_ENH.................................*
DATA:  BEGIN OF STATUS_ZRAR_ENRICH_ENH               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZRAR_ENRICH_ENH               .
CONTROLS: TCTRL_ZRAR_ENRICH_ENH
            TYPE TABLEVIEW USING SCREEN '0009'.
*.........table declarations:.................................*
TABLES: *ZRAR_ENRICH_ENH               .
TABLES: ZRAR_ENRICH_ENH                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
