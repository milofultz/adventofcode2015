include "64cube.inc"

enum $00                        ; Declare memory for variables
  total rBYTE 3
  volume rBYTE 2
  length rBYTE 1
  width rBYTE 1
  height rBYTE 1
  isSorted rBYTE 1
  product rBYTE 1
  ribbon rBYTE 1
  temp rBYTE 1
ende
enum $10
  memory rBYTE 2
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  _setw IRQ, VBLANK_IRQ

  lda #$30                      ; Init `memory` to #$3000
  sta memory + 1
  lda #0
  sta memory

  cli

; $30-39 = 0-9
; $0a    = LF (\n)
; $78    = 'x'

Part2:
  ; X = pointer to length, width, and height variables
  ; Y = pointer to `memory` pointer

  lda #0                        ; Init accumulator to 0
  tax                           ; Init X register to 0 (pointer to L,W,H)
  tay                           ; Init Y register to 0 (memory pointer)

  GetNextChar:
  lda ($10),y                   ; Load dereferenced value $0010 into accumulator
  inc memory                    ; Increment memory LSD
  bne ContinueGetNextChar       ; If memory LSD did not exceed $ff, continue
  jsr IncrementHighMemory       ; Else, increment memory MSD

  ContinueGetNextChar:
  cmp #0                        ; If value is zero,
  beq Infinite                  ;   Goto Infinite (end of input)
  cmp #$78                      ; If accumulator represents an 'x',
  beq StoreNum                  ;   Goto StoreNum
  sec
  sbc #$30                      ; If accumulator represents a number,
  bcs CompileNum                ;   Goto CompileNum (acc contains number)
                                ; Else if accumulator represents a newline,
  jsr GetVolume                 ; Calculate the total volume of L,W,H
  jsr GetRibbon                 ; Calculate the total ribbon

  AddRibbon:
  lda total + 2                 ; Load total LSD into accumulator
  clc
  adc ribbon                    ; Add ribbon to total LSD
  bcc AddVolumeLSD              ; If sum didn't exceed $ff, continue
  jsr IncrementTotalSD          ; Else, increment total SD

  AddVolumeLSD:
  clc
  adc volume + 1                ; Add volume LSD to total LSD
  sta total + 2                 ; Store result in total LSD
  bcc AddVolumeSD               ; If sum didn't exceed $ff, continue
  jsr IncrementTotalSD          ; Else, increment total SD

  AddVolumeSD:
  lda total + 1                 ; Load total SD into accumulator
  clc
  adc volume                    ; Add volume MSD to total SD
  sta total + 1                 ; Store result in total SD
  bcc ContinueAddVolumeSD       ; If sum didn't exceed $ff, continue
  jsr IncrementTotalMSD         ; Else, increment total MSD

  ContinueAddVolumeSD:
  lda #0                        ; Re-initialize L,W,H and X/Y register
  sta length
  sta width
  sta height
  tax
  tay
  jmp GetNextChar               ; Start next box

  StoreNum:
  inx                           ; Point to next side (L,W,H)
  jmp GetNextChar               ; Get next character

  CompileNum:
  pha                           ; Save current number
  txa
  pha                           ; Save current pointer to L,W,H
  tay
  ldx $05,y                     ; Load tens-place of number into X register
  ldy #10                       ; Load 10 into Y register
  jsr Multiply                  ; Multiply tens-place number by 10
  pla                           ; Retrieve current pointer to L,W,H
  tax                           ; Store it in X register
  pla                           ; Retrieve current number
  clc
  adc product + 1               ; Add current number to product LSD
  sta $05,x                     ; Store sum at current side (L,W,H)
  jmp GetNextChar               ; Get next character

  IncrementHighMemory:
  inc memory + 1                ; Increment memory MSD
  rts                           ; Return from subroutine

  IncrementTotalSD:
  inc total + 1                 ; Increment total SD
  beq IncrementTotalMSD         ; If total + 1 crossed from $ff -> $00,
                                ;   Goto IncrementTotalMSD
  rts

  IncrementTotalMSD:
  inc total                     ; Increment total MSD
  rts



;TEST:
;  ; GetTwoSmallest
;  lda #20
;  sta length
;  lda #30
;  sta width
;  lda #10
;  sta height
;
;  jsr GetTwoSmallest            ; Result should be #10, #20, #30
;  jmp Infinite
;
;  ; GetVolume
;  lda #20
;  sta length
;  lda #30
;  sta width
;  lda #10
;  sta height
;
;  jsr GetVolume                 ; Result should be #$1770/#6000
;  jmp Infinite
;
;  ; GetRibbon
;  lda #20
;  sta length
;  lda #30
;  sta width
;  lda #10
;  sta height
;
;  jsr GetRibbon                ; Result should be #$3C/#60
;  jmp Infinite


Infinite:
  jmp Infinite


;
; Helper Subroutines
;

Multiply:
  ; IN:  X (number), Y (iterator) as two numbers to multiply
  ; OUT: none (updated `product`)

  lda #0
  sta product + 1
  sta product                   ; Initialize product to 0

  AddNum:
  txa                           ; Put number in accumulator
  clc
  adc product + 1               ; Sum product and number in accumulator
  bcc StoreNewProduct           ; If sum didnt exceed #$ff, goto StoreNewProduct
  inc product                   ; Else, increment product MSD

  StoreNewProduct:
  sta product + 1               ; Store new sum in product
  dey                           ; Decrement iterator
  bne AddNum                    ; If iterator is not zero, goto AddNum
  rts                           ; Else, return from subroutine

GetTwoSmallest:
  ; IN:  length, width, and height values
  ; OUT: sorted LWH values

  ; X = Length of input values to iterate through
  ; Y = Current index of iteration

  lda #2                        ; Handle comparing of two elements. Without
  tax                           ;   this, the final comparison will be with the
                                ;   last number and a number outside of scope

  OuterLoop:
  lda #0
  tay                           ; Initialize current index to 0
  lda #1
  sta isSorted                  ; Set isSorted to 1 (true)

  InnerLoop:                    ; This loop will compare two numbers for sorting
  lda $0006,y                   ; Load the second number into the accumulator
  cmp $0005,y                   ; Subtract the first number from the second
  bcs NextNum                   ; If second num > first num, goto NextNum
                                ; Else, swap the two numbers
  sta temp                      ; Store the second number in temp variable
  lda $0005,y                   ; Load the first number in accumulator
  sta $0006,y                   ; Store the first number into second mem slot
  lda temp
  sta $0005,y                   ; Store the second number into first mem slot
  lda #0
  sta isSorted                  ; Set isSorted to 0 (false)

  NextNum:
  stx temp                      ; Load length of input into temp variable
  iny                           ; Increment current index
  cpy temp                      ; If we are not on the last number,
  bne InnerLoop                 ;   Goto InnerLoop
                                ; Else, continue
  lda isSorted                  ; Load isSorted flag into the accumulator
  beq OuterLoop                 ; If isSorted is not 1 (false), goto OuterLoop
  rts                           ; Else, the list is sorted

GetRibbon:
  ; IN:  length, width, height
  ; OUT: none (updated `ribbon`)

  jsr GetTwoSmallest            ; Organize length, width, and height by size
  lda #0
  sta ribbon                    ; Initialize ribbon to 0
  clc
  adc length
  adc length
  adc width
  adc width                     ; Add each of the two smallest sides twice
  sta ribbon                    ; Store total in `ribbon`
  rts                           ; Return from subroutine

GetVolume:
  ; IN:  length, width, height
  ; OUT: none (updated `volume`)

  ; X = Address to current dimension (length, width, height)

  lda #0
  sta volume                    ; Initialize volume MSD to #$00
  lda length
  sta volume + 1                ; Init volume LSD to first dimension (length)
  ldx #$06                      ; Address to second dimension (width)

  PrepMultiplyMSD:
  lda #0                        ; Initialize accumulator to 0
  ldy $00,x                     ; Get current dimension value
  jsr MultiplyVolumeMSD         ; Multiply dimension value by the volume MSD

  PrepMultiplyLSD:
  lda #0                        ; Initialize accumulator to 0
  ldy $00,x                     ; Get current dimension value
  jsr MultiplyVolumeLSD         ; Multiply dimension value by the volume LSD

  NextDimension:
  inx                           ; Move address to next dimension
  cpx #$08                      ; If not all three dimensions have been used,
  bne PrepMultiplyMSD           ;   Goto PrepMultiplyMSD
  rts                           ; Else, volume is calculated, return

  MultiplyVolumeMSD:
  ; IN:  `volume` (num) and Y (iterator)
  ; OUT: `volume`
  clc
  adc volume                    ; Add volume MSD to accumulator
  dey                           ; Decrement iterator
  bne MultiplyVolumeMSD         ; If Y is not zero, continue multiplication
  sta volume                    ; Else, save accumulator value to volume MSD
  rts

  MultiplyVolumeLSD:
  ; IN:  `volume` + 1 (num) and Y (iterator)
  ; OUT: `volume` + 1
  clc
  adc volume + 1                ; Add volume LSD to accumulator
  bcc SkipCarry                 ; If accumulator didn't exceed $ff, continue
  inc volume                    ; Else, increment volume MSD
  SkipCarry:
  dey                           ; Decrement iterator
  bne MultiplyVolumeLSD         ; If Y is not zero, continue multiplication
  sta volume + 1                ; Else, save accumulator value to volume LSD
  rts


IRQ:
  rti

  org $3000
  ;incbin "roms/aoc2015/02/ins1.raw"
  ;incbin "roms/aoc2015/02/ins2.raw"
  incbin "roms/aoc2015/02/in.raw"
