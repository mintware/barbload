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

forkStURTopPt:	patch	barb_cseg, 6EE8h
		call	code:forkStairsURTop
		jc	.beginSmth
		jmp	orig_off(step)
.beginSmth:	pop	di
		jmp	ax
		endpatch

forkStairsURTop:
		test	word [action], ACTION_DOWN
		jnz	.chkDirection
		clc
		retf
.chkDirection:	cmp	byte [dueWest], 1
		je	.takeFork
		add	word [actorPosX], 32	; the fix
		mov	ax, beginTurning
		jmp	.coda
.takeFork:	mov	ax, beginStairsDown
.coda:		stc
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
		test	word [action], ACTION_UP
		jnz	.chkDirection
		clc
		retf
.chkDirection:	cmp	byte [dueWest], 0
		je	.takeFork
		sub	word [actorPosX], 32	; the fix
		mov	ax, beginTurning
		jmp	.coda
.takeFork:	mov	ax, beginStairsUp
.coda:		stc
		retf
