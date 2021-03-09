/* 
  tut13.c
  10/30/94
  from tutprog13.pas
  Adapted from Denthor's tutprog13.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut13.c
           to compile this program.
*/

#include "tutheadr.h"

#define NUM 400     // Number of stars

struct Star
{
  int x;
  int y;
  int z;
} Stars[NUM];

struct Pos
{
  int x;
  int y;
} Clear[2][NUM];

char logo[50][320];
char far* logoptr=&logo[0][0];

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Init;
void Init()
{
  int loop1,loop2;

  for(loop1=0;loop1<NUM;loop1++)  
    do
    {
      //Stars[loop1].x=random (320)-160;
      //Stars[loop1].y=random (200)-100;
      Stars[loop1].x=random (600)-300; //Fill out the distant field more
      Stars[loop1].y=random (400)-200;
      Stars[loop1].z=loop1+1; 
    } while((Stars[loop1].x==0)&&(Stars[loop1].y==0));
    //  { Make sure no stars are heading directly towards the viewer }
    
  for(loop1=0;loop1<32;loop1++)
    Pal ((unsigned char)(32+loop1),(unsigned char)(10+loop1),(unsigned char)(10+loop1),(unsigned char)(30+loop1));

  Pal ((unsigned char)247,20,20,20);
  Pal ((unsigned char)136,30,0 ,0 );
  Pal (101,40,0 ,0 );
  Pal (19 ,60,0 ,0 ); // { Pallette for the logo at the top of the screen }

  LoadCEL ("logo.cel",logoptr);
  for(loop1=0;loop1<320;loop1++)
    for(loop2=0;loop2<50;loop2++)
      PutPixel (loop1,loop2,logo[loop2][loop1],VGA);
      // { Placing the logo at the top of the screen }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Calcstars;
//  { This ccalculates the 2-d coordinates of our stars and saves these values
//    into the variable clear }
void Calcstars()
{
  int loop1,x,y;
  for(loop1=0;loop1<NUM;loop1++)
  {
    x=((Stars[loop1].x << 7) / Stars[loop1].z)+160;
    y=((Stars[loop1].y << 7) / Stars[loop1].z)+100;
    Clear[0][loop1].x=x;
    Clear[0][loop1].y=y;
  }
}
// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Drawstars;
//  { This draws the 2-d values stored in clear to the vga screen, with various
//    colors according to how far away it is. }
void Drawstars()
{
  int loop1,x,y;
  int starcolor;
  for(loop1=0;loop1<NUM;loop1++)
  {
    x=Clear[0][loop1].x;
    y=Clear[0][loop1].y;
    if((x>0) && (x<320) && (y>50) && (y<200))
	{
	  if(Stars[loop1].z>383)
	    starcolor=32;
	  else
        starcolor=63-(Stars[loop1].z/12);
      PutPixel(x,y,(unsigned char)starcolor,VGA);
	}
  }
}  

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Clearstars;
//  { This clears the 2-d values from the vga screen, which is faster then a
//    cls (vga,0) }
void Clearstars()
{
  int loop1,x,y;
  for(loop1=0;loop1<NUM;loop1++)
  {
    x=Clear[1][loop1].x;
    y=Clear[1][loop1].y;
    if((x>0)&&(x<320)&&(y>50)&&(y<200))PutPixel(x,y,0,VGA);
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure MoveStars (Towards:boolean);
//  { If towards is True, then the z-value of each star is decreased to come
//    towards the viewer, otherwise the z-value is increased to go away from
//    the viewer }

void Movestars(int towards)
{
  int loop1;
  if(towards) for(loop1=0;loop1<NUM;loop1++)
  {
      Stars[loop1].z=Stars[loop1].z-2;
      if(Stars[loop1].z<1)Stars[loop1].z=Stars[loop1].z+NUM;
  }
  else for( loop1=0;loop1<NUM;loop1++)
  {
      Stars[loop1].z=Stars[loop1].z+2;
      if(Stars[loop1].z>NUM)Stars[loop1].z=Stars[loop1].z-NUM;
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Play;
//  { This is our main procedure }
void Play()
{
  int ch;
  Calcstars();
  Drawstars(); // { This draws our stars for the first time }
  do
  { 
    if(_bios_keybrd(_KEYBRD_READY)) ch=getch()&0x00ff;
    _fmemmove(Clear[1],Clear[0],4*NUM);
    Calcstars();   //  { Calculate new star positions }
    WaitRetrace();
    Clearstars();  //  { Erase old stars }
    Drawstars();     //  { Draw new stars }
    if(ch==' ')Movestars(FALSE); else Movestars(TRUE);
      //{ Move stars towards or away from the viewer }
  }
  while(ch!=0x1b); // ESC { Until the escape key is pressed }
}

void main()
{
  randomize();
  SetMCGA();
  Init();
  Play();
  SetText();
}

/*
BEGIN
  clrscr;
  writeln ('Hello! Another effect for you, this one is on starfields, again by');
  writeln ('request.  In this sample program, a starfield will be coming towards');
  writeln ('you. Hit the space bar to have it move away from you, any other key');
  writeln ('to have it come towards you again. Hit [ESC] to end.');
  writeln;
  Writeln ('The logo at the top of the screen was drawn by me in Autodesk Animator.');
  Writeln ('It only took a few seconds, so please don''t laugh too much at my attempt.');
  writeln;
  writeln ('The code is very easy to follow, and the documentation is as usual in the');
  writeln ('main text. Leave me mail with further ideas for future trainers.');
  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  randomize;
  setmcga;
  init;
  Play;
  settext;
  Writeln ('All done. This concludes the thirteenth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS. I am also an avid');
  Writeln ('Connectix BBS user, and occasionally read RSAProg. E-mail me at :');
  Writeln ('    smith9@batis.bis.und.ac.za');
  Writeln ('The numbers are available in the main text. You may also write to me at:');
  Writeln ('             Grant Smith');
  Writeln ('             P.O. Box 270');
  Writeln ('             Kloof');
  Writeln ('             3640');
  Writeln ('             Natal');
  Writeln ('             South Africa');
  Writeln ('I hope to hear from you soon!');
  Writeln; Writeln;
  Write   ('Hit any key to exit ...');
  readkey;
END.
*/
