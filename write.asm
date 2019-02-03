// write
// -----
// Common stuff used for writing


// --------------------------------------------------------------------------
// writes memory buffer to disk.
// write_track and write_sector strings need to be up to date.
// assumes channels 2 (buffer) and 15 (command) are open.

.label buffer   = $fb  // sector buffer zero page pointer

WRITE:
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

        lda IMAGE_TYPE        
        cmp #$01
        beq image_type_d71      // Continue for D71
        cmp #$02
        beq image_type_d81      // Continue for D81
        brk                     // This should be unreachanle. Extend here on more image types.        
image_type_d71:
        jsr WRITE_D71
        rts
image_type_d81:
        jsr WRITE_D81
        rts

.align $100
WRITE_SECTOR:
        jsr RESET_BLOCK_POINTER

        // send 256 bytes to the drive buffer.

        ldx #2
        jsr CHKOUT              // use file 2 (buffer) as output.

        ldy #0
!:
        lda (buffer),y
        jsr BSOUT
        iny
        bne !-

        // send drive buffer to disk.

        ldx #15
        jsr CHKOUT              // use file 15 (command) as output.

        ldy #0
!:
        lda u2_command,y       // read byte from command string.
        jsr BSOUT              // send to command channel.
        iny
        cpy #u2_command_end - u2_command
        bne !-

        jsr CLRCH              // execute sent command
        rts

u2_command:     .text "U2 2 0 "
write_track:    .text "01 "             // modified during write
write_sector:   .text "00"              // same
u2_command_end:

// --------------------------------------------------------------------------
// Zero track administration. put '01' in command string.
RESET_TRACK:
        lda #$30
        sta write_track+0
        lda #$31
        sta write_track+1
        rts

// --------------------------------------------------------------------------
// Zero sector administration. put '00' in command string.
RESET_SECTOR:
        lda #$30
        sta write_sector+0
        sta write_sector+1
        rts

// --------------------------------------------------------------------------
// text Advance one track
NEXT_TRACK:
        inc write_track+1
        lda write_track+1
        cmp #$3a
        beq !+
        rts
!:
        inc write_track+0
        lda #$30
        sta write_track+1
        rts

// --------------------------------------------------------------------------
// text Advance one sector
NEXT_SECTOR:
        inc write_sector+1
        lda write_sector+1
        cmp #$3a
        beq !+
        rts
!:
        inc write_sector+0
        lda #$30
        sta write_sector+1
        rts

// --------------------------------------------------------------------------
// loop counters
current_track:
        .byte 0
current_sector:
        .byte 0
device:
        .byte $09

// --------------------------------------------------------------------------
.align $100      // align sector buffer to nearest page boundary
sector_buffer:
        .fill 256,$f0