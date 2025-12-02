*&---------------------------------------------------------------------*
*& Include          ZRAR_PC_CHANGE_UPLOAD_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  SELECTION-SCREEN SKIP 1.

**Begin of Insertion by F4SAWAM Defect 3059  01/10/2025
  PARAMETERS: p_rdp1 RADIOBUTTON GROUP rdp1,
              p_rdp2 RADIOBUTTON GROUP rdp1.
  SELECTION-SCREEN SKIP 1.
**End Of Insertion By F4SAWAM Defect 3059

  PARAMETERS: p_file LIKE rlgrap-filename OBLIGATORY.

  SELECTION-SCREEN SKIP 1.

  PARAMETERS : p_test AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b1.
