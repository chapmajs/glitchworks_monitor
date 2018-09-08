;GWMON-80 v0.1.1 for 8080/8085/Z80 and Compatibles 
;Copyright (c) 2018 The Glitch Works
;http://www.glitchwrks.com
;
;See LICENSE included in the project root for licensing
;information.
;
;*** STOP! THIS CODE WILL NOT RUN BY ITSELF! ***
;
;This is the base monitor. Consult README for information
;on including the I/O module specific to your system.

        ORG XXXXH               ;See README for more info

;Initialization and sign-on message
LOG:    JMP SETUP           ;See README for more info
SE1:    LXI H, LOGMSG$
        CALL STROUT
        LXI H, MSG$
        CALL STROUT

;Main command loop
CMDLP:  LXI H, PROMPT$
        CALL STROUT
        LXI H, CMDLP        ; Get CMDLP address in HL
        PUSH H              ; Push HL, prime stack for RET to CMDLP
        CALL CIN
        ANI 5Fh
        CPI 'D'
        JZ MEMDMP
        CPI 'E'
        JZ EDMEM
        CPI 'G'
        JZ GO
        CPI 'O'
        JZ OUTPUT
        CPI 'I'
        JZ INPUT
        CPI 'L'
        JZ LOAD
        LXI H, ERR$
        CALL ERROUT

;Get a port address, write byte out
OUTPUT: CALL SPCOUT
        CALL GETHEX
        MOV B, A
        CALL SPCOUT
        CALL GETHEX
        CALL JMPOUT
        RET

;Input from port, print contents
INPUT:  CALL SPCOUT
        CALL GETHEX
        MOV B, A
        CALL SPCOUT
        MOV A, B
        CALL JMPIN
        CALL HEXOUT
        RET

;Edit memory from a starting address until X is
;pressed. Display mem loc, contents, and results
;of write.
EDMEM:  CALL SPCOUT
        CALL ADRIN
        MOV H, D
        MOV L, E
ED1:    MVI A, 13
        CALL COUT
        MVI A, 10
        CALL COUT
        CALL ADROUT
        CALL SPCOUT
        MVI A, ':'
        CALL COUT
        CALL SPCOUT
        CALL DMPLOC
        CALL SPCOUT
        CALL GETHEX
        RC
        MOV M, A
        CALL SPCOUT
        CALL DMPLOC
        INX H
        JMP ED1

;Get an address and jump to it
GO:     CALL SPCOUT
        CALL ADRIN
        MOV H, D
        MOV L, E
        PCHL

;Dump memory between two address locations
MEMDMP: CALL SPCOUT
        CALL ADRIN
        MOV H, D
        MOV L, E
        MVI C, 10h
        CALL SPCOUT
        CALL ADRIN
MD1:    MVI A, 13
        CALL COUT
        MVI A, 10
        CALL COUT
        CALL DMP16
        MOV A, D
        CMP H
        RM
        MOV A, E
        CMP L
        JM MD2
        JMP MD1
MD2:    MOV A, D
        CMP H
        JNZ MD1
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DMP16 -- Dump 16 consecutive memory locations
;
;pre: HL pair contains starting memory address
;post: memory from HL to HL + 16 printed
;post: HL incremented to HL + 16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DMP16:  CALL ADROUT
        CALL SPCOUT
        MVI A, ':'
        CALL COUT
        MVI C, 10h
DM1:    CALL SPCOUT
        CALL DMPLOC
        INX H
        DCR C
        RZ
        JMP DM1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DMPLOC -- Print a byte at HL to console
;
;pre: HL pair contains address of byte
;post: byte at HL printed to console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DMPLOC: MOV A, M
        CALL HEXOUT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HEXOUT -- Output byte to console as hex
;
;pre: A register contains byte to be output
;post: byte is output to console as hex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEXOUT: PUSH B
        MOV B, A
        RRC
        RRC
        RRC
        RRC
        ANI 0Fh
        CALL HEXASC
        CALL COUT
        MOV A, B
        ANI 0Fh
        CALL HEXASC
        CALL COUT
        POP B
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;HEXASC -- Convert nybble to ASCII char
;
;pre: A register contains nybble
;post: A register contains ASCII char
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HEXASC: ADI 90h
        DAA
        ACI 40h
        DAA
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ADROUT -- Print an address to the console
;
;pre: HL pair contains address to print
;post: HL printed to console as hex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ADROUT: MOV A, H
        CALL HEXOUT
        MOV A, L
        CALL HEXOUT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ADRIN -- Get an address word from console
;
;pre: none
;post: DE contains address from console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ADRIN:  CALL GETHEX
        MOV D, A
        CALL GETHEX
        MOV E, A
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GETHEX -- Get byte from console as hex
;
;pre: none
;post: A register contains byte from hex input
;post: Carry flag set if X was received
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GETHEX: PUSH D
        CALL CIN
        CPI 'X'
        JZ GE2
        CALL ASCHEX
        RLC
        RLC
        RLC
        RLC
        MOV D, A
        CALL CIN
        CALL ASCHEX
        ORA D
GE1:    POP D
        RET
GE2:    STC
        JMP GE1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ASCHEX -- Convert ASCII coded hex to nybble
;
;pre: A register contains ASCII coded nybble
;post: A register contains nybble
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ASCHEX: SUI 30h
        CPI 0Ah
        RM
        ANI 5Fh
        SUI 07h
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;JMPOUT -- Output to a dynamic port
;
;pre: B register contains the port to output to
;pre: A register contains the byte to output
;post: byte is output
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JMPOUT: MVI C, 0D3h
        CALL GOBYT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;JMPIN -- Input from a dynamic port
;
;pre: A register contains the port to input from
;post: A register contains port value
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
JMPIN:  MVI C, 0DBh
        MOV B, A
        CALL GOBYT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;GOBYT -- Push a two-byte instruction and RET
;         and jump to it
;
;pre: B register contains operand
;pre: C register contains opcode
;post: code executed, returns to caller
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GOBYT:  LXI H, 0000
        DAD SP
        DCX H
        MVI M, 0C9h
        DCX H
        MOV M, B
        DCX H
        MOV M, C
        PCHL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SPCOUT -- Print a space to the console
;
;pre: none
;post: 0x20 printed to console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SPCOUT: MVI A, ' '
        CALL COUT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;STROUT -- Print a null-terminated string
;
;pre: HL contains pointer to start of a null-
;     terminated string
;post: string at HL printed to console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STROUT: MOV A, M
        CPI 00
        RZ
        CALL COUT
        INX H
        JMP STROUT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ERROUT -- Print a null-terminated error string
;
;pre: HL contains pointer to start of a null-
;     terminated string
;post: string at HL printed to console
;post: program execution returned to command loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ERROUT: CALL CRLF
        CALL STROUT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CRLF -- Print a CR, LF
;
;pre: none
;post: CR, LF printed to console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CRLF:   MVI A, 13
        CALL COUT
        MVI A, 10
        CALL COUT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LOAD -- Load an Intel HEX file from console
;
;post: Intel HEX file loaded, or error printed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOAD:   CALL CRLF       ; Newline
LOAD1:  CALL CINNE
        CPI ':'
        JNZ LOAD1       ; Wait for start colon
        CALL COUT
        CALL GETHEX     ; Get record length
        MOV B, A        ; Record length in B
        MOV C, A        ; Start checksumming in C
        CALL GETHEX     ; Start address high byte
        MOV H, A        ; Store in H
        ADD C
        MOV C, A        ; Checksum
        CALL GETHEX     ; Start address low byte
        MOV L, A        ; Store in L
        ADD C
        MOV C, A        ; Checksum
        CALL GETHEX     ; Get record type
        MOV D, A        ; Store record type in D
        ADD C
        MOV C, A        ; Checksum record type
        MOV A, B        ; Check record length
        ANA A
        JZ LOAD3        ; Length == 0, done getting data
LOAD2:  CALL GETHEX
        MOV M, A        ; Store char at HL
        ADD C
        MOV C, A        ; Checksum
        INX H           ; Move memory pointer up
        DCR B
        JNZ LOAD2       ; Not done with the line
LOAD3:  CALL GETHEX     ; Get checksum byte
        ADD C
        JNZ CSUMER      ; Checksum bad, print error
        ORA D
        JZ LOAD         ; Record Type 00, keep going
LOAD4:  CALL CINNE      ; Record Type 01, done
        CPI 10          ; Check for LF
        JNZ LOAD4
        RET             ; Got LF, return to command loop
CSUMER: LXI H, CSERR$
        CALL ERROUT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Monitor Strings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LOGMSG$: db 13, 10, 10, 'GWMON-80 0.1.1 for 8080/8085/Z80 and Compatible', 13, 10
         db 'Copyright (c) 2018 The Glitch Works', 0
PROMPT$: db 13, 10, 10, '>', 0
ERR$:    db 'ERROR', 0
CSERR$:  db 'CHECKSUM ERROR', 0
