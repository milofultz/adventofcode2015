include "64cube.inc"

enum $00                        ; Declare memory for variables
  memory rBYTE 2                ; Pointer at memory holding the input characters
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
  sta memory
  lda #2
  sta coordsLength + 1
  lda #$40
  sta uniqueCoords + 1
  lda #$a0
  sta memory + 1

  cli

; PROGRAM

; 5e = ^
; 76 = v
; 3c = <
; 3e = >

;
; Tests for Helper Functions
;

;  ; GetNextCoord
;
;  ; Test Overflow
;  lda #$5e                      ; Up ^
;  sta $a000
;  lda #$3e                      ; Right >
;  sta $a001
;  lda #$76                      ; Down v
;  sta $a002
;  lda #$3c                      ; Left <
;  sta $a003
;  ; Test Underflow
;  lda #$76                      ; Down v
;  sta $a004
;  lda #$3c                      ; Left <
;  sta $a005
;  lda #$5e                      ; Up ^
;  sta $a006
;  lda #$3e                      ; Right >
;  sta $a007
;  ; Finish
;  lda #0                        ; End of input (null)
;  sta $a008
;
;  ; Test Overflow
;
;  lda #0
;  tax
;  tay
;  sta coordX
;  sta coordY
;  lda #$ff
;  sta coordX + 1
;  sta coordY + 1
;
;  jsr GetNextCoord
;  lda coordY
;  cmp #1
;  bne TestFailed
;  lda coordY + 1
;  bne TestFailed
;  jsr GetNextCoord
;  lda coordX
;  cmp #1
;  bne TestFailed
;  lda coordX + 1
;  bne TestFailed
;  jsr GetNextCoord
;  lda coordY
;  bne TestFailed
;  lda coordY + 1
;  cmp #$ff
;  bne TestFailed
;  jsr GetNextCoord
;  lda coordX
;  bne TestFailed
;  lda coordX + 1
;  cmp #$ff
;  bne TestFailed
;
;  ; Test Underflow
;
;  lda #0
;  tax
;  tay
;  sta coordX
;  sta coordY
;  sta coordX + 1
;  sta coordY + 1
;
;  jsr GetNextCoord
;  lda coordY
;  cmp #$80
;  bne TestFailed
;  lda coordY + 1
;  cmp #$ff
;  bne TestFailed
;  jsr GetNextCoord
;  lda coordX
;  cmp #$80
;  bne TestFailed
;  lda coordX + 1
;  cmp #$ff
;  bne TestFailed
;  jsr GetNextCoord
;  lda coordY
;  bne TestFailed
;  lda coordY + 1
;  bne TestFailed
;  jsr GetNextCoord
;  lda coordX
;  bne TestFailed
;  lda coordX + 1
;  bne TestFailed
;
;  jmp TestPassed

  ; isUniqueCoord
  lda #0
  sta coordX
  sta coordY
  lda #1
  sta coordX + 1
  sta coordY + 1
  lda #4
  sta coordsLength

  jsr isUniqueCoord
  cpx #0
  bne TestFailed

  jmp TestPassed

TestFailed:
  jmp TestFailed

TestPassed:
  jmp TestPassed

;
; Helper Functions
;

Infinite:
  jmp Infinite

isUniqueCoord:
  ; IN:  uniqueCoords (pointer), coordsLength (pointer), coordX/coordY
  ; OUT: X as boolean

  ldx #0
  rts

GetNextCoord:
  ; IN:  memory (address)
  ; OUT: none (changed coordX/coordY)

  ldy #0
  lda (memory),y                   ; Load memory pointer into the accumulator
  beq Infinite                  ; If end of input is reached, end program
  cmp #$76                      ; Else if character is `v`,
  beq DecrementCoordY           ;   Decrement coordY
  cmp #$5e                      ; If character is `^`,
  beq IncrementCoordY           ;   Increment coordY
  cmp #$3c                      ; If character is `<`,
  beq DecrementCoordX           ;   Decrement coordX
                                ; Else if character is `>`, increment coordX
  ; IncrementCoordX
  inc coordX + 1
  bne NextCoordSet              ; If increment didn't overflow, continue
  lda coordX
  sec
  sbc #$80
  beq SetCoordXPositive         ; If coordX MSD is exactly #$80, flip polarity
  bcs DecrementCoordYMSD        ; Else if value's above #$80, decrement MSD
  IncrementCoordXMSD:
  inc coordX
  jmp NextCoordSet
  SetCoordXPositive:
  lda #0
  sta coordX
  jmp NextCoordSet

  DecrementCoordX:
  dec coordX + 1                ; Decrement coordX LSD
  lda #$ff
  cmp coordX + 1                ; If decrement didn't underflow coordX LSD,
  bne NextCoordSet              ;   Continue
  lda coordX
  beq SetCoordXNegative         ; If coordX MSD is zero, flip the polarity
  sec
  sbc #$80
  bcs IncrementCoordXMSD        ; Else if coordX MSD is already negative,
                                ;   Increment coordX MSD
  DecrementCoordXMSD:
  dec coordX                    ; Else, coordX MSD is positive, so increment it
  jmp NextCoordSet
  SetCoordXNegative:
  lda #$80
  sta coordX                    ; Set coordX to #$80 as polarity bit
  jmp NextCoordSet

  IncrementCoordY:
  inc coordY + 1
  bne NextCoordSet              ; If coordY doesn't overflow, continue
  lda coordY
  sec
  sbc #$80
  beq SetCoordYPositive         ; If coordY MSD is exactly #$80, flip polarity
  bcs DecrementCoordYMSD        ; Else if value's above #$80, decrement MSD
  IncrementCoordYMSD:
  inc coordY                    ; Else, increment coordY MSD
  jmp NextCoordSet
  SetCoordYPositive:
  lda #0
  sta coordY
  jmp NextCoordSet

  DecrementCoordY:
  dec coordY + 1                ; Decrement coordY LSD
  lda #$ff
  cmp coordY + 1                ; If decrement didn't underflow coordY LSD,
  bne NextCoordSet              ;   Continue
  lda coordY
  beq SetCoordYNegative         ; If coordY MSD is zero, flip the polarity
  sec
  sbc #$80
  bcs IncrementCoordYMSD        ; Else if coordY MSD is negative and not zero,
                                ;   Increment coordY MSD
  DecrementCoordYMSD:
  dec coordY                    ; Else, coordY MSD is positive, so increment it
  jmp NextCoordSet
  SetCoordYNegative:
  lda #$80
  sta coordY                    ; Set coordY to #$80 as polarity bit

  NextCoordSet:
  inc memory                    ; Move memory pointer to next character
  bne ContinueGNC               ; If memory LSD did not exceed $ff, continue
  inc memory + 1                ; Else, increment memory MSD
  ContinueGNC:
  rts                           ; Return from subroutine


IRQ:
  rti

  org $a000
  ;incbin "roms/aoc2015/03/ins1.raw"
  ;incbin "roms/aoc2015/03/ins2.raw"
  ;incbin "roms/aoc2015/03/ins3.raw"
  incbin "roms/aoc2015/03/in.raw"
