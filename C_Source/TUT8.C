/* 
  tut8.c
  10/30/94
  from tutprog8.pas
  Adapted from Denthor's tutprog8.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut8.c
           to compile this program.
*/

#include "tutheadr.h"
#define MaxLines  12

int Obj[MaxLines][2][3]= {
        {{-10,-10,-10},{10,-10,-10}},{{-10,-10,-10},{-10,10,-10}},
        {{-10,10,-10},{10,10,-10}},{{10,-10,-10},{10,10,-10}},
        {{-10,-10,10},{10,-10,10}},{{-10,-10,10},{-10,10,10}},
        {{-10,10,10},{10,10,10}},{{10,-10,10},{10,10,10}},
        {{-10,-10,10},{-10,-10,-10}},{{-10,10,10},{-10,10,-10}},
        {{10,10,10},{10,10,-10}},{{10,-10,10},{10,-10,-10}}
        }; // { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
           // { (X2,Y2,Z2) ... for the two ends of a line }


struct Point Lines[MaxLines][2];
struct Point translated[MaxLines][2];
int xoff,yoff,zoff;
float lookup[360][2];

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure SetUpPoints;
//   { This sets the basic offsets of the object, creates the lookup table and
//     moves the object from a constant to a variable }
void SetUpPoints()
{
  int loop1;
  xoff=160;
  yoff=100;
  zoff=-256;
  for(loop1=0;loop1<360;loop1++)
  {
    lookup [loop1][0]=(float)sin ((double)rad ((float)loop1));
    lookup [loop1][1]=(float)cos ((double)rad ((float)loop1));
  }
  for(loop1=0;loop1<MaxLines;loop1++)
  {
    Lines [loop1][0].x=Obj [loop1][0][0];
    Lines [loop1][0].y=Obj [loop1][0][1];
    Lines [loop1][0].z=Obj [loop1][0][2];
    Lines [loop1][1].x=Obj [loop1][1][0];
    Lines [loop1][1].y=Obj [loop1][1][1];
    Lines [loop1][1].z=Obj [loop1][1][2];
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure DrawLogo;
//   { This draws 'ASPHYXIA' at the top of the screen in little balls }
void DrawLogo()
{
  char ball[5][5]=
         {{0,1,1,1,0},
          {1,4,3,2,1},
          {1,3,3,2,1},
          {1,2,2,2,1},
          {0,1,1,1,0}};

  char Logo[5][32] = {
  " O  OOO OOO O O O O O O OOO  O ",
  "O O O   O O O O O O O O  O  O O",
  "OOO OOO OOO OOO  O   O   O  OOO",
  "O O   O O   O O  O  O O  O  O O",
  "O O OOO O   O O  O  O O OOO O O" };
  int  loop1,loop2,loop3,loop4;
  Pal (13,0,63,0);
  Pal (1,0,0,40);
  Pal (2,0,0,45);
  Pal (3,0,0,50);
  Pal (4,0,0,60);
  for(loop1=0;loop1<5;loop1++)
    for(loop2=0;loop2<31;loop2++)
      if(Logo[loop1][loop2]=='O')
        for(loop3=0;loop3<5;loop3++)
          for(loop4=0;loop4<5;loop4++)
            PutPixel (loop2*10+loop3,loop1*4+loop4,ball[loop3][loop4],Vaddr);
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
  int loop1;
  struct Point temp;
  for(loop1=0;loop1<MaxLines;loop1++)
  {
temp.x=Lines[loop1][0].x;
temp.y=lookup[x][1]*Lines[loop1][0].y - lookup[x][0]*Lines[loop1][0].z;
temp.z=lookup[x][0]*Lines[loop1][0].y + lookup[x][1]*Lines[loop1][0].z;
translated[loop1][0]=temp;

temp.x=lookup[y][1]*translated[loop1][0].x-lookup[y][0]*translated[loop1][0].y;
temp.y=lookup[y][0]*translated[loop1][0].x+lookup[y][1]*translated[loop1][0].y;
temp.z=translated[loop1][0].z;
translated[loop1][0]=temp;

temp.z=lookup[z][1]*translated[loop1][0].z-lookup[z][0]*translated[loop1][0].x;
temp.x=lookup[z][0]*translated[loop1][0].z+lookup[z][1]*translated[loop1][0].x;
temp.y=translated[loop1][0].y;
translated[loop1][0]=temp;

temp.x=Lines[loop1][1].x;
temp.y=lookup[x][1]*Lines[loop1][1].y-lookup[x][0]*Lines[loop1][1].z;
temp.z=lookup[x][0]*Lines[loop1][1].y+lookup[x][1]*Lines[loop1][1].z;
translated[loop1][1]=temp;

temp.x=lookup[y][1]*translated[loop1][1].x-lookup[y][0]*translated[loop1][1].y;
temp.y=lookup[y][0]*translated[loop1][1].x+lookup[y][1]*translated[loop1][1].y;
temp.z=translated[loop1][1].z;
translated[loop1][1]=temp;

temp.z=lookup[z][1]*translated[loop1][1].z-lookup[z][0]*translated[loop1][1].x;
temp.x=lookup[z][0]*translated[loop1][1].z+lookup[z][1]*translated[loop1][1].x;
temp.y=translated[loop1][1].y;
translated[loop1][1]=temp;
  }
}



// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure DrawPoints;
//   { This draws the translated object to the virtual screen }
void DrawPoints()
{
  int loop1;
  int nx,ny,nx2,ny2;
  int temp1,temp2;
  for(loop1=0;loop1<MaxLines;loop1++)
  {
    temp1=round (translated[loop1][0].z+zoff);
    temp2=round (translated[loop1][1].z+zoff);
	if((temp1<0)&&(temp2<0))
	{
      nx  =round (256*translated[loop1][0].x) / temp1 + xoff;
      ny  =round (256*translated[loop1][0].y) / temp1 + yoff;
      nx2 =round (256*translated[loop1][1].x) / temp2 + xoff;
      ny2 =round (256*translated[loop1][1].y) / temp2 + yoff;
      if((nx > 0)  && (nx < 320)  && (ny > 25)  && (ny < 200) && 
         (nx2> 0)  && (nx2< 320)  && (ny2> 25)  && (ny2< 200)) 
           Line2 (nx,ny,nx2,ny2,13,Vaddr);
    }
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure ClearPoints;
//   { This clears the translated object from the virtual screen ... believe it
//     or not, this is faster then a straight "cls (vaddr,0)" }
void ClearPoints()
{
  int loop1;
  int nx,ny,nx2,ny2;
  int temp1,temp2;
  for(loop1=0;loop1<MaxLines;loop1++)
  {
    temp1=round (translated[loop1][0].z+zoff);
    temp2=round (translated[loop1][1].z+zoff);
	if((temp1<0)&&(temp2<0))
	{
      nx  =round (256*translated[loop1][0].x) / temp1 + xoff;
      ny  =round (256*translated[loop1][0].y) / temp1 + yoff;
      nx2 =round (256*translated[loop1][1].x) / temp2 + xoff;
      ny2 =round (256*translated[loop1][1].y) / temp2 + yoff;
      if((nx > 0) &&  (nx < 320) &&  (ny > 25) &&  (ny < 200) && 
         (nx2> 0) &&  (nx2< 320) &&  (ny2> 25) &&  (ny2< 200))
           Line2 (nx,ny,nx2,ny2,0,Vaddr);
    }
  }
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure MoveAround;
//   { This is the main display procedure. Firstly it brings the object towards
//     the viewer by increasing the Zoff, then passes control to the user }
void MoveAround()
{
  int deg,loop1;
  char ch;
  deg=0;
  ch=0x0;
  Cls(0,Vaddr);
  DrawLogo();
  for(loop1=-256;loop1<=-40;loop1++)
  {
    zoff=loop1*2;
    RotatePoints(deg,deg,deg);
    DrawPoints();
    WaitRetrace();
    Flip2(Vaddr,VGA);
    ClearPoints();
    deg++; // mod 360;
	if(deg==360)deg=0;
  }

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
    ClearPoints();
    RotatePoints (deg,deg,deg);
    deg++; // mod 360;
	if(deg==360)deg=0;
  }
}

void main()
{
  SetUpVirtual();
  printf("  Greetings and salutations! Hope you had a great Christmas and New\n");
  printf("  year! ;-) ... Anyway, this tutorial is on 3-D, so this is what is\n");
  printf("  going to happen ... a wireframe square will come towards you.\n");
  printf("  When it gets close, you get control. z and Z control the Z\n");
  printf("  movement, x and X control the X movement, and y and Y\n");
  printf("  control the Y movement. I have not included rotation control, but\n");
  printf("  it should be easy enough to put in yourself ... if you have any\n");
  printf("  hassles, leave me mail.\n");
  printf(" \n");
  printf("  Read the main text file for ideas on improving this code ... and\n");
  printf("  welcome to the world of 3-D!\n");
  printf("  Hit any key to continue: ");
  getch();
  SetMCGA();
  SetUpPoints();
  MoveAround();
  SetText();
  printf("  All done. This concludes the eigth sample program in the ASPHYXIA\n");
  printf("  Training series. You may reach DENTHOR under the names of GRANT\n");
  printf("  SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS. I am also an avid\n");
  printf("  Connectix BBS user, and occasionally read RSAProg.\n");
  printf("  For discussion purposes, I am also the moderator of the Programming\n");
  printf("  newsgroup on the For Your Eyes Only BBS.\n");
  printf("  The numbers are available in the main text. You may also write to me at:\n");
  printf("               Grant Smith\n");
  printf("               P.O. Box 270\n");
  printf("               Kloof\n");
  printf("               3640\n");
  printf("  I hope to hear from you soon!\n");
  printf("  \n");
  printf("  \n");
  printf("  \n");
  printf(" Translated into C by Steve Pinault,\n scp@ohm.att.com\n\n");
}
