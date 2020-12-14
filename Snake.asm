;; 6502 Snake game

LDA #$f0   ; Set the lower byte
STA $01
LDA #$03   ; Set the higher byte
STA $02
LDX #6     ; Set X to immediate 6
LDY #0     ; Set Y to immediate 0
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU

Loop:
LDY #0       ; Reset Y back to 0

;; Handle the loop counter
INC $3       ; Game loop delay
LDA $3       ; Load the delay counter into A
AND #$3f     ; Only worry about the 0011 1111 bits
STA $3
CPY $3       ; Check if loop counter is 0
BNE Loop     ; If not equal, restart loop

;;             Check if the key is W/A/S/D
LDA $ff      ; Load the last pressed key into A

CMP #$77     ; Up
BNE upEnd
PHA
LDA $00
CMP #$73
BNE validKey 
PLA
upEnd:

CMP #$61     ; Left
BNE leftEnd
PHA
LDA $00
CMP #$64
BNE validKey
PLA
leftEnd:

CMP #$73     ; Down
BNE downEnd
PHA
LDA $00
CMP #$77
BNE validKey
PLA
downEnd:

CMP #$64     ; Right
BNE rightEnd
PHA
LDA $00
CMP #$61
BNE validKey
PLA
rightEnd:

JMP invalidKey

validKey:
PLA
STA 0        ; If the key is W/A/S/D, store it to ZP-0
invalidKey:

;; Check the game controls
LDA 0
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
JSR clearOld ; First, clear old position
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
JSR clearOld ; First, clear old position
LDA $01      ; Load the lower byte into A
STA $4
AND #$1f     ; Only worry about the 0011 1111 bits
CMP #0       ; Check if the box is on the left
BNE Wrap2    ; If not, continue
LDA $4
ADC #$1f     ; If so, move to the right side of the screen
STA $1
STA $4
Wrap2:
LDA $4
DEC $01      ; Move box left
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU
JMP Loop     ; Restart loop

GoingDown:
JSR clearOld ; First, clear old position
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
JSR clearOld ; First, clear old position
LDA $01      ; Load the lower byte into A
STA $4
AND #$1f     ; Only worry about the 0011 1111 bits
CMP #$1f     ; Check if the box is on the right
BNE Wrap4    ; If not, continue
LDA $4
SEC
SBC #$20     ; If so, move to the left side of the screen
STA $1
STA $4
Wrap4:
LDA $4
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
LDY #2
STY $02      ; If so, reset the higher byte back to immediate 2
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

clearOld:
LDA #0
STA ($01), Y ; Clear old position
RTS
