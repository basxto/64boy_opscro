
COMPO & PLATFORMS
=================

This is for the combined 64B compo of lovebyte2021.
Target platforms are the classic Game Boy (DMG), Super Game Boy (SGB) and Game Boy Color (CGB).


WHAT RUNS WHERE
===============

64boy_opscro.fixedheader.gb is 32KiB (64B ROM + valid headers + lots of 0xFF) with enough flags set to run on hopefully all dmg, sgb and cgb emulators as well as the real hardware with flashcards.
It was tested on [SameBoy][], [Emulicious][], [BGB][] and on CGB with [EVERDRIVE GB X3][edgbx3].

64boy_opscro.min.gb is only 64B, this will run on Emulicious and on SameBoy if it's set to DMG mode. This can't run on hardware because the headers are missing.


WHY 32KiB
=========

32KiB of the ROM are memory mapped for the Game Boy, everything smaller isn't well defined.
Programs start at 0x100, which is also seen as the start of the "header" (as defined by [gbdev pandocs][doc]).
The "header" goes until 0x014F, consecutively BGB refuses to run ROMs smaller than 337B.
But this "header" isn't the header, I consider for "given that the header is not larger than the intro itself".
I only set 55B, the rest is in a don't care state and could be overwritten with random bytes, just the checksum would need to be updated in such a case.
I set 0x100 to `rst $38` to call 0x38, which is my real starting address.
I set the full nintendo logo 0x104-0x133 as well as the header checksum 0x14D, since the DMG bootrom will refuse to load the ROM otherwise.
Furthermore I set CGB (0x143 to enabled) and SGB (0x146 to disabled) flag.
Those are all bytes which are checked/needed by the hardware.
I furthermore set cartridge type (0x147), ROM size (0x148), RAM size (0x149) so that emulators/flashcarts know which cartridges to emulate.

If you have gnu coreutils, gnu make, dd and [rgbfix][] installed, you can recreate 64boy_opscro.fixedheader.gb from 64boy_opscro.mini.gb with `make 64boy_opscro.fixedheader.gb`.


HOW 64B ROM WORK
================

It assumes the emulator fills the rest of the ROM with 0xFF, which Emulicious and SameBoy do and I would expect an embty flashcart to be all 0xFF, so it look similar if only the first 64B are overwritten.
The program starts at 0x100 which will do `rst $38` (machine code 0xFF) and therefore jump into the first 64B.
CGB flag will be set to 0xFF, which turns CGB into non-CGB mode (all palettes white and can't changed), which makes it only run on DMG/SGB


PITFALLS
========

Targeting three systems with different bootroms was certainly not a good idea.
There isn't much, I can rely on, I use that they all set the upper tiles to all white, that's pretty much it.
Targeting DMG makes it necessary to wait for vblank to turn ofo the display.
Targeting CGB in CGB mode makes it neccessary to set up a palette, since it sets everything to white.
CGB in DMG mode would've made the header to big since it chooses colors depending on the checksum byte, whose value again depends on 24 other bytes.
Being in CGB mode therefore only requires the checksum byte to be a correct checksum, but not to be have any certain value, which again  makes the other 24 bytes don't care.
This all resulted in focusing on value reusage and interpreting machine code as graphics.
64B are equal to 4 uncompressed 2BPP Game Boy tiles.


[SameBoy]: https://sameboy.github.io/
[Emulicious]: https://emulicious.net/
[BGB]: https://bgb.bircd.org/
[edgbx3]: https://everdrive.me/cartridges/edgbx3.html
[doc]: https://gbdev.io/pandocs/#the-cartridge-header
[rgbfix]: https://rgbds.gbdev.io/docs/v0.4.2/rgbfix.1