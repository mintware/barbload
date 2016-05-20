;
; Barbarian patch for respawning position in the room
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"
%include "patch.mac"

;------------------------------------------------------------------------------

		; Prevent reading last symbol of the previous row of the map
		; when approaching off the screen from the west

;getCurMapColPt:	patch	barb_cseg, 5E97h
;		sub	ax, 8			; originally sub was after
;		jz	orig_off(5EF3h)		; jumps
;		js	orig_off(5EF3h)
;		endpatch

getRoomMapColPt:patch	barb_cseg, 5E72h
		cmp	byte [dueWest], 1
		jnz	short .east
		jmp	short .west

.east:		mov	ax, [actorPosX]
		cmp	ax, 320
		jb	short .initEast
		mov	ax, 319
.initEast:	mov	[getRoomMapX], ax
		mov	ax, [actorPosY]
		sub	ax, 48
		mov	[getRoomMapY], ax
		jmp	.get

.west:		mov	ax, [actorPosX]
		sub	ax, 8
		jns	short .initWest
		mov	ax, 0
.initWest:	mov	[getRoomMapX], ax
		mov	ax, [actorPosY]
		sub	ax, 48
		mov	[getRoomMapY], ax

.get:		call	orig_off(getRoomMapPoint)
		mov	[mapPointAbove5], al
		add	word [getRoomMapY], 8
		call	orig_off(getRoomMapPoint)
		mov	[mapPointAbove4], al
		add	word [getRoomMapY], 8
		call	orig_off(getRoomMapPoint)
		mov	[mapPointAbove3], al
		add	word [getRoomMapY], 8
		call	orig_off(getRoomMapPoint)
		mov	[mapPointAbove2], al
		add	word [getRoomMapY], 8
		call	orig_off(getRoomMapPoint)
		mov	[mapPointAbove1], al
		add	word [getRoomMapY], 8
		call	orig_off(getRoomMapPoint)
		mov	[mapPoint], al
		add	word [getRoomMapY], 8
		call	orig_off(getRoomMapPoint)
		mov	[mapPointBelow1], al
		retn
		endpatch

;------------------------------------------------------------------------------

initPosPt:	patch	barb_cseg, 56CEh, 56D4h
		call	code:initPos
		endpatch

initDueWest	db	0
initPosX	dw	20 << 3
initPosY	dw	18 << 3
initSiblingOff	db	0
initRoom	db	0

initPos:	mov	[arrActorPosX], ax
		mov	[actorPosX], ax

		push	ax
		mov	ax, [cs:initPosX]
		mov	[arrActorPosX], ax
		mov	[actorPosX], ax
		mov	ax, [cs:initPosY]
		mov	[arrActorPosY], ax
		mov	[actorPosY], ax

		mov	al, [cs:initDueWest]
		mov	[dueWest], al

		mov	al, [cs:initSiblingOff]
		mov	[siblingOffset], al

		pop	ax
		retf

;------------------------------------------------------------------------------

storeOrientPt:	patch	barb_cseg, 5C54h, 5C59h
		call	code:storeOrient
		endpatch

storeOrient:	dec	al
		mov	byte [room], al
		push	bx
		push	ax
		mov	bl, al
		xor	bh, bh

		; Room 15 needs special handling since respawn points
		; should be different under different circumstances

		cmp	al, 15				; room 15
		jne	.enter
		cmp	byte [movement], 10		; falling
		jne	.store
		mov	byte [roomRespawnPosX+bx], 14	; room for respawn +1
		mov	byte [roomRespawnPosY+bx], 0	; rewind flag
		jmp	.coda

.enter:		cmp	byte [roomRespawnPosY+bx], 0	; don't touch not
		je	.coda				; respawnable rooms

.store:		mov	ax, [roomEnterPosX]
		mov	cl, 3
		shr	ax, cl
		mov	[roomRespawnPosX+bx], al
		mov	ax, [roomEnterPosY]
		shr	ax, cl
		mov	[roomRespawnPosY+bx], al

		mov	al, [dueWest]
		mov	[cs:initDueWest], al
		mov	al, [siblingOffset]
		mov	[cs:initSiblingOff], al

.coda:		pop	ax
		pop	bx
		retf

;------------------------------------------------------------------------------

storePosPt:	patch	barb_cseg, 607Fh
		call	code:storePos
		jnz	orig_off(6097h)
		retn
		endpatch

storePos:	mov	bl, byte [room]
		cmp	bl, byte [cs:initRoom]
		je	.coda				; same room

		xor	bh, bh
		cmp	byte [roomRespawnPosY+bx], 0	; don't touch not
		je	.coda				; respawnable rooms

		mov	al, [dueWest]
		mov	[cs:initDueWest], al
		mov	ax, [actorPosX]
		mov	[cs:initPosX], ax
		mov	ax, [actorPosY]
		mov	[cs:initPosY], ax
		mov	[cs:initRoom], bl

.coda:		cmp	byte [dueWest], 0
		jne	.chkRight
		test	word [action], ACTION_LEFT
		retf
.chkRight:	test	word [action], ACTION_RIGHT
		retf
