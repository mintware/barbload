;
; Barbarian patch for orientation after leaving ladder
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"
%include "patch.mac"

;------------------------------------------------------------------------------

goLadderUpPt:	patch	barb_cseg, 63BFh, 63C4h
		call 	code:beginLadder
		endpatch

goLadderDnPt:	patch	barb_cseg, 6451h, 6456h
		call 	code:beginLadder
		endpatch

section bss

ladderOrient	resb	1

section code

beginLadder:
		mov	al, [dueWest]
		mov	[cs:ladderOrient], al
		mov	byte [dueWest], 0
		retf

;------------------------------------------------------------------------------

eoLadderUpPt:	patch	barb_cseg, 6431h, 6436h
		call	code:eoLadder
		endpatch

eoLadderDnPt:	patch	barb_cseg, 64BDh, 64C0h
		jmp	orig_off(6431h)
		endpatch

eoLadder:
		cmp	word [movement], 6 ; ladderUp
		jne	.restoreOrient
		sub	byte [actorPosY], 4

.restoreOrient:	mov	al, [cs:ladderOrient]

		; Turning after leaving ladder is just stupid, so let's
		; tune dueWest according to further movement if ACTION_LEFT
		; or ACTION_RIGHT is pending.

		test	word [action], ACTION_LEFT
		jz	.isRight
		mov	al, 1
		jmp	.coda

.isRight:	test	word [action], ACTION_RIGHT
		jz	.coda
		mov	al, 0
.coda:		mov	[dueWest], al
		cmp	al, 1
		jne	.exit
		sub	word [actorPosX], 8
.exit:		retf

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
