{$X+}
USES crt,gfx3;

Const jump = 64;       { Number of pixels active at once }
      sjump = 6;       { 1 shl 6 = 64 }

TYPE
        FontDat = Array [' '..'Z',1..16,1..16] of byte; {Our main font }
        target = record
                 herex,herey : integer;
                 targx,targy : integer;
                 dy,dx : integer;
                 active : boolean;
                 col : byte;
                 num:integer;
             END;
        PixelDat = Array [1..4095] of target; { This is the maximum number
                                                of points we canb fit in a
                                                segment... }

VAR Font : ^FontDat;                          { Our nice font }
    nextrow : ^PixelDat;
    scr : array [' '..'Z',1..8,1..8] of byte; { The basic bios font }
    Vir2 : VirtPtr;
    Vaddr2 : Word;                            { Spare virtual screen }
    counter:integer;
    PosLoop:integer;
    dir : boolean;
    pathx,pathy:array [1..314] of integer;    { Path of origination }
    arbpal : array [1..8,1..3] of byte;       { Used to remember certain
                                                colors }



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Bigmsg (x,y:integer;msg:string);
  { This draws string msg to screen in the bios font, but bigger }
VAR loop1,loop2,loop3,loop4,loop5:integer;
BEGIN
  for loop1:=1 to length (msg) do
    for loop2:=1 to 8 do
      for loop3:=1 to 8 do
        if (scr[msg[loop1],loop3,loop2]<>0) then BEGIN
          for loop4:=1 to 4 do
            for loop5:=1 to 8 do
              putpixel (x+(loop1*32)+(loop2*4)+loop4,y+(loop3*8)+loop5,
                getpixel (x+(loop1*32)+(loop2*4)+loop4,y+(loop3*8)+loop5,vaddr2)+51,vaddr);
        END;
END;




{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Static;
  { This moves the static and tunes in to our background logo }
VAR loop1,loop2,count,count2,count3:integer;
BEGIN
  flip (vaddr2,vaddr);
  Bigmsg (0,60,'ASPHYXIA');
  flip (vaddr,vga);
  count:=0;
  count2:=0;
  for loop2:=1 to 100 do BEGIN
    waitretrace;
    for loop1:=99 to 150 do BEGIN
      count:=random (64);
      pal (loop1,count,count,count);
    END;
    for loop1:=150 to 201 do BEGIN
      count:=random (64);
      pal (loop1,count,count,count);
    END;
  END;   { Do the static for a while }

  repeat
    inc (count);
    if count>10 then BEGIN
      count:=0;
      inc (count2);
    END;
    waitretrace;
    for loop1:=99 to 150 do BEGIN
      count3:=random (64-count2);
      if count3<0 then count3:=0;
      pal (loop1,count3,count3,count3);
    END;
    for loop1:=150 to 201 do BEGIN
      count3:=random (64);
      count3:=count3+count2;
      if count3>63 then count3:=63;
      pal (loop1,count3,count3,count3);
    END;
  until count2>63; { Static fade in Asphyxia logo }

  delay (500);
  for loop1:=30 to 62 do BEGIN
    line (0,loop1*2,319,loop1*2,0,vga);
    delay (5);
  END;
  for loop1:=62 downto 30 do BEGIN
    line (0,loop1*2+1,319,loop1*2+1,0,vga);
    delay (5);
  END;  { Erase logo with lines }
  delay (1000);
  while keypressed do readkey;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Fadeup;
  { This fades up the pallette to white }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
BEGIN
  For loop1:=1 to 64 do BEGIN
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]<63 then inc (Tmp[1]);
      If Tmp[2]<63 then inc (Tmp[2]);
      If Tmp[3]<63 then inc (Tmp[3]);
      Pal (loop2,Tmp[1],Tmp[2],Tmp[3]);
    END;
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure FadeTo (name:string);
  { This procedure fades the screen to name ... if you use this for yourself,
    you will need to cut out the extra stuff I do in here specific to this
    program }
VAR loop1,loop2:integer;
    tmp,pall2:array[0..255,1..3] of byte;
    f:file;
BEGIN
  assign (f,name);
  reset (f,1);
  blockread (f,pall2,768);
  close (f);
  for loop1:=100 to 150 do BEGIN
    pall2[loop1,1]:=loop1-100;
    pall2[loop1,2]:=loop1-100;
    pall2[loop1,3]:=loop1-100;
  END;  { Set the background colors }
  waitretrace;
  for loop1:=0 to 255 do
    getpal (loop1,tmp[loop1,1],tmp[loop1,2],tmp[loop1,3]);

  For loop1:=1 to 64 do BEGIN
    For loop2:=0 to 255 do BEGIN
      If Tmp[loop2,1]<Pall2[loop2,1] then inc (Tmp[loop2,1]);
      If Tmp[loop2,2]<Pall2[loop2,2] then inc (Tmp[loop2,2]);
      If Tmp[loop2,3]<Pall2[loop2,3] then inc (Tmp[loop2,3]);
      If Tmp[loop2,1]>Pall2[loop2,1] then dec (Tmp[loop2,1]);
      If Tmp[loop2,2]>Pall2[loop2,2] then dec (Tmp[loop2,2]);
      If Tmp[loop2,3]>Pall2[loop2,3] then dec (Tmp[loop2,3]);
    END;
    WaitRetrace;
    for loop2:=0 to 255 do
      pal (loop2,tmp[loop2,1],tmp[loop2,2],tmp[loop2,3]);
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Show (x,y:integer;ch:string);
  { This dumps string ch to screen at x,y in our main font }
VAR loop1,loop2,loop3:integer;
BEGIN
  for loop3:=1 to length (ch) do
    For loop1:=1 to 16 do
      for loop2:=1 to 16 do
        if Font^[ch[loop3],loop2,loop1]<>0 then
          putpixel (x+loop1+(loop3*17),y+loop2,getpixel (x+loop1+(loop3*17),y+loop2,vaddr2)+51,VGA);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Eye_Popper;
  { This fades up the colors used in our main font }
VAR Loop1,loop2:integer;
    tmp : array [1..3] of byte;
BEGIN
  if keypressed then exit;
  for loop1:=1 to 63 do
    for loop2:=1 to 8 do BEGIN
      Waitretrace;
      Getpal (loop2,tmp[1],tmp[2],tmp[3]);
      if tmp[1]<63 then inc (tmp[1]);
      if tmp[2]<63 then inc (tmp[2]);
      if tmp[3]<63 then inc (tmp[3]);
      pal (loop2,tmp[1],tmp[2],tmp[3]);
    END;
  for loop1:=151 to 200 do
    pal (loop1,63,63,63);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure FadeOutText;
  { This fades out the colors of our main font to the colors of the background
    static }
VAR Loop1,loop2:integer;
    tmp : array [1..3] of byte;
BEGIN
  if keypressed then exit;
  for loop1:=1 to 63 do BEGIN
    Waitretrace;
    for loop2:=151 to 200 do BEGIN
      Getpal (loop2,tmp[1],tmp[2],tmp[3]);
      if tmp[1]>loop2-151 then dec (tmp[1]);
      if tmp[2]>loop2-151 then dec (tmp[2]);
      if tmp[3]>loop2-151 then dec (tmp[3]);
      pal (loop2,tmp[1],tmp[2],tmp[3]);
    END;
  END;
  delay (100);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Move_Em_Out (num:integer;del:byte);
  { This procedure runs through each pixel that is active and moves it closer
    to its destination }
VAR loop2:integer;
BEGIN
  if del<>0 then delay (del);
  for loop2:=1 to num do
    if nextrow^[loop2].active then with nextrow^[loop2] do BEGIN
      putpixel (herex shr sjump,herey shr sjump,
                getpixel (herex shr sjump,herey shr sjump,vaddr),vga);
        { Restore old bacground }
      herex:=herex-dx;
      herey:=herey-dy;  { Move pixel one step closer }
      putpixel (herex shr sjump,herey shr sjump,col,vga); { Put down pixel }
      dec (num);
      if num=0 then BEGIN
        active:=false;
        putpixel (herex shr sjump,herey shr sjump,col,vaddr);
      END;  { If destination reached, deactivate }
    END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Doletter (msg : char; dx,dy : integer);
  { This procedure activates the pixels necessary to draw a letter }
VAR loop1,loop2:integer;
    x,y : Integer;
BEGIN
  if keypressed then exit;
  for loop2:=1 to 16 do BEGIN
    for loop1:=1 to 16 do     { Our font is 16x16 }
      if Font^[msg,loop1,loop2]<>0 then BEGIN { Don't do black pixels }
        if dir then PosLoop:=PosLoop+1
          else PosLoop:=PosLoop-1;
        if PosLoop=315 then PosLoop:=1;
        if PosLoop=0 then PosLoop:=314;
        X:=pathx[PosLoop]+160;
        y:=pathy[PosLoop]+100;     { Find point of origination }

        nextrow^ [counter].herex:=x shl sjump;
        nextrow^ [counter].herey:=y shl sjump;
          { This is where I am }
        nextrow^ [counter].targx:=(dx+loop2) shl sjump;
        nextrow^ [counter].targy:=(dy+loop1) shl sjump;
          { This is where I want to be }
        nextrow^ [counter].dx:=(nextrow^[counter].herex-nextrow^[counter].targx) div jump;
        nextrow^ [counter].dy:=(nextrow^[counter].herey-nextrow^[counter].targy) div jump;
          { This is how I get there }
        nextrow^ [counter].col:=Font^[msg,loop1,loop2];
        nextrow^ [counter].active:=TRUE;
        nextrow^ [counter].num:=jump;
        move_em_out(jump,6);

        inc (counter);
        if counter=jump+1 then counter:=1;
      END;
  END;
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DoPic;
  { This procedure morphs in the tank }
VAR f:file;
    ch:byte;
    count,loop1,loop2:integer;
    ourpal : array [0..255,1..3] of byte;
BEGIN
  cls (vaddr,0);
  getmem (nextrow,sizeof(nextrow^));
  GetMem(Vir2,64000);
  Vaddr2 := Seg(Vir2^);
  for loop2:=1 to 4095 do
    nextrow^[loop2].active:=false;

  assign (f,'tut17.cel');
  reset (f,1);
  seek (f,32);
  blockread (f,ourpal,768);
  for loop1:=0 to 255 do
    pal (loop1,ourpal[loop1,1],ourpal[loop1,2],ourpal[loop1,3]);
  count:=1;
  for loop2:=1 to 60 do
    for loop1:=1 to 160 do BEGIN
      blockread (f,ch,1);     { Go through the pic, and activate non-black
                                pixels }
      if ch<>0 then BEGIN
        nextrow^ [count].herex:=random (320) shl sjump;
        nextrow^ [count].herey:=random (200) shl sjump;
          { This is where I am }
        nextrow^ [count].targx:=(loop1+80) shl sjump;
        nextrow^ [count].targy:=(loop2+70) shl sjump;
          { This is where I want to be }
        nextrow^ [count].dx:=(nextrow^[count].herex-nextrow^[count].targx) div jump;
        nextrow^ [count].dy:=(nextrow^[count].herey-nextrow^[count].targy) div jump;
          { This is how I get there }
        nextrow^ [count].col:=ch;
        nextrow^ [count].active:=TRUE;
        nextrow^ [count].num:=jump;
        inc (count);
      END;
  END;
  close (f);
  for loop1:=0 to 64 do
    move_em_out (count,0);  { Move pixels to targets }
  delay (2000);
  fadeup;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Init;
VAR f:file;
    loop1,loop2:integer;
    loopie:real;
BEGIN
  getmem (Font,sizeof(Font^));

  for loop2:=1 to jump do
    nextrow^[loop2].active:=false;

  Assign(f,'gods.Fnt');
  Reset(f,1);
  Blockread(F,Font^,SizeOf(Font^));
  Close(f);

  assign (f,'biostext.dat');
  reset (f,1);
  Blockread (f,scr,sizeof (scr));
  close (f);

  counter:=1;
  PosLoop:=1;
  dir:=true;
  loopie:=0;
  for loop1:=1 to 314 do BEGIN
    loopie:=loopie+0.02;
    pathX[loop1]:=round(150*cos (loopie));
    pathy[loop1]:=round(90*sin (loopie));
  END;    { Generate our path of origination }
  cls (vga,0);
  cls (vaddr,0);
  cls (vaddr2,0);
  for loop1:=0 to 319 do
    for loop2:=0 to 199 do
      putpixel (loop1,loop2,random (50)+100,vaddr2); { Fill the screen with static }
  flip (vaddr2,vaddr);
  flip (vaddr,vga);
  fadeto ('game01.col');
  for loop1:=1 to 8 do
    getpal (loop1,arbpal[loop1,1],arbpal[loop1,2],arbpal[loop1,3]);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Play;
VAR loop1,loop2:integer;
    message : Array [1..10] of string;
BEGIN
  DoPic;
  init;
  while keypressed do readkey;
             {[                 ]}
  message[1]:='';
  message[2]:='';
  message[3]:='   PIXEL TEXT   ';
  message[4]:='';
  message[5]:='   A  ROUTINE';
  message[6]:='';
  message[7]:='      BY...';
  message[9]:='';
 message[10]:='';
  for loop2:=1 to 7 do BEGIN
    For loop1:=1 to length (message[loop2]) do BEGIN
      doletter (message[loop2][loop1],loop1*17,loop2*17);
      dir:=not(dir);
    END;
    for loop1:=1 to jump do move_em_out(jump,6);
  END;

  eye_popper;
  For loop1:=1 to 7 do
    show (0,loop1*17,message[loop1]);
  fadeouttext;
  flip (vaddr2,vaddr);
  flip (vaddr,vga);

  for loop1:=1 to 8 do
    pal (loop1,arbpal[loop1,1],arbpal[loop1,2],arbpal[loop1,3]);
  message[1]:='   TUNING...';
  For loop1:=1 to length (message[1]) do BEGIN
    if message[1][loop1]='.' then for loop2:=1 to 20 do
      move_em_out(jump,6);
    doletter (message[1][loop1],loop1*17,100);
    dir:=not(dir);
  END;
  for loop1:=1 to jump do move_em_out(jump,6);

  eye_popper;
  show (0,100,message[1]);
  fadeouttext;

  static;

  freemem (vir2,sizeof (vir2^));
END;


BEGIN
  clrscr;
  writeln ('Hi there ... welcome to the seventeenth Asphyxia VGA Trainer ... and');
  writeln ('the last one on demo effects for a while ... I am going to be doing');
  writeln ('more work on the theory aspect in future trainers.');
  writeln;
  writeln ('This is an effect I first saw in an Extreme demo, and features ''Pixel');
  writeln ('Text'', with various dots forming letters. Also included are some crossfades');
  writeln ('and a static routine.');
  writeln;
  writeln ('Check out the GFX3 unit for a faster putpixel...');
  writeln;
  writeln ('The tank was drawn by Fubar a while ago when he was starting to learn');
  writeln ('3D Studio. The font I found somewhere on my hard drive.');
  writeln;
  writeln;
  writeln ('Hit any key to continue ...');
  readkey;
  setmcga;
  setupvirtual;
  play;
  settext;
  shutdown;
  Writeln ('All done. This concludes the seventeenth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS.I also occasinally read');
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