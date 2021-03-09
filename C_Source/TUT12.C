/* 
  tut12.c
  10/30/94
  from tutprog12.pas
  Adapted from Denthor's tutprog12.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut12.c
           to compile this program.
*/

#include "tutheadr.h"
#define SIZE 80
                       //    { Size =  40 = 1 across, 4 down }
                       //    { Size =  80 = 2 across, 2 down }
                       //    { Size = 160 = 4 across, 1 down }
char terrain[21][256];
// base 8 are desert, top 13 are letters }
char far* des = &terrain[0][0];



// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// procedure LoadPal (FileName : string);
//  { This loads .col file and sets the pallette }
void LoadPal(char* FileName)
{
  FILE* fptr;
  char dac[256][3];
  char far* dacptr=&dac[0][0];
  
  if((fptr=fopen(FileName,"rb"))==NULL)
  {
    SetText();
    printf("Error opening file %s\n",FileName);
    exit(1);
  }
  fread(dac,sizeof(char),768,fptr);
  fclose(fptr);                    
  SetAllPal(dacptr);
}  


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Init;
//  { We get our memory and load the graphics here }
void Init()
{
  FILE* fptr;
  if((fptr=fopen("piccs.dat","rb"))==NULL)
  {
    SetText();
    printf("Error opening file piccs.dat\n");
    exit(1);
  }
  fread(des,sizeof(char),21*256,fptr);
  fclose(fptr);                    
  LoadPal ("pallette.col");
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Play;
//  { Our main procedure }
void Play()
{
  char sAsp[20]=
  {1,3,2,4,5,3,9,10,11,12,13,14,15,9,7,4,5,2,1,4}; //  { Data for 'ASPHYXIA' }
// D D D D D D A S  P  H  Y  X  I  A D D D D D D
// (D = Desert Icon)
  char sVGA[20]=      
  {4,7,1,2,4,5,8,3,16,17,9,5,6,2,5,8,6,2,5,7};     //  { Data for 'VGA' }
//                 V  G  A
  char sTra[20]=      
  {2,5,8,2,1,6,18,19,9,15,20,21,19,7,2,4,1,8,3,4}; //  { Data for 'TRAINER' }
//             T   R A I  N  E  R
  int loop1,loop2;
  int depth,farin;
  char what[20];
  int count;              
   moveto(0,200,SIZE); //{ This moves the view to the left hand corner }
   depth=200;    //{ This is our y for our viewport }
   farin=15;     //{ This is how far in to the icon we have drawn }
   count=0;      //{ This is for when the write ASPHYXIA VGA TRAINER }

   for(loop1=0;loop1<20;loop1++)what[loop1]=random(8);
        //{ This sets a random row of desert icons }
   while(1)
   {        
     for(loop1=0;loop1<20;loop1++)
       for(loop2=0;loop2<16;loop2++)
       {
         C4PutPixel (loop1*16+loop2,depth,terrain[what[loop1]][farin*16+loop2],SIZE);
         C4PutPixel (loop1*16+loop2,depth+201,terrain[what[loop1]][farin*16+loop2],SIZE);
       }
       // { This draws the two rows of pixels, above and below the viewport }
     depth--; //{ This moves our viewport up one pixel }
     farin--; //{ This moves us to the next row in our icons }
     if(depth==-1)depth=200; //{We have hit the top, jump to the bottom }
     if(farin==-1)           //{ We have finished our row of icons }
     {
       farin=15;
       for(loop1=0;loop1<20;loop1++)what[loop1]=random(8);
         //{ This sets a random row of desert icons }
       count++;
       if(count==24)for(loop1=0;loop1<20;loop1++)what[loop1]=sAsp[loop1]-1;
       if(count==22)for(loop1=0;loop1<20;loop1++)what[loop1]=sVGA[loop1]-1;
       if(count==20)for(loop1=0;loop1<20;loop1++)what[loop1]=sTra[loop1]-1;
       if(count==50)count=0;
     }
     WaitRetrace();
     moveto(0,depth,SIZE);
     if(_bios_keybrd(_KEYBRD_READY))break;
   }
   getch();
}   

void main()
{
  _clearscreen(_GCLEARSCREEN);
  InitChain4(SIZE);
  Init();
  Play();
  SetText();
}  
/*  
  Writeln ('Hello! After a long absence, here is the latest installment of the');
  Writeln ('ASPHYXIA VGA Trainer! This one, by popular demand, is on full screen');
  WRiteln ('scrolling in Chain-4. This isn''t very interactive, just hit any key');
  Writeln ('and a random landscape will scroll by for infinity, with the letters');
  Writeln ('ASPHYXIA VGA TRAINER scrolling passed at set intervals. You will notice');
  Writeln ('that two of our four pages are untouched. These could be put to good');
  Writeln ('use in for example a game etc.');
  Writeln;
  Writeln ('This code could easily be altered to produce a movie-credits type');
  Writeln ('sequence, a large game-map and so on. Have fun with it and see what');
  Writeln ('you can come up with! All desert art is done by Pieter Buys (Fubar), may');
  Writeln ('I add on very short notice by my request. The font was, I think, ripped,');
  Writeln ('I found it lying about on my hard drive.');
  Writeln;
  Writeln ('The code is very easy to follow and you should have it doing what you want');
  Writeln ('in no time.');
  writeln;
  writeln;
  Write ('  Hit any key to contine ...');
  Readkey;
  initChain4;
  init;
  play;
  Freemem (des,sizeof (des^));
  SetText;
  Writeln ('All done. This concludes the twelfth sample program in the ASPHYXIA');
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
  Readkey;
END.
*/
