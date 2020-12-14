;; 6502 Snake game

LDA #0     ; Set the lower byte
STA $01
LDA #2     ; Set the higher byte
STA $02
LDX #6     ; Set X to immediate 0


Loop:
LDY #0       ; Reset Y back to 0

;; Handle the loop counter
INC $3       ; Game loop delay
LDA $3       ; Load the delay counter into A
AND #$3f     ; Only worry about the 0011 1110 bits
STA $3
CPY $3       ; Check if loop counter is 0
BNE Loop     ; If not equal, restart loop
INC $4       ; If so, increment the second loop delay
;; Loop counter is temporary, to view the framerate

LDA $ff      ; Load the last pressed key into A

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
LDA #0
STA ($01), Y ; Clear old position
LDA $01      ; Load the lower byte into A
SEC
SBC #$20     ; Move up one unit on the screen
STA $01      ; Store new position
BCS Wrap1    ; Need to decrement the higher byte
JSR DecrementHigher
Wrap1:
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

GoingLeft:
LDA #$0
STA ($01), Y ; Clear old position
LDA $01      ; Load the lower byte into A
AND #$3f     ; Only worry about the 0011 1111 bits
CMP #0       ; Check if the box is on the left
BNE Wrap2    ; If not, continue
ADC #$1f     ; If so, move to the right side of the screen
STA $1
Wrap2:
DEC $01      ; Move box left
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

GoingDown:
LDA #0
STA ($01), Y ; Clear old position
LDA $01      ; Load the lower byte into A
CLC
ADC #$20     ; Move up one unit on the screen
STA $01      ; Store new position
BCC Wrap3    ; Need to decrement the higher byte
JSR IncrementHigher
Wrap3:
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

GoingRight:
LDA #$0
STA ($01), Y ; Clear old position
LDA $01      ; Load the lower byte into A
AND #$3f     ; Only worry about the 0011 1111 bits
CMP #$1f     ; Check if the box is on the right
BNE Wrap4    ; If not, continue
SEC
SBC #$1f     ; If so, move to the left side of the screen
STA $1
Wrap4:
INC $01      ; Move box right
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop


;; Subroutines
IncrementHigher:
INC $02      ; Decrement highest
LDY #6
CPY $02      ; Check if the higher byte is immediate 6
BNE ReturnDec  ; If not, continue with loop
LDY #1
STY $02      ; If so, reset the higher byte back to immediate 1
ReturnDec:
LDY #0
RTS

DecrementHigher:
DEC $02      ; Decrement highest
LDY #1
CPY $02      ; Check if the higher byte is immediate 1
BNE ReturnDec  ; If not, continue with loop
LDY #5
STY $02      ; If so, reset the higher byte back to immediate 5
ReturnDec:
LDY #0
RTS
