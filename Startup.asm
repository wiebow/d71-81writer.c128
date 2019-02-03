
/*
 D71 and D81 writer for Commodore 128
 (C) 2018 by Wiebo de Wit
 Based on sources by Ernoman. Thanks!
*/

.disk [filename="d7181_for_ult.d64"]
{
    [name="D7181 FOR ULT", type="prg", segments="prg_segment" ]
}

.segment prg_segment [ outPrg="d7181_for_ult.prg" ]

.import source "c128system.asm"
.import source "c128macros.asm"

:BasicUpstart128(MAIN)

.import source "input.asm"
.import source "ultio.asm"
.import source "reu.asm"
.import source "diskio.asm"
.import source "write.asm"
.import source "write71.asm"
.import source "write81.asm"

MAIN:
        :SetBankConfiguration(15)
        jsr DISPLAY_WELCOME
#if !EMU
        jsr DISPLAY_ULTIDOS
        cpx #10                 // x is incremented for each char printed
        bcs !+                  // =>10 chars printed, so DOS is available
        jsr DISPLAY_NODOS_ERROR
        rts                     // fail. exit.
#else
        jsr DISPLAY_EMU_WARNING
#endif
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
        jsr ULT_SET_PATH
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


// status read from the ultimate

status:
        .byte 0, 0

status_ptr:
        .byte 0
/*
FOR SOME REASON THE UI FUNCTIONS MUST BE AT THE END
DO NOT MOVE THESE!
*/
.import source "ui_input.asm"
.import source "ui_output.asm"