;GWMON-80 I/O Module for Intel 8251 UART on 8085 SBC rev 3

;Adjust CTLPRT and DATPRT for your specific hardware.
;Stack Pointer initialized at 0xE000, adjust as needed.
;
;On the 8085 SBC rev 3, this monitor is typically stored in a
;ROM-FS record and loaded by a bootblock. It is copied out of
;ROM to RAM at 0xE000.
;
;After including this module, you still need to
;set the ORG in the main monitor source.

CTLPRT  equ 01H
DATPRT  equ 00H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SETUP -- Prepare the system for running the
;   monitor
;
;pre: none
;post: stack and console are initialized
;post: ROM boot circuit is switched off
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETUP:  MVI A, 010H             ; Turn off ROM at 0x0000
        OUT 02H
        LXI SP, 0E000H
        LXI H, INIUART$
        MVI B, 06H              ; length of ini string
INURT:  MOV A, M
        OUT CTLPRT
        INX H
        DCR B
        JNZ INURT
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
MSG$:     db 13, 10, 'Running at 0xE000', 13, 10, 'Built with Intel 8251 I/O module', 0

        END