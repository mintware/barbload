;
; Barbarian patches for unexpected behavior on stairs
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"
%include "patch.mac"

;------------------------------------------------------------------------------
;
; Patch 1:	Don't switch to walking after leaving stairs if was running
;		when entered it.
;
;		Originally ACTION_RUN and ACTION_PANIC were cleared after
;		leaving the stairs as well as ACTION_UP and ACTION_DOWN.

eoStairsUp:	patch	barb_cseg, 62C5h
		and	word [action], ~(ACTION_UP | ACTION_DOWN)
		endpatch

eoStairsDn:	patch	barb_cseg, 635Ch
		and	word [action], ~(ACTION_UP | ACTION_DOWN)
		endpatch

;------------------------------------------------------------------------------
;
; Patch 2:	When approaching stairs from opposite direction and the down
;		action is pending Barbarian turns when he reaches the stairs,
;		but his position after that doesn't allow him to go down the
;		stairs.

forkStairsWest:
		mov	al, 1
		jmp	forkStairs

forkStairsEast:
		mov	al, 0

forkStairs:	cmp	[dueWest], al
		je	.coda
		pushf
		mov	dx, 16			; should be changed to 32 when
						; turning is fixed
		cmp	al, 1
		je	.tune
		neg	dx
.tune:		add	[actorPosX], dx		; the fix
		popf
.coda:		retf

;------------------------------------------------------------------------------

forkStURBtmPt:	patch	barb_cseg, 6EDBh, 6EE0h
		call	code:forkStairsEast
		endpatch

;------------------------------------------------------------------------------

forkStURTopPt:	patch	barb_cseg, 6EF4h, 6EF9h
		call	code:forkStairsWest
		endpatch

;------------------------------------------------------------------------------

forkStDRBtmPt:	patch	barb_cseg, 6F23h, 6F39h
		test	word [action], ACTION_UP
		jnz	.chkDirection
		jmp	orig_off(step)
.chkDirection:	pop	di
		call	code:forkStairsWest
		jz	.takeFork
		jmp	orig_off(beginTurning)
.takeFork:	endpatch

;------------------------------------------------------------------------------
;
; This patch is commented out because there are no such forks in the game.
;
;forkStDRTopPt:	patch	barb_cseg, 6F3Ch, 6F55h
;		test	word [action], ACTION_DOWN
;		jnz	.chkDirection
;		jmp	orig_off(step)
;.chkDirection:	pop	di
;		call	code:forkStairsEast
;		jz	.takeFork
;		jmp	orig_off(beginTurning)
;.takeFork:	jmp	orig_off(beginStairsDown)
;		endpatch
