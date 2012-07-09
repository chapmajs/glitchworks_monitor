The Glitch Works Monitor
========================

What is this?
-------------

The Glitch Works Monitor is intended to be a simple ROM-type system monitor for systems utilizing processors that are binary-compatible with the 8080, including (but not limited to) 8085 and Z80 systems. It is written in a modular format so that it can be extended for use with specific system hardware with ease. It is being developed and released under the GNU GPLv3 as open source software (see LICENSE and/or GPL-3.0 in project root for more information).

Contributing
------------

Contributions can be made to any part of this code; however, we're especially encouraging people to contribute their I/O modules. A wide variety of I/O modules make this monitor useful to more people without having to write their own modules.

### I/O Modules

I/O Modules should assemble under the Digital Research CP/M assembler, included with CP/M 2.2. Intel mnemonics are thus a requirement. If an I/O module is particular to a very restricted set of hardware (i.e. a system that cannot have more than one type/revision of processor), I/O modules may include opcodes from instruction sets that extend that of the 8080. Keeping to the 8080 Instruction Set Architecture is preferred.

### Core Monitor

The core monitor code should assemble under the Digital Research CP/M assembler, included with CP/M 2.2. Intel mnemonics are a requirement. The core monitor code *MUST* be 8080 compatible; therefore, no opcodes from instruction sets that extend that of the 8080 may be used. Contributions using non-8080 opcodes will be rejected. If you wish to optimize the core monitor code for your specific architecture, please fork the project.

Installation
------------

To build the monitor for your system, you must concatenate your I/O module onto the core monitor source (monitor.asm). The resulting combined file should then be edited to adjust the ORG offset. Here are a few ways to combine the files:

* Under CP/M: PIP CUSTMON.ASM=MONITOR.ASM,MODULE.ASM
* Under Linux: cat monitor.asm module.asm > custom_monitor.asm

After concatenating the core monitor source and your I/O module, the resulting file can be assembled using any assembler compatible with the Digital Research CP/M 2.2 assembler. The assembled object code can be LOADed as a CP/M program, burned to ROM, et c. This README does not currently cover assembler operation.

Command Syntax
--------------

Command syntax as follows:

	D XXXX YYYY	Dump memory from XXXX to YYYY
	E XXXX		Edit memory starting at XXXX (type an X and press enter to exit entry)
	G XXXX		GO starting at address XXXX (JMP in, no RET)
	I XX		Input from I/O port XX and display as hex
	O XX YY		Output to I/O port XX byte YY

The current ultra-basic command processor automatically inserts the spaces after each element.
So, to dump memory from 0x0000 to 0x000F you'd type

	d0000000f

...and you'd get

	>D 0000 000F
	0000 : xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx xx
	
	>

...where the xx fields are the hex representation of the bytes at those addresses.

No returns or spaces are typed in the commands. This is very similar to the NorthStar ROM monitor,
most likely because it's about the simplest way to implement. Input is autocased to caps, so you can
type entries in either (or even mixed) case. I do want to rewrite the command processor at some point,
allowing one to type out the command and backspace to correct if necessary. One day!

Writing I/O Modules
-------------------

I/O modules need to implement a few named subroutines:

* SETUP: prepare the stack and console device for use
* CIN: input a char from the console and echo
* COUT: output a char to the console

Additionally, all I/O modules should define the MSG$ string, which is a null-terminated string describing the particular platform the module is designed for. This will be output at monitor load.

SETUP should initialize the Stack Pointer and console device, if the devices are not already initialized. After initialization, it should do an unconditional JUMP to the label SE1.

CIN and COUT are character I/O routines for your console device. They should not modify any registers other than the A register, so push everything else to the stack and pop it off after your routine. Both of these subroutines should terminate in a RET instruction.
