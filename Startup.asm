
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
.import source "write71.asm"
.import source "write81.asm"
.import source "write.asm"

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
MENU:
#if !EMU

        jsr CLOSE_RESOURCES
#endif  
        jsr DISPLAY_DOS_PATH    // display the current path (again)
        jsr DISPLAY_MENU        // ask what to do
get_option:
        jsr GETIN
        beq get_option
        cmp #$0d                // enter is exit
        bne !+
        rts
!:
        // determine action
        cmp #$31
        beq MENU_CHANGE_PATH
        cmp #$32
        beq MENU_WRITE_FILE
        jmp get_option          // Unknown option

MENU_CHANGE_PATH:
        jsr ENTER_DOS_PATH      // ask and set new path name
        jsr ULT_SET_PATH
        jsr DISPLAY_ULT_STATUS  // get and print status        
        jmp MENU


MENU_WRITE_FILE:       
        jsr ENTER_FILE_NAME     // ask for the filename
        lda INPUT_BUFFER                
        bne !+                  // empty filename means back to // empty filename means back to menu
        jmp MENU            
#if !EMU // Emulator cannot open the file so just pretend here
!:
        jsr ULT_OPEN_FILE_READ  // attempt to open the file
        jsr DISPLAY_ULT_STATUS  // get and print status
        jsr STATUS_OK           // check status. 0=ok
        beq !+
        jmp MENU
#endif
!:
        jsr DETERMINE_IMAGE_TYPE
        lda IMAGE_TYPE        
        bne !+
        jmp MENU                // Unconfirmed image type means back to MENU
!:
        // ask for the device        
        jsr ENTER_DEVICE        // get destination id
        lda device
        bne !+
        jmp MENU                // Unconfirmed device means back to MENU
!:
        jsr WRITE
        bcs ERROR_OCCURRED
        jmp ALL_DONE

CLOSE_RESOURCES:
        jsr BUFFER_CHANNEL_CLOSE
        jsr COMMAND_CHANNEL_CLOSE
        jsr ULT_CLOSE_FILE
        rts

DETERMINE_IMAGE_TYPE:
        lda #$00
        sta IMAGE_TYPE
        ldx #$00
        ldy INPUT_LEN
        cpy #$03
        bcc select_manually
        dey
        dey
        dey
!:
        lda INPUT_BUFFER,y
        sta extension,x
        beq !+ // Null termination        
        inx
        iny
        jmp !-
!:        
        lda #<extension
        sta str_a
        lda #>extension
        sta str_a + 1
        lda #<d71_extension
        sta str_b
        lda #>d71_extension
        sta str_b + 1
        jsr STRCMP
        bne !+
SELECTED_D71_IMAGE:
        jsr DISPLAY_SELECTED_D71
        lda #$01
        sta IMAGE_TYPE
        rts
!:      lda #<d81_extension
        sta str_b
        lda #>d81_extension
        sta str_b + 1
        jsr STRCMP
        bne select_manually
SELECTED_D81_IMAGE:
        jsr DISPLAY_SELECTED_D81
        lda #$02
        sta IMAGE_TYPE
        rts
select_manually:        
        jmp SELECT_IMAGE_TYPE        

// --------------------------------------------------
        
ERROR_OCCURRED:
        jsr DISPLAY_FAIL       
        jmp MENU
ALL_DONE:
        jsr DISPLAY_DONE
        jmp MENU
CLOSE_APP:
        jsr DISPLAY_EXIT
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
extension:
        .text "AAA"
        .byte 0
IMAGE_TYPE:
        .byte 0
status:
        .byte 0, 0

status_ptr:
        .byte 0

.encoding "petscii_mixed"
d71_extension:
        .text "d71"
        .byte 0
d81_extension:
        .text "d81"
        .byte 0

/*
FOR SOME REASON THE UI FUNCTIONS MUST BE AT THE END
DO NOT MOVE THESE!
*/
.import source "ui_input.asm"
.import source "ui_output.asm"