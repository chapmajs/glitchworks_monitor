;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Cold boot routines for Tarbell 1011 single-
;density floppy controller
;   
;Modified for use with GWMON 2019-02-23 by
;       The Glitch Works.
;
;Updated 2/3/2016 by Mike Douglas
;
;Original work by:
;       MICHAEL J. KARAS
;       MICRO RESOURCES
;       These days Mike can be reached at 
;       mkaras@carousel-design.com (2009-03-23)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;SYSTEM EQUATES FOR TARBELL CONTROLLER

DWAIT   EQU 0FCH        ;WAIT FOR DISK PORT
DCOM    EQU 0F8H        ;DISK COMMAND PORT
DDATA   EQU 0FBH        ;DISK DATA PORT
DSTAT   EQU 0F8H        ;DISK STATUS PORT
DSEC    EQU 0FAH        ;DISK SECTOR PORT
DTRK    EQU 0F9H        ;DISK TRACK PORT
DSEL    EQU 0FCH        ;DISK SELECT PORT

;SYSTEM VARIABLES AND ADDRESS POINTERS

SBOOT   EQU 007DH       ;SINGLE DENSITY BOOT ENTRY
RDCMD   EQU 008CH       ;READ COMMAND FOR 1791 CONTROLLER

BOOT:   MVI A,0F2H      ;SELECT DISK A: AT SINGLE DENSITY
        OUT DSEL
        MVI A,0D0H      ;CLEAR ANY PENDING COMMAND
        OUT DCOM
        NOP             ;ALLOW TIME FOR COMMAND SETTLING
        NOP
        NOP
        NOP

HOME:   IN  DSTAT       ;GET STATUS
        RRC
        JC  HOME        ;WAIT FOR NOT BUSY COMPLETION
        MVI A,002H      ;ISSUE RESTORE CMND (10 MSEC. STEP RATE)
        OUT DCOM
        NOP             ;ALLOW TIME FOR COMMAND SETTLING
        NOP
        NOP
        NOP
        IN  DWAIT       ;WAIT FOR COMPLETION
        ORA A           ;SET FLAGS FOR ERROR ON "DRQ",NOT "INTRQ"
        JM  DRQER

        IN  DSTAT       ;GET DISK STATUS
        ANI 004H        ;MASK FOR TRACK 00 STATUS BIT
        JZ  TK0ER

        XRA A           ;ZERO ACCUMULATOR
        MOV L,A         ;SETUP MEMORY LOAD ADDRESS 0000H
        MOV H,A
        INR A           ;SETUP FOR SECTOR 01
        OUT DSEC
        MVI A,RDCMD     ;SETUP READ COMMAND
        OUT DCOM
        NOP             ;ALLOW TIME FOR COMMAND SETTLING
        NOP
        NOP
        NOP
RLOOP:  IN  DWAIT       ;WAIT FOR DISK CONTROLLER
        ORA A           ;SET FLAGS
        JP  RDONE       ;ARE WE DONE YET

        IN  DDATA       ;GET DATA FORM DISK
        MOV M,A         ;MOVE IT INTO MEMORY
        INX H           ;INCREMENT MEMORY POINTER
        JMP RLOOP       ;GO GET NEXT BYTE

RDONE:  IN  DSTAT       ;GET DISK READ STATUS
        ORA A           ;CHECK FOR ERRORS
        JZ  SBOOT       ;NO ERRORS? JUMP TO CP/M

        LXI H,LEMSG$    ;PRINT BOOT LOAD ERROR
        JMP LERR

DRQER:  LXI H,RQMSG$    ;PRINT COMMAND ERROR
        JMP LERR

TK0ER:  LXI H,REMSG$    ;PRINT RESTORE ERROR

LERR:   PUSH PSW        ;PUSH ERROR CODE TO STACK
        CALL STROUT
        LXI H,ERRSFX$   ;PRINT "ERR=" SUFFIX
        CALL STROUT
        POP PSW         ;GET ERROR CODE OFF STACK
        CALL HEXOUT     ;DISPLAY ERROR CODE

        RET             ;BACK TO THE MONITOR

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Cold boot error message strings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEMSG$:  DB 13, 10, 'LOAD', 0
RQMSG$:  DB 13, 10, 'COMMAND', 0
REMSG$:  DB 13, 10, 'TK0 RESTORE', 0
ERRSFX$: DB ' ERR=', 0
