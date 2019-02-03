
// using standard kernal calls
// main entry
// carry bit is set on return if an error occurs


/*
If there is a possibility that the
disk drive connected to the C-128 is not
a 1571 or that the 1571 has been set to
1541 mode, you can test bit 6 of the fast
serial flag (RAM location $0a lc, decimal
2588). If this bit is set after an open
operation (in either BASIC or ML), then
the drive is a fast device (i.e. a 1571 in
fast mode).
*/

WRITE_D81:
        // set 1581 fast mode

        jsr SET_1581_FAST

        // check for fast serial
        // should have been set by 1581 fast mode.

        bit SERIAL              // check bit 6
        bvs !+                  // if flow bit set, then fast serial is available
        lda #CYAN
        sta $d020
        sec
        rts
!:
        // open buffer channel for data

        jsr BUFFER_CHANNEL_OPEN
        bcc write_d81_loop
        lda #WHITE
        sta $d020
        sec
        rts

        // actual write loop

write_d81_loop:

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
        lda current_sector              // which sector are we now?
        cmp #40                         // 1581 always has 40 sectors
        beq next_track_d81              // go to next track
        jmp write_d81_loop              // do next sector in this track

next_track_d81:

        // start at sector 0 in next track

        lda #0
        sta current_sector
        jsr RESET_SECTOR

        // go to next track

        jsr NEXT_TRACK                  // update command string
        inc current_track               // update track counter
        lda current_track
        cmp #81                         // all tracks done?
        bne write_d81_loop              // do next track
        clc                             // no error
        rts

// Sets 1581 in fast serial mode

SET_1581_FAST:
        ldx #15
        jsr CHKOUT              // use file 15 (command) as output.

        ldy #0
!:
        lda fs_command,y        // read byte from command string
        jsr BSOUT               // send to command channel
        iny
        cpy #fs_command_end - fs_command
        bne !-
        jsr CLRCH               // execute sent command
        rts

fs_command:
        .text "U0>B1"
fs_command_end:

// see write.asm for the rest of the common routines
