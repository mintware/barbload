;
; Loader for Barbarian
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"

extern __patch_tbl, __patch_tbl_end
extern __patchw_tbl, __patchw_tbl_end
extern __patchb_tbl, __patchb_tbl_end

global do_patch
do_patch:
		; set es to barb_cseg

		mov	dx, ds
		sub	dx, barb_dseg
		mov	es, dx
		push	cs
		pop	ds

		; apply patches

		mov	bx, __patch_tbl
		mov	si, 4 + __patch_tbl_end
		sub	si, bx
		cld
		jmp	.next_patch

.apply_patch:	dec	si
		xor	ch, ch
		mov	cl, [bx+si]			; patch length
		dec	si
		dec	si
		call	get_prev_fptr
		push	si
		mov	si, [bx+si]			; patch src offset
		rep movsb
		pop	si
.next_patch:	sub	si, 4
		jnz	.apply_patch

		; patch words according to table

		mov	bx, __patchw_tbl
		mov	si, 4 + __patchw_tbl_end
		sub	si, bx
		jmp	.next_word

.patch_word:	dec	si
		dec	si
		call	get_prev_fptr
		mov	ax, [bx+si]
		mov	[es:di], ax
.next_word:	sub	si, 4
		jnz	.patch_word

		; patch bytes according to table

		mov	bx, __patchb_tbl
		mov	si, 4 + __patchb_tbl_end
		sub	si, bx
		jmp	.next_byte

.patch_byte:	dec	si
		call	get_prev_fptr
		mov	al, [bx+si]
		mov	[es:di], al
.next_byte:	sub	si, 4
		jnz	.patch_byte

		ret

;------------------------------------------------------------------------------

; read far ptr pointed to by ds:bx+si-4 to es:di

get_prev_fptr:
		mov	di, [bx+si-4]
		mov	ax, [bx+si-2]
		add	ax, dx
		mov	es, ax
		ret
