TLINK = tlink
NASM = nasm
PKZIP = pkzip
EHOPT = ehopt # comment out this line if ehopt isn't available on your system
META = http://sinil.in/mintware/barbarian/

progs = barbfix.exe barbenh.exe
dist = barbload.zip

!if $d(DEBUG)
debug_obj = debug.obj
!endif

obj_fix = \
	begin.obj \
	barbload.obj \
	do_patch.obj \
	room39.obj \
	room56.obj \
	weapon.obj \
	crystal.obj \
	end.obj

obj_enh = \
	begin.obj \
	barbload.obj \
	do_patch.obj \
	controls.obj \
	room39.obj \
	room56.obj \
	respawn.obj \
	ladder.obj \
	weapon.obj \
	dragon.obj \
	stairs.obj \
	crystal.obj \
	$(debug_obj) \
	end.obj

obj = $(obj_fix) $(obj_enh)

all: $(progs)

barbfix.exe: $(obj_fix)
	$(TLINK) /s /Tde @&&!
	$**
	$@
!
!if $d(EHOPT)
	$(EHOPT) $@ $*.opt "$(META)"
	del $@
	rename $*.opt $@
!endif

barbenh.exe: $(obj_enh)
	$(TLINK) /s /Tde @&&!
	$**
	$@
!
!if $d(EHOPT)
	$(EHOPT) $@ $*.opt "$(META)"
	del $@
	rename $*.opt $@
!endif

.asm.obj:
	$(NASM) -f obj -p common.inc -o $@ -l $&.lst $<

$(obj): common.inc

dist: $(dist)

$(dist): $(progs)
	$(PKZIP) $@ $**

clean:
	del *.obj
	del *.lst
	del *.map
	del *.exe
	del $(dist)
