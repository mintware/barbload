;
; Barbarian patch for handy controls
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"
%include "patch.mac"

		; Disable special handling of reused keys in int 09h handler

		patchw	barb_dseg, 718h, 0	; Enter
		patchw	barb_dseg, 752h, 0	; SpaceBar
		patchw	barb_dseg, 770h, 0	; UpArrow
		patchw	barb_dseg, 776h, 0	; LeftArrow
		patchw	barb_dseg, 77Ah, 0	; RightArrow
		patchw	barb_dseg, 780h, 0	; DownArrow

		; Tune scancode mapping for new keys. New virtual keys 90h..9Fh
		; were invented instead of existing 80h..8Fh keys, because
		; the latter change their meaning depending on the panel mode.

		patchb	barb_dseg, 552h, 9Ch	; Backspace
		patchb	barb_dseg, 554h, 94h	; Q
		patchb	barb_dseg, 555h, 95h	; W
		patchb	barb_dseg, 556h, 96h	; E
		patchb	barb_dseg, 557h, 98h	; R
		patchb	barb_dseg, 558h, 99h	; T
		patchb	barb_dseg, 560h, 9Ah	; Enter
		patchb	barb_dseg, 57Dh, 97h	; SpaceBar
		patchb	barb_dseg, 58Ch, 91h	; UpArrow
		patchb	barb_dseg, 58Fh, 90h	; LeftArrow
		patchb	barb_dseg, 591h, 93h	; RightArrow
		patchb	barb_dseg, 594h, 92h	; DownArrow

		; Let Tab switch panel modes instead of SpaceBar

		patchw	barb_dseg, 6FEh, 20h	; Tab

		; Originally keys with ASCII values weren't looked up in
		; the remapping table, but we need to remap QWERT, so let's
		; disable instructions that passes ASCII values as is.

		patchw	barb_cseg, 0ECFh, 9090h

		; Unfortunately the remapping table doesn't contain entries
		; for some keys that will be looked up in it after the patch
		; above. So we need to enrich the table.

		; We need number keys to switch weapon, but they are already
		; used in menus, so we can't just map them to new 9Dh..9Fh
		; virtual keys.

asciiKeys:	patch	barb_dseg, 545h
		db	1Bh			; Escape
		db	'1'
		db	'2'
		db	'3'
		db	'4'
		endpatch


procCtrl:	patch	barb_cseg, 4CB2h, 4CB8h
		call	code:newProcCtrl
		endpatch


newProcCtrl:
		mov	byte [word_21FEB], 1
		mov	al, [pressedKey]

.key1:		cmp	al, '1'
		jne	.key2
		mov	ax, 13 ; sword
		jmp	.knownKey
.key2:		cmp	al, '2'
		jne	.key3
		mov	ax, 14 ; bow
		jmp	.knownKey
.key3:		cmp	al, '3'
		jne	.newkeys
		mov	ax, 15 ; shield
		jmp	.knownKey

.newkeys:	cmp	al, 90h
		jb	.exit
		cmp	al, 9Fh
		jnb	.exit
		and	ax, 0Fh

.knownKey:	mov	byte [pressedKey], 0

		pop	dx			; Remove return offset from
		mov	dx, 4DCCh		; stack and push new address.
		push	dx			;
.exit:		retf
