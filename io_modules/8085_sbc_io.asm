;Glitch Works Monitor I/O Module for Glitch Works 8085
;SBC with Multi IO Rev 0 (Zilog 8530 SCC), port A
;
;Adjust CTLPRT and DATPRT for your Multi IO base
;address. The supplied params are for offset 0x00.
;
;After including this module, you still need to
;set the ORG in the main monitor source. If it is to
;be burned to ROM for the 8085 SBC, you want 0x0000

CTLPRT  equ 0002H
DATPRT  equ 0003H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SETUP -- Prepare the system for running the
;   monitor
;
;pre: none
;post: stack and console are initialized
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETUP:  LXI SP, 0FFFFH
        LXI H, INISCC$
        MVI B, 10H
INSCC:  MOV A, M
        OUT CTLPRT
        INX H
        DCR B
        JNZ INSCC
        JMP SE1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CIN -- Get a char from the console and echo
;
;pre: console device is initialized
;post: received char is in A register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CIN:    IN CTLPRT
        ANI 01H
        JZ CIN
        IN DATPRT
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
        ANI 04H
        JZ COUT1
        MOV A, B
        OUT DATPRT
        POP B
        RET

;Init string for the SCC, 9600 baud
INISCC$:  db 04H, 44H, 03H, 0C1H, 05H, 0EAH, 0BH, 56H, 0CH, 0EH, 0DH, 00H, 0EH, 01H, 0FH, 00H

;I/O Module description string
MSG$:     db 13, 10, 'Built with 8085 SBC Multi I/O module', 0
