;
; Barbarian patch for turning animation
;
; Copyright (c) 2016 Vitaly Sinilin
;
; Make turning animation look nicer

%include "origsyms.inc"
%include "patch.mac"

		; Tune turning animation per frame x position changing

		patch	barb_dseg, 0A090h
		dw	8
		dw	-12
		dw	-6
		dw	-1  ; 0 \are better but cause unaligment
		dw	-10 ;-9 /
		dw	-19
		endpatch
