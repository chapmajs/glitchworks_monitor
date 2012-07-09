;Glitch Works Monitor for 8080/8085/Z80 and Compatibles 
;Version 0.1 Copyright (c) 2012 Jonathan Chapman
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
        LXI H, ERR$
        CALL STROUT
        JMP CMDLP

;Get a port address, write byte out
OUTPUT: CALL SPCOUT
        CALL GETHEX
        MOV B, A
        CALL SPCOUT
        CALL GETHEX
        CALL JMPOUT
        JMP CMDLP

;Input from port, print contents
INPUT:  CALL SPCOUT
        CALL GETHEX
        MOV B, A
        CALL SPCOUT
        MOV A, B
        CALL JMPIN
        CALL HEXOUT
        JMP CMDLP

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
        JC CMDLP
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
        JM CMDLP
        MOV A, E
        CMP L
        JM MD2
        JMP MD1
MD2:    MOV A, D
        CMP H
        JNZ MD1
        JMP CMDLP

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

LOGMSG$:db 'Glitch Works Monitor for 8080/8085/Z80 and Compatible', 13, 10
        db 'Version 0.1 Copyright (c) 2012 Jonathan Chapman', 0
PROMPT$:db 13, 10, 10, '>', 0
ERR$:   db 13, 10, 'ERROR', 0
