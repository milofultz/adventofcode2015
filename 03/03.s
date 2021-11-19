include "64cube.inc"

enum $00                        ; Declare memory for variables
  coordX rBYTE 2                ; Current coordinates
  coordY rBYTE 2
  uniqueCoords rBYTE 2          ; Pointer at start of array memory
  coordsLength rBYTE 2          ; Number of discrete coordinates (total * 4)
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  _setw IRQ, VBLANK_IRQ

  lda #0                        ; Init coordinatess to [0, 0]
  tax
  tay
  sta coordX
  sta coordX + 1
  sta coordY
  sta coordY + 1
  sta coordsLength
  sta uniqueCoords
  lda #2
  sta coordsLength + 1
  lda #$40
  sta uniqueCoords + 1

  cli

; PROGRAM

; 5e = ^
; 76 = v
; 3c = <
; 3e = >

;
; Tests for Helper Functions
;

  ; GetNextCoord
  lda #0
  tax
  tay
  sta coordX
  sta coordX + 1
  sta coordY
  sta coordY + 1
  sta coordsLength
  sta uniqueCoords
  lda #2
  sta coordsLength + 1
  lda #$40
  sta uniqueCoords + 1

  lda #$5e                      ; Up ^
  sta $4000
  lda #$3e                      ; Right >
  sta $4001
  lda #$76                      ; Down v
  sta $4002
  lda #$3c                      ; Left <
  sta $4003

  jsr GetNextCoord
  lda coordY
  cmp #1
  bne ERROR
  jsr GetNextCoord
  lda coordX
  cmp #1
  bne ERROR
  jsr GetNextCoord
  lda coordX
  cmp #0
  bne ERROR
  jsr GetNextCoord
  lda coordY
  cmp #0
  bne ERROR

  jmp Infinite

ERROR:
  jmp ERROR

Infinite:
  jmp Infinite

;
; Helper Functions
;

IRQ:
  rti

  org $a000
  ;incbin "roms/aoc2015/03/ins1.raw"
  ;incbin "roms/aoc2015/03/ins2.raw"
  ;incbin "roms/aoc2015/03/ins3.raw"
  incbin "roms/aoc2015/03/in.raw"
