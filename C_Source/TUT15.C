/* 
  tut15.c
  10/30/94
  from tutprog15.pas
  Adapted from Denthor's tutprog15.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut15.c
           to compile this program.
*/

#include "tutheadr.h"

#define BIGPAL 26*256
struct RGBType
{
  char r;
  char g;
  char b;
} bob[256],bob2[256],biiiigpallette[BIGPAL];

int start,effect,background;
char costbl[256];
char mov1,mov2,mov3,mov4;
char bkg[50][80];

//    start:integer;  { Where in the Biiiig pallette are we? }
//    Effect,Background:Boolean; { Configuration of effects }

//    costbl : Array [0..255] of byte; { cos table lookup }
//    mov1,mov2,mov3,mov4 : byte;  { current positions }
//    bkg : array [1..50,1..80] of byte; { The pic in the background }

//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure Makerun (r,g,b:integer);
//  { This creates a ramp of colors and puts them into biiiigpallette }
void makerun(int r, int g, int b)
{
  int loop1;
  for(loop1=start;loop1<start+128;loop1++)
  {
    if(r==1)
      biiiigpallette[loop1].r=63-(loop1-start)/4;
    else
      if(r==2)
        biiiigpallette[loop1].r=(loop1-start) / 4; 
      else
        biiiigpallette[loop1].r=0;

    if(g==1)
      biiiigpallette[loop1].g=63-(loop1-start) / 4 ;
    else
      if(g==2)
        biiiigpallette[loop1].g=(loop1-start) / 4; 
      else
        biiiigpallette[loop1].g=0;

    if(b==1)
      biiiigpallette[loop1].b=63-(loop1-start) / 4; 
    else
      if(b==2)
        biiiigpallette[loop1].b=(loop1-start) / 4; 
      else
        biiiigpallette[loop1].b=0;
  }

  for(loop1=start+128;loop1<start+256;loop1++)
  {
    if(r==2)
      biiiigpallette[loop1].r=63-(loop1-start)/4;
    else
      if(r==1)
        biiiigpallette[loop1].r=(loop1-start) / 4; 
      else
        biiiigpallette[loop1].r=0;

    if(g==2)
      biiiigpallette[loop1].g=63-(loop1-start) / 4 ;
    else
      if(g==1)
        biiiigpallette[loop1].g=(loop1-start) / 4; 
      else
        biiiigpallette[loop1].g=0;

    if(b==2)
      biiiigpallette[loop1].b=63-(loop1-start) / 4; 
    else
      if(b==1)
        biiiigpallette[loop1].b=(loop1-start) / 4; 
      else
        biiiigpallette[loop1].b=0;
  }
  start+=256;
}


//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure init;
void init()
{
  int loop1,loop2,r,g,b;
  int ch;
  char rdch;
  FILE* fptr;

  printf("Do you want the Psychadelic effect?: ");
  while(1)
  {
    ch=getch()&0x00ff;
    if(ch=='y')break;
    if(ch=='Y')break;
    if(ch=='n')break;
    if(ch=='N')break;
  }
  if((ch=='y')||(ch=='Y'))
  {
    printf("Yeah!\n");
    effect=TRUE;
  }                
  else
  {
    printf("Nah\n");
    effect=FALSE;
  }
  printf("Do you want the background?: ");
  while(1)
  {
    ch=getch()&0x00ff;
    if(ch=='y')break;
    if(ch=='Y')break;
    if(ch=='n')break;
    if(ch=='N')break;
  }
  if((ch=='y')||(ch=='Y'))
  {
    printf("Yeah!\n");
    background=TRUE;
  }                
  else
  {
    printf("Nah\n");
    background=FALSE;
  }
  printf("Hit any key to continue: ");getch();
  _asm
  {
    mov     ax,0013h
    int     10h          ;           { Enter mode 13 }
    cli
    mov     dx,3c4h
    mov     ax,604h      ;           { Enter unchained mode }
    out     dx,ax
    mov     ax,0F02h     ;           { All planes}
    out     dx,ax

    mov     dx,3D4h
    mov     ax,14h       ;           { Disable dword mode}
    out     dx,ax
    mov     ax,0E317h    ;           { Enable byte mode.}
    out     dx,ax        ; so far is same as InitChain4
    mov     al,9
    out     dx,al
    inc     dx
    in      al,dx
    and     al,0E0h      ;  320x400 mode, see Abrash pg. 207.{ Duplicate each scan 8 times.}
    add     al,7
    out     dx,al
  }

  _fmemset(&bob2[0],0,768);
  SetAllPal((char far*)&bob2[0]);

  start=0;
  r=0;
  g=0;
  b=0;
  while(1)
  {
    makerun (r,g,b);
    b++;
    if(b==3)
    {
      b=0;
      g++;
    }
    if(g==3)
    {
      g=0;
      r++;
    }
    if((r==2)&&(g==2)&&(b==2))break;
  }
  // { Set up our major run of colors }
  start=0;
  if (!effect)
  {
    for(loop1=0;loop1<128;loop1++)
    {
      bob[loop1].r=63-loop1 / 4;
      bob[loop1].g=0;
      bob[loop1].b=loop1 / 4;
    }
    for( loop1=128;loop1<256;loop1++)
    {
      bob[loop1].r=loop1 / 4;
      bob[loop1].g=0;
      bob[loop1].b=63-loop1 / 4;
    }
  }
  else
    for(loop1=0;loop1<256;loop1++)
    {
      bob[loop1].r=biiiigpallette[loop1].r;
      bob[loop1].g=biiiigpallette[loop1].g;
      bob[loop1].b=biiiigpallette[loop1].b;
    }

    //{ Set up a nice looking pallette ... we alter color 0, so the border will
    //  be altered. }

  for(loop1=0;loop1<256;loop1++)
    costbl[loop1]=(char)round ((float)cos ((double)rad ((int)((long)loop1*(long)(255*2)/(long)360)))*31)+32;
    // { Set up our lookup table...}

  _fmemset(bkg,0,sizeof(bkg));
  if((fptr=fopen("bkg.dat","r"))==NULL)
     {SetText(); printf("Error opening file bkg.dat\n"); exit(1);}
  for(loop1=0;loop1<50;loop1++)
  {
    for(loop2=0;loop2<80;loop2++)
    {
      fread(&rdch,sizeof(rdch),1,fptr);
      if(rdch!=48)bkg[loop1][loop2]=rdch-28;
    }
	fread(&rdch,sizeof(rdch),1,fptr); // read newline
	fread(&rdch,sizeof(rdch),1,fptr); // newline is 2 bytes!
  }
  fclose (fptr);
  //{ Here we read in our background from the file bkg.dat }
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure DrawPlasma;
//  { This procedure draws the plasma onto the screen }
void drawplasma()
{
  int loop1,loop2;
  char tmov1,tmov2,tmov3,tmov4;
  char col;
  int where;

  tmov3=mov3;
  tmov4=mov4;
  where=0;
  __asm
  {
    mov   ax,0a000h
    mov   es,ax    ;    { In the two loops that follow, ES is not altered so
  }                   //    we just set it once, now }
  for(loop1=0;loop1<50;loop1++) // { Fifty rows down }
  {
    tmov1=mov1;
    tmov2=mov2;
    for(loop2=0;loop2<80;loop2++)  //{ Eighty columns across }
    {
      if(background)
        col=costbl[tmov1]+costbl[tmov2]+costbl[tmov3]+costbl[tmov4]+costbl[loop1]+costbl[loop2]+bkg[loop1][loop2];
      else
        col=costbl[tmov1]+costbl[tmov2]+costbl[tmov3]+costbl[tmov4]+costbl[loop1]+costbl[loop2];
        // { col = Intersection of numerous cos waves }
      __asm
      {
        mov    di,where   ; { di is killed elsewhere, so we need to restore it}
        mov    al,col
        mov    es:[di],al ; { Place col at ES:DI ... sequential across the screen}
      }
      where++;  // { Inc the place to put the pixel }
      tmov1+=4;
      tmov2+=3; // { Arb numbers ... replace to zoom in/out }
    }
    tmov3+=4;
    tmov4+=5;   // { Arb numbers ... replace to zoom in/out }
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure MovePlasma;
//  { This procedure moves the plasma left/right/up/down }
void moveplasma()
{
  mov1-=4;
  mov3+=4;
  mov1+=random (2);  // Note my random is 0 <= (int) random((int)x) < x
  mov2-=random (3);
  mov3+=random (2);
  mov4-=random (3);  // { Movement along the plasma + noise}
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure fadeupone (stage:integer);
//  { This procedure fades up the pallette bob2 by one increment and sets the
//    onscreen pallette. Colors are increased proportionally, do that all colors
//    reach their destonation at the same time }
void fadeupone(int stage)
{
  int loop1;
  struct RGBType temp;
  if(!effect)_fmemmove(&temp,&bob[0],3);
  _fmemmove(&bob[0],&bob[1],765);
  if(effect)_fmemmove (&bob[255],&biiiigpallette[start],3);
  else
    _fmemmove (&bob[255],&temp,3);
  start++;
  if(start==BIGPAL) start=0;
    // { Rotate the pallette }

  for(loop1=0;loop1<256;loop1++)
  {
    bob2[loop1].r=(bob[loop1].r*stage) / 64;
    bob2[loop1].g=(bob[loop1].g*stage) / 64;
    bob2[loop1].b=(bob[loop1].b*stage) / 64;
  } // { Fade up the pallette }
  SetAllPal ((char far*)&bob2[0]);
}


//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure Shiftpallette;
//  { This rotates the pallette, and introduces new colors if the psychadelic
//    effect has been chosen }
void shiftpalette()
{
  struct RGBType temp;
  if(!effect)_fmemmove(&temp,&bob2[0],3);
  _fmemmove(&bob2[0],&bob2[1],765);
  if(effect)_fmemmove (&bob2[255],&biiiigpallette[start],3) ;
  else
    _fmemmove (&bob2[255],&temp,3);
  start++;
  if(start==BIGPAL)start=0;
  SetAllPal ((char far*)&bob2[0]);
}

//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure Play;
void play()
{
  int loop1;
  start=256;
  for(loop1=1;loop1<65;loop1++)
  {
    fadeupone(loop1);
    drawplasma();
    moveplasma();
  } // { Fade up the plasma }
  while(1)
  {
    shiftpalette();
    drawplasma();
    moveplasma();
    if(_bios_keybrd(_KEYBRD_READY))break;
  }
  getch();
  _fmemmove (&bob[0],&bob2[0],768);
  for(loop1=1;loop1<65;loop1++)
  {
    fadeupone(64-loop1);
    drawplasma();
    moveplasma();
  } // { fade down the plasma }
}

void main()
{
  init();
  play();
  __asm
  {
    mov  ax,0003h
    int  10h
  }
}           

/*
BEGIN
  clrscr;
  writeln ('Hi there ... here is a tut on plasmas! (By popular demand). The');
  writeln ('program will ask you weather you want the Psychadelic effect, in');
  writeln ('which the pallette does strange things (otherwise the pallette');
  writeln ('remains constant), and it will ask weather you want a background');
  writeln ('(a static pic behind the plasma). Try them both!');
  writeln;
  writeln ('The thing about plasmas is that they are very easy to change/modify');
  writeln ('and this one is no exception .. you can even change the background');
  writeln ('with minimum hassle. Try adding and deleting things, you will be');
  writeln ('surprised by the results!');
  writeln;
  writeln ('This is by no means the only way to do plasmas, and there are other');
  writeln ('sample programs out there. Have fun with this one though! ;-)');
  writeln;
  writeln;
  init;
  play;
  asm
    mov  ax,0003h
    int  10h
  end;
  Writeln ('All done. This concludes the fifteenth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS.I also occasinally');
  Writeln ('RSAProg, comp.lang.pascal and comp.sys.ibm.pc.demos. E-mail me at :');
  Writeln ('    denthor@beastie.cs.und.ac.za');
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
