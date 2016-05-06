;
; Barbarian patch for orientation after leaving ladder
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"
%include "patch.mac"

;------------------------------------------------------------------------------

goLadderUpPt:	patch	barb_cseg, 63B9h
		call	code:goLadderUp
		jmp	orig_off(63CFh)
		endpatch

goLadderUp:	mov	word [0A3A5h], 0
		jmp	goLadderDn

;------------------------------------------------------------------------------

goLadderDnPt:	patch	barb_cseg, 644Bh
		call	code:goLadderDn
		jmp	orig_off(645Bh)
		endpatch

		; Store original orientation into action and align Barbarian
		; against the ladder.

goLadderDn:	cmp	byte [dueWest], 1
		je	.west
		mov	word [action], ACTION_RIGHT
		jmp	.rest

.west:		mov	word [action], ACTION_LEFT
.rest:		mov	byte [dueWest], 0
		sub	word [actorPosX], 40
		and	word [actorPosX], ~7
		retf

;------------------------------------------------------------------------------

eoLadderUpPt:	patch	barb_cseg, 6400h
		call	code:eoLadderUp
		jc	orig_off(6431h)
		jmp	orig_off(640Ch)
		endpatch

eoLadderUp:	cmp	al, 22h
		je	eoLadder
		cmp	al, 2Ah
		je	eoLadder
		cmp	al, 2Ch
		je	eoLadder
		clc
		retf

;------------------------------------------------------------------------------

eoLadderDnPt:	patch	barb_cseg, 6488h
		call	code:eoLadderDn
		jc	orig_off(64BDh)
		jmp	orig_off(6498h)
		endpatch

eoLadderDn:	cmp	al, 22h
		je	eoLadder
		cmp	al, 20h
		je	eoLadder
		cmp	al, 2Dh
		je	eoLadder
		cmp	al, 2Eh
		je	eoLadder
		clc
		retf

;------------------------------------------------------------------------------

eoLadder:	test	word [action], ACTION_LEFT
		jz	.isRight
		mov	byte [dueWest], 1
		sub	word [actorPosX], 8
		jmp	.exit

.isRight:	test	word [action], ACTION_RIGHT
		jz	.exit
		mov	byte [dueWest], 0

		; When run is pending actions left and right must not be
		; cleared, otherwise Barbarian will always run right after
		; leaving the ladder.

.exit:		test	word [action], ACTION_RUN
		jnz	.done
		and	word [action], ~(ACTION_LEFT | ACTION_RIGHT)
.done:		stc
		retf

;------------------------------------------------------------------------------

		patchb	barb_cseg, 6015h, 34h
		patchb	barb_cseg, 601Ah, 33h

stairsDownPt:	patch	barb_cseg, 605Bh
		jmp	orig_off(6065h)
		endpatch

stairsUpPt:	patch	barb_cseg, 6072h
		jmp	orig_off(607Ch)
		endpatch

;------------------------------------------------------------------------------

upOrDownPt:	patch	barb_cseg, 5FF4h
		call	code:upOrDown
		jmp	orig_off(6000h)
		endpatch

upOrDown:	mov	ax, [actorPosX]
		mov	dx, [actorPosY]
		sub	dx, 8
		cmp	byte [dueWest], 1
		je	.west
.east:		cmp	ax, 320
		jnb	.wayIsOpen
		mov	cx, 3
		sub	ax, 2			; fine tuning
.findLadderE:	sub	ax, 8
		call	getRoomMapPnt
		cmp	bl, '*'
		je	.ladderFoundE
		cmp	bl, '-'
		je	.ladderFoundE
		loop	.findLadderE
		mov	ax, [actorPosX]
		jmp	.findStairsE

.ladderFoundE:	add	ax, 16
		jmp	.ladderFoundW

.west:		or	ax, ax
		jz	.wayIsOpen
		js	.wayIsOpen
		mov	cx, 3
.findLadderW:	add	ax, 8
		call	getRoomMapPnt
		cmp	bl, ','
		je	.ladderFoundW
		cmp	bl, '.'
		je	.ladderFoundW
		loop	.findLadderW
		mov	ax, [actorPosX]
		jmp	.findStairsW

.ladderFoundW:	test	word [action], ACTION_UP | ACTION_DOWN
		jz	.coda
		and	ax, ~7
		mov	[actorPosX], ax
		jmp	.coda

.findStairsE:	mov	cx, 4
		sub	ax, 24
.findStELoop:	add	ax, 8
		call	getRoomMapPnt
		cmp	bl, 'A'
		je	.stairsFoundE
		cmp	bl, 'D'
		je	.stairsFoundE
		cmp	bl, 'H'
		je	.stairsFoundE
		loop	.findStELoop
		jmp	.wayIsOpen

.stairsFoundE:	jmp	.ladderFoundW

.findStairsW:	mov	cx, 4
		add	ax, 16			; fine per-pixel tuning
.findStWLoop:	sub	ax, 8
		call	getRoomMapPnt
		cmp	bl, 'B'
		je	.stairsFoundW
		cmp	bl, 'E'
		je	.stairsFoundW
		cmp	bl, 'H'
		je	.stairsFoundW
		cmp	bl, 'J'
		je	.stairsFoundW
		loop	.findStWLoop
		jmp	.wayIsOpen

.stairsFoundW:	add	ax, 8
		jmp	.ladderFoundW

.coda:		sub	bl, 20h
		xor	bh, bh
		retf

.wayIsOpen:	mov	bx, 0
		retf

;------------------------------------------------------------------------------

		; Local version of getRoomMapPoint. It takes xpos in AX
		; and ypos in DX.

getRoomMapPnt:	mov	bx, dx
		sar	bx, 1
		sar	bx, 1
		and	bx, 0FFFEh
		mov	si, ax
		sar	si, 1
		sar	si, 1
		sar	si, 1
		add	si, [arrMapRowOff+bx]
		mov	bl, [roomMap+si]
		retn
