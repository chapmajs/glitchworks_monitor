;The following is relocatable Z80 code produced from TDL's ZASM, it is
;a bootstrap for the first drive on a VersaFloppy II.
;
;This bootstrap is derived from one written by Bruce Jones and provided
;to Herb Johnson for distribution through his VersaFloppy II information
;page.

BOOT:   db   3EH,  7EH, 0D3H, 063H, 021H,  00H,  00H,  3EH,  0BH, 0D3H
        db   64H,  06H, 0C8H,  10H, 0FEH, 0DBH,  64H, 0CBH,  47H,  20H
        db  0FAH,  3EH,  01H, 0D3H,  66H, 03EH,  88H, 0D3H,  64H,  01H
        db   67H,  00H, 0EDH, 0B2H, 0EDH, 0B2H,  06H, 0C8H,  10H, 0FEH
        db  0DBH,  64H, 0CBH,  47H,  20H, 0FAH, 0E6H,  9DH, 0CAH,  00H
        db   00H,  18H, 0CFH