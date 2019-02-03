
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

WRITE_81:
        jsr ENTER_D81_FILE_NAME     // ask for the filename
        jsr ULT_OPEN_FILE_READ      // attempt to open the file
        jsr DISPLAY_ULT_STATUS      // get and print status
        jsr STATUS_OK               // check status. 0=ok
        beq !+
        rts                         // abort
!:
        // ask for the device
        jsr ENTER_DEVICE        // get destination id
        // open command channel to device

        jsr COMMAND_CHANNEL_OPEN
        bcc !+
        lda #RED
        sta $d020
        rts                     // abort
!:
        // Have the ultimate place the file in the REU
        // Note; reading the file using the read function seems to miss
        // every first byte on each transfer. Doing this via the REU seems to
        // work fine.

        jsr ULT_FILE_READ_REU
        jsr STATUS_OK
        beq !+
        sec                     // set carry bit to indicate problem
        rts                     // return
!:
        // Setup the REU transfer initial state

        jsr REU_SETUP_TRANSFER

        // set zero page pointer to sector buffer in ram

        lda #<sector_buffer
        sta buffer
        lda #>sector_buffer
        sta buffer+1

        // reset CMD string

        jsr RESET_SECTOR
        jsr RESET_TRACK

        // start at track 1, sector 0

        ldx #0
        stx current_sector
        inx
        stx current_track

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
        bcc write_d81
        lda #WHITE
        sta $d020
        sec
        rts

        // actual write loop

write_d81:

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
        jmp write_d81                   // do next sector in this track

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
        bne write_d81                   // do next track
        jsr DISPLAY_DONE                // display done
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
