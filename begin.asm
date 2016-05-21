;
; Sections of loader for Barbarian
;
; Copyright (c) 2016 Vitaly Sinilin
;

STACK_SZ	equ	32

section code

section orig_ptrs
global __orig_ptrs
__orig_ptrs:

section patch_tbl
global __patch_tbl
__patch_tbl:

section patchw_tbl
global __patchw_tbl
__patchw_tbl:

section patchb_tbl
global __patchb_tbl
__patchb_tbl:

section data

section bss
global __bss
__bss:

section stack stack align=16
		resb	STACK_SZ
global __stacktop
__stacktop:

group maingroup code patch_tbl patchb_tbl patchw_tbl data bss stack
