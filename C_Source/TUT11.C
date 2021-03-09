/* 
  tut11.c
  10/30/94
  from tutprog11.pas
  Adapted from Denthor's tutprog11.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut11.c
           to compile this program.
*/

#include "tutheadr.h"

char source[256][3];
char dest[256][3];
int dir;

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure LoadCELPal (FileName : String; Var Palette : Pallette);
//   { This loads in the pallette of the .CEL file into the variable Palette }
void loadcelpal(char* FileName, char Palette[][3] )
{
  FILE* fptr;

  if((fptr=fopen(FileName,"rb"))==NULL)
  {
    printf("Error opening file %s\n",FileName); 
	exit(1);
  }
  fseek(fptr,(long)32,SEEK_SET);
  fread(Palette,1,768,fptr);
  fclose(fptr);
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Init;
void Init()
{
  _fmemset(source,0,768);
  _fmemset(dest,0,768);
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure SetItUp;
//   { We define our third screen here }
void SetItUp()
{
    int loop1,loop2,loop3;
	char Pal1[256][3];
	char Pal2[256][3];
	int change;
	char r,g,b,r1,g1,b1;
	int where;

    Cls (0,Vaddr2);

    for(loop1=0;loop1<256;loop1++) Pal ((char)loop1,0,0,0);

  LoadCEL ("to.cel",Virtual2);
  loadcelpal ("to.cel",Pal2);
  Flip2(Vaddr2,VGA);
  LoadCEL ("from.cel",Virtual);
  loadcelpal ("from.cel",Pal1);

  where=0;

  for(loop1=0;loop1<320;loop1++)
    for(loop2=0;loop2<200;loop2++)
    {
      if((GetPixel(loop1,loop2,Vaddr)!=0) || (GetPixel (loop1,loop2,VGA)!=0))
      {
        change=FALSE;
        r=Pal1[GetPixel(loop1,loop2,Vaddr)][0];
        g=Pal1[GetPixel(loop1,loop2,Vaddr)][1];
        b=Pal1[GetPixel(loop1,loop2,Vaddr)][2];
        r1=Pal2[GetPixel(loop1,loop2,VGA)][0];
        g1=Pal2[GetPixel(loop1,loop2,VGA)][1];
        b1=Pal2[GetPixel(loop1,loop2,VGA)][2];
            
        for(loop3=0;loop3<=where;loop3++)                              
          if ((source[loop3][0]==r) && (source[loop3][1]==g) && (source[loop3][2]==b) &&
             (dest[loop3][0]==r1) && (dest[loop3][1]==g1) && (dest[loop3][2]==b1))
          {    
             PutPixel (loop1,loop2,(char)loop3,Vaddr2);
             change=TRUE;
          }
        //  { Here we check that this combination hasn't occured before. If it
        //    has, put the appropriate pixel onto the third screen (vaddr2) }

        if (!(change) )
        {
          where++;
          if (where==256)
          {
            SetText();
            printf("Pictures have too many colors! Squeeze then retry!\n");
            exit(1);
            // { There were too many combinations of colors. Alter picture and
            //  then retry }
			// E.g. 16 colors per picture would be a max of 256 combinations, so
			// should work every time.
          }
          PutPixel(loop1,loop2,(char)where,Vaddr2);
          source[where][0]=Pal1[GetPixel(loop1,loop2,Vaddr)][0];
          source[where][1]=Pal1[GetPixel(loop1,loop2,Vaddr)][1];
          source[where][2]=Pal1[GetPixel(loop1,loop2,Vaddr)][2];
          dest[where][0]=Pal2[GetPixel(loop1,loop2,VGA)][0];
          dest[where][1]=Pal2[GetPixel(loop1,loop2,VGA)][1];
          dest[where][2]=Pal2[GetPixel(loop1,loop2,VGA)][2];
          //  { Create a new color and set it's from and to pallette values }
        }
      }
    }
  Cls (0,VGA);
  Flip2(Vaddr2,VGA);
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Crossfade (direction:boolean;del,farin:word);
// { This fades from one picture to the other in the direction specified
//     with a del delay. It crossfades one degree for every value in farin.
//    If farin=63, then a complete crossfade occurs }
void Crossfade(int direction, int del, int farin)
{
  int loop1,loop2;
  char temp[256][3];
  char far* tempptr=&temp[0][0];
    
  if (direction)
  {
    _fmemcpy(temp,source,768);
    for(loop1=0;loop1<256;loop1++)
      Pal ((char)loop1,source[loop1][0],source[loop1][1],source[loop1][2]);
    for(loop1=0;loop1<=farin;loop1++)
    {
      WaitRetrace();
      SetAllPal(tempptr);

      for(loop2=0;loop2<256;loop2++)
      {
        if( temp[loop2][0]<dest[loop2][0])temp[loop2][0]++;
        if( temp[loop2][0]>dest[loop2][0])temp[loop2][0]--;
        if( temp[loop2][1]<dest[loop2][1])temp[loop2][1]++;
        if( temp[loop2][1]>dest[loop2][1])temp[loop2][1]--;
        if( temp[loop2][2]<dest[loop2][2])temp[loop2][2]++;
        if( temp[loop2][2]>dest[loop2][2])temp[loop2][2]--;                 
        //  { Move temp (the current pallette) from source to dest }
      }
      delay (del);
    }
  }
  else 
  {
    _fmemcpy(temp,dest,768);
    for(loop1=0;loop1<256;loop1++)
      Pal ((char)loop1,dest[loop1][0],dest[loop1][1],dest[loop1][2]);
    for(loop1=0;loop1<=farin;loop1++)
    {
      WaitRetrace();
      SetAllPal(tempptr);

      for(loop2=0;loop2<256;loop2++)
      {
        if( temp[loop2][0]<source[loop2][0])temp[loop2][0]++;
        if( temp[loop2][0]>source[loop2][0])temp[loop2][0]--;
        if( temp[loop2][1]<source[loop2][1])temp[loop2][1]++;
        if( temp[loop2][1]>source[loop2][1])temp[loop2][1]--;
        if( temp[loop2][2]<source[loop2][2])temp[loop2][2]++;
        if( temp[loop2][2]>source[loop2][2])temp[loop2][2]--;                 
        //  { Move temp (the current pallette) from source to dest }
      }
      delay (del);
    }
  }
}

void main()
{                      
  int loop1;
  _clearscreen(_GCLEARSCREEN);
  SetUpVirtual();
  SetMCGA();
  Init();
  SetItUp();
  for(loop1=0;loop1<256;loop1++)
    Pal((char)loop1,source[loop1][0],source[loop1][1],source[loop1][2]);
  Flip2(Vaddr2,VGA);
  delay (3000);

  dir=TRUE;
  while(1)
  {
    Crossfade(dir,20,63);
    dir=1-dir; // Toggle
    delay (1000);
    if(_bios_keybrd(_KEYBRD_READY))break;
  }
  getch();
  Crossfade(dir,20,20);
  getch();
  SetText();
}
/*  
BEGIN
  clrscr;
  writeln ('Hello there! This trainer program is on cross fading. What will happen');
  writeln ('is this : The program will load in two .CEL files, FROM.CEL and TO.CEL');
  writeln ('into the virtual screen at vaddr and to the VGA screen. The pallettes');
  writeln ('of these two pictures are loaded into pal1 and pal2. Note that you');
  writeln ('could easily rewrite this to load in other types of files if you do');
  writeln ('not own Autodesk Animator to draw your files (The pictures presented');
  writeln ('here were drawn by Fubar, sqeezed by me ;)). A third screen is then');
  Writeln ('generated into vaddr2 (this takes 5-10 seconds on my 386-40). Note');
  writeln ('that you could dump vaddr2 to disk as a file instead of calculating it');
  writeln ('each time...it would be faster and be half the size of the two pictures.');
  Writeln ('The picture will then crossfade between the two. Hit a key and it will');
  writeln ('crossfade halfway and then exit.');
  writeln;
  writeln ('After one particular comment E-Mailed to me, I thought I should just add');
  writeln ('this : I am not an employee of Autodesk, and they do not pay me to promote');
  writeln ('their product. You have no idea how much I wish they would :)  I recieve');
  writeln ('absolutely _nothing_ for writing the trainer...');
  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  randomize;
  setupvirtual;
  setmcga;
  init;
  SetItUp;
  for loop1:=0 to 255 do
    pal (loop1,source[loop1,1],source[loop1,2],source[loop1,3]);
  flip (vaddr2,vga);
  delay (3000);

  dir:=TRUE;
  while keypressed do readkey;
  repeat
    crossfade(dir,20,63);
    dir:=not (dir);
    delay (1000);
  until keypressed;
  Readkey;
  crossfade(dir,20,20);
  readkey;
  settext;
  Writeln ('All done. This concludes the eleventh sample program in the ASPHYXIA');
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
  shutdown;
  FreeMem (VirScr2,64000);
END.
*/
