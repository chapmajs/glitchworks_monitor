;GWMON-80 I/O module for the North Star Horizon, console
;on left serial port.

;Stack pointer set to 0xE800, assuming monitor to be put
;in ROM at 0xE800 for compatibility with standard North
;Star boot/monitor code.

;After including this module, you still need to
;set the ORG in the main monitor source.

CTLPRT  equ 03H
DATPRT  equ 02H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SETUP -- Prepare the system for running the
;   monitor
;
;Initialized the Horizon motherboard per the
;North Star DOS manual examples.
;
;pre: none
;post: stack and console are initialized
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETUP:  LXI SP, 0E800H
        XRA A                   ; Clear accumulator
        OUT 6                   ; Set up motherboard
        OUT 6
        OUT 6
        OUT 6
INIURT: MVI A, 0CEH             ; 8N2, x16 clock
        OUT 3                   ; Set left serial port
        OUT 5                   ; Set right serial port
        MVI A, 37H              ; RTS, ER, RXF, DTR, TXEN
        OUT 3
        OUT 5
        IN 2                    ; Clear serial port buffers
        IN 4
        MVI A, 30H              ; Reset PI flag on parallel port
        OUT 6
        JMP SE1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CINNE -- Get a char from the console, no echo
;
;pre: console device is initialized
;post: received char is in A register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CINNE:  IN CTLPRT
        ANI 02H
        JZ CINNE
        IN DATPRT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CIN -- Get a char from the console and echo
;
;pre: console device is initialized
;post: received char is in A register
;post: received char is echoed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CIN:    CALL CINNE
        OUT DATPRT
        RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;COUT -- Output a character to the console
;
;pre: A register contains char to be printed
;post: character is printed to the console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
COUT:   PUSH B
        MOV B, A
COUT1:  IN CTLPRT
        ANI 01H
        JZ COUT1
        MOV A, B
        OUT DATPRT
        POP B
        RET

;I/O Module description string
MSG$:     db 13, 10, 'Built for North Star Horizon, left serial port', 0