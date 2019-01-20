;Glitch Works Monitor I/O Module for the Seattle Computer
;Products Multiport Serial Card 400C, channel 0

;Adjust CTLPRT and DATPRT for your specific hardware.
;Stack Pointer initialized at 0xFFFF, adjust as needed.
;
;After including this module, you still need to
;set the ORG in the main monitor source.

DATPRT  equ 00H
CTLPRT  equ 01H
BPSPRT  equ 08H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SETUP -- Prepare the system for running the
;   monitor
;
;pre: none
;post: stack and console are initialized
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETUP:  LXI SP, 0FFFFH
        LXI H, INIUART$
        MVI B, 06H              ; length of ini string
INURT:  MOV A, M
        OUT CTLPRT
        INX H
        DCR B
        JNZ INURT
        MVI A, 0EH              ; 9600 bps
        OUT BPSPRT
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

;Init string for the 8251, x16 clock, 8N1
INIUART$:  db 00H, 00H, 00H, 40H, 4EH, 37H

;I/O Module description string
MSG$:     db 13, 10, 'Built for SCP 400C channel 0', 0

        END
