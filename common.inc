;
; Loader for Barbarian: pre-include file
;
; Copyright (c) 2016 Vitaly Sinilin
;

; Barbarian runs well on XTs, so the loader must do so.
cpu 8086

; i808[68] doesn't have pusha/popa instructions
%macro pusha 0
		push	ax
		push	cx
		push	dx
		push	bx
		push	bp
		push	si
		push	di
%endmacro

%macro popa 0
		pop	di
		pop	si
		pop	bp
		pop	bx
		pop	dx
		pop	cx
		pop	ax
%endmacro

%macro handy_far_ptr 2
.off		dw	%2
.seg		dw	%1
%endmacro

%macro far_ptr 2
		dw	%2
		dw	%1
%endmacro

section code    ; default section
