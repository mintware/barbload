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

		; It wasn't enough to just prevent initializing the dragon
		; whenever isDragonDead is set, because in this case the
		; dragon wasn't cleared from the rooms until Barbarian
		; leaves them.

initDragonPt:	patch	barb_cseg, 5283h
		call	code:initDragonCond
		jc	orig_off(5290h)
		retn
		endpatch

initDragonCond:	cmp	byte [isDragonDead], 1
		jne	.alive
.room35:	mov	byte [arrEnemy1+1EAh], 0
.room36:	mov	byte [arrEnemy1+1F8h], 0
.room37:	mov	byte [arrEnemy1+206h], 0
.dontinit:	clc
		retf

.alive:		mov	ax, [room]
		cmp	ax, 35
		jb	.init
		cmp	ax, 38
		jb	.dontinit
.init:		stc
		retf
