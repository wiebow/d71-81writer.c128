
// some default kernal calls for disk IO use.
// ----

// closes the buffer channel (2)

BUFFER_CHANNEL_CLOSE:
        lda #2
        jmp CLOSE

// opens drive buffer (#) as logical file 2.
// carry bit is set if command fails.

BUFFER_CHANNEL_OPEN:
        lda #2              // logical file number
        ldx device          // device number
        ldy #2              // command number
        jsr SETLFS

        lda #1
        ldy #>buffer_name
        ldx #<buffer_name
        jsr SETNAM
        jsr OPEN
!exit:
        rts

buffer_name:
        .text "#"

// closes command channel (15) and files and resets all i/o

COMMAND_CHANNEL_CLOSE:
        lda #15
        jmp CLOSE

// opens a command channel (15)
// uses entered device id
// carry bit is set if command failed.

COMMAND_CHANNEL_OPEN:
        lda #15             // logical file number
        ldx device          // device number
        ldy #15             // command number
        jsr SETLFS
        lda #0              // no file name
        jsr SETNAM
        jsr OPEN            // open channel, using parameters
!exit:
        rts
