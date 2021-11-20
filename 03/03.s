include "64cube.inc"

enum $00                        ; Declare memory for variables
  memory rBYTE 2                ; Pointer at memory holding the input characters
  coordX rBYTE 2                ; Current coordinates
  coordY rBYTE 2
  uniqueCoords rBYTE 2          ; Pointer at start of array memory
  coordsLength rBYTE 2          ; Number of discrete coordinates (total * 4)
  coordsIterator rBYTE 2        ; For checking through the array
  match rBYTE 1                 ; Boolean for if coords are a match
ende

enum $10
  total rBYTE 2                 ; Total number of coordinates
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  _setw IRQ, VBLANK_IRQ

  lda #0                        ; Init coordinatess to [0, 0]
  tax
  tay
  sta memory
  sta coordX
  sta coordX + 1
  sta coordY
  sta coordY + 1
  sta uniqueCoords
  sta coordsIterator
  sta coordsIterator + 1
  lda #4
  sta coordsLength
  lda #$40
  sta coordsLength + 1
  sta uniqueCoords + 1
  lda #$a0
  sta memory + 1

  cli

; PROGRAM

; 5e = ^
; 76 = v
; 3c = <
; 3e = >

MAIN:
  jsr GetNextCoord              ; Get next character and convert into coordinate
  ; jmp CountUniqueCoords       ; If end of input in GetNextCoord, do this
  jsr AddCoordIfUnique          ; Check coord against existing; add if not seen
  jmp MAIN                      ; Repeat until end of input is reached

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

;  ; AddCoordIfUnique
;
;  ; Edge: coord is starting point
;  lda #0
;  sta coordX
;  sta coordY
;  sta coordX + 1
;  sta coordY + 1
;  sta $4000                     ; Array memory slots
;  sta $4001
;  sta $4002
;  sta $4003
;  lda #4
;  sta coordsLength
;  lda #$40
;  sta coordsLength + 1
;
;  jsr AddCoordIfUnique
;  lda coordsLength
;  cmp #4
;  bne TestFailed
;
;  ; Coord in array
;  lda #0
;  sta coordX
;  sta coordY
;  sta $4004                     ; Array memory slots, X MSD/Y MSD
;  sta $4006
;  lda #1
;  sta coordX + 1
;  sta coordY + 1
;  sta $4005                     ; Array memory slots, X LSD/Y LSD
;  sta $4007
;  lda #8
;  sta coordsLength
;  lda #$40
;  sta coordsLength + 1
;
;  jsr AddCoordIfUnique
;  lda coordsLength
;  cmp #8
;  bne TestFailed
;
;  ; Coord not in array
;  lda #0
;  sta coordX
;  sta coordY
;  sta coordX + 1
;  sta $4000                     ; Array memory slots, X MSD/Y MSD
;  sta $4001
;  sta $4002
;  sta $4003
;  lda #1
;  sta coordY + 1
;  lda #4
;  sta coordsLength
;  lda #$40
;  sta coordsLength + 1
;
;  jsr AddCoordIfUnique
;  lda coordsLength
;  cmp #8
;  bne TestFailed

;  ; CountUniqueCoords
;
;  ; Test small amount (LSD)
;  lda #16
;  sta coordsLength
;  lda #$40
;  sta coordsLength + 1
;
;  jsr CountUniqueCoords
;  lda total
;  bne TestFailed
;  lda total + 1
;  cmp #4
;  bne TestFailed
;
;  ; Test large amount (MSD)
;  lda #0
;  sta coordsLength
;  lda #$41
;  sta coordsLength + 1
;
;  jsr CountUniqueCoords
;  lda total
;  bne TestFailed
;  lda total + 1
;  cmp #$40
;  bne TestFailed
;
;  ; Test Larger amount (LSD and MSD)
;  lda #$40
;  sta coordsLength
;  lda #$48
;  sta coordsLength + 1
;  jsr CountUniqueCoords
;  lda total
;  cmp #$2
;  bne TestFailed
;  lda total + 1
;  cmp #$10
;  bne TestFailed
;
;TestPassed:
;  jmp TestPassed
;
;TestFailed:
;  jmp TestFailed


;
; Helper Functions
;

Infinite:
  jmp Infinite


AddCoordIfUnique:
  ; IN:  uniqueCoords (pointer), coordsLength (pointer to end), coordX/coordY
  ; OUT: coordinates appended to array

  ; X = check for zero
  ; Y = iterator for Y

  lda coordX
  bne ContinueSetupACIU
  lda coordX + 1
  bne ContinueSetupACIU         ; If coordX is zero,
  lda coordY
  bne ContinueSetupACIU
  lda coordY + 1
  bne ContinueSetupACIU         ; and coordY is zero,
  rts                           ; This is our starting point, and not unique

  ContinueSetupACIU:
  lda #$40
  sta coordsIterator + 1
  lda #4
  sta coordsIterator            ; Set coordsIterator to #$4004 (indirect addr)

  CheckIfAtEndOfCoords:
  lda coordsIterator + 1        ; Load coordsIterator MSD
  cmp coordsLength + 1          ; If not the same as coordsLength MSD,
  bne CheckNextUniqueCoord      ;   Continue iterating
  lda coordsIterator            ; Load coordsIterator LSD
  cmp coordsLength              ; If not the same as coordsLength LSD,
  bne CheckNextUniqueCoord      ;   Continue iterating
  jmp IsUniqueCoord             ; If at end and no match is found, add to array

  CheckNextUniqueCoord:
  lda #1
  sta match                     ; Set match boolean to 1 (true)

  ldy #0                        ; Initialize local iterator
  lda (coordsIterator),y        ; If uniqueCoordX MSD is not zero,
  cmp coordX                    ; If coordX MSD is the same as coordX MSD,
  beq MatchXMSD                 ;   Continue
  lda #0                        ; Else, set match boolean to 0 (false)
  sta match
  MatchXMSD:
  iny                           ; Increment the iterator
  lda (coordsIterator),y        ; If uniqueCoordX LSD is not zero
  cmp coordX + 1                ; If coordX LSD is the same as coordX LSD,
  beq MatchXLSD                 ;   Continue
  lda #0
  sta match
  MatchXLSD:
  iny                           ; Increment the iterator
  lda (coordsIterator),y        ; If uniqueCoordY MSD is not zero
  cmp coordY                    ; If coordY MSD is the same as coordY MSD,
  beq MatchYMSD                 ;   Continue
  lda #0
  sta match
  MatchYMSD:
  iny                           ; Increment the iterator
  lda (coordsIterator),y        ; If uniqueCoordY LSD is not zero
  cmp coordY + 1                ; If coordY MSD is the same as coordY MSD,
  beq MatchYLSD                 ;   Continue
  lda #0
  sta match
  MatchYLSD:
  lda match                     ; If there is a match on current uniqueCoord,
  bne EndAddCoord               ;   Return from subroutine

  GotoNextCoord:
  ldy #0                        ; Reset the iterator
  lda coordsIterator            ; Load the coordsIterator LSD
  clc
  adc #4                        ; Add length of one set of coords
  sta coordsIterator            ; Store new address at coordsIterator LSD
  bcc CheckIfAtEndOfCoords      ; If result didn't overflow over $ff, continue
  inc coordsIterator            ; Else increment coordsIterator MSD
  jmp CheckIfAtEndOfCoords      ;   and continue

  IsUniqueCoord:
  ldy #0
  lda coordX
  sta (coordsIterator),y
  iny
  lda coordX + 1
  sta (coordsIterator),y
  iny
  lda coordY
  sta (coordsIterator),y
  iny
  lda coordY + 1
  sta (coordsIterator),y

  lda coordsLength              ; Load coordsLength LSD
  clc
  adc #4                        ; Add length of one set of coords
  sta coordsLength              ; Store new address in coordsLength LSD
  bcc EndAddCoord               ; If result didn't overflow over $ff, continue
  inc coordsLength + 1          ; Else increment coordsIterator MSD and end

  EndAddCoord:
  rts

CountUniqueCoords:
  ; IN:  uniqueCoords (pointer), coordsLength (pointer to end)
  ; OUT: none (updated `total`)

  ; X = holding carried bits during bit shifting

  lda coordsLength + 1
  sec
  sbc uniqueCoords + 1
  beq CountUniqueCoordsLSD
  sta total                     ; Get total amount of coords pre-bit shift
  asl
  asl
  asl
  asl
  asl
  asl                           ; Get the carry bits for the LSD
  tax                           ; X holds carried bits in correct spots
  lsr total
  lsr total                     ; Divide total MSD by 4

  CountUniqueCoordsLSD:
  lda coordsLength              ; Load coordsLength LSD
  lsr
  lsr                           ; Divide coordsLength LSD by 4
  sta total + 1                 ; Store in total LSD
  txa                           ; Load the shifted carry bits
  ora total + 1                 ; OR shifted carry bits against total LSD
  sta total + 1                 ; Store result in total LSD

  jmp ProgramEnd

GetNextCoord:
  ; IN:  memory (address)
  ; OUT: none (changed coordX/coordY)

  ldy #0
  lda (memory),y                ; Load memory pointer into the accumulator
  beq CountUniqueCoords         ; If end of input is reached, count coords
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
  dec coordX                    ; Else, coordX MSD is positive, so decrement it
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
  dec coordY                    ; Else, coordY MSD is positive, so decrement it
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

ProgramEnd:
  jmp ProgramEnd

IRQ:
  rti

  org $a000
  ;incbin "roms/aoc2015/03/ins1.raw"
  incbin "roms/aoc2015/03/ins2.raw"
  ;incbin "roms/aoc2015/03/ins3.raw"
  ;ncbin "roms/aoc2015/03/in.raw"
