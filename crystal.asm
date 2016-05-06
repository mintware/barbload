;
; Barbarian patch for respawning crystal
;
; Copyright (c) 2016 Vitaly Sinilin
;
; After the crystal is destroyed whenever Barbarian tries to take
; something, he gets a new crystal and tries to get rid of it.
; This happens because the variable hasCrystal is never reset in
; the original code.

%include "origsyms.inc"
%include "patch.mac"

dropCrystalPt:	patch	barb_cseg, 6AC1h
		call	code:dropCrystal
		endpatch

dropCrystal:	mov	byte [isCrystalDestd], 1
		mov	byte [hasCrystal], 0	; the fix
		retf
