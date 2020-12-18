;; 6502 Snake game

;; Memory addresses
;define prevKey   $00 ; previous valid key pressed
;define pointerL  $01 ; Low-byte for the snake head's pointer
;define pointerH  $02 ; High-byte for the snake head's pointer
;define lCounter  $03 ; Loop counter to adjust the refresh rate
;define xPosition $04 ; Current x position
;define oPointerL $05 ; Low-byte for the old snake head's pointer
;define oPointerH $06 ; High-byte for the old snake head's pointer
;define tmpPointL $07 ; The low-byte for a tmp pointer
;define tmpPointH $08 ; The high-byte for a tmp pointer
;define tmpByte   $09 ; Stores a temporary byte to be used for storing arithmetic stuff
;define tailLenL  $0a ; Double the length of the tail - low byte
;define tailLenH  $0b ; Double the length of the tail - high byte
;define lastTailL $0c ; Stores the index of whatever the last tail index is - low byte
;define lastTailH $0d ; Stores the index of whatever the last tail index is - high byte

Start:
;; Create pointer
LDA #$f0   ; Set the lower byte
STA $01
LDA #$03   ; Set the higher byte
STA $02

;; Init the tail length variables
LDA #$10   ; Load $10 into A
STA $b     ; Store into both the tail high bytes
STA $d

;; Create tail
LDX #$4     ; Length of snake (including head)
JSR makeTail

;; Create head
LDY #0       ; Set Y to immediate 0
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU

JSR makeItem ; Create the first item

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
JMP gameOver ; If so, game over
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
JMP gameOver ; If so, game over
Wrap4:
LDA $4
INC $01      ; Move box right
JMP DrawDot  ; Draw new dot, and remove old dot

DrawDot:
JSR updateTail ; This function will call loop once it's done
LDA ($01), Y ; Load whatever colour is stored at the new position
JSR checkTail ; Check if the snake is going to run into itself
JSR checkItem ; Check if the snake is going to run into an item
LDA #$3      ; Make the box cyan
STA ($01), Y ; Store the colour into the GPU
LDA #$a      ; Load the tail colour
STA ($05), Y ; Clear old position
JMP Loop

gameOver:
;; Display the tail count in the A and X register
LDA $a       ; Load the low tail count byte into A
LSR          ; Divide by 2
TAX          ; Transfer to X
LDA $b       ; Load the high tail count byte into A
SEC
SBC #$10     ; Subtract $10
LSR          ; Divide by 2
BRK
JMP Start

;; Subroutines
checkTail:
CMP #$0a     ; Check if the new location has a red pixel stored
BNE tailNotFound ; If it is, halt the program
PLA
PLA           ; Pull the subroutine stuff out of the stack
JMP gameOver  ; Hit something, game is over
tailNotFound: ; If it's not, continue with the program
RTS

checkItem:
CMP #$08     ; Check if the new location has an orange pixel stored
BNE itemNotFound ; If it is, add extra length to the snake the program
PHA
LDA #2       ; Increase the length of the tail by 2
JSR increaseTail
JSR makeItem ; Create new item
PLA
itemNotFound: ; If it's not, continue with the program
RTS

IncrementHigher:
INC $02      ; Decrement highest
LDY #6
CPY $02      ; Check if the higher byte is immediate 6
BNE ReturnDec  ; If not, continue with loop
JMP gameOver ; If so, game over 
ReturnDec:
LDY #0
RTS

DecrementHigher:
DEC $02      ; Decrement highest
LDY #1
CPY $02      ; Check if the higher byte is immediate 1
BNE ReturnDec  ; If not, continue with loop
JMP gameOver ; If so, game over
ReturnDec:
LDY #0
RTS

;; Create the tail
makeTail:
PHA          ; Push A to the stack
CMP #0
Decrement:
BEQ continueTail ; If A is not 0, add a tail piece, otherwise, skip to continueTail
CLC
LDA $01      ; Load the snake's low byte position
STA ($a), Y  ; Store the current low-byte into the tail memory address
LDA $a       ; Load the tail length into A
ADC #1       ; Increment the tail length to set carry bit
STA $a       ; Store into the tail length
LDA $b       ; Load the high byte into A
ADC #0       ; Add the carry bit into the high byte
STA $b       ; Store into the high byte
CLC
LDA $02      ; Load the snake's high byte position
STA ($a), Y  ; Store the current high-byte into the tail memory address
LDA $a       ; Load the tail length into A
ADC #1       ; Increment the tail length to set carry bit
STA $a       ; Store into the tail length
LDA $b       ; Load the high byte into A
ADC #0       ; Add the carry bit into the high byte
STA $b       ; Store into the high byte
DEX          ; Decrement X by 1
JMP Decrement
continueTail:
CLC
LDA $a
SBC #1
STA $c       ; Store the final tail index into $0c
LDA $b
STA $d       ; Store the final high byte into the index at $0d
PLA          ; Pull A from stack
RTS

;; The more efficient tail update function
updateTail:
;; Load the head position, store in the final tail item
LDY #0
LDA ($c), Y  ; Load the low byte of the last tail element into A
STA $7       ; Store the last tail element into the low tmp byte
INY
LDA ($c), Y  ; Load the high byte of the last tail element into A
STA $8       ; Store the last tail element into the high temp byte
DEY          ; Set Y back to the proper low-byte index
LDA #0       ; Load black
STA ($7, X)  ; Clear the last element in the tail
LDA $1       ; Load the head low byte
STA ($c), Y ; Store into the low byte for the "last" tail element (visually last)
STA $7
INY
LDA $2       ; Load the head high byte
STA ($c), Y  ; Store into the high byte for the "last" tail element (visually last)
STA $8
LDA $c       ; Load the low byte of index
BNE dontContained; Check if the index is 0, if so, do the contained code
LDA $a       ; If it is, reset it back to the length - 2
STA $c
DEC $d
LDA $d       ; Now begin checking the high byte
CMP #$f
BNE dontContained ; Check if the high byte index is $10, if so, do the contained code
LDA $b
STA $d
LDA $c
BNE dontContained ; Check if the low byte is 0 again
DEC $d            ; If so, decrement high byte
dontContained: 
DEC $c       ; Decrement Y twice to find the new final element
DEC $c
LDY #0
RTS

;; Increase the tail length by 1, length passed through A
increaseTail:
ASL          ; Multiply the length to add by 2
STA $9       ; Store the length to add into the tmp address
LDA $a       ; Load the snake length into A
CLC
ADC $9       ; Add the length to add
STA $a       ; Store new length
LDA $b       ; Load the snake high byte
ADC #0       ; Add the carry bit
STA $b
RTS

;; Create new item on the field, pick up to gain more tail length
makeItem:
PHA 
LDX #0;
LoadRND:
LDY $fe      ; Load random low-byte into Y
STY $7
LDA $fe      ; Load random high-byte into A
AND #3       ; And with binary 11, puts in range of 0-3
CLC
ADC #2       ; Add 2
STA $8       ; Store into the tmp byte
LDA ($7, X)  ; Load the colour at the position on the screen
BNE LoadRND  ; If it's not black, find another spot
LDA #$8      ; Otherwise, Load orange
STA ($7, X)  ; Store to random point on screen (pointer)
LDY #0
PLA
RTS
