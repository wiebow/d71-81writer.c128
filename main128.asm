
/*
 D71 and D81 writer for Commodore 128
 (C) 2018 by Wiebo de Wit
 Based on sources by Ernoman. Thanks!
*/

.import source "c128system.asm"
.import source "c128macros.asm"

:BasicUpstart128(MAIN)

.import source "input.asm"
.import source "ultio.asm"
.import source "reu.asm"
.import source "diskio.asm"
.import source "write71.asm"
.import source "write81.asm"

MAIN:
        :SetBankConfiguration(15)
        jsr DISPLAY_WELCOME
        jsr DISPLAY_ULTIDOS
        cpx #10                 // x is incremented for each char printed
        bcs !+                  // =>10 chars printed, so DOS is available
        jsr DISPLAY_NODOS_ERROR
        rts                     // fail. exit.
!:
        // todo : REU check
        // set and display current DOS path. default is /usb0/

        ldy #0
!:
        lda str_default_path,y
        beq !+
        sta INPUT_BUFFER,y      // force path text to input buffer space
        iny
        jmp !-
!:
        jsr ULT_SET_PATH        // set path using input buffer
        jsr DISPLAY_DOS_PATH

        // ask what to do
menu:
        jsr DISPLAY_MENU
!:
        jsr $ffe4
        beq !-
        cmp #$0d                // enter is exit
        bne !+
        rts
!:
        // determine action

        cmp #$31
        bne !+
        jsr ENTER_DOS_PATH      // ask and set new path name
        jsr DISPLAY_ULT_STATUS  // get and print status
        jsr DISPLAY_DOS_PATH    // display the current path again
        jmp menu
!:
        cmp #$32
        bne !+
        jsr WRITE_71
        bcs error_occurred
        jmp menu
!:
        cmp #$33
        bne menu+3              // ask again
        jsr WRITE_81
        bcs error_occurred
        jmp menu

// --------------------------------------------------

!finish:
        jsr DISPLAY_DONE
        jmp CLOSE_APP
error_occurred:
        jsr DISPLAY_FAIL
CLOSE_APP:
        jsr BUFFER_CHANNEL_CLOSE
        jsr COMMAND_CHANNEL_CLOSE
        jsr ULT_CLOSE_FILE
        rts

// checks if memory buffer is empty.
// carry bit is cleared if buffer is empty, set when not.

CHECK_BUFFER_EMPTY:
        ldy #0
!:
        lda (buffer),y
        bne !+
        iny
        bne !-
        clc
        rts
!:
        sec
        rts

// Display a friendly welcome message

DISPLAY_WELCOME:
        lda #>str_welcome
        ldx #<str_welcome
        jsr PRINT
        rts

// display menu with 3 options.

DISPLAY_MENU:
        lda #>str_menu
        ldx #<str_menu
        jsr PRINT
        jsr NEW_LINE
        rts

// Display ultimate dos version

DISPLAY_ULTIDOS:
        jsr ULT_GET_DOS
        jsr ULT_DISPLAY_DATA
        jsr NEW_LINE
        rts

// Display no ultimate dos found message

DISPLAY_NODOS_ERROR:
        lda #>str_ult_dos_error
        ldx #<str_ult_dos_error
        jsr PRINT
        rts

// Display the path the ultimate is looking at

DISPLAY_DOS_PATH:
        lda #>str_current_path
        ldx #<str_current_path
        jsr PRINT
        jsr ULT_GET_PATH
        jsr ULT_DISPLAY_DATA
        jsr NEW_LINE
        rts

// Set the cursor home after track and sector were displayed

DISPLAY_PROGRESS_HOME:
        ldx #18
        lda #$9d
!next:
        jsr BSOUT
        dex
        bne !next-
        rts

// Display done message

DISPLAY_DONE:
        lda #>str_done
        ldx #<str_done
        jsr PRINT
        rts

// Display fail message

DISPLAY_FAIL:
        lda #>str_fail
        ldx #<str_fail
        jsr PRINT
        rts

// Display OK message

DISPLAY_OK:
        lda #>str_ok
        ldx #<str_ok
        jsr PRINT
        rts

// Ask for the d71 file name

ENTER_D71_FILE_NAME:
        lda #>str_enter_d71_file_name
        ldx #<str_enter_d71_file_name
        jsr PRINT
        jsr GET_TEXT
        jsr NEW_LINE
        rts

// Ask for the d81 file name

ENTER_D81_FILE_NAME:
        lda #>str_enter_d81_file_name
        ldx #<str_enter_d81_file_name
        jsr PRINT
        jsr GET_TEXT
        jsr NEW_LINE
        rts

// Ask for the device number

ENTER_DEVICE:
        lda #>str_enter_device
        ldx #<str_enter_device
        jsr PRINT
        jsr GET_DECIMAL
        jsr NEW_LINE
        rts

// Ask and set the dos path.

ENTER_DOS_PATH:
        lda #>str_enter_path
        ldx #<str_enter_path
        jsr PRINT
        jsr GET_TEXT
        jsr NEW_LINE
        jsr ULT_SET_PATH
        rts

// Display the current track and sector

DISPLAY_PROGRESS:
        lda #>str_track
        ldx #<str_track
        jsr PRINT
        ldx #$00
!:
        lda write_track,x   // found in write71.asm
        jsr BSOUT
        inx
        cpx #$03
        bne !-

        lda #>str_sector
        ldx #<str_sector
        jsr PRINT
        ldx #$00
!:
        lda write_sector,x
        jsr BSOUT
        inx
        cpx #$02
        bne !-
        rts

// Set cursor at a new line

NEW_LINE:
        lda #$0d
        jsr BSOUT
        rts

// print until 0 is reached

PRINT:
        stx stringaddr+1
        sta stringaddr+2
        ldy #$00
stringaddr:
        lda $ffff,y
        beq !+
        jsr BSOUT
        iny
        jmp stringaddr
!:
        rts

// ------------------------------------------

.encoding "petscii_mixed"

str_welcome:
        .byte $93 // clear
        .byte $0e // lowercase set (lower-> upper, upper->lower)
        .text "D71/81 writer C128 v1 by Ernoman and WdW"
        .byte $0d, 0
str_ult_dos_error:
        .text "! No Ultimate DOS detected."
        .byte $0d, $0d, 0
str_current_path:
        .text "Current DOS path is: "
        .byte 0
str_menu:
        .byte $0d
        .text "1.change path, 2.write D71, 3.write D81"
        .byte $0d, 0
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
str_fail:
        .text "Fail!"
        .byte $0d, 0
str_ok:
        .text "OK."
        .byte $0d, 0
str_track:
        .text "Track "
        .byte 0
str_sector:
        .text "sector "
        .byte 0
str_done:
        .byte $0d,$0d
        .text "Done!"
        .byte 0
str_default_path:
        .text "/usb0/"
        .byte 0
str_error_cmd:
        .text "! Cannot open CMD to "
        .byte 0
str_error_buffer:
        .text "! Cannot open buffer to "
        .byte 0

// status read from the ultimate

status:
        .byte 0, 0

status_ptr:
        .byte 0
