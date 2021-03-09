/* 
  10/30/94
  tut16.c
  from tutprog16.pas
  Adapted from Denthor's tutprog16.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut16.c
           to compile this program.
*/

#include "tutheadr.h"

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure LoadCELPal (FileName : String; Var Palette : Pallette);
//   { This loads in the pallette of the .CEL file into the variable Palette }
void loadcelpal(char* fname, char palette[][3])
{
  FILE* fptr;
  if((fptr=fopen(fname,"rb"))==NULL)
  {
    SetText();
    printf("Error opening file %s\n",fname);
    exit(1);
  }
  fseek(fptr,32,SEEK_SET);
  fread(palette,sizeof(char),768,fptr);
  fclose(fptr);                    
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Init;
void init()
{
  int loop1,loop2;
  char tpal[256][3];
  
  SetUpVirtual();
  Cls (0,Vaddr2);
  Cls (0,Vaddr);
  loadcelpal ("to.cel",tpal);
  for(loop1=0;loop1<256;loop1++)
    Pal ((char)loop1,tpal[loop1][0],tpal[loop1][1],tpal[loop1][2]);
  LoadCEL ("to.cel",Virtual);
  for(loop1=0;loop1<320;loop1++)
    for(loop2=0;loop2<200;loop2++)
      if(GetPixel(loop1,loop2,Vaddr)==0)
        PutPixel(loop1,loop2,(char)((loop1+loop2)%256),Vaddr);
}        

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Scale (x,y,w,h,origw,origh,source,dest:word); assembler;
//  { This scales the picture to the size of w and h, and places the result
//    at x , y. Origw and origh are the origional width and height of the
//    bitmap. The bitmap must start at the beginning of a segment, with
//    source being the segment value. The image is placed in screen at dest}
void scale(int x,int y,int w,int h,int origw,int origh,int source,int dest)
{
  int jx,jy,depth,temp;
  __asm
  {
  push  ds

  mov   ax,source
  mov   ds,ax
  mov   ax,dest
  mov   es,ax
  mov   depth,0
  dec   h

  xor   dx,dx
  mov   ax,origw
  shl   ax,6
  mov   bx,w
  div   bx
  shl   ax,2
  mov   jx,ax    ; { jx:=origw*256/w }

  xor   dx,dx
  mov   ax,origh
  shl   ax,6
  mov   bx,h
  div   bx
  shl   ax,2
  mov   jy,ax    ; { jy:=origh*256/h }

  xor   cx,cx
ALoop2 :         ; { vertical loop }
  push  cx
  mov   ax,depth
  add   ax,jy
  mov   depth,ax

  xor   dx,dx
  mov   ax,depth
  shr   ax,8
  mov   bx,origw
  mul   bx
  mov   temp,ax  ; { temp:=depth shr 8*origw;}


  mov   di,y
  add   di,cx
  mov   bx,di
  shl   di,8
  shl   bx,6
  add   di,bx
  add   di,x     ; { es:di = dest ... di=(loop1+y)*320+x }

  mov   cx,w
  xor   bx,bx
  mov   dx,jx
  mov   ax,temp
ALoop1 :         ; { horizontal loop }
  mov   si,bx
  shr   si,8
  add   si,ax    ; { ax = temp = start of line }

  movsb          ; { si=temp+(si shr 8) }
  add   bx,dx

  dec   cx
  jnz   ALoop1   ; { horizontal loop }

  pop   cx
  inc   cx
  cmp   cx,h
  jl    ALoop2   ; { vertical loop }

  pop   ds        
  }
}

//{DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
//Procedure Play;
void play()
{
  int x,y,z,loop1;
  z=114;
  while(1)
  {
    for(loop1=0;loop1<100;loop1++)
    {
      z--;
      x=(16<<8)/z; 
      y=(10<<8)/z;
      // { Perspective transforms ... makes the zoom smoother }
      Cls (0,Vaddr2);
      scale (160-(x >> 1),100-(y >> 1),x,y,320,200,Vaddr,Vaddr2);
      WaitRetrace();
      Flip2 (Vaddr2,VGA);
    }
    //   { Scale towards you }
    for(loop1=0;loop1<100;loop1++)
    {
      z++;
      x=(16<<8)/z; 
      y=(10<<8)/z;
      // { Perspective transforms ... makes the zoom smoother }
      Cls (0,Vaddr2);
      scale (160-(x >> 1),100-(y >> 1),x,y,320,200,Vaddr,Vaddr2);
      WaitRetrace();    
      Flip2 (Vaddr2,VGA);
    }
    if(_bios_keybrd(_KEYBRD_READY)){getch();break;}
  }
}
 
void main()
{ 
  SetUpVirtual();
  SetMCGA();
  init();
  play();
  SetText();
}          

/*
BEGIN
  clrscr;
  writeln ('Hokay! Here is the sixteenth tutorial! This one is on nice fast 2d');
  writeln ('scaling, for any size bitmap. Just hit any key and it will scale a');
  writeln ('picture up and down. Clipping is NOT performed, so the destination');
  writeln ('pic MUST fit in the screen boundaries. In one zoom towards and away');
  writeln ('from you there is 100 frames.');
  writeln;
  Writeln ('You can make many nice effects with scaling, this "bouncing" is just');
  writeln ('one of them ... go on, amaze everyone with your ingenuity ;-) Also,');
  writeln ('why not test your coding mettle, so to speak, by implementing clipping?');
  Writeln;
  writeln ('The routine could greatly be speeded up with 386 extended registers, but');
  writeln ('for the sake of compatability I have kept it to 286 code. Also, this');
  writeln ('routine isn''t fully optimised .. you may be able to get some speedups');
  writeln ('out of it... (probably by moving the finding of DI out of the loop and');
  writeln ('just adding a constant for each line ... hint hint) ;)');
  writeln;
  writeln ('The pic was drawn by me for Tut11, I am reusing it because I am at varsity..');
  writeln ('without a mouse. :(');
  writeln;
  writeln;
  writeln ('Hit any key to continue ... ');
  readkey;
  setupvirtual;
  setmcga;
  init;
  play;
  settext;
  shutdown;
  freemem (virscr2,sizeof(virscr2^));
  Writeln ('All done. This concludes the sixteenth sample program in the ASPHYXIA');
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
