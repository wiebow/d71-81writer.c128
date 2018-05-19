// Reu transfer
// ------------
// Transfers sectors from reu to the sector buffer
// http://www.zimmers.net/anonftp/pub/cbm/documents/chipdata/programming.reu

.const REU_STATUS   = $DF00
.const REU_COMMAND  = $DF01
.const REU_C64BASE_L  = $DF02
.const REU_C64BASE_H  = $DF03
.const REU_REUBASE_L  = $DF04
.const REU_REUBASE_H  = $DF05
.const REU_REUBASE_BNK = $DF06
.const REU_TRANSLEN_L = $DF07
.const REU_TRANSLEN_H = $DF08
.const REU_IRQMASK  = $DF09
.const REU_CONTROL  = $DF0A

REU_SETUP_TRANSFER:
    lda #%00000000      //  Increase addresses
    sta REU_CONTROL
    lda #0
    sta REU_REUBASE_L
    sta REU_REUBASE_H
    sta REU_REUBASE_BNK
    rts

REU_TRANSFER_SECTOR:

    // set pointer to address where data will be placed (local)
    lda #<sector_buffer
    sta REU_C64BASE_L
    lda #>sector_buffer
    sta REU_C64BASE_H

    // set length of transfer action

    lda #<$0100             //  lobyte of 256
    sta REU_TRANSLEN_L
    lda #>$0100             //  hibyte of 256
    sta REU_TRANSLEN_H

    lda #%10010001      //  REU -> c64 with immediate execution
    sta REU_COMMAND
    rts
