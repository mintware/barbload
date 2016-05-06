;
; Barbarian patch for fast program start
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"
%include "patch.mac"

		patchb	barb_cseg, 508Ah, 255	; 255 lives

		; Room to the west of room 0 (for debugging!)
		patchb	barb_dseg, 0A3D3h, 5

;dontAskVideo:	patch	barb_cseg, 60h
;		mov	bx, 2			; EGA
;		endpatch

;noTitle:	patch	barb_cseg, 438Ah
;		nop
;		nop
;		nop
;		endpatch

noSpeech:	patch	barb_cseg, 0A0Eh
		retn
		endpatch

;noSpeech:	patch	barb_cseg, 0A14h
;		mov	word [0BC5h], 0
;		endpatch

noTitles:	patch	barb_cseg, 43E6h
		nop
		nop
		nop
		endpatch

keybControls:	patch	barb_cseg, 45D3h
		mov	al, '2'
		nop
		endpatch

speed3:		patch	barb_cseg, 4813h
		mov	al, '3'
		nop
		endpatch
