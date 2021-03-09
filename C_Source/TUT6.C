/*
  tut6.c
  10/30/94
  from tutprog6.pas
  Adapted from Denthor's tutprog6.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  I modified the parameters of the spiral to cover the whole screen.
  It takes about 15 seconds to draw the spiral on my 486.
  (Running under Windows it takes 25 seconds!)
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut6.c
           to compile this program.
*/

#include "tutheadr.h"

float costbl[8000];
float sintbl[8000];
int  ncolors=40;

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD} 
// Procedure NormCirc; 
// This generates a spiral without using a lookup table } 
void NormCirc()
{
  float deg,radius;
  int x,y;
  int x1,y1;
  int loop1;
  for(loop1=60;loop1>60-ncolors;loop1--)
  {
    deg=(float)-90.0;
	radius=160+loop1;
	while(radius>=0)
	{
      x=round(radius*(float)cos ((double)rad (deg)));
      y=round(radius*(float)sin ((double)rad (deg)));
	  x1=x+160;y1=y+100;
	  if((x1>=0)&&(x1<320)&&(y1>=0)&&(y1<200))
                PutPixel (x1,y1,(char)(61-loop1),VGA);
      deg=deg+(float)0.045; // Increase the degree so the circle is round 
      radius-=(float)0.005; // Decrease the radius for a spiral effect 
	}
  }
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//  Procedure Setupvars;
void Setupvars()
{
    float deg;
	int loop1;
    deg=(float)-90.0;
	for(loop1=0;loop1<8000;loop1++)
	{
	  deg=deg+(float)0.045;  // 360 degs / 0.045 degs = 8000 elements in array.
	  costbl[loop1]=(float)cos((double)rad(deg));
	  sintbl[loop1]=(float)sin((double)rad(deg));
	}
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure LookupCirc;
// This draws a spiral using a lookup table }
void LookupCirc()
{
  float radius;
  int x,y,pos; 
  int x1,y1;
  int loop1;
  Cls (0,VGA);
  Setupvars();
  for(loop1=60;loop1>60-ncolors;loop1--)
  {
    pos=0;
    radius=160+loop1;
    while(radius>=0)
	{
      x=round(radius*costbl[pos]);  // Note how I am not recalculating sin}
      y=round(radius*sintbl[pos]);  // and cos for each point.            }
	  x1=x+160;y1=y+100;
	  if((x1>=0)&&(x1<320)&&(y1>=0)&&(y1<200))
                PutPixel (x1,y1,(char)(61-loop1),VGA);
      radius-=(float)0.005;
	  pos++;
      if(pos==8000)pos=0;   // 
	}
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure PalPlay;               
// Moves the pallette down 1 color, working with colors 0 to number-1.
void PalPlay6(int number)
{
    char Tmp[3];
	int loop1;

// This copies color 0 from our virtual pallette to the Tmp variable:
   _fmemmove(Tmp,Pall[0],3);
// This moves the entire virtual pallette down one color:
   _fmemmove(Pall[0],Pall[1],(number-1)*3);
// This copies the Tmp variable to the bottom of the virtual pallette:
   _fmemmove(Pall[number-1],Tmp,3);
   WaitRetrace();
   for(loop1=0;loop1<number;loop1++)
     Pal((unsigned char)(loop1+1),Pall[loop1][0],Pall[loop1][1],Pall[loop1][2]);
}

void main()
{                                         
  int c,loop1;
  _clearscreen(_GCLEARSCREEN);
  printf("Hi there! This program will demonstrate the usefullness of \n");
  printf("pregenerated arrays, also known as lookup tables. The program\n");
  printf("will first draw a spiral without using a lookup table, rotate\n");
  printf("the pallette until a key is pressed, the calculate the lookup\n");
  printf("table, then draw the same spiral using the lookup table.\n");
  printf("\n");
  printf("This is merely one example for the wide range of uses of a \n");
  printf("lookup table.\n");
  printf("\n");
  printf("\n");
  printf("  Hit any key to contine ...\n");
  getch();
  SetMCGA();
  // Arrangement for ncolors = 40:
  for(loop1=0;loop1<ncolors/2;loop1++)
  {
    Pall[loop1][0] = 3*loop1+3;
    Pall[loop1][1] = 0;
    Pall[loop1][2] = 0;
  }
  for(loop1=0;loop1<ncolors/2;loop1++)
  {
    Pall[ncolors/2+loop1][0] = 3*ncolors/2+3;
    Pall[ncolors/2+loop1][1] = 3*loop1;
    Pall[ncolors/2+loop1][2] = 0;
  }
   WaitRetrace();
   for(loop1=0;loop1<ncolors;loop1++)
     Pal ((char)(loop1+1),Pall[loop1][0],Pall[loop1][1],Pall[loop1][2]);
        // This sets the true pallette to variable Pall }

//  NormCirc();   //      { This draws a spiral without lookups }
//  while(1)      //  I've commented this out because it's too slow 
//  {             //  with the expanded spiral!
//     PalPlay6(ncolors);
//     c=_bios_keybrd(_KEYBRD_READY);
//     if(c)break;
//  }
//  getch();
//  Blackout();
  LookupCirc();    //   { This draws a spiral with lookups }
//  getch();
//  FadeUp();
  while(1)
  {
     PalPlay6(ncolors);
     c=_bios_keybrd(_KEYBRD_READY);
     if(c)break;
  }
  getch();
  FadeDown();
  SetText();
}
