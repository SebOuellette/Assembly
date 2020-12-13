;; 6502 W/A/S/D detector

LDA #0     ; Set the lower byte
STA $01
LDA #2     ; Set the higher byte
STA $02
LDX #6     ; Set X to immediate 0
LDY #$00


Loop:
LDA $ff      ; Load the last pressed key into A

CMP $00      ; Check if the new key is the same as the old key
BEQ Loop     ; This is the same, go back to the beginning of the loop
STA $00      ; Save the new key into the pointer

;; Check the game controls
CMP #$77     ; Up (Idk how variables work yet)
BEQ GoingUp

CMP #$61     ; Left
BEQ GoingLeft

CMP #$73     ; Down
BEQ GoingDown

CMP #$64     ; Right
BEQ GoingRight

JMP Loop     ; Listen for another key


;; Functions
GoingUp:
LDA #$2
STA ($01), Y
JMP Increment     ; Increment the pointer properly

GoingLeft:
LDA #$7
JMP Increment     ; Increment the pointer properly

GoingDown:
LDA #$5
JMP Increment     ; Increment the pointer properly

GoingRight:
LDA #$6
;                   Increment the pointer properly

Increment:
STA ($01), Y ; Store the colour into the GPU

INC $01      ; Increment the lower address byte
CPY $01      ; Check if the lower byte is immediate 0
BNE Loop     ; If not, restart loop
INC $02      ; If so, increment higher address byte

CPX $02      ; Check if the higher byte is immediate 6
BNE Loop     ; If not, restart loop
LDY #$02
STY $02      ; If so, reset it to immediate 2
LDY #$00

BEQ Loop     ; Restart loop
