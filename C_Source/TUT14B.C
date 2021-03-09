/* 
  tut14b.c
  10/30/94
  from tutprog14.pas
  Adapted from Denthor's tutprog14.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com  
  Variation of tut14.c to do solid cube with face sorting and shading.
  For each side of the cube, a normal vector is rotated along with the
  corners of the face, to use for computing the shading.
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut14b.c
           to compile this program.
*/

#include "tutheadr.h"

#define maxpolys 6

int a[maxpolys][5][3] = 
{
     // 6 sides of a cube, plus exterior normals:
     {{-10,-10,10},{-10,10,10},{10,10,10},{10,-10,10},{0,0,8}},       //z= 10
     {{-10,-10,-10},{-10,10,-10},{10,10,-10},{10,-10,-10},{0,0,-8}},  //z=-10
     {{-10,-10,-10},{-10,10,-10},{-10,10,10},{-10,-10,10},{-8,0,0}},  //x=-10
     {{10,-10,-10},{10,10,-10},{10,10,10},{10,-10,10},{8,0,0}},       //x= 10
     {{10,-10,10},{10,-10,-10},{-10,-10,-10},{-10,-10,10},{0,-8,0}},  //y=-10
     {{10,10,10},{10,10,-10},{-10,10,-10},{-10,10,10},{0,8,0}}        //y= 10
};         
        // The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
        // (X2,Y2,Z2) ... for the 4 points of a poly }
		// fifth point is exterior normal. Later gets multiplied by 8,
		// so normal has length 64, giving right scale for color.

struct IPoint
{
  int x;
  int y;
  int z;
};  
struct IPoint lines[maxpolys][5],translated[maxpolys][5];
int lookup[360][2];  // sin and cos table
int poly[200][2];
int ytopclip,ybotclip;
int xoff,yoff,zoff;

///////////////////////////////////////////////////////////////////////////
//Procedure doside (x1,y1,x2,y2:integer);
//  { This scans the side of a polygon and updates the poly variable }
void doside(int x1,int y1,int x2,int y2)
{
  int temp,x,xinc,loop1;
  
  if(y1==y2)return;
  if(y2<y1)
  {
    temp=y2;
    y2=y1;
    y1=temp;
    temp=x2;
    x2=x1;
    x1=temp;
  }
  xinc=((x2-x1)<<7)/(y2-y1);
  x=(x1<<7);
  for(loop1=y1;loop1<=y2;loop1++)
  {
    if((loop1>ytopclip-1)&&(loop1<ybotclip+1))
    {
      if((x>>7)<poly[loop1][0]) poly[loop1][0]=(x>>7); // min
      if((x>>7)>poly[loop1][1]) poly[loop1][1]=(x>>7); // max
    }
    x+=xinc;
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
// This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
// in color col }
void drawpoly(int x1,int y1,int x2,int y2,int x3,int y3,int x4,int y4,char color,int where)
{
  int miny,maxy,loop1;

  _asm
  {
    mov   si,offset poly
    mov   cx,200
Loop1:
    mov   ax,32766
    mov   ds:[si],ax
    inc   si
    inc   si
    mov   ax,-32767
    mov   ds:[si],ax
    inc   si
    inc   si
    loop  Loop1
   }       // { Setting the minx and maxx values to extremes }
  miny=y1;
  maxy=y1;
  if (y2<miny)  miny=y2;
  if (y3<miny)  miny=y3;
  if (y4<miny)  miny=y4;
  if (y2>maxy)  maxy=y2;
  if (y3>maxy)  maxy=y3;
  if (y4>maxy)  maxy=y4;
  if (miny<ytopclip)  miny=ytopclip;
  if (maxy>ybotclip)  maxy=ybotclip;
  if ((miny>199) || (maxy<0)) return;

  doside (x1,y1,x2,y2);
  doside (x2,y2,x3,y3);
  doside (x3,y3,x4,y4);
  doside (x4,y4,x1,y1);

  for( loop1= miny;loop1<=maxy;loop1++)
    // Hline2 (poly[loop1][0],poly[loop1][1],loop1,color,where); //transparent
    Hline (poly[loop1][0],poly[loop1][1],loop1,color,where);  //solid
}

//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure SetUpPoints;
//  { This creates the lookup table }
void SetUpPoints()
{
  int loop1;
  for(loop1=0;loop1<360;loop1++)
  {
    lookup[loop1][0]=round((float)sin((double)rad(loop1))*(float)16384);
    lookup[loop1][1]=round((float)cos((double)rad(loop1))*(float)16384);
  }
}


//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure RotatePoints (x,Y,z:Integer);
//  { This rotates the objecct in lines to translated }
void rotatepoints(int x, int y, int z)
{
  int loop1,loop2;
  int a,b,c;
  
  for(loop1=0;loop1<maxpolys;loop1++)
  {
    for(loop2=0;loop2<5;loop2++) // rotate the normals also!
    {
      b=lookup[y][1];
      c=lines[loop1][loop2].x;
      _asm
      {
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      }
      b=lookup[y][0];
      c=lines[loop1][loop2].z;
      _asm
      {
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        add   a,dx
      }
      translated[loop1][loop2].x=a;
      translated[loop1][loop2].y=lines[loop1][loop2].y;
      b=-lookup[y][0];
      c=lines[loop1][loop2].x;
      _asm
      {
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      }
      b=lookup[y][1];
      c=lines[loop1][loop2].z;
      _asm
      {
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        add   a,dx
      }
      translated[loop1][loop2].z=a;


      if(x!=0)
      {
        b=lookup[x][1];
        c=translated[loop1][loop2].y;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        }
        b=lookup[x][0];
        c=translated[loop1][loop2].z;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          sub   a,dx
        }
        b=lookup[x][0];
        c=translated[loop1][loop2].y;
        translated[loop1][loop2].y=a;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        }
        b=lookup[x][1];
        c=translated[loop1][loop2].z;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          add   a,dx
        }
        translated[loop1][loop2].z=a;
      }



      if(z!=0)
      {
        b=lookup[z][1];
        c=translated[loop1][loop2].x;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        }
        b=lookup[z][0];
        c=translated[loop1][loop2].y;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          sub   a,dx
        }
        b=lookup[z][0];
        c=translated[loop1][loop2].x;
        translated[loop1][loop2].x=a;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        }
        b=lookup[z][1];
        c=translated[loop1][loop2].y;
        _asm
        {
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          add   a,dx
        }
        translated[loop1][loop2].y=a;
      }
    }
  }
}


/////////////////////////////////////////////////////////////////////////////
// Sort in descending order.
// There are probably better ways of doing this...
void sort(int* x, int* index, int n)
{
  int i,j;
  int temp;
  for(i=0;i<n;i++)index[i]=i;
  for(i=0;i<n-1;i++)
    for(j=i+1;j<n;j++)
	  if(x[i]<x[j])
	  {
	    temp=x[i];
		x[i]=x[j];
		x[j]=temp;
		temp=index[i];
		index[i]=index[j];
		index[j]=temp;
	  }
}

//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//  Procedure DrawPoints;
//  { This draws the translated object to the virtual screen }
void drawpoints()
{
  int loop1,loop2;
  int temp;
  int nx;
  int tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4;
  int zdist[maxpolys];
  int index[maxpolys];
  int zcolor;
  
  for(loop1=0;loop1<maxpolys;loop1++)
  {
    zdist[loop1]=translated[loop1][0].z+translated[loop1][1].z+
	      translated[loop1][2].z+translated[loop1][3].z;
  }
  sort(zdist,index,maxpolys);

  // Find the 3 nearest, and then draw the furthest first:
  for(loop2=2;loop2>=0;loop2--)
  {
	loop1=index[loop2];
    if((translated[loop1][0].z+zoff<0)&&(translated[loop1][1].z+zoff<0)
     &&(translated[loop1][2].z+zoff<0)&&(translated[loop1][3].z+zoff<0))
     {
	  zcolor=translated[loop1][4].z;
	  if(zcolor==64)zcolor=63;
	  if(zcolor<10)zcolor=10;
      temp=(translated[loop1][0].z)+zoff;
      nx=translated[loop1][0].x;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,160
        mov   nx,ax
      }
      tx1=nx;
      nx=translated[loop1][0].y;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,100
        mov   nx,ax
      }
      ty1=nx;


      temp=(translated[loop1][1].z)+zoff;
      nx=translated[loop1][1].x;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,160
        mov   nx,ax
      }
      tx2=nx;
      nx=translated[loop1][1].y;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,100
        mov   nx,ax
      }
      ty2=nx;


      temp=(translated[loop1][2].z)+zoff;
      nx=translated[loop1][2].x;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,160
        mov   nx,ax
      }
      tx3=nx;
      nx=translated[loop1][2].y;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,100
        mov   nx,ax
      }
      ty3=nx;


      temp=(translated[loop1][3].z)+zoff;
      nx=translated[loop1][3].x;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,160
        mov   nx,ax
      }
      tx4=nx;
      nx=translated[loop1][3].y;
      _asm
      {
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,100
        mov   nx,ax
      }
      ty4=nx;

      drawpoly (tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4,(char)zcolor,Vaddr);
    }
  }
}      

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure MoveAround;
//{ This is the main display procedure. }
void movearound()
{
  int deg,loop1,loop2;
  int degincr=1; // degincr must divide 360! (was 2)
  int clipincr=1; // clipincr must divide 100;
  int ch;

  for(loop1=0;loop1<64;loop1++)
  {
    Pal((char)loop1,(char)loop1,0,0);
    Pal((char)(64+loop1),0,(char)loop1,0);
    Pal((char)(128+loop1),0,0,(char)loop1);
  }

  deg=0;    
  Cls (0,Vaddr);
  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<5;loop2++)  // 5th point is normal to face
    {
      lines[loop1][loop2].x=a[loop1][loop2][0]*8;
      lines[loop1][loop2].y=a[loop1][loop2][1]*8;
      lines[loop1][loop2].z=a[loop1][loop2][2]*8;
    }
     
  Cls(0,Vaddr);
  Cls(0,VGA);
  xoff=160;
  yoff=100;
  zoff=-500;
  
  ytopclip=101;
  ybotclip=100;
  Line2(0,100,319,100,100,VGA);
  delay (500);
  for(loop1=0;loop1<100/clipincr;loop1++)
  {
    rotatepoints(deg,deg,deg);
    drawpoints();
    Line2(0,ytopclip,319,ytopclip,100,Vaddr);
    Line2(0,ybotclip,319,ybotclip,100,Vaddr);
    WaitRetrace();
    Flip2(Vaddr,VGA);
    Cls (0,Vaddr);
    deg+=degincr; if(deg==360)deg=0; // Was deg+=5 mod 360.
    ytopclip=ytopclip-clipincr;
    ybotclip=ybotclip+clipincr;
  }
  while(1)
  {
    rotatepoints(deg,deg,deg);
    drawpoints();
    Line2(0,0,319,0,100,Vaddr);
    Line2(0,199,319,199,100,Vaddr);
    WaitRetrace();
    Flip2(Vaddr,VGA);
    Cls (0,Vaddr);
    deg+=degincr; if(deg==360)deg=0; // Was deg+=5 mod 360.
    if(_bios_keybrd(_KEYBRD_READY))
    {
      ch=(0x00ff&getch());
      if(ch==0x1b)break;
    }
  }
  for(loop1=0;loop1<100/clipincr;loop1++)
  {
    ytopclip=ytopclip+clipincr;
    ybotclip=ybotclip-clipincr;
    rotatepoints(deg,deg,deg);
    drawpoints();
    Line2(0,ytopclip,319,ytopclip,100,Vaddr);
    Line2(0,ybotclip,319,ybotclip,100,Vaddr);
    WaitRetrace();
    Flip2(Vaddr,VGA);
    Cls (0,Vaddr);
    deg+=degincr; if(deg==360)deg=0; // Was deg+=5 mod 360.
  }
}

void main()
{
  SetUpVirtual();
  SetMCGA();
  SetUpPoints();
  movearound();
  SetText();
}

  
/*
BEGIN
  clrscr;
  writeln ('Welcome to the fourteenth trainer! This one is on glenzing, and also');
  writeln ('throws in a faster poly, fixed point math and a lot more assembler.');
  writeln;
  Writeln ('This isn''t very interactive ... hit any key to start, and then');
  writeln ('hit the [ESC] key to exit. It is a glenzed cube spinning in the');
  writeln ('middle of the screen. Read the text file for more information on');
  writeln ('how the fixed point etc. works ... it will also help a lot if you');
  writeln ('compare it with TUTPROG9.PAS, as this is the same 3D system, just');
  writeln ('speeded up.');
  writeln;
  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  SetUpVirtual;
  SetMCGA;
  SetUpPoints;
  MoveAround;
  SetText;
  ShutDown;
  Writeln ('All done. This concludes the fourteenth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS.I also occasinally');
  Writeln ('RSAProg, comp.lang.pascal and comp.sys.ibm.pc.demos. E-mail me at :');
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
