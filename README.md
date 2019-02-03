# d71-81writer.c128
D71 and D81 image writer tool for use with the 1541Ultimate 2 or 2+. Commodore 128 version.

Written by Ernoman and WdW.

Introduction
============

This C128 tool will enable you to use your 1541 Ultimate 2 cartridge (U2) to
write .D71 and .D81 images to a physical drive.

It uses fast serial, and is therefore a bit faster than the C64 version. If you
have a C128, I recommend you use the C128 version.

Preparations
============

- Set your physical drive to another id than the emulated U2 drive, because having
two drives with the same device id on the serial bus is asking for trouble. You
can also disable the emulated drive and use device 8 on the physical drive.
- The diskette must be formatted before you can use it. It does not need
to be empty, though.  In order to get a 1:1 copy its best to format the diskette
with the index option (this will zero all sectors), as the write tool will skip
empty sectors to speed up the process.

Example: HEADER "EMPTY", U8, I01

- Enable the Command Interface and the REU with at least 1MB of memory.
- Disable any cartridge in the U2 interface, otherwise you willl end up in C64 mode.
- Put your image files somewhere on a USB or Micro SD card and insert it into the U2.

Usage
=====

When the tools starts, make sure if you see the Ultimate DOS version appear
under the header. If this does not happen, re-check your U2 settings!! The tool
will not function properly until you see the DOS version.

Select the option you want to perform:

1 will allow you to set the Ultimate DOS path the tool is looking at.
2 or 3 will prompt you to enter a D71 or D81 filename. the destination device is asked
after that and writing will start.

Build the code
=============

The code is build using Kickassembler (at the moment of writing v5.3).
There are two builds:
1) For Vice emulation purposes
java -jar C:/Tools/kickassembler/KickAss.jar -define EMU -odir ./bin Startup.asm

This build omits the 1541 Ultimate API parts. It quits when disk writing is supposed to start.
The intended use for this build is to be able to test some of the code using an emulator like Vice.

2) For real
java -jar C:/Tools/kickassembler/KickAss.jar -odir ./bin -o Startup.asm

Note the Startup.asm instructs the compiler to create a D64 image containing the d7181_for_ult.prg.
Should you desire a different file name make sure to edit the Startup.asm accordingly.
