// Keyboard input
// --------------
//
// Uses the kernel to get data from the keyboard.
// Taken from http://codebase64.org/doku.php?id=base:robust_string_input
//
//======================================================================
//Input a string and store it in INPUT_BUFFER, terminated with a null byte.
//x:a is a pointer to the allowed list of characters, null-terminated.
//max # of chars in y returns num of chars entered in y.
//======================================================================

// Get alphanumeric text

GET_TEXT:
    lda #>ALPHANUM_FILTER
    ldx #<ALPHANUM_FILTER
    ldy #32
    jmp FILTERED_INPUT

// Get decimal numbers.
// y = max chars

GET_DECIMAL:
    lda #>DECIMAL_FILTER
    ldx #<DECIMAL_FILTER
    jmp FILTERED_INPUT

// y = max chars
// x = lsb filter string
// a = msb filter string
FILTERED_INPUT:
    sty MAXCHARS
    stx allowed+1           // set pointer to filter list.
    sta allowed+2
    lda #$00                // Zero characters received.
    sta INPUT_LEN
    sta INPUT_BUFFER
    jsr print_cursor

get_input:
    jsr GETIN
    beq get_input
    sta LASTCHAR            // store character typed
    cmp #$14                // Delete
    beq delete
    cmp #$0d                // Return
    beq input_done

    // Check the allowed list of characters.

    ldx #$00
allowed:
    lda $FFFF,x             // get allowed char list
    beq get_input           // reached end with no match
    cmp LASTCHAR
    beq input_ok             // Match found
    inx
    jmp allowed             // get next character

input_ok:
    lda INPUT_LEN
    cmp MAXCHARS          // max length reached?
    bne !+
    dec INPUT_LEN         // replace last character in buffer
    lda #$9d              // do crsr left  on screen
    jsr BSOUT
!:    
    lda LASTCHAR          // get typed character
    ldy INPUT_LEN         // get buffer index
    sta INPUT_BUFFER,y    // Add char to buffer
    jsr BSOUT             // Print it
    jsr print_cursor
    inc INPUT_LEN         // update index
    lda INPUT_LEN
    jmp get_input

input_done:
    ldy INPUT_LEN
    lda #$00
    sta INPUT_BUFFER,y    // Zero-terminate the input buffer
    jsr remove_cursor
    rts

delete:
    lda INPUT_LEN
    beq get_input
    dec INPUT_LEN
    lda #$14              // do back space on screen
    jsr BSOUT
    jmp get_input

print_cursor:
    lda #>CURSOR
    ldx #<CURSOR
    jsr PRINT
    rts

remove_cursor:
    lda #>CURSOR_REM
    ldx #<CURSOR_REM
    jsr PRINT
    rts


DECIMAL_FILTER:
  .text "1234567890"
  .byte 0

ALPHANUM_FILTER:
  .text " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,-+!#$%&'()*/"
  .byte 0

MAXCHARS:
  .byte 0

LASTCHAR:
  .byte 0

INPUT_LEN:
  .byte 0

INPUT_BUFFER:
  .fill 32, 0

CURSOR:
  .byte $12, $20, $92, $9d, 0
CURSOR_REM:
  .byte $20, 0