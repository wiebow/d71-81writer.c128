// ui_input
// --------
// Some functions that allow the user to input data.
// The data is processed accordingly.
// This file relies on input.asm

// ------------------------------------------
// Ask for the d71 file name
ENTER_D71_FILE_NAME:
        lda #>str_enter_d71_file_name
        ldx #<str_enter_d71_file_name
        jsr PRINT
        jsr GET_TEXT
        jsr NEW_LINE
        rts

// ------------------------------------------
// Ask for the d81 file name
ENTER_D81_FILE_NAME:
        lda #>str_enter_d81_file_name
        ldx #<str_enter_d81_file_name
        jsr PRINT
        jsr GET_TEXT
        jsr NEW_LINE
        rts

// ------------------------------------------
// Ask for the device number
ENTER_DEVICE:
        lda #>str_enter_device
        ldx #<str_enter_device
        jsr PRINT
        ldy #3                  // permit 3 characters
        jsr GET_DECIMAL
        jsr NEW_LINE
        lda #0                  // reset device
        sta device
        ldy INPUT_LEN
device_digit:        
        // set the device number in the disk writer
        dey
        lda INPUT_BUFFER,y
        sec
        sbc #$30
        sta device
        dey
        bmi device_entered
        lda INPUT_BUFFER,y
        sec
        sbc #$30
        tax
        beq device_entered
device_ten:
        // A two digit device number requires this addition
        lda #$0a
        clc
        adc device
        sta device
        dex
        beq device_entered
        jmp device_input_error
device_entered:
        // sanity check on device
        lda device
        cmp #8
        beq !+
        cmp #9
        beq !+
        cmp #10
        beq !+
        cmp #11
        beq !+
device_input_error:
        jsr DISPLAY_ERROR_DEVICENR
        jmp ENTER_DEVICE
!:
        rts

// ------------------------------------------
// Ask and set the dos path.
ENTER_DOS_PATH:
        lda #>str_enter_path
        ldx #<str_enter_path
        jsr PRINT
        jsr GET_TEXT
        jsr NEW_LINE
        rts

// ------------------------------------------
.encoding "petscii_mixed"
str_enter_path:
        .text "Enter new path: "
        .byte 0
str_enter_d71_file_name:
        .text "D71 file name: "
        .byte 0
str_enter_d81_file_name:
        .text "D81 file name: "
        .byte 0
str_enter_device:
        .text "Destination device: "
        .byte 0
