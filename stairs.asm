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

forkStairs:	; bh - fork direction (1=west)
		; cf - vert direction (0=up, 1=down)

		jc	.down

		mov	bl, ACTION_UP
		mov	ax, beginStairsUp
		jmp	.chkAction

.down:		mov	bl, ACTION_DOWN
		mov	ax, beginStairsDown

.chkAction:	test	byte [action], bl
		jnz	.chkDirection
		clc
		ret

.chkDirection:	cmp	byte [dueWest], bh
		je	.coda
		mov	dx, 32
		cmp	bh, 1
		je	.tune
		neg	dx
.tune:		add	word [actorPosX], dx	; the fix
		mov	ax, beginTurning
.coda:		stc
		ret

;------------------------------------------------------------------------------

forkStURTopPt:	patch	barb_cseg, 6EE8h
		call	code:forkStairsURTop
		jc	.beginSmth
		jmp	orig_off(step)
.beginSmth:	pop	di
		jmp	ax
		endpatch

forkStairsURTop:
		stc				; down
		mov	bh, 1
		call	forkStairs
		retf

;------------------------------------------------------------------------------

forkStURBtmPt:	patch	barb_cseg, 6ECFh
		call	code:forkStairsURBtm
		jc	.beginSmth
		jmp	orig_off(step)
.beginSmth:	pop	di
		jmp	ax
		endpatch

forkStairsURBtm:
		clc				; up
		mov	bh, 0
		call	forkStairs
		retf

;------------------------------------------------------------------------------

forkStDRBtmPt:	patch	barb_cseg, 6F23h
		call	code:forkStairsDRBtm
		jc	.beginSmth
		jmp	orig_off(step)
.beginSmth:	pop	di
		jmp	ax
		endpatch

forkStairsDRBtm:
		clc				; up
		mov	bh, 1
		call	forkStairs
		retf
