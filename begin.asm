;
; Sections of loader for Barbarian
;
; Copyright (c) 2016 Vitaly Sinilin
;

STACK_SZ	equ	32

section code
section orig_ptrs align=16
section patch_tbl align=16
section patchb_tbl align=16
section patchw_tbl align=16

section bss
global __bss
__bss:

section stack stack align=16
		resb	STACK_SZ
global __stacktop
__stacktop:

group maingroup code patch_tbl patchb_tbl patchw_tbl bss stack
