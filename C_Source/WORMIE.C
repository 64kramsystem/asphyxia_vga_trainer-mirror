/* 
  wormie.c
  10/30/94
  from wormie.pas
  Adapted from Denthor's wormie.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut wormie.c
           to compile this program.
*/

// Program T_holic;
#include "tutheadr.h"

char Block[40][40] = {
       {0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0},
       {0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0},
       {0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0},
       {0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0},
       {0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0},
       {0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0},
       {1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1},
       {0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0},
       {0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0},
       {0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0},
       {0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0},
       {0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0},
       {0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0},
       {0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0}
       };


   char WholePal[256][3];
   int curx,cury,curcol;
   int right,down;


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure PreparePalette;
//    { This sets up the palette to have pretty gradients in it for our use }
void PreparePalette()
{
   int loop;
   for(loop=0;loop<30;loop++)
   {
      WholePal [loop][0]=loop*2;
      WholePal [loop][1]=0;
      WholePal [loop][2]=0;
   }

   for(loop=30;loop<60;loop++)
   {
      WholePal [loop][0]=0;
      WholePal [loop][1]=loop*2-30;
      WholePal [loop][2]=0;
   }

   for(loop=60;loop<90;loop++)
   {
      WholePal [loop][0]=0;
      WholePal [loop][1]=0;
      WholePal [loop][2]=loop*2-30;
   }

   for(loop=90;loop<120;loop++)
   {
      WholePal [loop][0]=loop*2-30;
      WholePal [loop][1]=loop*2-30;
      WholePal [loop][2]=loop*2-30;
   }

   for(loop=120;loop<150;loop++)
   {
      WholePal [loop][0]=loop*2-30;
      WholePal [loop][1]=loop*2-30;
      WholePal [loop][2]=0;
   }

   for(loop=150;loop<180;loop++)
   {
      WholePal [loop][0]=0;
      WholePal [loop][1]=loop*2-30;
      WholePal [loop][2]=loop*2-30;
   }

   for(loop=180;loop<210;loop++)
   {
      WholePal [loop][0]=loop*2-30;
      WholePal [loop][1]=0;
      WholePal [loop][2]=loop*2-30;
   }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure IngeniouslyMoveCurPos;
//    { This moves the position of the block to put down around the screen }
void IngeniouslyMoveCurPos()
{
   curcol = 1 + curcol%210;
   if(right) curx += 4; else curx -= 3;
   if(down)  cury += 3; else cury -= 2;

   if(curx > 250) right = 0;
   if(cury > 150) down  = 0;

   if(curx < 10)  right = 1;
   if(cury < 10)  down  = 1;

}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure DrawBlock;
//    { This draws the block onto the VGA screen }
void DrawBlock()
{
   int xloop,yloop;
   for(xloop=0;xloop<40;xloop++)
      for(yloop=0;yloop<40;yloop++)
	    if(Block[yloop][xloop] == 1)
            PutPixel(curx+xloop,cury+yloop,(char)curcol,VGA);
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure StartSnakiepoo;
//    { This is the proc where we set things up & set em in motion! ;-) }
void StartSnakiepoo()
{
   curx=100;
   cury=100;
   curcol=1;
   PreparePalette();
   while(1)
   {
      if(_bios_keybrd(_KEYBRD_READY))break;
      DrawBlock();
	  rotatepal(WholePal,1,210);  // CunninglyManipulatePalette;
      IngeniouslyMoveCurPos();
   }
   FadeDown();
   getch();
}

void main()
{
   SetMCGA();
   StartSnakiepoo();
   SetText();
}
/*
Begin
   ClrScr;
   Writeln ('Hi there!  This is a small little routine that Livewire');
   Writeln ('and Denthor of ASPHYXIA threw together during lunch break');
   Writeln ('at varsity. We first saw this routine in the T-Holic demo');
   Writeln ('by Extreme a few months back, and decided to write it as');
   Writeln ('a supliment to the ASPHYXIA VGA Demo Trainer Series on the');
   Writeln ('MailBox BBS here in Durban.                              ');
   Writeln;
   Writeln ('The routine consists of a wormy type thing bouncing around');
   Writeln ('the screen, and looks quite effective. The code is');
   Writeln ('documented, and the concept behind it is so easy everyone');
   Writeln ('should be able to understand it.                         ');
   Writeln;
   Writeln ('The Pal routines, setmcga, waitretrace etc. are taken');
   Writeln ('directly from the ASPHYXIA Trainer Series, and you should');
   Writeln ('read those to understand how they work.');
   Writeln;
   Writeln ('See the Trainer Series for how to get into contact with us.');
   Writeln; Writeln;
   Writeln ('Hit any key to continue ....                             ');
   Readkey;
   SetMCGA;
   StartSnakiepoo;
   SetText;
   Writeln ('All done. This was a sample routine written by ASPHYXIA.');
   Writeln ('Please read the ASPHYXIA Demo Trainer Series on the MailBox BBS,');
   Writeln ('written by Denthor. You may reach DENTHOR under the name of GRANT');
   Writeln ('SMITH on the MailBox BBS, or leave a message to ASPHYXIA on the');
   Writeln ('ASPHYXIA BBS. Get the numbers from Roblist, or write to :');
   Writeln ('             Grant Smith');
   Writeln ('             P.O. Box 270');
   Writeln ('             Kloof');
   Writeln ('             3640');
   Writeln ('We hope to hear from you soon!');
   Writeln; Writeln;
   Write   ('Hit any key to exit ...');
   Readkey;
End.
*/
