;
; Barbarian patch for the weapon dropping bug
;
; Copyright (c) 2016 Vitaly Sinilin
;
; When Barbarian tries to drop the bow, he drops the shield instead
; if he has it, or casts the shield otherwise.
; When Barbarian tries to drop the shield, he drops the bow instead
; if he has it, or casts the bow otherwise.
; This patch fixes this behaviour.

%include "origsyms.inc"
%include "patch.mac"

		patch	barb_cseg, 5465h
		dw	dropShield	; was dropBow
		dw	dropBow		; was dropShield
		endpatch
