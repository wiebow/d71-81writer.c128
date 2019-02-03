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
        jsr GET_DECIMAL
        jsr NEW_LINE
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
        .text "Destination device (8 or 9): "
        .byte 0
