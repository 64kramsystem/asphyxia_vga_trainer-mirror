Program Copper;

Uses Crt;

Const MaxRasters = 895;   {  (64+64) * 7 = 896   }
      WaitHoriz = FALSE;      { Wait for horizontal retace? }
      DisableInterrupts = TRUE;  { Disable interupts ? }

Var Rastercolors : Array[0..MaxRasters,1..3] Of Byte;
    Position,temp,deg: Integer;   { Position = What is the first color? }
                                  { Temp = What color for indiv. lines }
                                  { Deg = degree for movement }
    ret,r,g,b:byte;               { Ret = verticle retrace??? }


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure RampColors (r,g,b:boolean);
  { Create a ramp of colors in the RasterColors array, from black to bright
    to black again. The R,G,B variables are booleans that determine what mix
    of colors make up the ramp. }
VAR Loop1:Integer;
BEGIN
  For loop1:=0 To 63 Do Begin
    if r then RasterColors[Temp,1]:=loop1 else RasterColors[Temp,1]:=0;
    if g then RasterColors[Temp,2]:=loop1 else RasterColors[Temp,2]:=0;
    if b then RasterColors[Temp,3]:=loop1 else RasterColors[Temp,3]:=0;
    Temp:=Temp+1;
  End;
  For loop1:=63 DownTo 0 Do Begin
    if r then RasterColors[Temp,1]:=loop1 else RasterColors[Temp,1]:=0;
    if g then RasterColors[Temp,2]:=loop1 else RasterColors[Temp,2]:=0;
    if b then RasterColors[Temp,3]:=loop1 else RasterColors[Temp,3]:=0;
    Temp:=Temp+1;
  End;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function rad (theta : real) : real;
  {  This calculates the degrees of an angle }
BEGIN
  rad := theta * pi / 180
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Init;
  { Initialise all variables }
BEGIN
  Temp :=0;
  Deg  :=0;
  Position:=0;

  RampColors (TRUE,FALSE,FALSE);    { Red Ramp }
  RampColors (FALSE,TRUE,FALSE);    { Green Ramp }
  RampColors (FALSE,FALSE,TRUE);    { Blue Ramp }
  RampColors (TRUE,TRUE,FALSE);     { Yellow Ramp }
  RampColors (TRUE,FALSE,TRUE);     { Purple Ramp }
  RampColors (FALSE,TRUE,TRUE);     { Light Blue Ramp }
  RampColors (TRUE,TRUE,TRUE);      { White Ramp }

  if DisableInterrupts then
    Port[$21]:=1;                   { Disable interupts. Makes scrolling
                                      much smoother, but MUST BE RESTORED
                                      AT PROGRAM END! }
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
PROCEDURE Play;
  { Make the copper bars }
BEGIN
  Repeat
    Temp:=Position;

    Repeat
      r:=RasterColors[Temp,1];
      g:=RasterColors[Temp,2];
      b:=RasterColors[Temp,3];

      asm
        mov     dx,3c8h
        mov     al,0
        out     dx,al
        inc     dx
        mov     al,[r]
        out     dx,al
        mov     al,[g]
        out     dx,al
        mov     al,[b]
        out     dx,al    { Change color 0's pallette }
      end;    { Calling a separate pal procedure is too slow ... }

      if waithoriz then
        asm
          mov     dx,03dah
@WaitHRTEnd:
          in      al,dx
          test    al,01h
          jz      @WaitHRTEnd            { Wait until horiz. retrace finished }
      end;

      Inc(temp);                          { Increase colorcount }
      If temp>MaxRasters Then temp:=0;           { Limit }

      asm
        mov     dx,03dah
        in      al,dx
        test    al,8
        jz      @Zero      { If not in Vert. Retrace, change color }
        mov     ret,1
        jmp     @Fin
@Zero :
        mov     ret,0
@Fin :
      end;
    Until ret=1;
    { During vert. retrace ... }

    deg:=deg+1;
    position:=position+round (sin (rad (deg))*15);    { For scrolling }
    If position>MaxRasters Then position:=0;            { Limits }
    If position<0 Then position:=MaxRasters;

  Until Port[$60]<$80;   { has a key been pressed? }
                         { Until keypressed takes too long ... }

  asm
    mov    dx,3c8h
    mov    al,0
    out    dx,al
    inc    dx
    mov    al,0
    out    dx,al
    mov    al,0
    out    dx,al
    mov    al,0
    out    dx,al
  end;   { Restore pallette zero to black }
  if DisableInterrupts then
    Port[$21]:=0;                                { Enable interrupts }
END;

BEGIN
  ClrScr;
  Writeln ('Hi there!  This is a small litttle program to demonstrate how to do');
  Writeln ('copper bars in textmode through SIMPLE pallette manipulation. It was');
  Writeln ('mainly coded in order to display how to check for horizontal retrace.');
  Writeln;
  Writeln ('To achive this effect, we continally alter the pallette of color 0,');
  Writeln ('according to a color gradient we have precalculated. If we alter this');
  Writeln ('color once every horizontal retrace, we get a cool spectrum, which you');
  Writeln ('can see behind this text. To obtain movement, we change wich color to');
  Writeln ('start with every verticle retrace. The code is easy do understand and');
  Writeln ('well documented, so you shouldn''t have any problems.');
  Writeln;
  Writeln ('The verticle retrace and many other things are discussed in the ASPHYXIA');
  Writeln ('VGA Trainer Series, available on ASPHYXIA BBS (031) 765 5312');
  Writeln;
  Writeln ('Do you like it?  If you want to get in contact with me (Denthor) or');
  Writeln ('any of the other ASPHYXIA members (Goth, EzE, Fubar, Nobody), leave');
  Writeln ('mail to those names on Connectix BBS (031) 2669992, or write to');
  Writeln ('me (Grant Smith/DENTHOR) on the ASPHYXIA BBS or the For Your Eyes');
  Writeln ('Only BBS.');
  Writeln;
  Writeln ('You may also get me on (031) 732129, or write to P.O.Box 270 Kloof 3640');
  Writeln;
  Writeln ('Bye,');
  Writeln (' - Denthor');
  Init;
  Play;
END.