;; 6502 W/A/S/D detector

LDA #0     ; Set the lower byte
STA $01
LDA #2     ; Set the higher byte
STA $02
LDX #6     ; Set X to immediate 0


Loop:
LDY #0       ; Reset Y back to 0
LDA $ff      ; Load the last pressed key into A

;; Handle the loop counter
INC $3       ; Game loop delay
CPY $3       ; Check if loop counter is 0
BNE Loop     ; If not equal, restart loop
INC $4       ; If so, increment the second loop delay
;; Loop counter is temporary, to view the framerate

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
PHA
LDA $01      ; Load the lower byte
CLC
SBC #$1f     ; Move up one unit on the screen
STA $01      ; Store new position
BCS Wrap1    ; Need to decrement the higher byte
Wrap1:
JSR DecrementHigher
PLA
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

GoingLeft:
LDA #$7
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

GoingDown:
LDA #$5
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

GoingRight:
LDA #$6
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

IncrementHigher:
INC $02      ; Increment highest
CPX $02      ; Check if the higher byte is immediate 6
BNE Loop     ; If not, continue with loop
LDY #2
STY $02      ; If so, reset the higher byte back to immediate 2
JMP Loop     ; Restart loop

DecrementHigher:
DEC $02      ; Decrement highest
LDY #1
CPY $02      ; Check if the higher byte is immediate 1
BNE ReturnDec  ; If not, continue with loop
LDY #5
STY $02      ; If so, reset the higher byte back to immediate 5
ReturnDec:
RTS
