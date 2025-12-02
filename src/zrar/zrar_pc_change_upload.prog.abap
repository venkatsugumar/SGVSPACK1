*********************************************************************
*& Program           : zdemo_rai_change                             *
*& Module            : RAR                                          *
*& Functional Contact: Pillarisetti, Raghu Premchhand               *
*& Funct. Spec. Ref. : Defect 2374                                  *
*& Developer         : Vasanth Krishnamoorthy                       *
*& Create Date       : 04/25/2024                                   *
*& Program Type      : Report                                       *
*& Description       : Program to generate the change RAI’s &       *
*&                     will update correct PC from the input file.  *
*& Transports        :                                              *
*********************************************************************
*&  REVISION LOG                                                    *
*********************************************************************
* PROGRAMMER   DATE       TASK#      DESCRIPTION                    *
*********************************************************************
*& Date       |  Name    |  CTS#       |      Description           *
*& 06/10/2024 |F3XOFTB   |  DS4K918112 |    Defect - 2599           *
*&                                     |  In the input file change  *
*&                                     |  POB as starting point POB *
*&                                     |  as starting point and     *
*&                                     |  automate the process      *
*********************************************************************
*********************************************************************
*& Date       |  Name    |  CTS#       |      Description           *
*& 01/13/2025 |F4SAWAM   |  DS4K921104 |    ACDOCA not populating   *
*&                                     |  Customer number for RAR   *
*&                                     |   ECC converted Sales Docs *
*&                                     |    starting 8/27/2024      *
*********************************************************************
REPORT zrar_pc_change_upload.
INCLUDE zrar_pc_change_upload_top.
INCLUDE zrar_pc_change_upload_sel.
INCLUDE zrar_pc_change_upload_f01.

INITIALIZATION.
  DATA: oref TYPE REF TO lcl_cust_upload.
  IF oref IS NOT BOUND.
    CREATE OBJECT oref.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

* F4Help for presentation server upload
  p_file  = oref->select_file( i_file = CONV string( p_file )
                                i_type = oref->lc_excel ).

START-OF-SELECTION.
  IF p_rdp1 = 'X'.  "Inserted by F4SAWAM Defect 3059  01/10/2025
    "Read file from presentation Server
    oref->read_local_file( ).

    "Validate the records
    oref->validate_record( ).

    "Create RAI item
    oref->create_api_rai( ).

    "Display ALV
    oref->alv_dis( ).
  ENDIF.

  IF p_rdp2 = 'X'.
    "Read file from presentation Server
    oref->read_local_file( ).

    "Validate the records
    PERFORM validate_record.

    "Display ALV
    oref->alv_dis_new( ).
  ENDIF.
**End of Insertion by F4SAWAM Defect 3059  01/10/2025
