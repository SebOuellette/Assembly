; 6502 - Colour grid program

;; Initialize the registers
LDX #$00 ; Put 0 into the X register
LDA #$02 ; Put 2 into the A register
STA $01  ; Store A to the second zero-page index
LDA #$00 ; Put 0 into the A register
STA $00  ; Store A to the first zero-page index 

;; Run the program
LDA $fe  ; Load random colour into the A register
STA ($00,X)
LDY #$ff

CPY $00 
BNE IncBig

INC $01
INC $00
LDY #$06
CPY $01
BNE NotOverwriting
LDA #$02
STA $01

NotOverwriting:
JMP $60A

IncBig:
INC $00
JMP $60A
