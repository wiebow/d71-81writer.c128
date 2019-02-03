// ui_output
// ---------
// Some functions to display data to the user
// It relies on ultio.asm to get the data

// ------------------------------------------
// Display a friendly welcome message
DISPLAY_WELCOME:
        lda #>str_welcome
        ldx #<str_welcome
        jsr PRINT
        rts

// ------------------------------------------
// Display exit message
DISPLAY_EXIT:
        lda #>str_exit
        ldx #<str_exit
        jsr PRINT
        rts

// ------------------------------------------
// display menu with 3 options.
DISPLAY_MENU:
        lda #>str_menu
        ldx #<str_menu
        jsr PRINT
        rts

// ------------------------------------------
// Display ultimate dos version
DISPLAY_ULTIDOS:
        jsr ULT_GET_DOS
        jsr ULT_DISPLAY_DATA
        jsr NEW_LINE
        rts

// ------------------------------------------
// Display no ultimate dos found message
DISPLAY_NODOS_ERROR:
        lda #>str_ult_dos_error
        ldx #<str_ult_dos_error
        jsr PRINT
        rts

// ------------------------------------------
// Display the path the ultimate is looking at
DISPLAY_DOS_PATH:
        lda #>str_current_path
        ldx #<str_current_path
        jsr PRINT
        jsr ULT_GET_PATH
        jsr ULT_DISPLAY_DATA
        jsr NEW_LINE
        rts

// ------------------------------------------
// Set the cursor home after track and sector were displayed
DISPLAY_PROGRESS_HOME:
        ldx #18
        lda #$9d
!next:
        jsr BSOUT
        dex
        bne !next-
        rts

// ------------------------------------------
// Display done message
DISPLAY_DONE:
        lda #>str_done
        ldx #<str_done
        jsr PRINT
        rts

// ------------------------------------------
// Display fail message
DISPLAY_FAIL:
        lda #>str_fail
        ldx #<str_fail
        jsr PRINT
        rts

// ------------------------------------------
// Display OK message
DISPLAY_OK:
        lda #>str_ok
        ldx #<str_ok
        jsr PRINT
        rts

// ------------------------------------------
// Display D71 message
DISPLAY_SELECTED_D71:
        lda #>str_selected_d71
        ldx #<str_selected_d71
        jsr PRINT
        rts

// ------------------------------------------
// Display D81 message
DISPLAY_SELECTED_D81:
        lda #>str_selected_d81
        ldx #<str_selected_d81
        jsr PRINT
        rts

// ------------------------------------------
// Display device error message
DISPLAY_ERROR_DEVICENR:
        lda #>str_error_devicenr
        ldx #<str_error_devicenr
        jsr PRINT
        rts

// ------------------------------------------
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

// Display emulation warning
// (for when testing this with vice)
#if EMU
DISPLAY_EMU_WARNING:
        lda #>str_emu
        ldx #<str_emu
        jsr PRINT
        rts
#endif

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
        .byte $0e, $08 // lowercase set (lower-> upper, upper->lower)
        .text "D71/81 writer C128 v1.1"
        .byte $0d
        .text "     by Ernoman and WdW"
        .byte $0d, 0
str_exit:
        .byte $09, $0d, 0        
str_ult_dos_error:
        .text "! No Ultimate DOS detected."
        .byte $0d, $0d, 0
str_current_path:
        .text "Current DOS path is: "
        .byte 0
str_menu:
        .byte $0d, $0d        
        .text "1.Change path, 2.Write Disk Image"
        .byte $0d, 0
str_fail:
        .byte $0d
        .text "Fail"
        .byte $0d, 0
str_ok:
        .byte $0d
        .text "OK"
        .byte $0d, 0
str_track:
        .text "Track "
        .byte 0
str_sector:
        .text "sector "
        .byte 0
str_done:
        .byte $0d
        .text "Done!"
        .byte $0d, $0d, 0
str_selected_d71:
        .text "Selected D71 image"
        .byte $0d, 0
str_selected_d81:
        .text "Selected D81 image"
        .byte $0d, 0        
str_default_path:
        .text "/usb0/"
        .byte 0
str_error_cmd:
        .text "! Cannot open CMD to "
        .byte 0
str_error_buffer:
        .text "! Cannot open buffer to "
        .byte 0
str_error_devicenr:
        .text "! Illegal device nr."
        .byte $0d, 0        
#if EMU
str_emu:
        .byte $0d
        .text "EMU build. Ultimate parts are skipped!"
        .byte $0d
        .text "DO NOT RELEASE"
        .byte $0d
        .byte $0d
        .byte 0
#endif
