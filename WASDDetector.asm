;; 6502 W/A/S/D detector

LDX #$00

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
STA $0200, X
INX
JMP Loop     ; Listen for another key

GoingLeft:
LDA #$7
STA $0200, X
INX
JMP Loop     ; Listen for another key

GoingDown:
LDA #$5
STA $0200, X
INX
JMP Loop     ; Listen for another key

GoingRight:
LDA #$6
STA $0200, X
INX
JMP Loop     ; Listen for another key
