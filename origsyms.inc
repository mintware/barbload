;
; Original symbols of Barbarian
;
; Copyright (c) 2016 Vitaly Sinilin
;

barb_cseg	equ	0000h
barb_dseg	equ	08CEh

; barb_cseg

dropBow		equ	54D4h
dropShield	equ	54ACh

getRoomMapPoint	equ	5F17h

beginStairsUp	equ	6244h
beginStairsDown	equ	62CEh
beginTurning	equ	67F5h
step		equ	6E2Ah

ladderDownWest	equ	6E59h

; barb_dseg

pressedKey	equ	084Eh
trapInt9	equ	0867h
arrMapRowOff	equ	0901h
siblingOffset	equ	8E74h
room		equ	8E79h
ctrlMode	equ	8E86h
action		equ	8E87h
arrActorPosX	equ	8ED4h
arrActorPosY	equ	8EDCh
actorPosX	equ	8E8Dh
actorPosY	equ	8E8Fh
activeWeapon	equ	8F52h
isCrystalDestd	equ	8F54h
hasCrystal	equ	8F58h
dueWest		equ	8F57h
isDragonDead	equ	8F5Ch
roomMap		equ	8FC2h
word_21FEB	equ	930Bh
roomRespawnPosX	equ	96DFh
roomRespawnPosY	equ	9718h
arrEnemy1	equ	9751h
roomEnterPosX	equ	0A36Fh
roomEnterPosY	equ	0A371h
animation	equ	0A37Ch
movement	equ	0A380h

mapPointAbove5	equ	0A38Ch
mapPointAbove4	equ	0A38Dh
mapPointAbove3	equ	0A38Eh
mapPointAbove2	equ	0A38Fh
mapPointAbove1	equ	0A390h
mapPoint	equ	0A391h
mapPointBelow1	equ	0A392h

getRoomMapX	equ	0A393h
getRoomMapY	equ	0A395h

; enums

ACTION_UP	equ	1
ACTION_DOWN	equ	2
ACTION_RIGHT	equ	4
ACTION_LEFT	equ	8
ACTION_ATTACK	equ	10h
ACTION_JUMP	equ	20h
ACTION_RUN	equ	40h
ACTION_BLOCK	equ	80h
ACTION_PANIC	equ	100h
ACTION_TAKE	equ	200h
ACTION_SELECT	equ	400h
ACTION_DROP	equ	800h
ACTION_SWORD	equ	1400h
ACTION_BOW	equ	2400h
ACTION_SHIELD	equ	4400h
