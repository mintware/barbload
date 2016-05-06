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
		xor	si, si
.next_ptr:	cmp	si, __orig_ptrs_end wrt orig_ptrs
		je	.end_orig_ptrs
		add	[si+2], dx
		add	si, 4				; sizeof dword
		jmp	.next_ptr
.end_orig_ptrs:

		; apply patches

		mov	ax, patch_tbl
		mov	ds, ax
		xor	si, si
.next_patch:	cmp	si, __patch_tbl_end wrt patch_tbl
		je	.end_patch_loop
		call	get_next_fptr
		xor	ch, ch
		mov	cl, byte [si+2]
		push	si
		mov	si, [si]
		push	ds
		push	cs
		pop	ds
		call	memcpy
		pop	ds
		pop	si
		add	si, 3				; dw + db
		jmp	.next_patch
.end_patch_loop:

		; patch words according to table

		mov	ax, patchw_tbl
		mov	ds, ax
		xor	si, si
.next_word:	cmp	si, __patchw_tbl_end wrt patchw_tbl
		je	.end_word_loop
		call	get_next_fptr
		mov	ax, [si]
		mov	[es:di], ax
		add	si, 2				; sizeof word
		jmp	.next_word
.end_word_loop:

		; patch bytes according to table

		mov	ax, patchb_tbl
		mov	ds, ax
		xor	si, si
.next_byte:	cmp	si, __patchb_tbl_end wrt patchb_tbl
		je	.end_byte_loop
		call	get_next_fptr
		mov	al, [si]
		mov	[es:di], al
		add	si, 1				; sizeof byte
		jmp	.next_byte
.end_byte_loop:

		ret

;------------------------------------------------------------------------------

memcpy:
		cld
		rep movsb
		ret

;------------------------------------------------------------------------------

; read far ptr pointed to by ds:si to es:di and increment si

get_next_fptr:
		mov	di, [si]			; offset
		mov	ax, [si+2]			; segment
		add	ax, dx
		mov	es, ax
		add	si, 4				; skip far ptr
		ret
