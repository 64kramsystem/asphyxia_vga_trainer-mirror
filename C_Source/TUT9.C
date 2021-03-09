/* 
  tut9.c
  10/30/94
  from tutprog9.pas
  Adapted from Denthor's tutprog9.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut9.c
           to compile this program.
*/

#include "tutheadr.h"
#define maxpolys 5
int A[maxpolys][4][3] = 
        {
         {{-10,10,0},{-2,-10,0},{0,-10,0},{-5,10,0}},
         {{10,10,0},{2,-10,0},{0,-10,0},{5,10,0}},
         {{-2,-10,0},{2,-10,0},{2,-5,0},{-2,-5,0}},
         {{-6,0,0},{6,0,0},{7,5,0},{-7,5,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        }; // { The 3-D coordinates of our object ... stored as (X1,Y1,Z1}, }
           // { (X2,Y2,Z2} ... for the 4 points of a poly }
int S[maxpolys][4][3] = 
        {
         {{-10,-10,0},{10,-10,0},{10,-7,0},{-10,-7,0}},
         {{-10,10,0},{10,10,0},{10,7,0},{-10,7,0}},
         {{-10,1,0},{10,1,0},{10,-2,0},{-10,-2,0}},
         {{-10,-8,0},{-7,-8,0},{-7,0,0},{-10,0,0}},
         {{10,8,0},{7,8,0},{7,0,0},{10,0,0}}
        }; // { The 3-D coordinates of our object ... stored as {X1,Y1,Z1}, }
           //{ {X2,Y2,Z2} ... for the 4 points of a poly }
int P[maxpolys][4][3] = 
        {
         {{-10,-10,0},{-7,-10,0},{-7,10,0},{-10,10,0}},
         {{10,-10,0},{7,-10,0},{7,0,0},{10,0,0}},
         {{-9,-10,0},{9,-10,0},{9,-7,0},{-9,-7,0}},
         {{-9,-1,0},{9,-1,0},{9,2,0},{-9,2,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        }; // { The 3-D coordinates of our object ... stored as (X1,Y1,Z1}, }
           // { (X2,Y2,Z2} ... for the 4 points of a poly }
int H[maxpolys][4][3] = 
        {
         {{-10,-10,0},{-7,-10,0},{-7,10,0},{-10,10,0}},
         {{10,-10,0},{7,-10,0},{7,10,0},{10,10,0}},
         {{-9,-1,0},{9,-1,0},{9,2,0},{-9,2,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        }; // { The 3-D coordinates of our object ... stored as {X1,Y1,Z1}, }
           // { (X2,Y2,Z2} ... for the 4 points of a poly }
int Y[maxpolys][4][3] = 
        {
         {{-7,-10,0},{0,-3,0},{0,0,0},{-10,-7,0}},
         {{7,-10,0},{0,-3,0},{0,0,0},{10,-7,0}},
         {{-2,-3,0},{2,-3,0},{2,10,0},{-2,10,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        }; // { The 3-D coordinates of our object ... stored as {X1,Y1,Z1}, }
           // { {X2,Y2,Z2} ... for the 4 points of a poly }
int X[maxpolys][4][3] = 
        {
         {{-7,-10,0},{10,7,0},{7,10,0},{-10,-7,0}},
         {{7,-10,0},{-10,7,0},{-7,10,0},{10,-7,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        }; // { The 3-D coordinates of our object ... stored as {X1,Y1,Z1}, }
           // { {X2,Y2,Z2} ... for the 4 points of a poly }
int I[maxpolys][4][3] = 
        {
         {{-10,-10,0},{10,-10,0},{10,-7,0},{-10,-7,0}},
         {{-10,10,0},{10,10,0},{10,7,0},{-10,7,0}},
         {{-2,-9,0},{2,-9,0},{2,9,0},{-2,9,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}},
         {{0,0,0},{0,0,0},{0,0,0},{0,0,0}}
        }; // { The 3-D coordinates of our object ... stored as {X1,Y1,Z1}, }
           // { {X2,Y2,Z2) ... for the 4 points of a poly }



struct Point Lines[maxpolys][4];
struct Point translated[maxpolys][4];
int xoff,yoff,zoff;
float lookup[360][2];




// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
//   { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
//    in color col }
void DrawPoly(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4, char color, int where)
{
  int x;
  int mny,mxy;
  int mnx,mxx,yc;
  int mul1,div1,mul2,div2,mul3,div3,mul4,div4;

  mny=y1; mxy=y1;
  if (y2<mny) mny=y2;
  if (y2>mxy) mxy=y2;
  if (y3<mny) mny=y3;
  if (y3>mxy) mxy=y3;  //  { Choose the min y mny and max y mxy }
  if (y4<mny) mny=y4;
  if (y4>mxy) mxy=y4;

  if (mny<0)   mny=0;
  if (mxy>199) mxy=199;
  if (mny>199) return;
  if (mxy<0)   return;  //      { Verticle range checking }

  mul1=x1-x4; div1=y1-y4;
  mul2=x2-x1; div2=y2-y1;
  mul3=x3-x2; div3=y3-y2;
  mul4=x4-x3; div4=y4-y3; // { Constants needed for intersection calc }

  for (yc=mny;yc<=mxy;yc++)
  {
      mnx=320;
      mxx=-1;
      if ((y4>=yc) || (y1>=yc))
        if ((y4<=yc)|| (y1<=yc)) // { Check that yc is between y1 and y4 }
          if (!(y4==y1))
            {
              x=(yc-y4)*mul1/div1+x4; // { Point of intersection on x axis }
              if (x<mnx)
                mnx=x;
              if (x>mxx)
                mxx=x;    // { Set point as start or end of horiz line }
            }
      if ((y1>=yc) || (y2>=yc))
        if ((y1<=yc) || (y2<=yc))// { Check that yc is between y1 and y2 }
          if (!(y1==y2)) 
          {
              x=(yc-y1)*mul2 / div2+x1; // { Point of intersection on x axis }
              if (x<mnx)
                mnx=x;
              if (x>mxx)
                mxx=x;    //   { Set point as start or end of horiz line }
           }
      if ((y2>=yc) || (y3>=yc)) 
        if ((y2<=yc) || (y3<=yc)) //  { Check that yc is between y2 and y3 }
          if (!(y2==y3))
            {
              x=(yc-y2)*mul3 / div3+x2; //{ Point of intersection on x axis }
              if (x<mnx)
                mnx=x;
              if (x>mxx)
                mxx=x;  //     { Set point as start or end of horiz line }
            }
      if ((y3>=yc) || (y4>=yc))
        if ((y3<=yc) || (y4<=yc)) //  { Check that yc is between y3 and y4 }
          if (!(y3==y4))
            {
              x=(yc-y3)*mul4 / div4+x3; // { Point of intersection on x axis }
              if (x<mnx)
                mnx=x;
              if (x>mxx)
                mxx=x; //       { Set point as start or end of horiz line }
            }
      if (mnx<0)
        mnx=0;
      if (mxx>319)
        mxx=319;   //       { Range checking on horizontal line }
      if (mnx<=mxx)
         Hline (mnx,mxx,yc,color,where);
         //  { Draw the horizontal line }
    }
}



// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure SetUpPoints;
//   { This creates the lookup table }
void SetUpPoints()
{
  int loop1;
  for(loop1=0;loop1<360;loop1++)
  {
    lookup [loop1][0]=(float)sin((double)rad((float)loop1));
    lookup [loop1][1]=(float)cos((double)rad((float)loop1));
  } 
}  


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure RotatePoints (X,Y,Z:Integer);
//   { This rotates object lines by X,Y and Z; then places the result in
//     TRANSLATED }
// rotate about x: newy = cos*y-sin*z (cos*cos-sin*sin)
//                 newz = sin*y+cos*z (sin*cos+cos*sin)
//           i.e:  newy+i*newz=e^(i*theta)*(y+i*z) (theta=int x)
//                            =(cos+i*sin)*(y+i*z)
// translated[loop1][0] and translated[loop1][1] are the two endpoints
// of line segment loop1.
//
void RotatePoints(int x, int y, int z)
{
  int loop1,loop2;
  struct Point temp;
  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
temp.x=Lines[loop1][loop2].x;
temp.y=lookup[x][1]*Lines[loop1][loop2].y - lookup[x][0]*Lines[loop1][loop2].z;
temp.z=lookup[x][0]*Lines[loop1][loop2].y + lookup[x][1]*Lines[loop1][loop2].z;
translated[loop1][loop2]=temp;

temp.x=lookup[y][1]*translated[loop1][loop2].x-lookup[y][0]*translated[loop1][loop2].y;
temp.y=lookup[y][0]*translated[loop1][loop2].x+lookup[y][1]*translated[loop1][loop2].y;
temp.z=translated[loop1][loop2].z;
translated[loop1][loop2]=temp;

temp.z=lookup[z][1]*translated[loop1][loop2].z-lookup[z][0]*translated[loop1][loop2].x;
temp.x=lookup[z][0]*translated[loop1][loop2].z+lookup[z][1]*translated[loop1][loop2].x;
temp.y=translated[loop1][loop2].y;
translated[loop1][loop2]=temp;
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure DrawPoints;
//   { This draws the translated object to the virtual screen }
void DrawPoints()
{
  int loop1;
  int nx0,ny0,nx1,ny1,nx2,ny2,nx3,ny3;
  int temp0,temp1,temp2,temp3;
  for(loop1=0;loop1<maxpolys;loop1++)
  {
    temp0=round (translated[loop1][0].z+zoff);
    temp1=round (translated[loop1][1].z+zoff);
    temp2=round (translated[loop1][2].z+zoff);
    temp3=round (translated[loop1][3].z+zoff);
	if((temp0<0)&&(temp1<0)&&(temp2<0)&&(temp3<0))
	{
      nx0 =round (256*translated[loop1][0].x) / temp0 + xoff;
      ny0 =round (256*translated[loop1][0].y) / temp0 + yoff;
      nx1 =round (256*translated[loop1][1].x) / temp1 + xoff;
      ny1 =round (256*translated[loop1][1].y) / temp1 + yoff;
      nx2 =round (256*translated[loop1][2].x) / temp2 + xoff;
      ny2 =round (256*translated[loop1][2].y) / temp2 + yoff;
      nx3 =round (256*translated[loop1][3].x) / temp3 + xoff;
      ny3 =round (256*translated[loop1][3].y) / temp3 + yoff;
      DrawPoly(nx0,ny0,nx1,ny1,nx2,ny2,nx3,ny3,13,Vaddr);
    }
  }
}

//  Procedure Whizz (sub:boolean);
void Whizz(int sub, int* deg)
{
  int loop1;
  
  for(loop1=-64;loop1<=-5;loop1++)
  {
      zoff=loop1*8;
      if(sub) xoff-=7; else xoff+=7;
      RotatePoints(*deg,*deg,*deg);
      DrawPoints();
      WaitRetrace();
      Flip2(Vaddr,VGA);
      Cls(0,Vaddr);
      (*deg)++; if(*deg==360)*deg=0;
  }
}  



// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure MoveAround;
//  {  This is the main display procedure. Firstly it brings the object towards
//    the viewer by increasing the Zoff, then passes control to the user }
void MoveAround()
{
  int loop1,loop2;
  int deg;
  char ch;
  
  deg=0;
  ch=0x0;
  yoff=100;
  xoff=350;
  Cls(0,Vaddr);
  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=A[loop1][loop2][0];
      Lines[loop1][loop2].y=A[loop1][loop2][1];
      Lines[loop1][loop2].z=A[loop1][loop2][2];
    }
  Whizz (1, &deg);

  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=S[loop1][loop2][0];
      Lines[loop1][loop2].y=S[loop1][loop2][1];
      Lines[loop1][loop2].z=S[loop1][loop2][2];
    }
  Whizz (0, &deg);

  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=P[loop1][loop2][0];
      Lines[loop1][loop2].y=P[loop1][loop2][1];
      Lines[loop1][loop2].z=P[loop1][loop2][2];
    }
  Whizz (1, &deg);

  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=H[loop1][loop2][0];
      Lines[loop1][loop2].y=H[loop1][loop2][1];
      Lines[loop1][loop2].z=H[loop1][loop2][2];
    }
  Whizz (0, &deg);

  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=Y[loop1][loop2][0];
      Lines[loop1][loop2].y=Y[loop1][loop2][1];
      Lines[loop1][loop2].z=Y[loop1][loop2][2];
    }
  Whizz (1, &deg);

  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=X[loop1][loop2][0];
      Lines[loop1][loop2].y=X[loop1][loop2][1];
      Lines[loop1][loop2].z=X[loop1][loop2][2];
    }
  Whizz (0, &deg);

  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=I[loop1][loop2][0];
      Lines[loop1][loop2].y=I[loop1][loop2][1];
      Lines[loop1][loop2].z=I[loop1][loop2][2];
    }
  Whizz (1, &deg);

  for(loop1=0;loop1<maxpolys;loop1++)
    for(loop2=0;loop2<4;loop2++)
    {
      Lines[loop1][loop2].x=A[loop1][loop2][0];
      Lines[loop1][loop2].y=A[loop1][loop2][1];
      Lines[loop1][loop2].z=A[loop1][loop2][2];
    }
  Whizz (0, &deg);


  Cls (0,Vaddr);
  Cls (0,VGA);
  xoff = 160;

  while(ch!=0x1b)  // escape
  {
    if(_bios_keybrd(_KEYBRD_READY))
	{
	  ch=(getch()&0x00ff);
	  if(ch==0x71)break; // 'q'
	  if(ch==0x51)break; // 'Q'
	  if(ch==0x1b)break; // ESC
	  if(ch=='Z')zoff+=5;
	  if(ch=='z')zoff-=5;
	  if(ch=='X')xoff+=5;
	  if(ch=='x')xoff-=5;
	  if(ch=='Y')yoff+=5;
	  if(ch=='y')yoff-=5;
    }
    DrawPoints();
    WaitRetrace();
    Flip2(Vaddr,VGA);
    Cls(0,Vaddr);
    RotatePoints(deg,deg,deg);
    deg++; if(deg==360)deg=0;
  }
}  

void main()
{
  SetUpVirtual();
  _clearscreen(_GCLEARSCREEN);
  SetMCGA();
  SetUpPoints();
  MoveAround();
  SetText();
}          

/*  
  Sorry, I got too lazy to convert these to printf's!
  Writeln ('Hello there! Varsity has begun once again, so it is once again');
  Writeln ('back to the grindstone ;-) ... anyway, this tutorial is, by');
  Writeln ('popular demand, on poly-filling, in relation to 3-D solids.');
  Writeln;
  Writeln ('In this program, the letters of ASPHYXIA will fly past you. As you');
  Writeln ('will see, they are solid, not wireframe. After the last letter has');
  Writeln ('flown by, a large A will be left in the middle of the screen.');
  Writeln;
  Writeln ('You will be able to move it around the screen, and you will notice');
  Writeln ('that it may have bits only half on the screen, i.e. clipping is');
  Writeln ('perfomed. To control it use the following : "A" and "Z" control the Z');
  Writeln ('movement, "," and "." control the X movement, and "S" and "X"');
  Writeln ('control the Y movement. I have not included rotation control, but');
  Writeln ('it should be easy enough to put in yourself ... if you have any');
  Writeln ('hassles, leave me mail.');
  Writeln;
  Writeln ('I hope this is what you wanted...leave me mail for new ideas.');
  writeln;
  writeln;
  Write ('  Hit any key to contine ...');
  Readkey;
  SetMCGA;
  SetUpPoints;
  MoveAround;
  SetText;
  ShutDown;
  Writeln ('All done. This concludes the ninth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS. I am also an avid');
  Writeln ('Connectix BBS user, and occasionally read RSAProg.');
  Writeln ('The numbers are available in the main text. You may also write to me at:');
  Writeln ('             Grant Smith');
  Writeln ('             P.O. Box 270');
  Writeln ('             Kloof');
  Writeln ('             3640');
  Writeln ('I hope to hear from you soon!');
  Writeln; Writeln;
  Write   ('Hit any key to exit ...');
  Readkey;
END.
*/
