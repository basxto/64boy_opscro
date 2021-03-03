# what emulators use to PADDING
# it's also RST $38
PADDING = 0xFF

RGBDS = 
AS = $(RGBDS)rgbasm
ASFLAGS = -p $(PADDING)
LD = $(RGBDS)rgblink
LDFLAGS = -p $(PADDING)
DD = dd

.PHONY: all clean
all: main.micro.gb


%.gb: %.o
	$(LD) $(LDFLAGS) -o $@ $<

%.micro.gb: %.gb
	$(DD) if=$< of=$@ bs=1 count=64

clean:
	$(RM) *.gb *.o