/*
  tut2.c
  10/30/94
  from tutprog2.pas
  Adapted from Denthor's tutprog2.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut2.c
           to compile this program.
  I compiled and ran all of these on my computer (a 486DX2) and they
  worked for me; that's all I can say!
*/

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#include <conio.h>
#include <graph.h>
#include <bios.h>
#include "tutheadr.h"

//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure SetUpScreen;
//  This gets our screen ready by setting up the pallette and drawing
//  the lines. 
void SetUpScreen()
{
   int Loop;

   // Clear the entire PALL variable to zero: 
   _fmemset(Pall,0,768);

 //This sets colors 0 to 200 in the PALL variable to values between
 //0 to 63. the MOD function gives you the remainder of a division,
 //ie. 105 mod 10 = 5:
   for(Loop=0;Loop<200;Loop++) 
       Pall[Loop][0]=(unsigned char)(Loop%64);

   for(Loop=0;Loop<320;Loop++)
   {
  // These two lines start drawing lines from the left and the right
  // hand sides of the screen, using colors 1 to 199. Look at these
  // two lines and understand them: 
     Line(319,199,319-Loop,0,(unsigned char)((Loop%199)+1));
	 Line(0,0,Loop,199,(unsigned char)((Loop%199)+1));
	 PalPlay(1); // This calls the PalPlay procedure with wait for vsync
   }
}

//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
void SetUpScreenV2()
{
   int Loop;

   _fmemset(Pall,0,768);

 //This sets colors 0 to 200 in the PALL variable to values between
 //0 to 63. 
   for(Loop=0;Loop<200;Loop++) 
       Pall[Loop][1]=(unsigned char)(Loop%64);

   for(Loop=0;Loop<320;Loop++)
   {
     Line(319,199,319-Loop,0,(unsigned char)(((Loop/2)%199)+1));
     Line(0,0,Loop,199,(unsigned char)(((Loop/2)%199)+1));
   }
}

//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
void SetUpScreenV3()
{
   int Loop;

   _fmemset(Pall,0,768);

 //This sets colors 0 to 200 in the PALL variable to values between
 //0 to 63. 
 //for(Loop=0;Loop<256;Loop++) 
 //    Pall[Loop][2]=(unsigned char)(Loop%64);
   for(Loop=0;Loop<64;Loop++)
       Pall[Loop][0]=(unsigned char)(Loop%64);
   for(Loop=64;Loop<128;Loop++)
       Pall[Loop][1]=(unsigned char)(Loop%64);
   for(Loop=128;Loop<192;Loop++)
   {
       Pall[Loop][0]=(unsigned char)(Loop%64);
       Pall[Loop][2]=(unsigned char)(Loop%64);
   }
   for(Loop=192;Loop<256;Loop++)
       Pall[Loop][2]=(unsigned char)(Loop%64);

   for(Loop=0;Loop<320;Loop++)
     Line(Loop,0,319-Loop,199,(unsigned char)(1+(Loop/2)%199));
   for(Loop=1;Loop<199;Loop++)
     Line(0,199-Loop,319,Loop,(unsigned char)(1+((199-Loop)/2)%199));
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure HiddenScreenSetup;
//  This procedure sets up the screen while it is blacked out, so that the
//  user can"t see what is happening. }
void HiddenScreenSetup()
{
  int loop1,loop2;
  for(loop1=0;loop1<320;loop1++)
     for(loop2=0;loop2<200;loop2++)
	   PutPixel(loop1,loop2,(unsigned char)(1+(rand()/128)),VGA);  
	   // rand() is in the range 0 to 32767, 2^15 / 2^7 = 2^8 = 256.
}


void main()
{
  int c;
  _clearscreen(_GCLEARSCREEN);
  printf("This program will draw lines of different colors across the\n");
  printf("screen and change them only by changing their pallette values.\n");
  printf("The nice thing about using the pallette is that one pallette\n");
  printf("change changes the same color over the whole screen, without\n");
  printf("you having to redraw it. Because I am using a WaitRetrace\n");
  printf("command, turning on and off your turbo during the demonstration\n");
  printf("should have no effect.\n");
  printf("\n");
  printf("The second part of the demo blacks out the screen using the\n");
  printf("pallette, fades in the screen, waits for a keypress, then fades\n");
  printf("it out again. I haven't put in any delays for the fadein/out,\n");
  printf("so you will have to put 'em in yourself to get it to the speed you\n");
  printf("like. Have fun and enjoy! ;-)\n");
  printf("\n");
  printf("Hit any key to continue ...\n");
  getch();
  SetMCGA();
  GrabPallette();
  SetUpScreen();
  // Call the PalPlay procedure repeatedly until a key is pressed: 
  // This time without wait for VSync:
  // while(1)
  // {
  //    PalPlay(0);
  //    c=_bios_keybrd(_KEYBRD_READY);
  //    if(c)break;
  // }
  // // Read in the key pressed otherwise it is left in the keyboard buffer }
  // c=_bios_keybrd(_KEYBRD_READ);
  // Call the PalPlay procedure repeatedly until a key is pressed: 
  // This time with wait for VSync:
  while(1)
  {
     PalPlay(1);
     c=_bios_keybrd(_KEYBRD_READY);
     if(c)break;
  }
  // Read in the key pressed otherwise it is left in the keyboard buffer }
  c=_bios_keybrd(_KEYBRD_READ);
  if((c&0xff)==0x71) // 'q'
  {
    RestorePallette();
    SetText();
    return;
  }
  FadeDown();
  SetUpScreenV2();
  while(1)
  {
     PalPlay(1);
     c=_bios_keybrd(_KEYBRD_READY);
     if(c)break;
  }
  c=_bios_keybrd(_KEYBRD_READ);
  if((c&0xff)==0x71)
  {
    RestorePallette();
    SetText();
    return;
  }
  FadeDown();
  SetUpScreenV3();
  while(1)
  {
     PalPlay(1);
     c=_bios_keybrd(_KEYBRD_READY);
     if(c)break;
  }
  c=_bios_keybrd(_KEYBRD_READ);
  if((c&0xff)==0x71)
  {
    RestorePallette();
    SetText();
    return;
  }
  FadeDown();
  /*
  Blackout(); 
  HiddenScreenSetup();
  Blackout();
  FadeUp(2);
  getch();
  FadeDown();
  */
  RestorePallette();
  SetText();
  printf("All done. This concludes the second sample program in the ASPHYXIA\n");
  printf("Training series. You may reach DENTHOR under the name of GRANT\n");
  printf("SMITH on the MailBox BBS, or leave a message to ASPHYXIA on the\n");
  printf("ASPHYXIA BBS. Get the numbers from Roblist, or write to :\n");
  printf("             Grant Smith\n");
  printf("             P.O. Box 270\n");
  printf("             Kloof\n");
  printf("             3640\n");
  printf("I hope to hear from you soon!\n");
  printf("\n"); 
  printf("\n"); 
  printf("     Translated into Microsoft C by: \n");
  printf("        Steve Pinault, 10/06/94,  scp@ohm.att.com  \n");
  printf("\n"); 
}
