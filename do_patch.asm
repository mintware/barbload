;
; Loader for Barbarian
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"

extern __orig_ptrs_end
extern __patch_tbl_end, __patchb_tbl_end, __patchw_tbl_end

section orig_ptrs
section patch_tbl
section patchb_tbl
section patchw_tbl

section code

global do_patch
do_patch:
		; set es to barb_cseg

		mov	dx, ds
		sub	dx, barb_dseg
		mov	es, dx

		; relocate far pointers to original symbols

		mov	ax, orig_ptrs
		mov	ds, ax
		mov	si, 2 + __orig_ptrs_end wrt orig_ptrs
		jmp	.next_ptr

.reloc_ptr:	dec	si
		dec	si
		add	[si], dx			; tune seg of far_ptr
.next_ptr:	dec	si
		dec	si
		jnz	.reloc_ptr

		; apply patches

		mov	ax, patch_tbl
		mov	ds, ax
		mov	si, 4 + __patch_tbl_end wrt patch_tbl
		jmp	.next_patch

.apply_patch:	dec	si
		xor	ch, ch
		mov	cl, byte [si]			; patch length
		dec	si
		dec	si
		call	get_prev_fptr
		push	si
		mov	si, [si]			; patch src offset
		push	ds
		push	cs
		pop	ds
		call	memcpy
		pop	ds
		pop	si
.next_patch:	sub	si, 4
		jnz	.apply_patch

		; patch words according to table

		mov	ax, patchw_tbl
		mov	ds, ax
		mov	si, 4 + __patchw_tbl_end wrt patchw_tbl
		jmp	.next_word

.patch_word:	dec	si
		dec	si
		call	get_prev_fptr
		mov	ax, [si]
		mov	[es:di], ax
.next_word:	sub	si, 4
		jnz	.patch_word

		; patch bytes according to table

		mov	ax, patchb_tbl
		mov	ds, ax
		mov	si, 4 + __patchb_tbl_end wrt patchb_tbl
		jmp	.next_byte

.patch_byte:	dec	si
		call	get_prev_fptr
		mov	al, [si]
		mov	[es:di], al
.next_byte:	sub	si, 4
		jnz	.patch_byte

		ret

;------------------------------------------------------------------------------

memcpy:
		cld
		rep movsb
		ret

;------------------------------------------------------------------------------

; read far ptr pointed to by ds:si-4 to es:di

get_prev_fptr:
		mov	di, [si-4]
		mov	ax, [si-2]
		add	ax, dx
		mov	es, ax
		ret
