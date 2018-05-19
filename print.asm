//  Print to screen
//  ---------------
//
//  Uses the kernel to print strings to screen. 0 terminates.
//  Prints up to 255 characters.

//  Main entry
//  x = lsb string
//  a = msb string

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
