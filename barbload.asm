;
; Loader for Barbarian
;
; Copyright (c) 2016 Vitaly Sinilin
;


PSP_SZ		equ	100h

extern __stacktop, __bss, __bssend
extern do_patch

group maingroup code data bss

main:
..start:	mov	bx, PSP_SZ + __stacktop
		mov	cl, 4
		shr	bx, cl				; new size in pars
		mov	ah, 4Ah				; resize memory block
		int	21h

		push	cs				; setup data segment
		pop	ds

		mov	bx, __bssend
		sub	bx, __bss
.zero_bss:	dec	bx
		mov	byte [__bss + bx], bh
		jnz	.zero_bss

		mov	[cmdtail.seg], es		; pass cmd tail from
		mov	word [cmdtail.off], 80h		; our PSP to barb

		mov	ax, 3516h			; read int 16h vector
		int	21h				; es:bx <- cur handler
		mov	[int16.seg], es			; save original
		mov	[int16.off], bx			; int 16h vector

		mov	dx, int_handler			; setup our own
		mov	ax, 2516h			; handler for int 16h
		int	21h				; ds:dx -> new handler

		mov	dx, exe
		push	cs
		pop	es
		mov	bx, parmblk
		mov	ax, 4B00h			; exec
		int	21h

		jnc	.exit
		call	uninstall
		mov	dx, errmsg
		mov	ah, 9
		int	21h

.exit:		mov	ah, 4Dh				; read errorlevel
		int	21h				; errorlevel => AL
		mov	ah, 4Ch				; exit
		int	21h

;------------------------------------------------------------------------------

int_handler:
		pusha
		push	ds
		push	es

		call	do_patch	; all patching work is done here

		call	uninstall	; restore original vector of int 16h

		pop	es
		pop	ds
		popa
.legacy:	jmp	far [cs:int16]

;------------------------------------------------------------------------------

uninstall:
		push	ds
		mov	ds, [cs:int16.seg]
		mov	dx, [cs:int16.off]
		mov	ax, 2516h
		int	21h
		pop	ds
		ret

;------------------------------------------------------------------------------

section data

errmsg		db	"Unable to exec original "
exe		db	"barb.exe",0,"$"

;------------------------------------------------------------------------------

section bss

parmblk		resw	1				; environment seg
cmdtail		res_fptr				; cmd tail
		resd	1				; first FCB address
		resd	1				; second FCB address

int16		res_fptr
