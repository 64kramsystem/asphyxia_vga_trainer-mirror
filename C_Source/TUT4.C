/*
  tut4.c
  10/30/94
  from tutprog4.pas
  Adapted from Denthor's tutprog4.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut4.c
           to compile this program.
*/

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#include <conio.h>
#include <graph.h>
#include <bios.h>
#include <string.h>
#include "tutheadr.h"



// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure BlockMove;
// This tests various ways of moving a block around the screen }
void BlockMove(int incr)
{
  int loop1,loop2,loop3;
  // Draw block to VGA w/o flipping:
  for(loop1=1;loop1<=50;loop1++)
  {
    for(loop2=1;loop2<=50;loop2++)
      for(loop3=1;loop3<=50;loop3++)
        PutPixel (loop1+loop2,loop3,32,VGA);
    Cls(0,VGA);
  }

  // Draw block to Virtual Screen, then flips it to VGA:
  for(loop1=1;loop1<=100;loop1++)
  {
    for(loop2=1;loop2<=50;loop2++)
      for(loop3=1;loop3<=50;loop3++)
        PutPixel (loop1+loop2,loop3,32,Vaddr);
    Flip2(Vaddr,VGA);
    Cls(0,Vaddr);
  }

  // Draw block to Virtual Screen, waits for retrace, then flips it to VGA:
  for(loop1=1;loop1<=200;loop1+=incr)
  {
    for(loop2=1;loop2<=50;loop2++)
      for(loop3=1;loop3<=50;loop3++)
        PutPixel (loop1+loop2,loop3,32,Vaddr);
    WaitRetrace();
    Flip2(Vaddr,VGA);
    Cls(0,Vaddr);
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure PatternDraw;
// This test the speed of flipping by drawing two patterns and flipping them
void PatternDraw()
{
  int loop1,loop2;

  for(loop1=0;loop1<=100;loop1++)
    for(loop2=0;loop2<=100;loop2++)
      PutPixel (loop1,loop2,(unsigned char)loop1,Vaddr);  
  Flip2(Vaddr,VGA);

  for(loop1=0;loop1<=100;loop1++)
    for(loop2=0;loop2<=100;loop2++)
      PutPixel (loop1,loop2,(unsigned char)loop2,Vaddr);  
  Flip2(Vaddr,VGA);
}

void main()
{
  int c;
  int incr;
  VirtPtr=&Virtual[0];
  Vaddr = FP_SEG(VirtPtr);
  _clearscreen(_GCLEARSCREEN);
  incr=1;
  SetMCGA();
  Cls (0,Vaddr); 
  BlockMove(incr);

  while(1)
  {
    PatternDraw();
	c=_bios_keybrd(_KEYBRD_READY);
	if(c)break;
  }
  getch();
  SetText();
}
