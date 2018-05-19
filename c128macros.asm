
#importonce // and import AFTER c128system.asm

/*----------------------------------------------------------
 BasicUpstart for C128

 Syntax:    :BasicUpstart(address)
 Usage example: :BasicUpstart($2000)
             Creates a basic program that sys' the address
------------------------------------------------------------*/
.macro BasicUpstart128(address) {
    .pc = $1c01 "C128 Basic"
    .word upstartEnd  // link address
    .word 10   // line num
    .byte $9e  // sys
    .text toIntString(address)
    .byte 0
upstartEnd:
    .word 0  // empty link signals the end of the program
    .pc = $1c0e "Basic End"
}

/*----------------------------------------------------------
 Banking, RAM configurations

 bits:
 0:   $d000-$dfff (i/o block, ram or rom)
 1:   $4000-$7fff (lower basic rom)
 2-3: $8000-$bfff (upper basic rom, monitor, internal/external ROM)
 4-5: $c000-$ffff (char ROM, kernal, internal/external ROM, RAM)
 6:   select RAM block

 Setting a bit means RAM, clearing means ROM.
 Use the BASIC Bank configuration numbers.

 Syntax:		:SetBankConfiguration(number)
----------------------------------------------------------*/
.macro SetBankConfiguration(id) {
	.if(id==0) {
		lda #%00111111 	// no roms, RAM 0
	}
	.if(id==1) {
		lda #%01111111 	// no roms, RAM 1
	}
	.if(id==12) {
		lda #%00000110 	// internal function ROM, Kernal and IO, RAM 0
	}
	.if(id==14) {
		lda #%00000001 	// all roms, char ROM, RAM 0
	}
	.if(id==15) {
		lda #%00000000  // all roms, RAM 0. default setting.
	}
	.if(id==99) {
		lda #%00001110  // IO, kernal, RAM0. No basic,48K RAM.
	}
	sta MMUCR
}


/*----------------------------------------------------------
Configure common RAM amount.

RAM Bank 0 is always the visible RAM bank.
Valid values are 1,4,8 and 16.

Syntax:		:SetCommonRAM(1)
----------------------------------------------------------*/
.macro SetCommonRAM(amount) {
	lda MMURCR
	and #%11111100 			// clear bits 0 and 1. this is also option 1
	.if(amount==4) {
		ora #%00000001
	}
	.if(amount==8) {
		ora #%00000010
	}
	.if(amount==16) {
		ora #%00000011
	}
	sta MMURCR
}

/*----------------------------------------------------------
Configure where common RAM is enabled. Top, bottom, or both.
Valid options are 1, 2 or 3.
1 = bottom (default)
2 = top
3 = bottom and top

Syntax:		:SetCommonEnabled(1)
----------------------------------------------------------*/
.macro SetCommonEnabled(option) {
	lda MMURCR
	and #%11110011 			// clear bits 2 and 3
	ora #option*4
	sta MMURCR
}

/*----------------------------------------------------------
 Set RAM block that the VIC chip will use, bit 6 of MMUCR.
 Only useful for text display. Pretty useless, really.
 Kernal routines use RAM0, so you need to roll your own routines.

 Use SetVICBank() to set the 16k block that the VIC will use in that block.

 Syntax:		:SetVICRamBank(0 or 1)
 ----------------------------------------------------------*/
.macro SetVICRAMBank(value) {
	lda MMURCR
	and #%10111111 			// clear bit 6
	.if(value==1) {
		ora #%01111111 		// enable bit 6
	}
	sta MMURCR
}

/*----------------------------------------------------------
 Sets 16K block that VIC is looking at.
 0 = $0000 - $3fff
 1 = $4000 - $7fff
 2 = $8000 - $bfff
 3 = $c000 - $ffff

 Syntax:		:SetVICBank(1)
----------------------------------------------------------*/
.macro SetVICBank (bank) {
	lda $dd00
	and #%11111100
	ora #3-bank
	sta $dd00
}

/*----------------------------------------------------------
 Sets the 2K offset in the VIC 16K block where the character set
 is read from. The offset must be an even number from 0 to 14.

 Syntax:		:SetVICCharacterOffset(2)
 If the VIC chip is using $4000-$7fff then character
 data is read from $4800  ($800 = 2048 bytes)
----------------------------------------------------------*/
.macro SetVICCharacterOffset (offset) {
	lda $d018
	and #%11110001 		// clear the 3 offset control bits
	ora	#offset
	sta $d018
}

/*----------------------------------------------------------
 Sets the 1K offset in the VIC 16K block where the screen
 memory is read from. The value can be 0-15.

 Syntax:		:SetVICMatrixOffset(1)
 If the VIC chip is using $0000-$3fff then screen
 data is read from $0400 (1k = 1024 bytes = $400 offset)
----------------------------------------------------------*/
.macro SetVICMatrixOffset (offset) {
	lda $d018
	and #%00001111 		// clear the 4 offset control bits
	.if(offset > 0) {
		ora #offset*16
	}
	sta $d018
}

/*----------------------------------------------------------
 Sets the 8k offset in the VIC 16K block where the bitmap
 data is read from. The value can be 0 or 1.
 This is only valid when bitmap mode is enabled.

 Syntax:		:SetVICBitmapOffset(1)
 If the VIC chip is using $0000-$3fff then bitmap
 data is read from $2000
----------------------------------------------------------*/
.macro SetVICBitmapOffset (offset) {
	lda $d018
	and #%11110111 		// clear bit 3. no offset.
	.if(offset==1) {
		ora #%00001000
	}
	sta $d018
}

/*----------------------------------------------------------
 Sets RAM bank that will be involved in I/O.
 Also sets bank where the filename will be found.
 Use the Basic bank definitions. (0-15)

 Syntax:		:SetIOBank(15,15)
----------------------------------------------------------*/
.macro SetIOBank (bank, bankname) {
	lda #bank
	ldx #bankname
	jsr SETBNK
}

/*----------------------------------------------------------
 Opens IO channel.

 Syntax:		:OpenIOChannel(15,8,15)
----------------------------------------------------------*/
.macro OpenIOChannel (filenumber, devicenumber,secondary) {
	lda #filenumber
	ldx #devicenumber
	ldy #secondary
	jsr SETLFS
}

/*----------------------------------------------------------
 Sets IO filename

 Syntax:		:SetIOName(4,$2000)
----------------------------------------------------------*/
.macro SetIOName (length, address) {
	lda #length
	ldx #<address
	ldy #>address
	jsr SETNAM
}

/*----------------------------------------------------------
 Sets IO input channel. Use logical file number.

 Syntax:		:SetInputChannel(1)
----------------------------------------------------------*/
.macro SetInputChannel (parameter) {
	ldx #parameter
	jsr CHKIN
}

/*----------------------------------------------------------
 Sets IO output channel. Use logical file number.

 Syntax:		:SetOutputChannel(1)
----------------------------------------------------------*/
.macro SetOutputChannel (parameter) {
	ldx #parameter
	jsr CHKOUT
}

/*----------------------------------------------------------
 Performs the chosen escape code.

 Syntax:		:DoEscapeCode('X')
----------------------------------------------------------*/
.macro DoEscapeCode (code) {
	lda #code
	jsr JESCAPE
}


// Go to 80 columns mode
.macro Go80 () {
	lda MODE 		// are we in 80 columns mode?
	bmi !+ 			// bit 7 set? then yes
	jsr SWAPPER		// swap mode to 80 columns
!:
}
