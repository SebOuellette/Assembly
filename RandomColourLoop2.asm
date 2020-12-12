Init:
LDA #$00      ; Initialize least significant byte
STA $00
LDA #$02      ; Initialize most significant byte
STA $01
LDX #$00      ; Initialize X
LDY #$06      ; Initialize Y

LDA $fe       ; Load colour

Program:
STA ($00, X)  ; Store colour into the GPU address defined at zero-page 0
INC $00       ; Increment pointer address

CPX $00       ; Check if pointer lower-byte is zero
BNE Program   ; If equal, continue, otherwise continue;

;; Roll over
INC $01       ; Increment the pointer's higher-byte
CPY $01       ; Check if the pointer's higher-byte is $06
BEQ Init      ; Restart program if yes
JMP Program   ; Go back to loop if not
