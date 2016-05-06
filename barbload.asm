;
; Loader for Barbarian
;
; Copyright (c) 2016 Vitaly Sinilin
;


PSP_SZ		equ	100h

extern __stacktop
extern do_patch

main:
..start:	mov	bx, PSP_SZ + __stacktop
		mov	cl, 4
		shr	bx, cl				; new size in pars
		mov	ah, 4Ah				; resize memory block
		int	21h

		push	cs				; setup data segment
		pop	ds

		mov	ax, 3516h			; read int 16h vector
		int	21h				; es:bx <- cur handler
		mov	[int16.seg], es			; save original
		mov	[int16.off], bx			; int 16h vector

		mov	dx, int_handler			; setup our own
		mov	ax, 2516h			; handler for int 16h
		int	21h				; ds:dx -> new handler

		mov	[cmdtail.seg], cs		; pass cmd tail from
		mov	word [cmdtail.off], 80h		; our PSP to barb
		mov	dx, exe
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

errmsg		db	"Unable to exec original "
exe		db	"barb.exe",0,"$"

parmblk		dw	0				; environment seg
cmdtail		handy_far_ptr 0, 0			; cmd tail
		dd	0				; first FCB address
		dd	0				; second FCB address

int16		handy_far_ptr 0, 0