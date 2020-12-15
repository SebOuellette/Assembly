;; 6502 Snake game

Init:
JMP Start  ; Skip the variables
;; Memory addresses
;define prevKey   $00 ; previous valid key pressed
;define pointerL  $01 ; Low-byte for the snake head's pointer
;define pointerH  $02 ; High-byte for the snake head's pointer
;define lCounter  $03 ; Loop counter to adjust the refresh rate
;define xPosition $04 ; Current x position
;define oPointerL $05 ; Low-byte for the old snake head's pointer
;define oPointerH $06 ; High-byte for the old snake head's pointer
;define tailLen   $07 ; Double the length of the tail
;define tmpPointL $08 ; The low-byte for a tmp pointer
;define tmpPointH $09 ; The high-byte for a tmp pointer
;define lastTail  $0a ; Stores the index of whatever the last tail index is

Start:
;; Create pointer
LDA #$f0   ; Set the lower byte
STA $01
LDA #$03   ; Set the higher byte
STA $02

;; Create tail
LDX #$20    ; Length of tail to add
JSR addTail

LDY #0     ; Set Y to immediate 0
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU

Loop:
LDY #0       ; Reset Y back to 0

;; Handle the loop counter
INC $3       ; Game loop counter
LDA $3       ; Load the loop counter into A
AND #$3f     ; Only worry about the 0001 1111 bits
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

;; Store the old player address
LDA 1        ; Load the old low-byte
STA 5        ; Copy to new memory address
LDA 2        ; Load the old high-byte
STA 6        ; Copy to new memory address

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
LDA $01      ; Load the lower byte into A
SEC
SBC #$20     ; Move up one unit on the screen
STA $01      ; Store new position
BCS Wrap1    ; Need to decrement the higher byte
JSR DecrementHigher
Wrap1:
JMP DrawDot  ; Draw new dot, and remove old dot

GoingDown:
LDA $01      ; Load the lower byte into A
CLC
ADC #$20     ; Move up one unit on the screen
STA $01      ; Store new position
BCC Wrap2    ; Need to decrement the higher byte
JSR IncrementHigher
Wrap2:
JMP DrawDot  ; Draw new dot, and remove old dot

GoingLeft:
LDA $01      ; Load the lower byte into A
STA $4
AND #$1f     ; Only worry about the 0011 1111 bits
CMP #0       ; Check if the box is on the left
BNE Wrap3    ; If not, continue
LDA $4
ADC #$1f     ; If so, move to the right side of the screen
STA $1
STA $4
Wrap3:
LDA $4
DEC $01      ; Move box left
JMP DrawDot  ; Draw new dot, and remove old dot

GoingRight:
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
JMP DrawDot  ; Draw new dot, and remove old dot

DrawDot:
JSR updateTail ; This function will call loop once it's done
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU
LDA #$a      ; Load the tail colour
STA ($05), Y ; Clear old position
JMP Loop

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

;; Create the tail
addTail: 
PHA          ; Push A to the stack
Decrement:
BEQ continueTail ; If A is not 0, add a tail piece, otherwise, skip to continueTail
LDY $7       ; Load the tail length into Y
INC $7       ; Increment the tail length
LDA $01
STA $1000, Y  ; Store the current low-byte into the tail memory address
LDY $7       ; Load the new tail length/index into Y
INC $7       ; Increment the tail length again
LDA $02
STA $1000, Y  ; Store the current high-byte into the tail memory address
DEX           ; Decrement A by 1
JMP Decrement
continueTail:
DEY
STY $0a      ; Store the final tail index into $0a
PLA          ; Pull A from stack
RTS

;; The more efficient tail update function
updateTail:
;; Load the head position, store in the final tail item
LDY $a       ; Put the final tail length index into Y
LDA $1000, Y
STA $8       ; Load the last tail element into the low tmp byte
INY
LDA $1000, Y
STA $9       ; Load the last tail element into the high temp byte
DEY          ; Set Y back to the proper low-byte index
LDA #0       ; Load black
STA ($8, X)  ; Clear the last element in the tail
LDA $1       ; Load the head low byte
STA $1000, Y ; Store into the low byte for the "last" tail element (visually last)
STA $8
INY
LDA $2       ; Load the head high byte
STA $1000, Y ; Store into the high byte for the "last" tail element (visually last)
STA $9
DEY          ; Decrement Y
BNE countLoop ; Check if the index is 0, if not, do the loop
LDA $7       ; If it is, reset it back to the length - 2
TAY
countLoop: 
DEY          ; Decrement Y twice to find the new final element
DEY
STY $a
LDY #0
RTS
