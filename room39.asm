;
; Barbarian patch for room 39
;
; Copyright (c) 2016 Vitaly Sinilin
;
; There is a bug that prevents returning back from room 39 to room 37
; by going down the ladder.
;
; Every room has four siblings stored in array <left,right,top,bottom>.
; Room 39 has itself as the bottom sibling. That needs to be fixed.
;
; n.b. Sibling IDs are stored one-based. Below room 39 is room 37, but
; the patch has 38 for this reason.

%include "origsyms.inc"
%include "patch.mac"

		patchb	barb_dseg, 0A471h, 38
