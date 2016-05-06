;
; Pointers to original Barbarian procedures
;
; These pointers are relocated after loading Barbarian into memory
; and can be used for far jmp to original Barbarian labels from loader's
; code segment.
;
; Copyright (c) 2016 Vitaly Sinilin
;

extern p_procCtrlAction
extern p_procCtrlFastAction
extern p_procCtrlState
