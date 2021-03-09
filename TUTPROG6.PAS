{$X+}
USES crt;

CONST VGA = $a000;

TYPE tbl = Array [1..8000] of real;
             { This will be the shape of the 'table' where we look up
               values, which is faster then calculating them }

VAR loop1:integer;
    Pall : Array [1..20,1..3] of byte;
      { This is our temporary pallette. We ony use colors 1 to 20, so we
        only have variables for those ones. }

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
Procedure Cls (Col : Byte);
   { This clears the screen to the specified color }
BEGIN
  Fillchar (Mem [VGA:0],64000,col);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Putpixel (X,Y : Integer; Col : Byte);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Mem [VGA:X+(Y*320)]:=Col;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure WaitRetrace; assembler;
  {  This waits for a vertical retrace to reduce snow on the screen }
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
Procedure Pal(ColorNo : Byte; R,G,B : Byte);
  { This sets the Red, Green and Blue values of a certain color }
Begin
   Port[$3c8] := ColorNo;
   Port[$3c9] := R;
   Port[$3c9] := G;
   Port[$3c9] := B;
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function rad (theta : real) : real;
  {  This calculates the degrees of an angle }
BEGIN
  rad := theta * pi / 180
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure NormCirc;
  { This generates a spireal without using a lookup table }
VAR deg,radius:real;
    x,y:integer;

BEGIN
  gotoxy (1,1);
  Writeln ('Without pregenerated arrays.');
  for loop1:=60 downto 43 do BEGIN
    deg:=0;
    radius:=loop1;
    repeat
      X:=round(radius*COS (rad (deg)));
      Y:=round(radius*sin (rad (deg)));
      putpixel (x+160,y+100,61-loop1);
      deg:=deg+0.4;           { Increase the degree so the circle is round }
      radius:=radius-0.02;    { Decrease the radius for a spiral effect }
    until radius<0; {  Continue till at the centre (the radius is zero) }
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure LookupCirc;
  {  This draws a spiral using a lookup table }
VAR radius:real;
    x,y,pos:integer;
    costbl : ^tbl;
    sintbl : ^tbl;

    Procedure Setupvars;
      {  This is a nested procedure (a procedure in a procedure), and may
         therefore only be used from within the main part of this procedure.
         This section gets the memory for the table, then generates the
         table. }
    VAR deg:real;
    BEGIN
      getmem (costbl,sizeof(costbl^));
      getmem (sintbl,sizeof(sintbl^));
      deg:=0;
      for loop1:=1 to 8000 do BEGIN         { There are 360 degrees in a    }
        deg:=deg+0.4;                       { circle. If you increase the   }
        costbl^[loop1]:=cos (rad(deg));     { degrees by 0.4, the number of }
        sintbl^[loop1]:=sin (rad(deg));     { needed parts of the table is  }
      END;                                  { 360/0.4=8000                  }
    END;
    { NB : For greater accuracy I increase the degrees by 0.4, because if I
           increase them by one, holes are left in the final product as a
           result of the rounding error margin. This means the pregen array
           is bigger, takes up more memory and is slower to calculate, but
           the finished product looks better.}

BEGIN
  cls (0);
  gotoxy (1,1);
  Writeln ('Generating variables....');
  setupvars;
  gotoxy (1,1);
  Writeln ('With pregenerated arrays.');
  for loop1:=60 downto 43 do BEGIN
    pos:=1;
    radius:=loop1;
    repeat
      X:=round (radius*costbl^[pos]);   { Note how I am not recalculating sin}
      Y:=round (radius*sintbl^[pos]);   { and cos for each point.            }
      putpixel (x+160,y+100,61-loop1);
      radius:=radius-0.02;
      inc (pos);
      if pos>8000 then pos:=1;    { I only made a table from 1 to 8000, so it}
                                  { must never exceed that, or the program   }
                                  { will probably crash.                     }
    until radius<0;
  END;
  freemem (costbl,sizeof(costbl^));   { Freeing the memory taken up by the   }
  freemem (sintbl,sizeof(sintbl^));   { tables. This is very important.      }
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure PalPlay;
  { This procedure mucks about with our "virtual pallette", then shoves it
    to screen. }
Var Tmp : Array[1..3] of Byte;
  { This is used as a "temporary color" in our pallette }
    loop1 : Integer;
BEGIN
   Move(Pall[1],Tmp,3);
     { This copies color 1 from our virtual pallette to the Tmp variable }
   Move(Pall[2],Pall[1],18*3);
     { This moves the entire virtual pallette down one color }
   Move(Tmp,Pall[18],3);
     { This copies the Tmp variable to no. 18 of the virtual pallette }
   WaitRetrace;
   For loop1:=1 to 18 do
     pal (loop1,pall[loop1,1],pall[loop1,2],pall[loop1,3]);
END;


BEGIN
  ClrScr;
  writeln ('Hi there! This program will demonstrate the usefullness of ');
  writeln ('pregenerated arrays, also known as lookup tables. The program');
  writeln ('will first draw a spiral without using a lookup table, rotate');
  writeln ('the pallette until a key is pressed, the calculate the lookup');
  writeln ('table, then draw the same spiral using the lookup table.');
  writeln;
  writeln ('This is merely one example for the wide range of uses of a ');
  writeln ('lookup table.');
  writeln;
  writeln;
  Write ('  Hit any key to contine ...');
  Readkey;
  setmcga;
  directvideo:=FALSE;  { This handy trick allows you to use GOTOXY and }
                       { Writeln in GFX mode. Hit CTRL-F1 on it for more }
                       { info/help }
  For Loop1 := 1 to 18 do BEGIN
    Pall[Loop1,1] := (Loop1*3)+9;
    Pall[Loop1,2] := 0;
    Pall[Loop1,3] := 0;
  END;
       { This sets colors 1 to 18 to values between 12 to 63. }

   WaitRetrace;
   For loop1:=1 to 18 do
     pal (loop1,pall[loop1,1],pall[loop1,2],pall[loop1,3]);
        { This sets the true pallette to variable Pall }

  normcirc;         { This draws a spiral without lookups }
  Repeat
    PalPlay;
  Until keypressed;
  readkey;
  lookupcirc;       { This draws a spiral with lookups }
  Repeat
    PalPlay;
  Until keypressed;
  Readkey;

  SetText;
  Writeln ('All done. This concludes the sixth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the name of GRANT');
  Writeln ('SMITH on the MailBox BBS, or leave a message to ASPHYXIA on the');
  Writeln ('ASPHYXIA BBS. I am also an avid Connectix BBS user.');
  Writeln ('Get the numbers from Roblist, or write to :');
  Writeln ('             Grant Smith');
  Writeln ('             P.O. Box 270');
  Writeln ('             Kloof');
  Writeln ('             3640');
  Writeln ('I hope to hear from you soon!');
  Writeln; Writeln;
  Write   ('Hit any key to exit ...');
  Readkey;
END.