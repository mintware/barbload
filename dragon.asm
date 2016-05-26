;
; Barbarian patch for invisible dragon
;
; Copyright (c) 2016 Vitaly Sinilin
;
; When Barbarian kills the dragon it won't respawn unlike regular enemies.
; And for that reason a boolean variable exists. But unfortunately
; this variable only prevents the dragon to be shown, but still
; allows it to kill Barbarian unexpectedly.

%include "origsyms.inc"
%include "patch.mac"

		; Function initDragon is called whenever you enter a room.
		; If the room is not 35, 36, or 37, it initializes the
		; dragon randomly in one of these three rooms.

		; Let's make use of padding space before original initDragon()
		; to prepend some code to it and patch mainLoop() to call
		; this extended version.

initDragonPt:	patch	barb_cseg, 5278h, 5280h
		cmp	byte [isDragonDead], 1
		jne	orig_off(5280h)
		ret
		endpatch

mainLoopPt:	patch	barb_cseg, 4A38h, 4A3Bh
		call	orig_off(5278h)
		endpatch

		; It wasn't enough to just prevent initializing the dragon
		; whenever isDragonDead is set, because in this case the
		; dragon wasn't cleared from the room where it was killed.

killDragonPt:	patch	barb_cseg, 70ADh, 70B2h
		call	code:killDragon
		endpatch

killDragon:
		mov	ax, 14
		mul	word [room]
		mov	si, ax
		mov	byte [arrEnemy1+si], 0	; clear dragon from the room
.legacy:	mov	byte [isDragonDead], 1
		retf

