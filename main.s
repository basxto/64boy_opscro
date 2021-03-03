INCLUDE "hardware.inc/hardware.inc"

SECTION "Entry Point", ROM0[$38]
    ; we assume $FF at $100
    ; and this is sadly the longest section available
init:
    di
    ; just wait 1 vblank
    ;ld b, $1
    ; we expect B to be 0
    ;inc b
    ; 
    ;ld c, LOW(rLY)
    ; must be >=144
    ; should be 0xX1 for nicer numbers later
    ld b, $91
    ; make sure to be in mode 1
    ; to not damage DMG's display
    ;call waitvblank
    rst $30
    ; returns with B=A=0
    ;xor a
    ; that is not the best setting
    ; disable 
    ;ldh [rLCDC], a
    ldh [rBCPS], a
    ; do I ven need to set this?
    ;ldh [rBCPS], a
    ; source (de)
    ;ld d, a ; still 0x00
    ;ld e, a ; still 0x00
    jr main


SECTION "MAIN", ROM0[$14]
main:
    ;ldh [rBCPS], a
    ldh [rBCPD], a
    ldh [rLCDC], a
    ;ldh [rBCPS], a
    ;ld c, LOW(rLCDC)
    
    ; fully disable display
    ; no need for wasting time on checking stat
    
    ;ldh [rLCDC], a
    ; destination
    ;;inc de
    ;ld hl, $8000
    ld h, b ; 0x90
    ld l, a
    ld d, a ; still 0x00
    ld e, a ; still 0x00
    ; amount
    ; copies whole code and a bit more
    ;ld b, h
    ; <b> is still at 0x90 from before =)
    ;;ld hl, images
    rst $8 ;call vmemcpy
    ;ld d, $80
    ;rst $8 ;
    ;halt
    ; write a solid block to hl
    ;dec a; set it $FF; was $00 before
    ;;ld a, h
    ;;ld b, h
    ;;rst $0 ; call alternator

    ;ld e, d
    ;ld b, h
    ;rst $8 ;call vmemcpy
    ;ld a, h
    ; l should be 0 again
    ld h, $98 
    ;dec a;, $h
    ; set palette
    ;ldh [rBCPD], a
    ;xor a
    ;ld b, $FF
    ;dec b ; set $FF
    ;;ld a, 12
    ; b is set to 0
    ;rst $0 ; call alternator
    ;dec b ; set $FF
    ;rst $0 ; call alternator

    ;ld c, LOW(rBCPS)
    ;ld a, BCPSF_AUTOINC
    ;ldh [rBCPS], a
    ; just loop
	;rst $30
    ;ld hl, rLY
    ; we want to catch VBlank
    ; 143-144 sets carry flag
    ;ld a, 143
    ; enable stat
    ld a, LCDCF_ON | LCDCF_BGON ;  | LCDCF_BG8000
    ;ldh [rBCPS], a
    ;ldh [rBCPD], a
    ;ld c, LOW(rBCPS)
    ;ldh [c], a
    ;inc c
    ;ldh [c], a
    ldh [rLCDC], a
    ; vv probably can't be smaller
    ; prepare later inc [hl]
    ld hl, rSCX
.infloop:
    ; run the loop <b> times
    ; exits on LY=0
    ; b is just assumed to be 0
    ld b, l ; l = $43
    ;ld c, LOW(rLY)
.waitloop:
    rst $30
    ;dec b
    jr NZ, .waitloop
    ;call waitvblank
    ; just scroll background
    inc [hl]
    dec hl ; rSCX
    inc [hl]
    inc hl ; rSCY
    ; just loop infinitely
    jr .infloop
SECTION "WAITVBLANK", ROM0[$30]
    ; waits for <b> vblanks
    ; returns at the END of VBlank
    ; when rLY becomes 0
    ; afaik it switches too early to 0
    ; and is still in mode 1
    ; expects c=LOW(rLY)
    ; returns with A = 0
waitvblank:
    ;ldh a, [c]
    ldh a, [rLY]
    ;cp 144
    sub b
    jr NZ, waitvblank
    dec b
    ;jr NZ, waitvblank
    ;jr NZ, waitvblank
    ret

;.infloop:
;    ld b, l ; l = $43
;.wait:
;    ldh a, [rLY]
;    cp b
;    jr NZ, .wait
;    dec b
;    jr NZ, .wait

SECTION "ALT", ROM0[$0]
; hl: destination
; de: source
; b: amount (0 is 256 times)
alternator:
    ld [hl+], a ; 1
    ;rrca ; 1
    ;dec a
    cpl
    ld [hl+], a ; 1
    ;rlca ; 1
    ;inc a
    cpl
    dec b ; 1
    jr NZ, alternator ; 2
    ret ; 1
SECTION "VMEMCPY", ROM0[$8]
vmemcpy:
    ; mem copy should go here one day
	;jr vmemcpy
    ; for now just load constants
    ld a, [de] ; 1
    inc de ; 1
    and %11111100 ; 2
    ld [hl+], a ; 1
    ld [hl+], a ; 1
    ld [hl+], a ; 1
    ld [hl+], a ; 1
    dec b ; 1
    jr NZ, vmemcpy ; 2
    ret ; 1
    ; 6 unused bytes


vmemcpy2:
;    ld c, %00010001 ; filter
;    ld a, [de] ; 1
;    ld [hl+], a ; 1
;    dec b ; 1

;.loop:
    ; read next tile
;    ld a, [de]
;    inc de
;    ld b, a
;.tileloop:
    ; filter for the bits who are used for pixel row
    ; XXXXBXA
    ;and a, %00000101
;    and a, %00001111 ; new
;    ld c, a
;    ;rlca
;    ;or c ; XXXXBBAA
;    ;ld c, a
;    swap a ; BBAAXXXX
;    or c ; BBAABBAA
;    and %11111100
;    ;\> BBAABB00
;    ; write it four times (two pixel rows)
;    ld [hl+], a
;    ld [hl+], a
;    ld [hl+], a
;    ld [hl+], a
;    ; shift b >>2
;    ld a, b
;    ;rrca
;    ;rrca
;    swap a
;    ld b, a
; ^ 8B too big ;/
;    dec d ; what register to use here?
;    bit 0, d
;    jr NZ, .tileloop

SECTION "limit64B", ROM0[$40]
    rst $38 ; padding value
    ; just for warnings when $38 gets too long