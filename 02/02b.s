include "64cube.inc"

enum $00                        ; Declare memory for variables
  total rBYTE 3
  volume rBYTE 2
  length rBYTE 1
  width rBYTE 1
  height rBYTE 1
  isSorted rBYTE 1
  factor rBYTE 1
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

;Part2:
;  lda #0                        ; Init accumulator to 0
;  tax                           ; Init X register to 0 (pointer to L,W,H)
;  tay                           ; Init Y register to 0 (memory pointer)
;
;  GetNextChar:
;  lda ($10),y                   ; Load dereferenced value $0010 into accumulator
;  inc memory                    ; Increment memory LSD
;  bne ContinueGetNextChar       ; If memory LSD did not exceed $ff, continue
;  jsr IncrementHighMemory       ; Else, increment memory MSD
;
;  ContinueGetNextChar:
;  cmp #0                        ; If value is zero,
;  beq Infinite                  ;   Goto Infinite (end of input)
;  cmp #$78                      ; If accumulator represents an 'x',
;  beq StoreNum                  ;   Goto StoreNum
;  sec
;  sbc #$30                      ; If accumulator represents a number,
;  bcs CompileNum                ;   Goto CompileNum (acc contains number)
;                                ; Else if accumulator represents a newline,
;  AddAreaLSD:
;  jsr FindArea                  ; Calculate the total area in `area`
;  lda total + 2                 ; Load total LSD into accumulator
;  clc
;  adc area + 1                  ; Add area LSD to total LSD
;  sta total + 2                 ; Store result in total LSD
;  bcc AddAreaSD                 ; If sum didn't exceed $ff, continue
;  jsr IncrementTotalSD          ; Else, increment total SD
;
;  AddAreaSD:
;  lda total + 1                 ; Load total SD into accumulator
;  clc
;  adc area                      ; Add area MSD to total SD
;  sta total + 1                 ; Store result in total SD
;  bcc ContinueAddAreaSD         ; If sum didn't exceed $ff, continue
;  jsr IncrementTotalMSD         ; Else, increment total MSD
;
;  ContinueAddAreaSD:
;  lda #0                        ; Re-initialize L,W,H and X/Y register
;  sta length
;  sta width
;  sta height
;  tax
;  tay
;  jmp GetNextChar               ; Start next box
;
;  StoreNum:
;  inx                           ; Point to next side (L,W,H)
;  jmp GetNextChar               ; Get next character
;
;  CompileNum:
;  pha                           ; Save current number
;  txa
;  pha                           ; Save current pointer to L,W,H
;  tay
;  ldx $05,y                     ; Load tens-place of number into X register
;  ldy #10                       ; Load 10 into Y register
;  jsr Multiply                  ; Multiply tens-place number by 10
;  pla                           ; Retrieve current pointer to L,W,H
;  tax                           ; Store it in X register
;  pla                           ; Retrieve current number
;  clc
;  adc product + 1               ; Add current number to product LSD
;  sta $05,x                     ; Store sum at current side (L,W,H)
;  jmp GetNextChar               ; Get next character
;
;  IncrementHighMemory:
;  inc memory + 1                ; Increment memory MSD
;  rts                           ; Return from subroutine
;
;  IncrementTotalSD:
;  inc total + 1                 ; Increment total SD
;  beq IncrementTotalMSD         ; If total + 1 crossed from $ff -> $00,
;                                ;   Goto IncrementTotalMSD
;  rts
;
;  IncrementTotalMSD:
;  inc total                     ; Increment total MSD
;  rts
;
;Infinite:
;  jmp Infinite


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
  ; GetVolume
  lda #10
  sta length
  lda #20
  sta width
  lda #30
  sta height

  jsr GetVolume                 ; Result should be #$1770/#6000

Infinite:
  jmp Infinite


;
; Helper Subroutines
;

GetTwoSmallest:
  ; IN:  length, width, and height values
  ; OUT: sorted LWH values

  ; X = Length of input values to iterate through
  ; Y = Current index of iteration

  lda #2                        ; Handle comparing of two elements. Without
  tax                           ;   this, the final comparison will be with the
                                ;   last number and a number outside of scope

  OuterLoop:                    ; This loop will iterate through the entire list
  lda #0
  tay                           ; Initialize current index to 0
  lda #1
  sta isSorted                  ; Reset the isSorted flag

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
  sta isSorted                  ; Ensure isSorted is not set to 1

  NextNum:
  stx temp                      ; Load length of input into temp variable
  iny                           ; Increment current index
  cpy temp                      ; If we are not on the last number,
  bne InnerLoop                 ;   Goto InnerLoop
                                ; Else, continue
  lda isSorted                  ; Load isSorted flag into the accumulator
  beq OuterLoop                 ; If isSorted is not 1 (false), goto OuterLoop
                                ; Else, the list is sorted
  rts

GetVolume:
  ; IN:  length, width, height
  ; OUT: none (updated `volume`)
  lda #0
  sta volume                    ; Initialize volume MSD to #$00
  lda length
  sta volume + 1                ; Initialize volume LSD to length
  ldx #$06                      ; Address to second dimension (width)

  PrepMultiplyLSD:
  lda #0
  sta temp                      ; Initalize `temp` to 0
  ldy $00,x                     ; Get current dimension value
  jsr MultiplyVolumeLSD

  PrepMultiplyMSD:
  lda volume
  beq SkipMSD
  lda #0
  ldy $00,x
  jsr MultiplyVolumeMSD
  lda volume
  SkipMSD:
  clc
  adc temp
  sta volume

  NextDimension:
  inx
  cpx #$08
  bne PrepMultiplyLSD
  rts

  MultiplyVolumeLSD:
  ; IN:  `volume` + 1 (num) and Y (iterator)
  ; OUT: `volume` + 1 and `temp` as `carry`
  clc
  adc volume + 1                ; Add volume LSD to accumulator
  bcc SkipCarry                 ; If accumulator didn't exceed $ff, continue
  inc temp                      ; Else, increment `temp`
  SkipCarry:
  dey                           ; Decrement iterator
  bne MultiplyVolumeLSD         ; If Y is not zero, continue multiplication
  sta volume + 1                ; Else, save accumulator value to volume LSD
  rts

  MultiplyVolumeMSD:
  ; IN:  `volume` (num) and Y (iterator)
  ; OUT: `volume`
  clc
  adc volume                    ; Add volume MSD to accumulator
  dey                           ; Decrement iterator
  bne MultiplyVolumeMSD         ; If Y is not zero, continue multiplication
  sta volume                    ; Else, save accumulator value to volume MSD
  rts

;FindArea:
;  ; IN:  length, width, and height values
;  ; OUT: none (updated `area`)
;  AreaOfSides:
;  ldx length
;  ldy width
;  jsr Multiply
;  lda product
;  sta topArea
;  lda product + 1
;  sta topArea + 1               ; Get topArea and store
;
;  ldy height
;  jsr Multiply
;  lda product
;  sta sideArea
;  lda product + 1
;  sta sideArea + 1              ; Get topArea and store
;
;  ldx height
;  ldy width
;  jsr Multiply
;  lda product
;  sta frontArea
;  lda product + 1
;  sta frontArea + 1             ; Get topArea and store
;
;  AreaOfRibbon:
;  ldx #$08
;  ldy #$0a
;  jsr GetSmallest               ; Set X to smallest area
;  ldy #$0c
;  jsr GetSmallest               ; Set X to smallest area
;  lda $00,x
;  sta area
;  lda $01,x
;  sta area + 1
;
;  ldx #$08                      ; Load memory location of topArea
;
;  SumAreasAndRibbon:
;  lda area                      ; Load most significant area value into acc
;  clc
;  adc $00,x                     ; Add most significant `xxxArea` value to acc
;  adc $00,x                     ;   Once for each side
;  sta area                      ; Store acc in area's most significant digit
;
;  lda area + 1                  ; Load least significant area value into acc
;  jsr SumAreaLSD                ; Jump to subroutine SumAreaLSD
;  jsr SumAreaLSD                ; Do it once for each side
;
;  ContinueSumB:
;  sta area + 1                  ; Store acc in area's least significant digit
;  inx
;  inx                           ; Move to next `xxxArea` memory location
;  cpx #$0e                      ; If there are more `xxxArea` memory addresses:
;  bne SumAreasAndRibbon         ;   Goto SumAreasAndRibbon
;  rts                           ; Else, return from subroutine
;
;  SumAreaLSD:
;  clc
;  adc $01,x                     ; Add least significant `xxxArea` value to acc
;  bcs IncrementAreaMSD          ; If result of $ff -> $00, goto IncrementAreaMSD
;  rts                           ; Else, return from subroutine
;
;  IncrementAreaMSD:
;  inc area                      ; Increment area MSD
;  rts

IRQ:
  rti

  org $3000
  ;incbin "roms/aoc2015/02/ins1.raw"
  ;incbin "roms/aoc2015/02/ins2.raw"
  incbin "roms/aoc2015/02/in.raw"
