;
; Pointers to original Barbarian procedures
;
; These pointers are relocated after loading Barbarian into memory
; and can be used for far jmp to original Barbarian labels from loader's
; code segment.
;
; Copyright (c) 2016 Vitaly Sinilin
;

%include "origsyms.inc"

global p_procCtrlAction
global p_procCtrlFastAction
global p_procCtrlState

section orig_ptrs

p_procCtrlAction	handy_far_ptr	barb_cseg,	04CD5h
p_procCtrlFastAction	handy_far_ptr	barb_cseg,	04DCCh
p_procCtrlState		handy_far_ptr	barb_cseg,	04CF1h
