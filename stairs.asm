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

forkStairs:	; al - horizontal direction (1=west)
		; cf - vertical direction (0=up, 1=down)
		; on return: cf=0 -> do step,
		;            otherwise zf=1 -> do fork,
		;            otherwise -> do turn

		jc	.down
		mov	ah, ACTION_UP
		jmp	.chkAction

.down:		mov	ah, ACTION_DOWN

.chkAction:	test	byte [action], ah
		jnz	.chkDirection
		clc
		retf

.chkDirection:	cmp	byte [dueWest], al
		je	.coda
		pushf
		mov	dx, 16			; should be changed to 32 when
						; turning is fixed
		cmp	al, 1
		je	.tune
		neg	dx
.tune:		add	word [actorPosX], dx	; the fix
		popf
.coda:		stc
		retf

;------------------------------------------------------------------------------

forkStURBtmPt:	patch	barb_cseg, 6ECFh, 6EE0h
		clc				; up
		mov	al, 0			; east
		call	code:forkStairs
		jc	.beginSmth
		jmp	orig_off(step)
.beginSmth:	pop	di
		endpatch

;------------------------------------------------------------------------------

forkStURTopPt:	patch	barb_cseg, 6EE8h, 6EF9h
		stc				; down
		mov	al, 1			; west
		call	code:forkStairs
		jc	.beginSmth
		jmp	orig_off(step)
.beginSmth:	pop	di
		endpatch

;------------------------------------------------------------------------------

forkStDRBtmPt:	patch	barb_cseg, 6F23h
		clc				; up
		mov	al, 1			; west
		call	code:forkStairs
		jc	.beginSmth
		jmp	orig_off(step)
.beginSmth:	pop	di
		jz	.takeFork
		jmp	orig_off(beginTurning)
.takeFork:	jmp	orig_off(beginStairsUp)
		endpatch

;------------------------------------------------------------------------------
;
; This patch is commented out because there are no such forks in the game.
;
;forkStDRTopPt:	patch	barb_cseg, 6F3Ch
;		stc				; down
;		mov	al, 0			; east
;		call	code:forkStairs
;		jc	.beginSmth
;		jmp	orig_off(step)
;.beginSmth:	pop	di
;		jz	.takeFork
;		jmp	orig_off(beginTurning)
;.takeFork:	jmp	orig_off(beginStairsDown)
;		endpatch
