{$X+}

Uses Crt;

CONST VGA=$a000;

Var Pall,Pall2 : Array[0..255,1..3] of Byte;
     { This declares the PALL variable. 0 to 255 signify the colors of the
       pallette, 1 to 3 signifies the Red, Green and Blue values. I am
       going to use this as a sort of "virtual pallette", and alter it
       as much as I want, then suddenly bang it to screen. Pall2 is used
       to "remember" the origional pallette so that we can restore it at
       the end of the program. }



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetMCGA;  { This procedure gets you into 320x200x256 mode. }
BEGIN
  asm
     mov        ax,0013h
     int        10h
  end;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetText;  { This procedure returns you to text mode.  }
BEGIN
  asm
     mov        ax,0003h
     int        10h
  end;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure WaitRetrace; assembler;
  { This waits until you are in a Verticle Retrace ... this means that all
    screen manipulation you do only appears on screen in the next verticle
    retrace ... this removes most of the "fuzz" that you see on the screen
    when changing the pallette. It unfortunately slows down your program
    by "synching" your program with your monitor card ... it does mean
    that the program will run at almost the same speed on different
    speeds of computers which have similar monitors. In our SilkyDemo,
    we used a WaitRetrace, and it therefore runs at the same (fairly
    fast) speed when Turbo is on or off. }

label
  l1, l2;
asm
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure GetPal(ColorNo : Byte; Var R,G,B : Byte);
  { This reads the values of the Red, Green and Blue values of a certain
    color and returns them to you. }
Begin
   Port[$3c7] := ColorNo;
   R := Port[$3c9];
   G := Port[$3c9];
   B := Port[$3c9];
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Pal(ColorNo : Byte; R,G,B : Byte);
  { This sets the Red, Green and Blue values of a certain color }
Begin
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Putpixel (X,Y : Integer; Col : Byte);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Mem [VGA:X+(Y*320)]:=Col;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure line(a,b,c,d,col:integer);
  { This draws a line from a,b to c,d of color col. }
   Function sgn(a:real):integer;
   BEGIN
        if a>0 then sgn:=+1;
        if a<0 then sgn:=-1;
        if a=0 then sgn:=0;
   END;
var u,s,v,d1x,d1y,d2x,d2y,m,n:real;
    i:integer;
BEGIN
     u:= c - a;
     v:= d - b;
     d1x:= SGN(u);
     d1y:= SGN(v);
     d2x:= SGN(u);
     d2y:= 0;
     m:= ABS(u);
     n := ABS(v);
     IF NOT (M>N) then
     BEGIN
          d2x := 0 ;
          d2y := SGN(v);
          m := ABS(v);
          n := ABS(u);
     END;
     s := INT(m / 2);
     FOR i := 0 TO round(m) DO
     BEGIN
          putpixel(a,b,col);
          s := s + n;
          IF not (s<m) THEN
          BEGIN
               s := s - m;
               a:= a +round(d1x);
               b := b + round(d1y);
          END
          ELSE
          BEGIN
               a := a + round(d2x);
               b := b + round(d2y);
          END;
     END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure PalPlay;
  { This procedure mucks about with our "virtual pallette", then shoves it
    to screen. }
Var Tmp : Array[1..3] of Byte;
  { This is used as a "temporary color" in our pallette }
    loop1 : Integer;
BEGIN
   Move(Pall[200],Tmp,3);
     { This copies color 200 from our virtual pallette to the Tmp variable }
   Move(Pall[0],Pall[1],200*3);
     { This moves the entire virtual pallette up one color }
   Move(Tmp,Pall[0],3);
     { This copies the Tmp variable to the bottom of the virtual pallette }
   WaitRetrace;
   For loop1:=1 to 255 do
     pal (loop1,pall[loop1,1],pall[loop1,2],pall[loop1,3]);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetUpScreen;
  { This gets our screen ready but setting up the pallette and drawing
    the lines. }
Var Loop : Integer;
BEGIN
   FillChar(Pall,SizeOf(Pall),0);
       { Clear the entire PALL variable to zero. }
   For Loop := 0 to 200 do BEGIN
      Pall[Loop,1] := Loop mod 64;
   END;
       { This sets colors 0 to 200 in the PALL variable to values between
         0 to 63. the MOD function gives you the remainder of a division,
         ie. 105 mod 10 = 5 }

   For Loop := 1 to 320 do BEGIN
      Line(319,199,320-Loop,0,(Loop Mod 199)+1);
      Line(0,0,Loop,199,(Loop Mod 199)+1);
       { These two lines start drawing lines from the left and the right
         hand sides of the screen, using colors 1 to 199. Look at these
         two lines and understand them. }
      PalPlay;
        { This calls the PalPlay procedure }
   END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure GrabPallette;
VAR loop1:integer;
BEGIN
  For loop1:=0 to 255 do
    Getpal (loop1,pall2[loop1,1],pall2[loop1,2],pall2[loop1,3]);
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Blackout;
  { This procedure blackens the screen by setting the pallette values of
    all the colors to zero. }
VAR loop1:integer;
BEGIN
  WaitRetrace;
  For loop1:=0 to 255 do
    Pal (loop1,0,0,0);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure HiddenScreenSetup;
  { This procedure sets up the screen while it is blacked out, so that the
    user can't see what is happening. }
VAR loop1,loop2:integer;
BEGIN
  For loop1:=0 to 319 do
    For loop2:=0 to 199 do
      PutPixel (loop1,loop2,Random (256));
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Fadeup;
  { This procedure slowly fades up the new screen }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=1 to 64 do BEGIN
      { A color value for Red, green or blue is 0 to 63, so this loop only
        need be executed a maximum of 64 times }
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]<Pall2[loop2,1] then inc (Tmp[1]);
      If Tmp[2]<Pall2[loop2,2] then inc (Tmp[2]);
      If Tmp[3]<Pall2[loop2,3] then inc (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are less then they
          should be, increase them by one. }
      Pal (loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure FadeDown;
  { This procedure fades the screen out to black. }
VAR loop1,loop2:integer;
    Tmp : Array [1..3] of byte;
      { This is temporary storage for the values of a color }
BEGIN
  For loop1:=1 to 64 do BEGIN
    WaitRetrace;
    For loop2:=0 to 255 do BEGIN
      Getpal (loop2,Tmp[1],Tmp[2],Tmp[3]);
      If Tmp[1]>0 then dec (Tmp[1]);
      If Tmp[2]>0 then dec (Tmp[2]);
      If Tmp[3]>0 then dec (Tmp[3]);
        { If the Red, Green or Blue values of color loop2 are not yet zero,
          then, decrease them by one. }
      Pal (loop2,Tmp[1],Tmp[2],Tmp[3]);
        { Set the new, altered pallette color. }
    END;
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure RestorePallette;
  { This procedure restores the origional pallette }
VAR loop1:integer;
BEGIN
  WaitRetrace;
  For loop1:=0 to 255 do
    pal (loop1,Pall2[loop1,1],Pall2[loop1,2],Pall2[loop1,3]);
END;


BEGIN
  ClrScr;
  Writeln ('This program will draw lines of different colors across the');
  Writeln ('screen and change them only by changing their pallette values.');
  Writeln ('The nice thing about using the pallette is that one pallette');
  Writeln ('change changes the same color over the whole screen, without');
  Writeln ('you having to redraw it. Because I am using a WaitRetrace');
  Writeln ('command, turning on and off your turbo during the demonstration');
  Writeln ('should have no effect.');
  Writeln;
  Writeln ('The second part of the demo blacks out the screen using the');
  Writeln ('pallette, fades in the screen, waits for a keypress, then fades');
  Writeln ('it out again. I haven''t put in any delays for the fadein/out,');
  Writeln ('so you will have to put ''em in yourself to get it to the speed you');
  Writeln ('like. Have fun and enjoy! ;-)');
  Writeln; Writeln;
  Writeln ('Hit any key to continue ...');
  Readkey;
  SetMCGA;
  GrabPallette;
  SetUpScreen;
  repeat
     PalPlay;
       { Call the PalPlay procedure repeatedly until a key is pressed. }
  Until Keypressed;
  Readkey;
    { Read in the key pressed otherwise it is left in the keyboard buffer }
  Blackout;
  HiddenScreenSetup;
  FadeUp;
  Readkey;
  FadeDown;
  Readkey;
  RestorePallette;
  SetText;
  Writeln ('All done. This concludes the second sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the name of GRANT');
  Writeln ('SMITH on the MailBox BBS, or leave a message to ASPHYXIA on the');
  Writeln ('ASPHYXIA BBS. Get the numbers from Roblist, or write to :');
  Writeln ('             Grant Smith');
  Writeln ('             P.O. Box 270');
  Writeln ('             Kloof');
  Writeln ('             3640');
  Writeln ('I hope to hear from you soon!');
  Writeln; Writeln;
  Write   ('Hit any key to exit ...');
  Readkey;
END.
