;
; Barbarian patch for room 56
;
; Copyright (c) 2016 Vitaly Sinilin
;
; When Barbarian falls into abyss in room 54 it respawns in room 0.
; It might've been done intentionally to piss off the player, but I
; consider it a bug since it opens a shortcut for completion the
; game without all way back.
;
;  .->54-53
;  |  55
;  `--56

%include "origsyms.inc"
%include "patch.mac"

		; respawn in room 54 (was 0)

		patchb	barb_dseg, roomRespawnPosX+56, 55
