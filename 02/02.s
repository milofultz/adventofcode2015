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
  ;; GetSmallestLWH
  ;lda #$30
  ;sta length
  ;lda #$10
  ;sta width
  ;lda #$20
  ;sta height
  ;jsr GetSmallestLWH
  ;jmp Infinite

  ;; Multiply
  ;ldx #10
  ;ldy #10
  ;jsr Multiply
  ;jmp Infinite

;
; Helper Subroutines
;

GetSmallestLWH:
  ; IN:  length, width, and height values
  ; OUT: smallest dimension in accumulator
  lda length
  sec
  cmp width                     ; If width is smaller than the length
  bcs WidthIsSmaller            ;   Load width into accumulator

  lda length                    ; Else, load length into accumulator
  jmp HeightCheck

  WidthIsSmaller:
  lda width

  HeightCheck:
  cmp height                    ; If height is smaller than current smallest
  bcs HeightIsSmaller           ;   Load height in accumulator
                                ; Else, keep previous value in accumulator
  rts                           ; Return from the subroutine

  HeightIsSmaller:
  lda height
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
