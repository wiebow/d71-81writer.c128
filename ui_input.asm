// ui_input
// --------
// Some functions that allow the user to input data.
// The data is processed accordingly.
// This file relies on input.asm

// ------------------------------------------
// Ask for the d71 file name
ENTER_FILE_NAME:
        lda #>str_enter_file_name
        ldx #<str_enter_file_name
        jsr PRINT
        jsr GET_TEXT
        jsr NEW_LINE
        rts

// ------------------------------------------
// Ask for image type
SELECT_IMAGE_TYPE:
        lda #>str_select_image_type
        ldx #<str_select_image_type
        jsr PRINT

!:
        jsr GETIN
        beq !-
        cmp #$0d                // enter is exit
        bne !+
        rts
!:
        // determine action
        cmp #$31
        beq selected_d71
        cmp #$32
        beq selected_d81
        rts
selected_d71:
        jmp SELECTED_D71_IMAGE
selected_d81:
        jmp SELECTED_D81_IMAGE

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
        // TODO: Len = 0 =rts
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
// Strcmp (placed here as we are comparing user input)
// Arguments:
// str_a: First string
// str_b: Second string
// Returns comparison result in A:
// -1: First string is less than second
// 0: Strings are equal
// 1; First string is greater than second
.label str_a = $FC
.label str_b = $FE
STRCMP:
    ldy #$00        
scload:
    lda (str_a), y    
    cmp (str_b), y    
    bne scdone      
    iny             
    cmp #$00        
    bne scload      
    lda #$00        
    rts             
scdone:
    bcs scgrtr
    lda #$FF
    rts             
scgrtr:
    lda #$01       
    rts

// ------------------------------------------
.encoding "petscii_mixed"
str_enter_path:
        .text "Enter new path: "
        .byte 0
str_enter_file_name:
        .text "Disk image file name: "
        .byte 0
str_enter_device:
        .text "Destination device: "
        .byte 0
str_select_image_type:
        .text "1.D71 image, 2.D81 image"
        .byte 0
