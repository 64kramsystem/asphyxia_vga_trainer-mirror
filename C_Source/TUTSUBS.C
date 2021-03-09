/* 
  tutsubs.c
  10/30/94
  from gfx2.pas
  Adapted from Denthor's gfx2.pas
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
*/

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#include <conio.h>
#include <graph.h>
#include <bios.h>
#include <string.h> 
#include <time.h> 
#include "tutheadr.h"


//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure SetMCGA;  { This procedure gets you into 320x200x256 mode. }
void SetMCGA()
{
  _asm
  {
     mov        ax,0013h
     int        10h
  }
}


//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure SetText;  { This procedure returns you to text mode.  }
void SetText()
{
  _asm
  {
     mov        ax,0003h
     int        10h
  }
}


//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//procedure WaitRetrace; assembler;
/*
    This waits until you are in a Verticle Retrace ... this means that all
    screen manipulation you do only appears on screen in the next verticle
    retrace ... this removes most of the "fuzz" that you see on the screen
    when changing the pallette. It unfortunately slows down your program
    by "synching" your program with your monitor card ... it does mean
    that the program will run at almost the same speed on different
    speeds of computers which have similar monitors. In our SilkyDemo,
    we used a WaitRetrace, and it therefore runs at the same (fairly
    fast) speed when Turbo is on or off. 
*/

void WaitRetrace()
{
  _asm
  {
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
  }
}


//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
void GetPal(char ColorNo, char* R, char* G, char* B)
//  This reads the values of the Red, Green and Blue values of a certain
//  color and returns them to you. 
{
   outp(0x3c7,ColorNo);
   *R=inp(0x3c9);
   *G=inp(0x3c9);
   *B=inp(0x3c9);
}


//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure Pal(ColorNo : Byte; R,G,B : Byte);
void Pal(char ColorNo, char R, char G, char B)
//  This sets the Red, Green and Blue values of a certain color 
{
   outp(0x3c8,ColorNo);
   outp(0x3c9,R);
   outp(0x3c9,G);
   outp(0x3c9,B);
}

//////////////////////////////////////////////////////////////
void SetAllPal(char far* pal)
{ 
  outp(0x3c8,0x0); // Set to first color
  _asm
  {
    mov  cx,768
    lds  si,pal   // loads pal into ds:si
	mov  dx,0x3c9  
	rep  outsb    // sends out the string pointed to by ds:si
  }
}

//DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure PutPixel (X,Y : Integer; Col : Byte);
//  This puts a pixel on the screen by writing directly to memory. 
void PutPixel(int X, int Y, char Color, int Where)
{
  unsigned char far* VGAScreenPtr;
  unsigned int offset;
  offset=(unsigned)X + (unsigned)(Y<<8) + (unsigned)(Y<<6);
  VGAScreenPtr=MK_FP(Where,offset);
  *VGAScreenPtr=Color;
}

////////////////////////// line //////////////////////////////////
//  Procedure line(a,b,c,d,col:integer);
//  This draws a line from a,b to c,d of color col. }
//  This routine is adapted from Programmer's Guide to the EGA and VGA Cards,
//  by Ferraro. It's Bresenham's algorithm. I used it instead of translating
//  the one in the trainer because I already had it and it worked.

void Line(int x1, int y1, int x2, int y2, unsigned char Color)

{
  int dx,dy,incr1,incr2,d,x,y,xend,yend,yinc,xinc;

  dx=abs(x2-x1);
  dy=abs(y2-y1);

  if(dx>=dy) // slope < 1
  {
    if(x1>x2)
	{
	  x=x2; y=y2; xend=x1;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=-1; else yinc=1;}
	}
	else
	{
	  x=x1; y=y1; xend=x2;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=1; else yinc=-1;}
	}
    incr1=2*dy; d=incr1-dx; incr2=2*(dy-dx);
	PutPixel(x,y,Color,VGA);
    while(x<xend)
    {
      x++;
      if(d<0) d+=incr1;
      else { y+=yinc; d+=incr2;}
	  PutPixel(x,y,Color,VGA);
    }
  }
  else
  {
    if(y1>y2)
	{ 
	  x=x2; y=y2; yend=y1;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc = -1; else xinc = 1;}
    }
	else
	{
	  x=x1; y=y1; yend=y2;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc=1; else xinc = -1;}
	}
	incr1=2*dx; d=incr1-dy; incr2=2*(dx-dy);
	PutPixel(x,y,Color,VGA);
	while(y<yend)
	{
	  y++;
	  if(d<0) d+=incr1;
	  else { x+=xinc; d+=incr2; }
	  PutPixel(x,y,Color,VGA);
	}
  }
}
//////////////////////////////////////////////////////////////////

void Line2(int x1, int y1, int x2, int y2, unsigned char Color, int where)
// Same as Line (above), except takes the argument where instead of
// being hard coded to write to VGA.

//////////////////////////////////////////////////////////////////
{
  int dx,dy,incr1,incr2,d,x,y,xend,yend,yinc,xinc;

  dx=abs(x2-x1);
  dy=abs(y2-y1);

  if(dx>=dy) // slope < 1
  {
    if(x1>x2)
	{
	  x=x2; y=y2; xend=x1;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=-1; else yinc=1;}
	}
	else
	{
	  x=x1; y=y1; xend=x2;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=1; else yinc=-1;}
	}
    incr1=2*dy; d=incr1-dx; incr2=2*(dy-dx);
	PutPixel(x,y,Color,where);
    while(x<xend)
    {
      x++;
      if(d<0) d+=incr1;
      else { y+=yinc; d+=incr2;}
	  PutPixel(x,y,Color,where);
    }
  }
  else
  {
    if(y1>y2)
	{ 
	  x=x2; y=y2; yend=y1;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc = -1; else xinc = 1;}
    }
	else
	{
	  x=x1; y=y1; yend=y2;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc=1; else xinc = -1;}
	}
	incr1=2*dx; d=incr1-dy; incr2=2*(dx-dy);
	PutPixel(x,y,Color,where);
	while(y<yend)
	{
	  y++;
	  if(d<0) d+=incr1;
	  else { x+=xinc; d+=incr2; }
	  PutPixel(x,y,Color,where);
	}
  }
}


////////////////////////// Funny_Line //////////////////////////////////

void Funny_Line(int x1, int y1, int x2, int y2, int where)

//////////////////////////////////////////////////////////////////
{
  int dx,dy,incr1,incr2,d,x,y,xend,yend,yinc,xinc;
  int count = 50;

  dx=abs(x2-x1);
  dy=abs(y2-y1);

  if(dx>=dy) // slope < 1
  {
    if(x1>x2)
	{
	  x=x2; y=y2; xend=x1;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=-1; else yinc=1;}
	}
	else
	{
	  x=x1; y=y1; xend=x2;
	  if(dy==0) yinc=0;
	  else { if(y2>y1) yinc=1; else yinc=-1;}
	}
    incr1=2*dy; d=incr1-dx; incr2=2*(dy-dx);
	PutPixel(x,y,(char)count,where);
	count++;
	if(count==101)count=50;
    while(x<xend)
    {
      x++;
      if(d<0) d+=incr1;
      else { y+=yinc; d+=incr2;}
	  PutPixel(x,y,(char)count,where);
	  count++;
	  if(count==101)count=50;
    }
  }
  else
  {
    if(y1>y2)
	{ 
	  x=x2; y=y2; yend=y1;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc = -1; else xinc = 1;}
    }
	else
	{
	  x=x1; y=y1; yend=y2;
	  if(dx==0) xinc=0;
	  else { if(x2>x1) xinc=1; else xinc = -1;}
	}
	incr1=2*dx; d=incr1-dy; incr2=2*(dx-dy);
	PutPixel(x,y,(char)count,where);
	count++;
	if(count==101)count=50;
	while(y<yend)
	{
	  y++;
	  if(d<0) d+=incr1;
	  else { x+=xinc; d+=incr2; }
	  PutPixel(x,y,(char)count,where);
	  count++;
	  if(count==101)count=50;
	}
  }
}
// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure PalPlay;
void PalPlay()
{
//  This procedure mucks about with our "virtual pallette", then shoves it
//  to screen. 
//  This is used as a "temporary color" in our pallette:
    char Tmp[3];

// This copies color 200 from our virtual pallette to the Tmp variable:
   _fmemmove(Tmp,Pall[200],3);
// This moves the entire virtual pallette up one color:
   _fmemmove(Pall[2],Pall[1],199*3);
// This copies the Tmp variable to the bottom of the virtual pallette:
// Don't change 0: leave this always black to not change overscan color.
   _fmemmove(Pall[1],Tmp,3);
   WaitRetrace();
   SetAllPal((char far*)&Pall[0][0]);
}

//////////////////////////////////////////////////////////////////////
// More general purpose version of the above routine, used in tut7.c:
// Moves all colors up one. Note fmemmove is (dest,src)

void rotatepal(char locpal[][3], int start, int end)
{
   char Tmp[3];
   int loop1;
   int number=end-start;

   _fmemmove(Tmp,locpal[end],3);
   _fmemmove(locpal[start+1],locpal[start],number*3);
   _fmemmove(locpal[start],Tmp,3);
   WaitRetrace();
   for(loop1=start;loop1<end+1;loop1++)
     Pal((unsigned char)loop1,locpal[loop1][0],locpal[loop1][1],
                              locpal[loop1][2]);
}


// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure GrabPallette;
void GrabPallette()
{
  int loop1;
  for(loop1=0;loop1<256;loop1++)
  {
    GetPal((unsigned char)loop1,&Pall2[loop1][0],&Pall2[loop1][1],&Pall2[loop1][2]);
  }
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Blackout;
//  This procedure blackens the screen by setting the pallette values of
//  all the colors to zero. 
void Blackout()
{
  int loop1;
  WaitRetrace();
  for(loop1=0;loop1<256;loop1++)
  {
    Pal((unsigned char)loop1,0,0,0);
  }
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Fadeup;
// This procedure slowly fades up the new screen }
void FadeUp()
{
  int loop1,loop2;
  char Tmp[3]; // This is temporary storage for the values of a color 

  // A color value for Red, green or blue is 0 to 63, so this loop only
  // need be executed a maximum of 64 times:
  for(loop1=0;loop1<64;loop1++)
  {
    WaitRetrace();
	for(loop2=0;loop2<256;loop2++)
	{
	  GetPal((unsigned char)loop2,&Tmp[0],&Tmp[1],&Tmp[2]);
      // If the Red, Green or Blue values of color loop2 are less then they
      // should be, increase them by one: 
      if(Tmp[0]<Pall2[loop2][0]) Tmp[0]++;
      if(Tmp[1]<Pall2[loop2][1]) Tmp[1]++;
      if(Tmp[2]<Pall2[loop2][2]) Tmp[2]++;
      // Set the new, altered pallette color: 
	  Pal((unsigned char)loop2,Tmp[0],Tmp[1],Tmp[2]);
	}
  }
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure FadeDown;
// This procedure fades the screen out to black. }
void FadeDown()
{
  int loop1,loop2;
  char Tmp[3]; // This is temporary storage for the values of a color 

  // A color value for Red, green or blue is 0 to 63, so this loop only
  // need be executed a maximum of 64 times:
  for(loop1=0;loop1<64;loop1++)
  {
    WaitRetrace();
	for(loop2=0;loop2<256;loop2++)
	{
	  GetPal((unsigned char)loop2,&Tmp[0],&Tmp[1],&Tmp[2]);
      // If the Red, Green or Blue values of color loop2 are not yet zero,
      // then, decrease them by one. }
      if(Tmp[0]>0) Tmp[0]--;
      if(Tmp[1]>0) Tmp[1]--;
      if(Tmp[2]>0) Tmp[2]--;
      // Set the new, altered pallette color: 
	  Pal((unsigned char)loop2,Tmp[0],Tmp[1],Tmp[2]);
	}
  }
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure RestorePallette;
// This procedure restores the origional pallette 
void RestorePallette()
{
  int loop1;
  WaitRetrace();
  for(loop1=0;loop1<256;loop1++)
    Pal ((unsigned char)loop1,Pall2[loop1][0],Pall2[loop1][1],Pall2[loop1][2]);
}

///////////////////////////////////////////////////////////////////////////////

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Cls (Col : Byte; Where:Word);
// This clears the screen to the specified color, on the VGA or on the
// virtual screen 
// Argument Where will be either VGA or Vaddr: the SEG of the Screen Pointer.
void Cls(char Color, int Where)
{
  unsigned char far* ScreenPtr;
  ScreenPtr=MK_FP(Where,0x0);
  _fmemset(ScreenPtr,Color,(unsigned int)64000);
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Flip;
// { This flips the virtual screen to the VGA screen. }
void Flip()
{
  unsigned char far* ScreenPtr;
  ScreenPtr=MK_FP(VGA,0x0);
  _fmemmove(ScreenPtr,VirtPtr,(unsigned int)64000);
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// procedure flip(source,dest:Word);
//   { This copies the entire screen at "source" to destination }
void Flip2(int Source, int Dest)
{
  _asm
  {
    push    ds
    mov     ax, Dest
    mov     es, ax
    mov     ax, Source
    mov     ds, ax
    xor     si, si
    xor     di, di
    mov     cx, 32000
    rep     movsw
    pop     ds
  }
}

//////////////////////////////////////////////////////////////
// Initializes the random number generator with a new seed
// based on the system time
void randomize()
{
  srand((unsigned)time(NULL));
}

//////////////////////////////////////////////////////////////
// returns a value from 0 to x-1.
// RAND_MX1 is RAND_MAX + 1 to insure that the boundary
// value of x is never attained.
int random(int x)
{
  return (int)((long)(rand()*(long)x)/(long)RAND_MX1);
}

// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
// Function rad (theta : real) : real;
// This calculates the degrees of an angle
//   rad := theta * pi / 180
float rad(float theta)
{
  return theta*PI/(float)180.0;
}

int round(float x)
{
  if(x>=0)
    return (int)(x+0.5);
  else
    return (int)(x-0.5);
}

////////////////  SetUpVirtual /////////////////////////
// Sets up pointers to 2 virtual screens

void SetUpVirtual()
{
  VirtPtr=&Virtual[0];
  Vaddr = FP_SEG(VirtPtr);
  VirtPtr2=&Virtual2[0];
  Vaddr2 = FP_SEG(VirtPtr2);
}

//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure Hline (x1,x2,y:word;col:byte;where:word); assembler;
//  { This draws a horizontal line from x1 to x2 on line y in color col }
void Hline(int x1, int x2, int y, char col, int where)
{
 _asm
 {
  mov   ax,where
  mov   es,ax
  mov   ax,y
  mov   di,ax
  shl   ax,8
  shl   di,6
  add   di,ax
  add   di,x1

  mov   al,col
  mov   ah,al
  mov   cx,x2
  sub   cx,x1
  shr   cx,1
  jnc   lstart
  stosb
lstart :
  rep   stosw
 }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Putpixel (X,Y : Integer; Col : Byte; where:word);
// This puts a pixel on the screen by writing directly to memory. }
// Assembly version
void PutPixel2(int x, int y, char col, int where)
{
  _asm
  {
    mov     ax,where
    mov     es,ax
    mov     bx,x
    mov     dx,y
    mov     di,bx
    mov     bx, dx   //               {; bx = dx}
    shl     dx, 8
    shl     bx, 6
    add     dx, bx   //               {; dx = dx + bx (ie y*320)}
    add     di, dx   //               {; finalise location}
    mov     al, col
    stosb
  }
}    

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Function Getpixel (X,Y : Integer; where:word):byte; assembler;
// { This gets a pixel from the screen by reading directly from memory. }
char GetPixel(int x, int y, int where)
{
  _asm
  {
  mov     ax,where
  mov     es,ax
  mov     bx,x
  mov     dx,y
  mov     di,bx
  mov     bx, dx                  ; bx = dx}
  shl     dx, 8
  shl     bx, 6
  add     dx, bx                  ; dx = dx + bx (ie y*320)}
  add     di, dx                  ; finalise location}
  mov     al, es:[di]
  }
}  
// This generates warning of no return value, but
// this is OK; value is returned in al. See pg. 279 "C For Yourself",
// Microsoft Press.

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure LoadCEL (FileName :  string; ScrPtr : pointer);
//  { This loads the cel 'filename' into the pointer scrptr }
void LoadCEL(char* FileName, char far* ScrPtr)
{
  FILE* fptr;
  char far* TmpPtr;
  
  TmpPtr=ScrPtr;  // Do this so ScrPtr doesn't get incremented.
  if((fptr=fopen(FileName,"rb"))==NULL)
  {                                            
    SetText();
    printf("Error opening file %s\n",FileName);
    exit(1);
  }
  fseek(fptr,(long)800,SEEK_SET);  //offset 800 from beginning of file.
  fread(TmpPtr,sizeof(char),(unsigned)64000,fptr);
  fclose(fptr);
}  

void delay(int wait)
{
  long goal;
  goal=(long)wait + clock();
  while(goal>clock());
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure InitChain4; ASSEMBLER;
//   {  This procedure gets you into Chain 4 mode }
//   Also see listing 10.1, pg. 206 of Power Graphics Programming, Abrash
void InitChain4(int ScrSize)
{
 _asm 
 {
    mov    ax, 13h
    int    10h       ;  { Get into MCGA Mode }

    mov    dx, 3c4h  ;  { Port 3c4h = Sequencer Address Register }
    mov    al, 4     ;  { Index 4 = memory mode }
    out    dx, al
    inc    dx        ;  { Port 3c5h ... here we set the mem mode }
    in     al, dx
    and    al, not 08h ; turn off bit 3, the C4 bit, see pg 357 Ferraro.
    or     al, 04h     ; turn on bit 2, the O/E bit
    out    dx, al
    mov    dx, 3ceh  ; Port 3ceh = Graphics Address Register
    mov    al, 5     ; Index 5 = Mode
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 10h ; turn off bit 4, the O/E bit
    out    dx, al
    dec    dx
    mov    al, 6     ; Index 6 = Miscellaneous Register
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 02h  ; Turn of bit 1, chain odd/even
    out    dx, al
    mov    dx, 3c4h  ; Sequencer Address Register
    mov    ax, (0fh shl 8) + 2 ; write 0fh to register: enable all 4 planes
    out    dx, ax
    mov    ax, 0a000h
    mov    es, ax
    sub    di, di
    mov    ax, 0000h ;  Store 0000h to es:di, 32K times:
    mov    cx, 32768 ;  8000h=32K words = 64K bytes
    cld
    rep    stosw      ;     { Clear garbage off the screen ... }

    mov    dx, 3d4h
    mov    al, 14h  ; underline register
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 40h ; Turn off double word addressing, see pg 380 Ferraro
    out    dx, al
    dec    dx
    mov    al, 17h  ; mode control register
    out    dx, al
    inc    dx
    in     al, dx
    or     al, 40h  ; byte mode
    out    dx, al

    mov    dx, 3d4h
    mov    al, 13h    ;   Offset register, = logical display width
    out    dx, al
    inc    dx
    mov    ax, ScrSize   ;    Size * 8 = Pixels across. Only 320 are visible
    out    dx, al        ;    Note that size is a keyword in MASM!
  }
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure C4PutPixel(X,Y : Word; Col : Byte); ASSEMBLER;
//   { This puts a pixel on the chain 4 screen }
void C4PutPixel(int x, int y, char col, int ScrSize)
{
  _asm 
  {
    mov    ax,y
    xor    bx,bx
    mov    bx,ScrSize
    imul   bx
    shl    ax,1
    mov    bx,ax
    mov    ax, x
    mov    cx, ax
    shr    ax, 2
    add    bx, ax
    and    cx, 00000011b
    mov    ah, 1
    shl    ah, cl
    mov    dx, 3c4h        ;         { Sequencer Register    }
    mov    al, 2           ;         { Map Mask Index        }
    out    dx, ax

    mov    ax, 0a000h
    mov    es, ax
    mov    al, col
    mov    es: [bx], al
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Plane(Which : Byte); ASSEMBLER;
//   { This sets the plane to write to in Chain 4}
void Plane(char Which)
{
 _asm
 {
   mov     al, 2h
   mov     ah, 1
   mov     cl, Which
   shl     ah, cl
   mov     dx, 3c4h     ;            { Sequencer Register    }
   out     dx, ax
 }
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// procedure moveto(x, y : word);
//   { This moves to position x*4,y on a chain 4 screen }
void moveto(int x, int y, int Size)
{
  int o;
  o=y*Size*2+x;
  _asm
  {
    mov    bx, o
    mov    ah, bh
    mov    al, 0ch

    mov    dx, 3d4h
    out    dx, ax

    mov    ah, bl
    mov    al, 0dh
    mov    dx, 3d4h
    out    dx, ax
  }
}

