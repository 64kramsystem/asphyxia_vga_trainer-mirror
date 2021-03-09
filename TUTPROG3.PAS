{$X+}
USES crt;

CONST VGA = $a000;

VAR loop1:integer;
    Pall : Array [1..199,1..3] of byte;
      { This is our temporary pallette. We ony use colors 1 to 199, so we
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
Procedure Putpixel (X,Y : Integer; Col : Byte);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Mem [VGA:X+(Y*320)]:=Col;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure WaitRetrace; assembler;
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
Procedure Circle (X,Y,rad:integer;Col:Byte);
  { This draws a circle with centre X,Y, with Rad as it's radius }
VAR deg:real;
BEGIN
  deg:=0;
  repeat
    X:=round(rad*COS (deg));
    Y:=round(rad*sin (deg));
    putpixel (x+160,y+100,col);
    deg:=deg+0.005;
  until (deg>6.4);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Line2 (x1,y1,x2,y2:integer;col:byte);
  { This draws a line from x1,y1 to x2,y2 using the first method }
VAR x,y,xlength,ylength,dx,dy:integer;
    xslope,yslope:real;
BEGIN
  xlength:=abs (x1-x2);
  if (x1-x2)<0 then dx:=-1;
  if (x1-x2)=0 then dx:=0;
  if (x1-x2)>0 then dx:=+1;
  ylength:=abs (y1-y2);
  if (y1-y2)<0 then dy:=-1;
  if (y1-y2)=0 then dy:=0;
  if (y1-y2)>0 then dy:=+1;
  if (dy=0) then BEGIN
    if dx<0 then for x:=x1 to x2 do
      putpixel (x,y1,col);
    if dx>0 then for x:=x2 to x1 do
      putpixel (x,y1,col);
    exit;
  END;
  if (dx=0) then BEGIN
    if dy<0 then for y:=y1 to y2 do
      putpixel (x1,y,col);
    if dy>0 then for y:=y2 to y1 do
      putpixel (x1,y,col);
    exit;
  END;
  xslope:=xlength/ylength;
  yslope:=ylength/xlength;
  if (yslope/xslope<1) and (yslope/xslope>-1) then BEGIN
    if dx<0 then for x:=x1 to x2 do BEGIN
                   y:= round (yslope*x);
                   putpixel (x,y,col);
                 END;
    if dx>0 then for x:=x2 to x1 do BEGIN
                   y:= round (yslope*x);
                   putpixel (x,y,col);
                 END;
  END
  ELSE
  BEGIN
    if dy<0 then for y:=y1 to y2 do BEGIN
                   x:= round (xslope*y);
                   putpixel (x,y,col);
                 END;
    if dy>0 then for y:=y2 to y1 do BEGIN
                   x:= round (xslope*y);
                   putpixel (x,y,col);
                 END;
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure line(a,b,c,d,col:integer);
  { This draws a line from x1,y1 to x2,y2 using the first method }

    function sgn(a:real):integer;
    begin
         if a>0 then sgn:=+1;
         if a<0 then sgn:=-1;
         if a=0 then sgn:=0;
    end;

var u,s,v,d1x,d1y,d2x,d2y,m,n:real;
    i:integer;
begin
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
     end;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure PalPlay;
  { This procedure mucks about with our "virtual pallette", then shoves it
    to screen. }
Var Tmp : Array[1..3] of Byte;
  { This is used as a "temporary color" in our pallette }
    loop1 : Integer;
BEGIN
   Move(Pall[199],Tmp,3);
     { This copies color 199 from our virtual pallette to the Tmp variable }
   Move(Pall[1],Pall[2],198*3);
     { This moves the entire virtual pallette up one color }
   Move(Tmp,Pall[1],3);
     { This copies the Tmp variable to the bottom of the virtual pallette }
   WaitRetrace;
   For loop1:=1 to 199 do
     pal (loop1,pall[loop1,1],pall[loop1,2],pall[loop1,3]);
END;


BEGIN
  ClrScr;
  Writeln ('This sample program will test out our line and circle algorithms.');
  Writeln ('In the first part, many circles will be draw creating (hopefully)');
  Writeln ('a "tunnel" effect. I will the rotate the pallete to make it look');
  Writeln ('nice. I will then draw some lines and rotate the pallette on them');
  Writeln ('too. Note : I am using the slower (first) line algorithm (in');
  Writeln ('procedure line2). Change it to Procedure Line and it will be using');
  Writeln ('the second line routine. NB : For descriptions on how pallette works');
  Writeln ('have a look at part two of this series; I won''t re-explain it here.');
  Writeln;
  Writeln ('Remember to send me any work you have done, I am most eager to help.');
  Writeln; Writeln;
  Writeln ('Hit any key to continue ...');
  Readkey;
  setmcga;

  For Loop1 := 1 to 199 do BEGIN
    Pall[Loop1,1] := Loop1 mod 30+33;
    Pall[Loop1,2] := 0;
    Pall[Loop1,3] := 0;
  END;
       { This sets colors 1 to 199 to values between 33 to 63. The MOD
         function gives you the remainder of a division, ie. 105 mod 10 = 5 }

   WaitRetrace;
   For loop1:=1 to 199 do
     pal (loop1,pall[loop1,1],pall[loop1,2],pall[loop1,3]);
        { This sets the true pallette to variable Pall }

  for loop1:=1 to 90 do
    circle (160,100,loop1,loop1);
       { This draws 90 circles all with centres at 160,100; with increasing
         radii and colors. }

  Repeat
    PalPlay;
  Until keypressed;
  Readkey;

  for loop1:=1 to 199 do
    line2 (0,1,319,loop1,loop1);   { *** Replace Line2 with Line to use the
                                         second line algorithm *** }
       { This draws 199 lines, all starting at 0,1 }

  Repeat
    PalPlay;
  Until keypressed;

  readkey;
  SetText;
  Writeln ('All done. Okay, so maybe it wasn''t a tunnel effect, but you get the');
  Writeln ('general idea ;-) This concludes the third sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the name of GRANT SMITH');
  Writeln ('on the MailBox BBS, or leave a message to ASPHYXIA on the ASPHYXIA BBS.');
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