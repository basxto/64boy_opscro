# what emulators use to PADDING
# it's also RST $38
PADDING = 0xFF

RGBDS = 
AS = $(RGBDS)rgbasm
ASFLAGS = -p $(PADDING)
LD = $(RGBDS)rgblink
LDFLAGS = -p $(PADDING)
DD = dd
RGBFIX = $(RGBDS)rgbfix

.PHONY: all clean
all: 128boy_opscro.min.gb


%.gb: %.o
	$(LD) $(LDFLAGS) -n $*.sym -m $*.map -o $@ $<

128boy_opscro.gb: main.gb
	cp $^ $@
	cp main.sym 128boy_opscro.sym
	cp main.map 128boy_opscro.map


%.min.gb: %.gb
	$(DD) if=$< of=$@ bs=1 count=337
	cp $*.sym $*.min.sym
	cp $*.map $*.min.map

# Just increase size and fill with $FF
%.padded.gb: %.min.gb
	$(DD) if=/dev/zero ibs=1 count=32KiB | tr "\000" "\377" > "$@"
	$(DD) if="$^" of="$@" conv=notrunc
	cp $*.min.sym $*.padded.sym
	cp $*.min.map $*.padded.map

# Fix the header
%.fixedheader.gb: %.padded.gb
	cp $*.padded.sym $*.fixedheader.sym
	cp $*.padded.map $*.fixedheader.map
	cp "$^" "$@"
# 0x100 (rst $38): 1B
# We assume everything being $FF
# but this really *has to* be $FF
# Effectively sets starting address
#	printf "\377" | $(DD) of="${@}" bs=1 seek=$$((0x100)) conv=notrunc
# Random data can render it unplayable:
# cgb flag: 1B
	printf "\200" | $(DD) of="${@}" bs=1 seek=$$((0x143)) conv=notrunc
# Do not accidentially enable SGB:
# sgb flag: 1B
# Those three are just for
# emulators and flashcarts:
# cartridge type: 1B
# rom size: 1B
# ram size: 1B
	printf "\0\0\0\0" | $(DD) of="${@}" bs=1 seek=$$((0x146)) conv=notrunc
# logo: 48B
# checksum: 1B
	$(RGBFIX) -f lh $@
# total: 55B

%.zip: %.fixedheader.gb %.min.gb
	zip $@ $^ $*.min.gb Makefile README.md FILE_ID.DIZ screenshot.png screencap.mp4

clean:
	$(RM) *.gb *.o *.sym *.map *.zip