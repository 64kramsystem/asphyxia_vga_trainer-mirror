{$X+}
USES Crt;

CONST VGA = $A000;
      maxpolys = 5;
      A : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-10,10,0),(-2,-10,0),(0,-10,0),(-5,10,0)),
         ((10,10,0),(2,-10,0),(0,-10,0),(5,10,0)),
         ((-2,-10,0),(2,-10,0),(2,-5,0),(-2,-5,0)),
         ((-6,0,0),(6,0,0),(7,5,0),(-7,5,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }
     S : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-10,-10,0),(10,-10,0),(10,-7,0),(-10,-7,0)),
         ((-10,10,0),(10,10,0),(10,7,0),(-10,7,0)),
         ((-10,1,0),(10,1,0),(10,-2,0),(-10,-2,0)),
         ((-10,-8,0),(-7,-8,0),(-7,0,0),(-10,0,0)),
         ((10,8,0),(7,8,0),(7,0,0),(10,0,0))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }
     P : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-10,-10,0),(-7,-10,0),(-7,10,0),(-10,10,0)),
         ((10,-10,0),(7,-10,0),(7,0,0),(10,0,0)),
         ((-9,-10,0),(9,-10,0),(9,-7,0),(-9,-7,0)),
         ((-9,-1,0),(9,-1,0),(9,2,0),(-9,2,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }
     H : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-10,-10,0),(-7,-10,0),(-7,10,0),(-10,10,0)),
         ((10,-10,0),(7,-10,0),(7,10,0),(10,10,0)),
         ((-9,-1,0),(9,-1,0),(9,2,0),(-9,2,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }
     Y : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-7,-10,0),(0,-3,0),(0,0,0),(-10,-7,0)),
         ((7,-10,0),(0,-3,0),(0,0,0),(10,-7,0)),
         ((-2,-3,0),(2,-3,0),(2,10,0),(-2,10,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }
     X : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-7,-10,0),(10,7,0),(7,10,0),(-10,-7,0)),
         ((7,-10,0),(-10,7,0),(-7,10,0),(10,-7,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }
     I : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-10,-10,0),(10,-10,0),(10,-7,0),(-10,-7,0)),
         ((-10,10,0),(10,10,0),(10,7,0),(-10,7,0)),
         ((-2,-9,0),(2,-9,0),(2,9,0),(-2,9,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0)),
         ((0,0,0),(0,0,0),(0,0,0),(0,0,0))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }


Type Point = Record
               x,y,z:real;                { The data on every point we rotate}
             END;
     Virtual = Array [1..64000] of byte;  { The size of our Virtual Screen }
     VirtPtr = ^Virtual;                  { Pointer to the virtual screen }


VAR Lines : Array [1..maxpolys,1..4] of Point;  { The base object rotated }
    Translated : Array [1..maxpolys,1..4] of Point; { The rotated object }
    Xoff,Yoff,Zoff:Integer;               { Used for movement of the object }
    lookup : Array [0..360,1..2] of real; { Our sin and cos lookup table }
    Virscr : VirtPtr;                     { Our first Virtual screen }
    Vaddr  : word;                        { The segment of our virtual screen}


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
Procedure Cls (Where:word;Col : Byte);
   { This clears the screen to the specified color }
BEGIN
     asm
        push    es
        mov     cx, 32000;
        mov     es,[where]
        xor     di,di
        mov     al,[col]
        mov     ah,al
        rep     stosw
        pop     es
     End;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetUpVirtual;
   { This sets up the memory needed for the virtual screen }
BEGIN
  GetMem (VirScr,64000);
  vaddr := seg (virscr^);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure ShutDown;
   { This frees the memory used by the virtual screen }
BEGIN
  FreeMem (VirScr,64000);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure flip(source,dest:Word);
  { This copies the entire screen at "source" to destination }
begin
  asm
    push    ds
    mov     ax, [Dest]
    mov     es, ax
    mov     ax, [Source]
    mov     ds, ax
    xor     si, si
    xor     di, di
    mov     cx, 32000
    rep     movsw
    pop     ds
  end;
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Pal(Col,R,G,B : Byte);
  { This sets the Red, Green and Blue values of a certain color }
Begin
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
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Hline (x1,x2,y:word;col:byte;where:word); assembler;
  { This draws a horizontal line from x1 to x2 on line y in color col }
asm
  mov   ax,where
  mov   es,ax
  mov   ax,y
  mov   di,ax
  shl   ax,8
  shl   di,6
  add   di,ax
  add   di,x1

  mov   al,col
  mov   ah,al
  mov   cx,x2
  sub   cx,x1
  shr   cx,1
  jnc   @start
  stosb
@Start :
  rep   stosw
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
  { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
    in color col }
var
  x:integer;
  mny,mxy:integer;
  mnx,mxx,yc:integer;
  mul1,div1,
  mul2,div2,
  mul3,div3,
  mul4,div4:integer;

begin
  mny:=y1; mxy:=y1;
  if y2<mny then mny:=y2;
  if y2>mxy then mxy:=y2;
  if y3<mny then mny:=y3;
  if y3>mxy then mxy:=y3;    { Choose the min y mny and max y mxy }
  if y4<mny then mny:=y4;
  if y4>mxy then mxy:=y4;

  if mny<0 then mny:=0;
  if mxy>199 then mxy:=199;
  if mny>199 then exit;
  if mxy<0 then exit;        { Verticle range checking }

  mul1:=x1-x4; div1:=y1-y4;
  mul2:=x2-x1; div2:=y2-y1;
  mul3:=x3-x2; div3:=y3-y2;
  mul4:=x4-x3; div4:=y4-y3;  { Constansts needed for intersection calc }

  for yc:=mny to mxy do
    begin
      mnx:=320;
      mxx:=-1;
      if (y4>=yc) or (y1>=yc) then
        if (y4<=yc) or (y1<=yc) then   { Check that yc is between y1 and y4 }
          if not(y4=y1) then
            begin
              x:=(yc-y4)*mul1 div div1+x4; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y1>=yc) or (y2>=yc) then
        if (y1<=yc) or (y2<=yc) then   { Check that yc is between y1 and y2 }
          if not(y1=y2) then
            begin
              x:=(yc-y1)*mul2 div div2+x1; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y2>=yc) or (y3>=yc) then
        if (y2<=yc) or (y3<=yc) then   { Check that yc is between y2 and y3 }
          if not(y2=y3) then
            begin
              x:=(yc-y2)*mul3 div div3+x2; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if (y3>=yc) or (y4>=yc) then
        if (y3<=yc) or (y4<=yc) then   { Check that yc is between y3 and y4 }
          if not(y3=y4) then
            begin
              x:=(yc-y3)*mul4 div div4+x3; { Point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { Set point as start or end of horiz line }
            end;
      if mnx<0 then
        mnx:=0;
      if mxx>319 then
        mxx:=319;          { Range checking on horizontal line }
      if mnx<=mxx then
        hline (mnx,mxx,yc,color,where);   { Draw the horizontal line }
    end;
  end;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Function rad (theta : real) : real;
  {  This calculates the degrees of an angle }
BEGIN
  rad := theta * pi / 180
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetUpPoints;
  { This creates the lookup table }
VAR loop1,loop2:integer;
BEGIN
  For loop1:=0 to 360 do BEGIN
    lookup [loop1,1]:=sin (rad (loop1));
    lookup [loop1,2]:=cos (rad (loop1));
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Putpixel (X,Y : Integer; Col : Byte; where:word);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Asm
    mov     ax,[where]
    mov     es,ax
    mov     bx,[X]
    mov     dx,[Y]
    mov     di,bx
    mov     bx, dx                  {; bx = dx}
    shl     dx, 8
    shl     bx, 6
    add     dx, bx                  {; dx = dx + bx (ie y*320)}
    add     di, dx                  {; finalise location}
    mov     al, [Col]
    stosb
  End;
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure RotatePoints (X,Y,Z:Integer);
  { This rotates object lines by X,Y and Z; then places the result in
    TRANSLATED }
VAR loop1,loop2:integer;
    temp:point;
BEGIN
  For loop1:=1 to maxpolys do BEGIN
    For loop2:=1 to 4 do BEGIN
      temp.x:=lines[loop1,loop2].x;
      temp.y:=lookup[x,2]*lines[loop1,loop2].y - lookup[x,1]*lines[loop1,loop2].z;
      temp.z:=lookup[x,1]*lines[loop1,loop2].y + lookup[x,2]*lines[loop1,loop2].z;

      translated[loop1,loop2]:=temp;

      If y>0 then BEGIN
        temp.x:=lookup[y,2]*translated[loop1,loop2].x - lookup[y,1]*translated[loop1,loop2].y;
        temp.y:=lookup[y,1]*translated[loop1,loop2].x + lookup[y,2]*translated[loop1,loop2].y;
        temp.z:=translated[loop1,loop2].z;
        translated[loop1,loop2]:=temp;
      END;

      If z>0 then BEGIN
        temp.x:=lookup[z,2]*translated[loop1,loop2].x + lookup[z,1]*translated[loop1,loop2].z;
        temp.y:=translated[loop1,loop2].y;
        temp.z:=-lookup[z,1]*translated[loop1,loop2].x + lookup[z,2]*translated[loop1,loop2].z;
        translated[loop1,loop2]:=temp;
      END;
    END;
  END;
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DrawPoints;
  { This draws the translated object to the virtual screen }
VAR loop1:Integer;
    nx,ny,nx2,ny2,nx3,ny3,nx4,ny4:integer;
    temp:integer;
BEGIN
  For loop1:=1 to maxpolys do BEGIN
    If (translated[loop1,1].z+zoff<0) and (translated[loop1,2].z+zoff<0) and
       (translated[loop1,3].z+zoff<0) and (translated[loop1,4].z+zoff<0) then BEGIN
      temp:=round (translated[loop1,1].z+zoff);
      nx :=round (256*translated[loop1,1].X) div temp+xoff;
      ny :=round (256*translated[loop1,1].Y) div temp+yoff;
      temp:=round (translated[loop1,2].z+zoff);
      nx2:=round (256*translated[loop1,2].X) div temp+xoff;
      ny2:=round (256*translated[loop1,2].Y) div temp+yoff;
      temp:=round (translated[loop1,3].z+zoff);
      nx3:=round (256*translated[loop1,3].X) div temp+xoff;
      ny3:=round (256*translated[loop1,3].Y) div temp+yoff;
      temp:=round (translated[loop1,4].z+zoff);
      nx4:=round (256*translated[loop1,4].X) div temp+xoff;
      ny4:=round (256*translated[loop1,4].Y) div temp+yoff;
      drawpoly (nx,ny,nx2,ny2,nx3,ny3,nx4,ny4,13,vaddr);
    END;
  END;
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure MoveAround;
  { This is the main display procedure. Firstly it brings the object towards
    the viewer by increasing the Zoff, then passes control to the user }
VAR deg,loop1,loop2:integer;
    ch:char;

  Procedure Whizz (sub:boolean);
  VAR loop1:integer;
  BEGIN
    For loop1:=-64 to -5 do BEGIN
      zoff:=loop1*8;
      if sub then xoff:=xoff-7 else xoff:=xoff+7;
      RotatePoints (deg,deg,deg);
      DrawPoints;
      flip (vaddr,vga);
      Cls (vaddr,0);
      deg:=(deg+5) mod 360;
    END;
  END;

BEGIN
  deg:=0;
  ch:=#0;
  Yoff:=100;
  Xoff:=350;
  Cls (vaddr,0);
  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=a [loop1,loop2,1];
      Lines [loop1,loop2].y:=a [loop1,loop2,2];
      Lines [loop1,loop2].z:=a [loop1,loop2,3];
    END;
  Whizz (TRUE);

  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=s [loop1,loop2,1];
      Lines [loop1,loop2].y:=s [loop1,loop2,2];
      Lines [loop1,loop2].z:=s [loop1,loop2,3];
    END;
  Whizz (FALSE);

  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=p [loop1,loop2,1];
      Lines [loop1,loop2].y:=p [loop1,loop2,2];
      Lines [loop1,loop2].z:=p [loop1,loop2,3];
    END;
  Whizz (TRUE);

  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=h [loop1,loop2,1];
      Lines [loop1,loop2].y:=h [loop1,loop2,2];
      Lines [loop1,loop2].z:=h [loop1,loop2,3];
    END;
  Whizz (FALSE);

  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=y [loop1,loop2,1];
      Lines [loop1,loop2].y:=y [loop1,loop2,2];
      Lines [loop1,loop2].z:=y [loop1,loop2,3];
    END;
  Whizz (TRUE);

  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=x [loop1,loop2,1];
      Lines [loop1,loop2].y:=x [loop1,loop2,2];
      Lines [loop1,loop2].z:=x [loop1,loop2,3];
    END;
  Whizz (FALSE);

  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=i [loop1,loop2,1];
      Lines [loop1,loop2].y:=i [loop1,loop2,2];
      Lines [loop1,loop2].z:=i [loop1,loop2,3];
    END;
  Whizz (TRUE);

  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=a [loop1,loop2,1];
      Lines [loop1,loop2].y:=a [loop1,loop2,2];
      Lines [loop1,loop2].z:=a [loop1,loop2,3];
    END;
  Whizz (FALSE);

  cls (vaddr,0);
  cls (vga,0);
  Xoff := 160;

  Repeat
    if keypressed then BEGIN
      ch:=upcase (Readkey);
      Case ch of 'A' : zoff:=zoff+5;
                 'Z' : zoff:=zoff-5;
                 ',' : xoff:=xoff-5;
                 '.' : xoff:=xoff+5;
                 'S' : yoff:=yoff-5;
                 'X' : yoff:=yoff+5;
      END;
    END;
    DrawPoints;
    flip (vaddr,vga);
    cls (vaddr,0);
    RotatePoints (deg,deg,deg);
    deg:=(deg+5) mod 360;
  Until ch=#27;
END;


BEGIN
  SetUpVirtual;
  clrscr;
  Writeln ('Hello there! Varsity has begun once again, so it is once again');
  Writeln ('back to the grindstone ;-) ... anyway, this tutorial is, by');
  Writeln ('popular demand, on poly-filling, in relation to 3-D solids.');
  Writeln;
  Writeln ('In this program, the letters of ASPHYXIA will fly past you. As you');
  Writeln ('will see, they are solid, not wireframe. After the last letter has');
  Writeln ('flown by, a large A will be left in the middle of the screen.');
  Writeln;
  Writeln ('You will be able to move it around the screen, and you will notice');
  Writeln ('that it may have bits only half on the screen, i.e. clipping is');
  Writeln ('perfomed. To control it use the following : "A" and "Z" control the Z');
  Writeln ('movement, "," and "." control the X movement, and "S" and "X"');
  Writeln ('control the Y movement. I have not included rotation control, but');
  Writeln ('it should be easy enough to put in yourself ... if you have any');
  Writeln ('hassles, leave me mail.');
  Writeln;
  Writeln ('I hope this is what you wanted...leave me mail for new ideas.');
  writeln;
  writeln;
  Write ('  Hit any key to contine ...');
  Readkey;
  SetMCGA;
  SetUpPoints;
  MoveAround;
  SetText;
  ShutDown;
  Writeln ('All done. This concludes the ninth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS. I am also an avid');
  Writeln ('Connectix BBS user, and occasionally read RSAProg.');
  Writeln ('The numbers are available in the main text. You may also write to me at:');
  Writeln ('             Grant Smith');
  Writeln ('             P.O. Box 270');
  Writeln ('             Kloof');
  Writeln ('             3640');
  Writeln ('I hope to hear from you soon!');
  Writeln; Writeln;
  Write   ('Hit any key to exit ...');
  Readkey;
END.