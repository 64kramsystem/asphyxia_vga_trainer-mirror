{$X+}
USES GFX2,crt;

CONST Num = 400;     { Number of stars }

TYPE Star = Record
              x,y,z:integer;
            End;     { Information on each star }
     Pos = Record
             x,y:integer;
           End;      { Information on each point to be plotted }

VAR Stars : Array [1..num] of star;
    Clear : Array [1..2,1..num] of pos;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Init;
VAR loop1,loop2:integer;
    logo:array [1..50,1..320] of byte;
BEGIN
  for loop1:=1 to num do
    Repeat
      stars[loop1].x:=random (320)-160;
      stars[loop1].y:=random (200)-100;
      stars[loop1].z:=loop1;
    Until (stars[loop1].x<>0) and (stars[loop1].y<>0);
      { Make sure no stars are heading directly towards the viewer }
  pal (32,00,00,30);
  pal (33,10,10,40);
  pal (34,20,20,50);
  pal (35,30,30,60);   { Pallette for the stars coming towards you }

  pal (247,20,20,20);
  pal (136,30,0 ,0 );
  pal (101,40,0 ,0 );
  pal (19 ,60,0 ,0 );  { Pallette for the logo at the top of the screen }

  loadcel ('logo.cel',addr(logo));
  for loop1:=0 to 319 do
    for loop2:=1 to 50 do
      putpixel (loop1,loop2-1,logo[loop2,loop1+1],vga);
    { Placing the logo at the top of the screen }
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Calcstars;
  { This ccalculates the 2-d coordinates of our stars and saves these values
    into the variable clear }
VAR loop1,x,y:integer;
BEGIN
  For loop1:=1 to num do BEGIN
    x:=((stars[loop1].x shl 7) div stars[loop1].z)+160;
    y:=((stars[loop1].y shl 7) div stars[loop1].z)+100;
    clear[1,loop1].x:=x;
    clear[1,loop1].y:=y;
  END;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Drawstars;
  { This draws the 2-d values stored in clear to the vga screen, with various
    colors according to how far away it is. }
VAR loop1,x,y:integer;
BEGIN
  For loop1:=1 to num do BEGIN
    x:=clear[1,loop1].x;
    y:=clear[1,loop1].y;
    if (x>0) and (x<320) and (y>50) and (y<200) then
      If stars[loop1].z>400 then putpixel(x,y,32,vga)
      else
      If stars[loop1].z>300 then putpixel(x,y,33,vga)
      else
      If stars[loop1].z>200 then putpixel(x,y,34,vga)
      else
      If stars[loop1].z>100 then putpixel(x,y,34,vga)
      else
      putpixel(x,y,35,vga)
  END;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Clearstars;
  { This clears the 2-d values from the vga screen, which is faster then a
    cls (vga,0) }
VAR loop1,x,y:integer;
BEGIN
  For loop1:=1 to num do BEGIN
    x:=clear[2,loop1].x;
    y:=clear[2,loop1].y;
    if (x>0) and (x<320) and (y>50) and (y<200) then
      putpixel (x,y,0,vga);
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure MoveStars (Towards:boolean);
  { If towards is True, then the z-value of each star is decreased to come
    towards the viewer, otherwise the z-value is increased to go away from
    the viewer }
VAR loop1:integer;
BEGIN
  If towards then
    for loop1:=1 to num do BEGIN
      stars[loop1].z:=stars[loop1].z-2;
      if stars[loop1].z<1 then stars[loop1].z:=stars[loop1].z+num;
    END
    else
    for loop1:=1 to num do BEGIN
      stars[loop1].z:=stars[loop1].z+2;
      if stars[loop1].z>num then stars[loop1].z:=stars[loop1].z-num;
    END;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Play;
  { This is our main procedure }
VAR ch:char;
BEGIN
  Calcstars;
  Drawstars;  { This draws our stars for the first time }
  ch:=#0;
  Repeat
    if keypressed then ch:=readkey;
    clear[2]:=clear[1];
    Calcstars;     { Calculate new star positions }
    waitretrace;
    Clearstars;    { Erase old stars }
    Drawstars;     { Draw new stars }
    if ch=' ' then Movestars(False) else Movestars(True);
      { Move stars towards or away from the viewer }
  Until ch=#27;
    { Until the escape key is pressed }
END;

BEGIN
  clrscr;
  writeln ('Hello! Another effect for you, this one is on starfields, again by');
  writeln ('request.  In this sample program, a starfield will be coming towards');
  writeln ('you. Hit the space bar to have it move away from you, any other key');
  writeln ('to have it come towards you again. Hit [ESC] to end.');
  writeln;
  Writeln ('The logo at the top of the screen was drawn by me in Autodesk Animator.');
  Writeln ('It only took a few seconds, so please don''t laugh too much at my attempt.');
  writeln;
  writeln ('The code is very easy to follow, and the documentation is as usual in the');
  writeln ('main text. Leave me mail with further ideas for future trainers.');
  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  randomize;
  setmcga;
  init;
  Play;
  settext;
  Writeln ('All done. This concludes the thirteenth sample program in the ASPHYXIA');
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
END.