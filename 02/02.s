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
;  ; GetSmallest
;  lda #1
;  sta topArea
;  lda #$30
;  sta topArea + 1
;  lda #1
;  sta sideArea
;  lda #$10
;  sta sideArea + 1
;  lda #0
;  sta frontArea
;  lda #$20
;  sta frontArea + 1
;
;  ldx #$08                      ; Address to most-significant digit of topArea
;  ldy #$0a                      ; Address to most-significant digit of sideArea
;  jsr GetSmallest
;  ldy #$0c                      ; Address to most-significant digit of frontArea
;  jsr GetSmallest
;  txa
;  jmp Infinite

;  ; Multiply
;  ldx #10
;  ldy #5
;  jsr Multiply                  ; Result should be #$0032/#50
;  ldx #10
;  ldy #30
;  jsr Multiply                  ; Result should be #$012c/#300
;  jmp Infinite

;  ; FindArea
;  lda #10
;  sta length
;  lda #30
;  sta width
;  lda #8
;  sta height
;  jsr FindArea
;  jmp Infinite

;
; Helper Subroutines
;

GetSmallest:
  ; IN:  X (address 1), Y (address 2) - Each address is for 2 byte numbers
  ; OUT: X (address of smaller number found at X, Y addresses)
  sec
  lda $00,y
  cmp $00,x
  beq CompareLessSignificant
  bcc StoreY

  StoreX:
  rts

  StoreY:
  tya
  tax
  rts

  CompareLessSignificant:
  lda $01,y
  cmp $01,x
  beq StoreX
  bcs StoreX
  jmp StoreY

Multiply:
  ; IN:  X (number), Y (iterator) as two numbers to multiply
  ; OUT: none (updated `product`)
  lda #0
  sta product + 1               ; Initialize product to 0
  sta product

  AddNum:
  txa                           ; Put number in accumulator
  clc
  adc product + 1               ; Sum product and number in accumulator
  bcc StoreNewProduct           ; If sum didnt exceed #$ff, goto StoreNewProduct

  inc product                   ; Else, increment second place of product

  StoreNewProduct:
  sta product + 1               ; Store new sum in product
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
