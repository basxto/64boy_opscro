INCLUDE "hardware.inc/hardware.inc"

SECTION "Entry Point", ROM0[$38]
    ; we assume $FF at $100
init:
    ; must be >=144
    ; should be 0xX1 for nicer numbers later
    ld b, $91
    ; make sure to be in mode 1
    ; to not damage DMG's display
    rst waitly
    ; returns with A=0
    ; set palette index #0
    ldh [rBCPS], a
    ld h, b
    ; we are at the end of 64B
    jr main

SECTION "MAIN", ROM0[$11]
main:
    ; a: $00
    ; b: $90
    ; c: $91
    ; registers are at ^^^
    ; write first byte of first color
    ; of first cgb palette
    ; palette is assumed to be set all white
    ; by bootrom
    ldh [rBCPD], a
    ; turn off LCD, we are still in vblank
    ; makes later vram access easier
    ldh [rLCDC], a
    
    ; destination hl=0x9000
    ;ld h, b ; loaded at entry point
    ld l, a
    ; source de=0x0000
    ld d, a
    ld e, a
    ; amount b is still set 0x90
    ; copies whole code as tiles and a bit more
    rst vmemcpy
    ; set up tilemap
    ld h, $98 
    ;ld a, 12
    ; we can't assume it being $FF
    xor a
    ; b is set to 0
    rst alternator
    rst alternator
    ; enable stat
    ld a, LCDCF_ON | LCDCF_BGON
    ldh [rLCDC], a
    ; prepare later inc [hl]
    ld hl, rSCX
.infloop:
    ; run the loop <b> times
    ; exits on LY=1
    ld b, l ; l = $43
.waitloop:
    rst waitly
    ; b got decreased
    jr NZ, .waitloop
    ; just scroll background
    dec [hl]
    dec hl ; rSCX
    inc [hl]
    inc hl ; rSCY
    ; just loop infinitely
    jr .infloop

SECTION "WAITLY", ROM0[$30]
    ; wait for rLY == B
    ; returns with A = C = 0
waitly:
    ldh a, [rLY]
    sub b
    jr NZ, waitly
    ld c, b
    dec b
    ret

SECTION "ALT", ROM0[$0]
; hl: destination
; de: source
; b: amount (0 is 256 times)
alternator:
    inc a
    ld [hl+], a ; 1
    cpl
    ld [hl+], a ; 1
    dec b ; 1
    jr NZ, alternator ; 2
    ret ; 1

SECTION "VMEMCPY", ROM0[$8]
; hl: destination
; de: source
; b: amount (0 is 256 times)
vmemcpy:
.loop:
    ; read
    ld a, [de] ; 1
    inc de ; 1
    ; write as 1BPP
    ld [hl+], a ; 1
    ld [hl+], a ; 1
    dec b ; 1
    ; loop while b != 0
    jr NZ, .loop ; 2
    ; clean up l
    ld  l, b
    ret ; 1

SECTION "limit64B", ROM0[$40]
    rst $38 ; padding value
    ; just for warnings when $38 gets too long