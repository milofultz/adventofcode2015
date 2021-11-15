include "64cube.inc"

enum $00
  memory rBYTE 2
  floor rBYTE 1
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  _setw IRQ, VBLANK_IRQ

  lda #0
  sta floor
  sta memory
  tax
  tay
  lda #$20
  sta memory + 1

  cli


FindFloor:
  lda ($00),y                   ; Load value at address $00yy into accumulator
  beq Infinite                  ; If end of input stream is reached, end loop

  cmp #$28                      ; If character is an opening parentheses:
  beq IncrementFloor            ;   Goto IncrementFloor

  DecrementFloor:
  dec floor                     ; Decrement floor
  ; These three instructions should be activated for Part 2 only
  lda floor
  cmp #$ff                      ; If we enter the "basement" ($ff):
  beq Infinite                  ;   Goto end
  jmp NextFloor                 ; Goto NextFloor

  IncrementFloor:
  inc floor                     ; Increment Floor

  NextFloor:
  inc memory                    ; Increment first byte of `memory`
  beq IncrementHighMemory       ; If first byte of `memory` goes $ff -> $00,
                                ;   Goto IncrementHighMemory
  jmp FindFloor                 ; Else, goto FindFloor

  IncrementHighMemory:
  inc memory + 1                ; Increment second byte of `memory`
  jmp FindFloor                 ; Goto FindFloor

Infinite:
  jmp Infinite

IRQ:
  rti

  org $2000
  ;incbin "roms/aoc2015/01/ins1.raw"
  ;incbin "roms/aoc2015/01/ins2.raw"
  incbin "roms/aoc2015/01/in.raw"
