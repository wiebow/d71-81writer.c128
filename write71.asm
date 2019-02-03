
// using standard kernal calls



// main entry
// carry bit is set on return if an error occurs
WRITE_D71:
        jsr SET_1571_MODE       // set drive in 1571 mode

        // check for fast serial

        bit SERIAL              // check bit 6
        bvs !+                  // if set, then fast serial is available
        lda #3
        sta $d020
        sec
        rts
!:
        // open buffer channel for data

        jsr BUFFER_CHANNEL_OPEN
        bcc write_d71_loop
        lda #1
        sta $d020
        sec
        rts

        // actual write loop

write_d71_loop:

        jsr DISPLAY_PROGRESS            // print progress string
        jsr DISPLAY_PROGRESS_HOME       // move cursor to column 0

        // get sector data from reu to memory buffer
        // 256 bytes

        jsr REU_TRANSFER_SECTOR
        jsr CHECK_BUFFER_EMPTY          // all 0's means empty sector
        bcc !+                          // carry bit clear means buffer is empty
        jsr WRITE_SECTOR                // write to disk
!:
        jsr NEXT_SECTOR                 // update command string
        inc current_sector              // update sector counter
        ldx current_track               // get index to table
        lda sectors_1571,x              // get # sectors in this track
        cmp current_sector              // all track sectors done?
        beq next_track_d71              // go to next track
        jmp write_d71_loop              // do next sector in this track

next_track_d71:

        // start at sector 0 in next track

        lda #0
        sta current_sector
        jsr RESET_SECTOR

        // go to next track

        jsr NEXT_TRACK                  // update command string
        inc current_track               // update track counter
        lda current_track
        cmp #71                         // all tracks done?
        bne write_d71_loop              // do next track
        clc                             // no error
        rts





// --------------------------------------------------------------------------
// resets block pointer to position 0
// assumes channel 15 is open, and channel 2 is used for block operations

RESET_BLOCK_POINTER:
        ldx #15
        jsr CHKOUT          // use file 15 (command) as output.

        ldy #0
!loop:
        lda bp_command,y    // read byte from command string
        jsr BSOUT          // send to command channel
        iny
        cpy #bp_command_end - bp_command
        bne !loop-
        jsr CLRCH          // execute sent command
        rts

bp_command:
        .text "B-P 2 0"
bp_command_end:


// Sets 1571 drive in double sided mode

SET_1571_MODE:
        ldx #15
        jsr CHKOUT              // use file 15 (command) as output.

        ldy #0
!:
        lda ds_command,y        // read byte from command string
        jsr BSOUT               // send to command channel
        iny
        cpy #ds_command_end - ds_command
        bne !-
        jsr CLRCH               // execute sent command
        rts

ds_command:
        .text "U0>M1"
ds_command_end:


// see track.asm for the rest of the common routines


// -------------------------------------------------



// 1571 # of sectors per track
// sectors start at 0, tracks start at 1

sectors_1571:
        .byte 0
        // side 1, track 1
        .byte 21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21 // 17
        .byte 19,19,19,19,19,19,19 // 7
        .byte 18,18,18,18,18,18    // 6
        .byte 17,17,17,17,17       // 5
        // side 2, track 36
        .byte 21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21
        .byte 19,19,19,19,19,19,19
        .byte 18,18,18,18,18,18
        .byte 17,17,17,17,17


