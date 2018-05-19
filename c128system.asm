
// c128 zeropage, system locations and kernal jump table
// definitions. Not all of them, but the most important ones.
// import this first, as consts can only be used AFTER defining them.

// VCD helper subroutines are included on the bottom of the file.

#importonce // and import BEFORE c128macros.asm

// zero page locations

.const STATUS 		= $90 		// I/O operation status byte

.const FA 			= $ba 		// current device number
.const MODE 		= $d7 		// sense active screen. bit 7 on is 80 columns

// common RAM subroutines. common RAM ends at $03ff

.const FETCH 		= $02a2 	// lda(vec),y from any bank
.const FETVEC 		= $02aa 	// vector for FETCH. zero page address
.const STASH		= $02af 	// sta(vec),y from any bank
.const STAVEC 		= $02b9 	// vector for STASH. zero page address
.const CMPARE 		= $02be 	// cmp(vec),y from any bank
.const CMPVEC 		= $02c8 	// vector for CMPARE. zero page address
//.const JSRFAR
//.const JMPFAR
.const CURRENT_BANK = $03d5 	// the current bank config. $0f is default.

.const SERIAL       = $0a1c     // fast serial register

.const FAST 		= $77b3 	// handles the fast statement
.const SLOW 		= $77c4 	// handles the slow statement

// editor jump table

.const JESCAPE		= $c01e 	// perform ESC code
.const COLOR80		= $ce5c 	// conversion table - vic to vdc color code

// I/O

.const CLKRATE 		= $d030 	// processor clock speed

// c128 VCD

.const VDCADR 		= $d600 	// VDC address/status register
.const VDCDAT 		= $d601 	// VDC data register

.const D1TIMH       = $dc05     // timer a hi
.const D1TIML       = $dc06     // timer a lo
.const D1SDR        = $dc0c     // serial data control register
.const D1ICR        = $dc0d     // serial interrupt control register
.const D1CRA        = $dc0e     // serial control register
.const D2PRA        = $dd00



// c128 MMU (mirrored from $d500)

.const MMUCR		= $ff00 	// bank configuration register
.const PCRA 		= $ff01 	// preconfig register A
.const PCRB 		= $ff02 	// preconfig register B
.const PCRC 		= $ff03 	// preconfig register C
.const PCRD 		= $ff04 	// preconfig register D
.const MMUMCR		= $ff05 	// cpu mode configuration register
.const MMURCR 		= $ff06 	// ram configuration register

// c128 specific kernal table

.const SPIN 		= $ff47		// serial fast input or output
.const CLOSE_ALL	= $ff4a 	// close all files to a device
.const C64MODE		= $ff4d 	// enter 64 mode
.const DMA_CALL		= $ff50 	// send command to dma device
.const BOOT_CALL	= $ff53 	// boot a program from disk
.const PHOENIX 		= $ff56 	// init function cartridges
.const SWAPPER 		= $ff5f 	// switch between 40 or 80 colums
.const DLCHR 		= $ff62 	// copy char defintions from ROM to VDC RAM
.const PFKEY 		= $ff65 	// program function key
.const SETBNK 		= $ff68 	// set bank for i/o operations
.const GETCFG		= $ff6b 	// get MMU bank configuration byte
.const JSRFAR 		= $ff6e 	// jump to subroutine in any bank
.const JMPFAR		= $ff71 	// jump to routine in any bank
.const INDFET 		= $ff74 	// lda indexed from any bank
.const INDSTA 		= $ff77 	// sta indexed to any bank
.const INDCMP 		= $ff7a 	// cmp indexed to any bank
.const KEY 			= $ff9f 	// scans the entire c128 keyboard

// generic kernal jump table

.const LISTN        = $ffb1     // send listen to serial
.const TALK         = $ffb4     // send talk to serial
.const SETLFS   	= $ffba 	// set logical file
.const SETNAM		= $ffbd 	// set file name
.const OPEN			= $ffc0 	// open device channel
.const CLOSE		= $ffc3 	// close device channel
.const CHKIN 		= $ffc7 	// set channel in
.const CHKOUT 		= $ffc9 	// set channel out
.const CLRCH 		= $ffcc 	// restore default i/o channels
.const BASIN 		= $ffcf 	// input from channel
.const BSOUT 		= $ffd2 	// output to channel
.const LOAD 		= $ffd5		// load from device
.const SAVE 		= $ffd8 	// save to device
.const SETTIM 		= $ffdb 	// set software clock
.const RDTIM 		= $ffde 	// read software clock
.const STOP 		= $ffe1 	// scan the STOP key
.const GETIN 		= $ffe4		// get key input
.const CLALL 		= $ffe7 	// close all files and channels
.const SCRORG 		= $ffed 	// get current screen window size
.const PLOT 		= $fff0 	// set or read cursor position
								// now uses $e4 - $ee, editor parameters
