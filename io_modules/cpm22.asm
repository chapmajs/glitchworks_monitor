;Glitch Works Monitor I/O Module for CP/M-80 2.2
;This module uses the CP/M BDOS routines for 
;character input/output.
;
;After including this module, you still need to
;set the ORG in the main monitor source. Most
;CP/M users will want to use 'ORG 0100H'

CONIO	equ	0006H
CONIN	equ	0001H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SETUP -- Prepare the system for running the
;	monitor
;
;pre: none
;post: stack and console are initialized
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETUP:	JMP SE1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CIN -- Get a char from the console and echo
;
;pre: console device is initialized
;post: received char is in A register
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CIN:	PUSH B
		PUSH D
        PUSH H
        MVI C, CONIN
		CALL BDOS
        POP H
        POP D
        POP B
		RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;COUT -- Output a character to the console
;
;pre: A register contains char to be printed
;post: character is printed to the console
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
COUT:	PUSH B
        PUSH D
        PUSH H
        MVI C, CONIO
		MOV E, A
		CALL BDOS
        POP H
        POP D
        POP B
		RET

;I/O Module description string
MOD$:	db 13, 10, 'Built with CP/M 2.2 I/O module', 0
