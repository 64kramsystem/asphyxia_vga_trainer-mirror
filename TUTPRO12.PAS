{$X+}
Uses Crt,GFX2;

Const Size : Byte = 80;      { Size =  40 = 1 across, 4 down }
                             { Size =  80 = 2 across, 2 down }
                             { Size = 160 = 4 across, 1 down }

Type Icon = Array [1..256] of byte;
     Terrain = Array [1..21] of Icon;  {base 8 are desert, top 13 are letters }

VAR des : ^Terrain;       { Desert}


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure InitChain4; ASSEMBLER;
  {  This procedure gets you into Chain 4 mode }
Asm
    mov    ax, 13h
    int    10h         { Get into MCGA Mode }

    mov    dx, 3c4h    { Port 3c4h = Sequencer Address Register }
    mov    al, 4       { Index 4 = memory mode }
    out    dx, al
    inc    dx          { Port 3c5h ... here we set the mem mode }
    in     al, dx
    and    al, not 08h
    or     al, 04h
    out    dx, al
    mov    dx, 3ceh
    mov    al, 5
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 10h
    out    dx, al
    dec    dx
    mov    al, 6
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 02h
    out    dx, al
    mov    dx, 3c4h
    mov    ax, (0fh shl 8) + 2
    out    dx, ax
    mov    ax, 0a000h
    mov    es, ax
    sub    di, di
    mov    ax, 0000h {8080h}
    mov    cx, 32768
    cld
    rep    stosw            { Clear garbage off the screen ... }

    mov    dx, 3d4h
    mov    al, 14h
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 40h
    out    dx, al
    dec    dx
    mov    al, 17h
    out    dx, al
    inc    dx
    in     al, dx
    or     al, 40h
    out    dx, al

    mov    dx, 3d4h
    mov    al, 13h
    out    dx, al
    inc    dx
    mov    al, [Size]      { Size * 8 = Pixels across. Only 320 are visible}
    out    dx, al
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure C4PutPixel(X,Y : Word; Col : Byte); ASSEMBLER;
  { This puts a pixel on the chain 4 screen }
Asm
    mov    ax,[y]
    xor    bx,bx
    mov    bl,[size]
    imul   bx
    shl    ax,1
    mov    bx,ax
    mov    ax, [X]
    mov    cx, ax
    shr    ax, 2
    add    bx, ax
    and    cx, 00000011b
    mov    ah, 1
    shl    ah, cl
    mov    dx, 3c4h                  { Sequencer Register    }
    mov    al, 2                     { Map Mask Index        }
    out    dx, ax

    mov    ax, 0a000h
    mov    es, ax
    mov    al, [col]
    mov    es: [bx], al
End;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Plane(Which : Byte); ASSEMBLER;
  { This sets the plane to write to in Chain 4}
Asm
   mov     al, 2h
   mov     ah, 1
   mov     cl, [Which]
   shl     ah, cl
   mov     dx, 3c4h                  { Sequencer Register    }
   out     dx, ax
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure moveto(x, y : word);
  { This moves to position x*4,y on a chain 4 screen }
var o : word;
begin
  o := y*size*2+x;
  asm
    mov    bx, [o]
    mov    ah, bh
    mov    al, 0ch

    mov    dx, 3d4h
    out    dx, ax

    mov    ah, bl
    mov    al, 0dh
    mov    dx, 3d4h
    out    dx, ax
  end;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure LoadPal (FileName : string);
  { This loads .col file and sets the pallette }
type
  DACType = array [0..255,1..3] of byte;
var
  DAC : DACType;
  Fil : file of DACType;
  I : integer;
begin
  assign (Fil, FileName);
  reset (Fil);
  read (Fil, DAC);
  close (Fil);
  for I := 0 to 255 do
    pal (i,dac[i,1],dac[i,2],dac[i,3]);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Init;
  { We get our memory and load the graphics here }
VAR f:file;
BEGIN
  Getmem (des,sizeof (des^));
  assign (f,'piccs.dat');
  reset (f,1);
  blockread (f,des^,sizeof(des^));
  close (f);
  loadpal ('pallette.col');
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Play;
  { Our main procedure }
CONST sAsp : Array [0..19] of byte =
(1,3,2,4,5,3,9,10,11,12,13,14,15,9,7,4,5,2,1,4);   { Data for 'ASPHYXIA' }
      sVGA : Array [0..19] of byte =
(4,7,1,2,4,5,8,3,16,17,9,5,6,2,5,8,6,2,5,7);       { Data for 'VGA' }
      sTra : Array [0..19] of byte =
(2,5,8,2,1,6,18,19,9,15,20,21,19,7,2,4,1,8,3,4);   { Data for 'TRAINER' }

Var loop1,loop2:integer;
    depth,farin:integer;
    what:array[0..19] of byte;
    count:integer;
Begin
   MoveTo(0,200); { This moves the view to the left hand corner }
   depth:=200;    { This is our y for our viewport }
   farin:=15;     { This is how far in to the icon we have drawn }
   count:=0;      { This is for when the write ASPHYXIA VGA TRAINER }
   for loop1:=0 to 19 do what[loop1]:=random (8)+1;
        { This sets a random row of desert icons }
   Repeat
     for loop1:=0 to 19 do
       for loop2:=0 to 15 do BEGIN
         c4putpixel (loop1*16+loop2,depth,des^[what[loop1],farin*16+loop2+1]);
         c4putpixel (loop1*16+loop2,depth+201,des^[what[loop1],farin*16+loop2+1]);
       END;
        { This draws the two rows of pixels, above and below the viewport }
     depth:=depth-1; { This moves our viewport up one pixel }
     farin:=farin-1; { This moves us to the next row in our icons }
     if depth=-1 then depth:=200; {We have hit the top, jump to the bottom }
     if farin=-1 then BEGIN { We have finished our row of icons }
       farin:=15;
       for loop1:=0 to 19 do what[loop1]:=random (8)+1;
         { This sets a random row of desert icons }
       inc (count);
       if count=24 then for loop1:=0 to 19 do what[loop1]:=sasp[loop1];
       if count=22 then for loop1:=0 to 19 do what[loop1]:=svga[loop1];
       if count=20 then for loop1:=0 to 19 do what[loop1]:=stra[loop1];
       if count=50 then count:=0;
     END;
     waitretrace;
     moveto(0,depth);
   Until keypressed;
   Readkey;
End;


BEGIN
  clrscr;
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