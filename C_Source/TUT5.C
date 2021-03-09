/*
  tut5.c
  10/30/94
  from tutprog5.pas
  Adapted from Denthor's tutprog5.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut5.c
           to compile this program.
*/

#include "tutheadr.h"

#define xsize 16
#define ysize 16

char Letter[xsize][ysize];
char LetterBlock[62][xsize][ysize];
char* Font;

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// procedure LoadPal (FileName : string);
// This loads the Pallette file and puts it on screen }
int LoadPal(char* fn)
{
  struct DACType
  {
    char R;
	char G;
	char B;
  } DAC[256];
  FILE* fptr;
  int i;

  if((fptr=fopen(fn,"rb"))==NULL)
    { SetText(); printf("Error opening file %s\n",fn); exit(1); }
  fread(DAC,sizeof(struct DACType),256,fptr);
  fclose(fptr);
  for(i=0;i<256;i++)Pal((char)i,DAC[i].R,DAC[i].G,DAC[i].B);
  return 0;
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Setup;
//   { This loads the font and the pallette }
void Setup()
{
    char fn[80];
	char loop1;
	int loop2,loop3;
	FILE* fptr;
	Font = &LetterBlock[0][0][0];
  sprintf(fn,"%s","softrock.fnt");
  if((fptr=fopen(fn,"rb"))!=NULL)
  {
    fread(Font,sizeof(LetterBlock),1,fptr);
    fclose(fptr);
  }
  else
  {
    printf("SoftRock.FNT from TEXTER5 not found in current directory\n");
	for(loop1=0;loop1<62;loop1++)
	  for(loop2=0;loop2<16;loop2++)
	    for(loop3=0;loop3<16;loop3++)
		  LetterBlock[loop1][loop2][loop3]=loop2;
  }
  SetMCGA();
  LoadPal("pallette.col");
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure ScrollMsg (Msg : String);
// This scrolls the string in MSG across the screen }
void ScrollMsg(char* Msg)
{
  int loop1,loop2,loop3;
  int index;
  char MsgChar;
  char far* Scrdest;
  char far* Scrsrc;

  loop1=0;
  while((MsgChar=Msg[loop1])!=0x00)
  {
	for(loop2=0;loop2<xsize;loop2++)
	{
    //This bit scrolls the screen by one then puts in the new row of letters 
      WaitRetrace();
	  for(loop3=100;loop3<100+ysize;loop3++)
	  {
        Scrdest=MK_FP(VGA,(unsigned)(loop3*320));
        Scrsrc=MK_FP(VGA,(unsigned)(1+loop3*320));
		_fmemmove(Scrdest,Scrsrc,319);
	  }
      for(loop3=100;loop3<100+ysize;loop3++)
	  {
	    index=Msg[loop1]-32;
		PutPixel(319,loop3,LetterBlock[index][loop2][loop3-100],VGA);
	  }
      //    Change the -100 above to the minimum of loop3-1, which you
      //    will change in order to move the position of the scrolly 
	}

    //This next bit scrolls by one pixel after each letter so that there
    //are gaps between the letters 

      WaitRetrace();
	  for(loop3=100;loop3<100+ysize;loop3++)
	  {
        Scrdest=MK_FP(VGA,(unsigned)(loop3*320));
        Scrsrc=MK_FP(VGA,(unsigned)(1+loop3*320));
		_fmemmove(Scrdest,Scrsrc,319);
	  }
      for(loop3=100;loop3<100+ysize;loop3++)
	  {
		PutPixel(319,loop3,0,VGA);
	  }
	  loop1++;
  }
}


void main()
{
  int c;
  _clearscreen(_GCLEARSCREEN);
/*
  Writeln ('This program will give you an example of a scrolly. If the file');
  Writeln ('SOFTROCK.FNT is in the current directory, this program will scroll');
  Writeln ('letters, otherwise it will only scroll bars. It also searches for');
  Writeln ('PALLETTE.COL, which it uses for it''s pallette. Both SOFTROCK.FNT');
  Writeln ('and PALLETTE.COL come with TEXTER5.ZIP, at a BBS near you.');
  Writeln;
  Writeln ('You will note that you can change what the scrolly says merely by');
  Writeln ('changing the string in the program.');
  Writeln;
*/
  Setup();
  while(1)
  {
    ScrollMsg ("ASPHYXIA RULZ!!!   ");
	c=_bios_keybrd(_KEYBRD_READY);
	if(c)break;
  }
  SetText();
} 
/*
  freemem (font, sizeof (font^));
  Writeln ('All done. This concludes the fifth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the name of GRANT');
  Writeln ('SMITH on the MailBox BBS, or leave a message to ASPHYXIA on the');
  Writeln ('ASPHYXIA BBS. Get the numbers from Roblist, or write to :');
  Writeln ('             Grant Smith');
  Writeln ('             P.O. Box 270');
  Writeln ('             Kloof');
  Writeln ('             3640');
  Writeln ('I hope to hear from you soon!');
  Writeln; Writeln;
  Write   ('Hit any key to exit ...');
  Readkey;
*/
