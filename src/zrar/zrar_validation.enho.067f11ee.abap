"Name: \FU:SD_VBKD_SELECT\SE:BEGIN\EI
ENHANCEMENT 0 ZRAR_VALIDATION.
***********************************************************************
*& Enhancement       : ZRAR_VALIDATION                                *
*& Module            : RAR                                            *
*& Sub-Module        : RAR                                            *
*& Functional Contact: Ratnakar Venkat                                *
*& Funct. Spec. Ref. : -                                              *
*& Developer(Company): Surekha Pawar                                  *
*& Create Date       : 02/03/2022                                     *
*& Program Type      : Enhancement                                    *
*& Project Phase     : Wave 1                                         *
*& Description       : Skip this VBKD validation for Fiserv           *
*& Transports        : DS4K906593, DS4K906596                         *
***********************************************************************
"Exit this check as part of Defect 18071.
  "This validation is not required for Fiserv
    EXIT.

ENDENHANCEMENT.
