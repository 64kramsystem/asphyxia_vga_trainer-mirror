{$X+}
USES crt;

TYPE RGBType = Record
               R, G, B : Byte;
            End;
     PalType = Array[0..255] of RGBType;

VAR bob,bob2:paltype;  { Two pallettes, current and temporary }
    biiiigpallette : array [1..6656] of RGBType; { A massive pallette for the
                                                   psychadelic effect }
    start:integer;  { Where in the Biiiig pallette are we? }
    Effect,Background:Boolean; { Configuration of effects }

    costbl : Array [0..255] of byte; { cos table lookup }
    mov1,mov2,mov3,mov4 : byte;  { current positions }
    bkg : array [1..50,1..80] of byte; { The pic in the background }



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure PAL(Col,R,G,B : Byte); assembler;
   { This sets the Red, Green and Blue values of a certain color }
asm
   mov    dx,3c8h
   mov    al,[col]
   out    dx,al
   inc    dx
   mov    al,[r]
   out    dx,al
   mov    al,[g]
   out    dx,al
   mov    al,[b]
   out    dx,al
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetAllPal(Var Palette : PalType); Assembler;
  { This dumps the pallette in our variable onto the screen, fast }
Asm
   push   ds
   lds    si, Palette
   mov    dx, 3c8h
   mov    al, 0
   out    dx, al
   inc    dx
   mov    cx, 768
   rep    outsb
   pop    ds
End;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Makerun (r,g,b:integer);
  { This creates a ramp of colors and puts them into biiiigpallette }
VAR loop1:integer;
BEGIN
  for loop1:=start to start+127 do BEGIN
    if r=1 then
      biiiigpallette[loop1].r:=63-(loop1-start) div 4 else
    if r=2 then
      biiiigpallette[loop1].r:=(loop1-start) div 4 else
      biiiigpallette[loop1].r:=0;

    if g=1 then
      biiiigpallette[loop1].g:=63-(loop1-start) div 4 else
    if g=2 then
      biiiigpallette[loop1].g:=(loop1-start) div 4 else
      biiiigpallette[loop1].g:=0;

    if b=1 then
      biiiigpallette[loop1].b:=63-(loop1-start) div 4 else
    if b=2 then
      biiiigpallette[loop1].b:=(loop1-start) div 4 else
      biiiigpallette[loop1].b:=0;
  END;

  for loop1:=start+128 to start+255 do BEGIN
    if r=2 then
      biiiigpallette[loop1].r:=63-(loop1-start) div 4 else
    if r=1 then
      biiiigpallette[loop1].r:=(loop1-start) div 4 else
      biiiigpallette[loop1].r:=0;

    if g=2 then
      biiiigpallette[loop1].g:=63-(loop1-start) div 4 else
    if g=1 then
      biiiigpallette[loop1].g:=(loop1-start) div 4 else
      biiiigpallette[loop1].g:=0;

    if b=2 then
      biiiigpallette[loop1].b:=63-(loop1-start) div 4 else
    if b=1 then
      biiiigpallette[loop1].b:=(loop1-start) div 4 else
      biiiigpallette[loop1].b:=0;
  END;
  start:=start+256;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure init;
VAR loop1,loop2,r,g,b:integer;
    f:text;
    ch:char;

  Function rad (theta : real) : real; { Converts degrees to radians }
  BEGIN
    rad := theta * pi / 180
  END;

BEGIN
  write ('Do you want the Psychadelic effect? ');
  repeat
    ch:=upcase(readkey);
  until ch in ['Y','N'];
  if ch='Y' then BEGIN
    Writeln ('Yeah!');
    effect:=true;
  END else BEGIN
    Writeln ('Nah');
    effect:=false;
  END;
  writeln;
  while keypressed do readkey;
  write ('Do you want the background? ');
  repeat
    ch:=upcase(readkey);
  until ch in ['Y','N'];
  if ch='Y' then BEGIN
    Writeln ('Yeah!');
    background:=true;
  END else BEGIN
    Writeln ('Nah');
    background:=false;
  END;
  writeln;
  while keypressed do readkey;
  writeln ('Hit any key to continue...');
  readkey;
  while keypressed do readkey;
  asm
    mov     ax,0013h
    int     10h                     { Enter mode 13 }
    cli
    mov     dx,3c4h
    mov     ax,604h                 { Enter unchained mode }
    out     dx,ax
    mov     ax,0F02h                { All planes}
    out     dx,ax

    mov     dx,3D4h
    mov     ax,14h                  { Disable dword mode}
    out     dx,ax
    mov     ax,0E317h               { Enable byte mode.}
    out     dx,ax
    mov     al,9
    out     dx,al
    inc     dx
    in      al,dx
    and     al,0E0h                 { Duplicate each scan 8 times.}
    add     al,7
    out     dx,al
  end;

  fillchar (bob2,sizeof(bob2),0);  { Clear pallette bob2 }
  setallpal (bob2);

  start:=0;
  r:=0;
  g:=0;
  b:=0;
  Repeat
    makerun (r,g,b);
    b:=b+1;
    if b=3 then BEGIN
      b:=0;
      g:=g+1;
    END;
    if g=3 then BEGIN
      g:=0;
      r:=r+1;
    END;
  until (r=2) and (g=2) and (b=2);
    { Set up our major run of colors }

  start:=0;
  if not effect then BEGIN
    for loop1:=0 to 128 do BEGIN
      bob[loop1].r:=63-loop1 div 4;
      bob[loop1].g:=0;
      bob[loop1].b:=loop1 div 4;
    END;
    for loop1:=129 to 255 do BEGIN
      bob[loop1].r:=loop1 div 4;
      bob[loop1].g:=0;
      bob[loop1].b:=63-loop1 div 4;
    END;
  END else
    for loop1:=0 to 255 do bob[loop1]:=biiiigpallette[loop1];

    { Set up a nice looking pallette ... we alter color 0, so the border will
      be altered. }

  For loop1:=0 to 255 do
    costbl[loop1]:=round (cos (rad (loop1/360*255*2))*31)+32;
    { Set up our lookup table...}

  fillchar (bkg,sizeof(bkg),0);
  assign (f,'a:bkg.dat');
  reset (f);
  for loop1:=1 to 50 do BEGIN
    for loop2:=1 to 80 do BEGIN
      read (f,ch);
      if ord (ch)<>48 then
        bkg[loop1,loop2]:=ord (ch)-28;
    END;
    readln (f);
  END;
  close (f);
    { Here we read in our background from the file bkg.dat }
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DrawPlasma;
  { This procedure draws the plasma onto the screen }
VAR loop1,loop2:integer;
    tmov1,tmov2,tmov3,tmov4:byte; { Temporary variables, so we dont destroy
                                    the values of our main variables }
    col:byte;
    where:word;
BEGIN
  tmov3:=mov3;
  tmov4:=mov4;
  where:=0;
  asm
    mov   ax,0a000h
    mov   es,ax        { In the two loops that follow, ES is not altered so
                         we just set it once, now }
  end;
  For loop1:=1 to 50 do BEGIN   { Fifty rows down }
    tmov1:=mov1;
    tmov2:=mov2;
    for loop2:=1 to 80 do BEGIN { Eighty columns across }
      if background then
        col:=costbl[tmov1]+costbl[tmov2]+costbl[tmov3]+costbl[tmov4]+costbl[loop1]+costbl[loop2]+bkg[loop1,loop2]
      else
        col:=costbl[tmov1]+costbl[tmov2]+costbl[tmov3]+costbl[tmov4]+costbl[loop1]+costbl[loop2];
        { col = Intersection of numerous cos waves }
      asm
        mov    di,where   { di is killed elsewhere, so we need to restore it}
        mov    al,col
        mov    es:[di],al { Place col at ES:DI ... sequential across the screen}
      end;
      where:=where+1;  { Inc the place to put the pixel }
      tmov1:=tmov1+4;
      tmov2:=tmov2+3;  { Arb numbers ... replace to zoom in/out }
    END;
    tmov3:=tmov3+4;
    tmov4:=tmov4+5;    { Arb numbers ... replace to zoom in/out }
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure MovePlasma;
  { This procedure moves the plasma left/right/up/down }
BEGIN
  mov1:=mov1-4;
  mov3:=mov3+4;
  mov1:=mov1+random (1);
  mov2:=mov2-random (2);
  mov3:=mov3+random (1);
  mov4:=mov4-random (2);   { Movement along the plasma + noise}
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure WaitRetrace; assembler;
   {  This waits for a vertical retrace to reduce snow on the screen }
label
  l1, l2;
asm
    mov   dx,3DAh
l1:
    in    al,dx
    test  al,8
    jnz   l1
l2:
    in    al,dx
    test  al,8
    jz    l2
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure fadeupone (stage:integer);
  { This procedure fades up the pallette bob2 by one increment and sets the
    onscreen pallette. Colors are increased proportionally, do that all colors
    reach their destonation at the same time }
VAR loop1:integer;
    temp:rgbtype;
BEGIN
  if not effect then move (bob[0],temp,3);
  move (bob[1],bob[0],765);
  if effect then move (biiiigpallette[start],bob[255],3) else
    move (temp,bob[255],3);
  start:=start+1;
  if start=6657 then start:=0;
    { Rotate the pallette }

  for loop1:=0 to 255 do BEGIN
    bob2[loop1].r:=integer(bob[loop1].r*stage div 64);
    bob2[loop1].g:=integer(bob[loop1].g*stage div 64);
    bob2[loop1].b:=integer(bob[loop1].b*stage div 64);
  END; { Fade up the pallette }
  setallpal (bob2);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Shiftpallette;
  { This rotates the pallette, and introduces new colors if the psychadelic
    effect has been chosen }
VAR loop1:integer;
    temp:rgbtype;
BEGIN
  if not effect then move (bob2[0],temp,3);
  move (bob2[1],bob2[0],765);
  if effect then move (biiiigpallette[start],bob2[255],3) else
    move (temp,bob2[255],3);
  start:=start+1;
  if start=6657 then start:=0;
  setallpal (bob2);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Play;
VAR loop1:integer;
BEGIN
  start:=256;
  for loop1:=1 to 64 do BEGIN
    fadeupone(loop1);
    drawplasma;
    moveplasma;
  END; { Fade up the plasma }
  while keypressed do readkey;
  Repeat
    shiftpallette;
    drawplasma;
    moveplasma;
  Until keypressed; { Do the plasma }
  move (bob2,bob,768);
  for loop1:=1 to 64 do BEGIN
    fadeupone(64-loop1);
    drawplasma;
    moveplasma;
  END; { fade down the plasma }
  while keypressed do readkey;
END;

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