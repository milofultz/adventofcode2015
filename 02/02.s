include "64cube.inc"

enum $00                        ; Declare memory for variables
  total rBYTE 3
  product rBYTE 2
  length rBYTE 1
  width rBYTE 1
  height rBYTE 1
  topArea rBYTE 2
  sideArea rBYTE 2
  frontArea rBYTE 2
  area rBYTE 2
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  _setw IRQ, VBLANK_IRQ

  cli

TEST:
  ;; GetSmallestArea
  ;lda #$30
  ;sta topArea
  ;lda #$10
  ;sta sideArea
  ;lda #$20
  ;sta frontArea
  ;jsr GetSmallestArea
  ;jmp Infinite

  ;; Multiply
  ;ldx #10
  ;ldy #10
  ;jsr Multiply
  ;jmp Infinite

;
; Helper Subroutines
;

GetSmallestArea:
  ; IN:  topArea, sideArea, and frontArea values
  ; OUT: smallest dimension in accumulator
  lda topArea
  sec
  cmp sideArea                  ; If sideArea is smaller than the topArea
  bcs SideAreaIsSmaller         ;   Load sideArea into accumulator

  lda topArea                   ; Else, load topArea into accumulator
  jmp FrontAreaCheck

  SideAreaIsSmaller:
  lda sideArea

  FrontAreaCheck:
  cmp frontArea                 ; If frontArea is smaller than current smallest
  bcs FrontAreaIsSmaller        ;   Load frontArea in accumulator
                                ; Else, keep previous value in accumulator
  rts                           ; Return from the subroutine

  FrontAreaIsSmaller:
  lda frontArea
  rts                           ; Return from the subroutine

Multiply:
  ; IN:  X (number), Y (iterator) as two numbers to multiply
  ; OUT: none (updated `product`)
  lda #0
  sta product                   ; Initialize product to 0

  AddNum:
  txa                           ; Put number in accumulator
  clc
  adc product                   ; Sum product and number in accumulator
  bcc StoreNewProduct           ; If sum didnt exceed #$ff, goto StoreNewProduct

  inc product + 1               ; Else, increment second place of product

  StoreNewProduct:
  sta product                   ; Store new sum in product
  dey                           ; Decrement iterator
  bne AddNum                    ; If iterator is not zero, goto AddNum

  rts                           ; Else, return from subroutine


FindArea:
  ; IN:  length, width, and height values
  ; OUT: none (updated `area`)



Infinite:
  jmp Infinite

IRQ:
  rti

  org $2000
  ;incbin "roms/aoc2015/02/ins1.raw"
  ;incbin "roms/aoc2015/02/ins2.raw"
  incbin "roms/aoc2015/02/in.raw"
