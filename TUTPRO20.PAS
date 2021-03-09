{$X+}
USES Crt,GFX2;

CONST VGA = $A000;
      maxpolys = 18;

            A : Array [1..maxpolys,1..4,1..3] of integer =
        (
         ((-10, -10, 10 ),
          (10 , -10, 10 ),
          (10 , 10 , 10 ),
          (-10, 10 , 10 )),

         ((-10, 10 , -10),
          (10 , 10 , -10),
          (10 , -10, -10),
          (-10, -10, -10)),

         ((-10, 10 , 10 ),
          (-10, 10 , -10),
          (-10, -10, -10),
          (-10, -10, 10 )),

         ((10 , -10, 10 ),
          (10 , -10, -10),
          (10 , 10 , -10),
          (10 , 10 , 10 )),

         ((10 , 10 , 10 ),
          (10 , 10 , -10),
          (-10, 10 , -10),
          (-10, 10 , 10 )),

         ((-10, -10, 10 ),
          (-10, -10, -10),
          (10 , -10, -10),
          (10 , -10, 10 )),

(*********)

         ((-10, -10,-20 ),
          (10 , -10,-20 ),
          (10 , 10 ,-20 ),
          (-10, 10 ,-20 )),

         ((-10, 10 , -30),
          (10 , 10 , -30),
          (10 , -10, -30),
          (-10, -10, -30)),

         ((-10, 10 ,-20 ),
          (-10, 10 , -30),
          (-10, -10, -30),
          (-10, -10,-20 )),

         ((10 , -10,-20 ),
          (10 , -10, -30),
          (10 , 10 , -30),
          (10 , 10 ,-20 )),

         ((10 , 10 ,-20 ),
          (10 , 10 , -30),
          (-10, 10 , -30),
          (-10, 10 ,-20 )),

         ((-10, -10,-20 ),
          (-10, -10, -30),
          (10 , -10, -30),
          (10 , -10,-20 )),

(*********)

         ((-30, -10, 10 ),
          (-20, -10, 10 ),
          (-20, 10 , 10 ),
          (-30, 10 , 10 )),

         ((-30, 10 , -10),
          (-20, 10 , -10),
          (-20, -10, -10),
          (-30, -10, -10)),

         ((-30, 10 , 10 ),
          (-30, 10 , -10),
          (-30, -10, -10),
          (-30, -10, 10 )),

         ((-20, -10, 10 ),
          (-20, -10, -10),
          (-20, 10 , -10),
          (-20, 10 , 10 )),

         ((-20, 10 , 10 ),
          (-20, 10 , -10),
          (-30, 10 , -10),
          (-30, 10 , 10 )),

         ((-30, -10, 10 ),
          (-30, -10, -10),
          (-20, -10, -10),
          (-20, -10, 10 ))
        );  { The 3-D coordinates of our object ... stored as (X1,Y1,Z1), }
            { (X2,Y2,Z2) ... for the 4 points of a poly }

      XOfs = 100;
      YOfs = 160;


Type Point = Record
               x,y,z:integer;                { The data on every point we rotate}
             END;


VAR Lines : Array [1..maxpolys,1..4] of Point; { The base object to be rotated }
    Translated : Array [1..maxpolys,1..4] of Point; { The rotated object }
    centre, tcentre : Array [1..maxpolys] of Point;
    Order : Array[1..maxpolys] of integer;
    lookup : Array [0..360,1..2] of integer; { Our sin and cos lookup table }
    poly : array [0..199,1..2] of integer;
    ytopclip,ybotclip:integer;  {where to clip our polys to}
    xoff,yoff,zoff:integer;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetMCGA;  { This procedure gets you into 320x200x256 mode. }
BEGIN
  asm
     mov        ax,0013h
     int        10h
  end;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Hline (x1,x2,y:integer;col:byte;where:word); assembler;
  { This draws a horizontal line from x1 to x2 on line y in color col }
asm
  mov   ax,x1
  cmp   ax,0
  jge   @X1Okay
  mov   x1,0
@X1Okay :

  mov   ax,x2
  cmp   ax,319
  jle   @X2Okay
  mov   x2,319
@X2Okay :

  mov   ax,x1
  cmp   ax,x2
  jg    @Exit

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
@Exit :
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DrawPoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte;where:word);
  { This draw a polygon with 4 points at x1,y1 , x2,y2 , x3,y3 , x4,y4
    in color col }
var miny,maxy:integer;
    loop1:integer;

Procedure doside (x1,y1,x2,y2:integer);
  { This scans the side of a polygon and updates the poly variable }
VAR temp:integer;
    x,xinc:integer;
    loop1:integer;
BEGIN
  if y1=y2 then exit;
  if y2<y1 then BEGIN
    temp:=y2;
    y2:=y1;
    y1:=temp;
    temp:=x2;
    x2:=x1;
    x1:=temp;
  END;
  xinc:=((x2-x1) shl 7) div (y2-y1);
  x:=x1 shl 7;
  for loop1:=y1 to y2 do BEGIN
    if (loop1>(ytopclip)) and (loop1<(ybotclip)) then BEGIN
      if (x shr 7<poly[loop1,1]) then poly[loop1,1]:=x shr 7;
      if (x shr 7>poly[loop1,2]) then poly[loop1,2]:=x shr 7;
    END;
    x:=x+xinc;
  END;
END;

begin
  asm
    mov   si,offset poly
    mov   cx,200
@Loop1:
    mov   ax,32766
    mov   ds:[si],ax
    inc   si
    inc   si
    mov   ax,-32767
    mov   ds:[si],ax
    inc   si
    inc   si
    loop  @loop1
  end;     { Setting the minx and maxx values to extremes }
  miny:=y1;
  maxy:=y1;
  if y2<miny then miny:=y2;
  if y3<miny then miny:=y3;
  if y4<miny then miny:=y4;
  if y2>maxy then maxy:=y2;
  if y3>maxy then maxy:=y3;
  if y4>maxy then maxy:=y4;
  if miny<ytopclip then miny:=ytopclip;
  if maxy>ybotclip then maxy:=ybotclip;
  if (miny>199) or (maxy<0) then exit;

  Doside (x1,y1,x2,y2);
  Doside (x2,y2,x3,y3);
  Doside (x3,y3,x4,y4);
  Doside (x4,y4,x1,y1);

  for loop1:= miny to maxy do
    hline (poly[loop1,1],poly[loop1,2],loop1,color,where);
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetUpPoints;
  { This creates the lookup table }
VAR loop1,loop2:integer;
BEGIN
  For loop1:=0 to 360 do BEGIN
    lookup [loop1,1]:=round(sin (rad (loop1))*16384);
    lookup [loop1,2]:=round(cos (rad (loop1))*16384);
  END;
  For loop1:=1 to maxpolys do BEGIN
    centre[loop1].x := (lines[loop1,1].x + lines[loop1,2].x +
                        lines[loop1,3].x + lines[loop1,4].x) div 4;
    centre[loop1].y := (lines[loop1,1].y + lines[loop1,2].y +
                        lines[loop1,3].y + lines[loop1,4].y) div 4;
    centre[loop1].z := (lines[loop1,1].z + lines[loop1,2].z +
                        lines[loop1,3].z + lines[loop1,4].z) div 4;
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure RotatePoints (x,Y,z:Integer);
  { This rotates the objecct in lines to translated }
VAR loop1,loop2:integer;
    a,b,c:integer;
BEGIN
  For loop1:=1 to maxpolys do BEGIN
    for loop2:=1 to 4 do BEGIN
      b:=lookup[y,2];
      c:=lines[loop1,loop2].x;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      end;
      b:=lookup[y,1];
      c:=lines[loop1,loop2].z;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        add   a,dx
      end;
      translated[loop1,loop2].x:=a;
      translated[loop1,loop2].y:=lines[loop1,loop2].y;
      b:=-lookup[y,1];
      c:=lines[loop1,loop2].x;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      end;
      b:=lookup[y,2];
      c:=lines[loop1,loop2].z;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        add   a,dx
      end;
      translated[loop1,loop2].z:=a;


      if x<>0 then BEGIN
        b:=lookup[x,2];
        c:=translated[loop1,loop2].y;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        end;
        b:=lookup[x,1];
        c:=translated[loop1,loop2].z;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          sub   a,dx
        end;
        b:=lookup[x,1];
        c:=translated[loop1,loop2].y;
        translated[loop1,loop2].y:=a;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        end;
        b:=lookup[x,2];
        c:=translated[loop1,loop2].z;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          add   a,dx
        end;
        translated[loop1,loop2].z:=a;
      END;




      if z<>0 then BEGIN
        b:=lookup[z,2];
        c:=translated[loop1,loop2].x;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        end;
        b:=lookup[z,1];
        c:=translated[loop1,loop2].y;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          sub   a,dx
        end;
        b:=lookup[z,1];
        c:=translated[loop1,loop2].x;
        translated[loop1,loop2].x:=a;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          mov   a,dx
        end;
        b:=lookup[z,2];
        c:=translated[loop1,loop2].y;
        asm
          mov   ax,b
          imul  c
          sal   ax,1
          rcl   dx,1
          sal   ax,1
          rcl   dx,1
          add   a,dx
        end;
        translated[loop1,loop2].y:=a;
      END;
    END;
  END;


{******************}
  For loop1:=1 to maxpolys do BEGIN
    b:=lookup[y,2];
    c:=centre[loop1].x;
    asm
      mov   ax,b
      imul  c
      sal   ax,1
      rcl   dx,1
      sal   ax,1
      rcl   dx,1
      mov   a,dx
    end;
    b:=lookup[y,1];
    c:=centre[loop1].z;
    asm
      mov   ax,b
      imul  c
      sal   ax,1
      rcl   dx,1
      sal   ax,1
      rcl   dx,1
      add   a,dx
    end;
    tcentre[loop1].x:=a;
    tcentre[loop1].y:=centre[loop1].y;
    b:=-lookup[y,1];
    c:=centre[loop1].x;
    asm
      mov   ax,b
      imul  c
      sal   ax,1
      rcl   dx,1
      sal   ax,1
      rcl   dx,1
      mov   a,dx
    end;
    b:=lookup[y,2];
    c:=centre[loop1].z;
    asm
      mov   ax,b
      imul  c
      sal   ax,1
      rcl   dx,1
      sal   ax,1
      rcl   dx,1
      add   a,dx
    end;
    tcentre[loop1].z:=a;


    if x<>0 then BEGIN
      b:=lookup[x,2];
      c:=tcentre[loop1].y;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      end;
      b:=lookup[x,1];
      c:=tcentre[loop1].z;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        sub   a,dx
      end;
      b:=lookup[x,1];
      c:=tcentre[loop1].y;
      tcentre[loop1].y:=a;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      end;
      b:=lookup[x,2];
      c:=tcentre[loop1].z;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        add   a,dx
      end;
      tcentre[loop1].z:=a;
    END;




    if z<>0 then BEGIN
      b:=lookup[z,2];
      c:=tcentre[loop1].x;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      end;
      b:=lookup[z,1];
      c:=tcentre[loop1].y;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        sub   a,dx
      end;
      b:=lookup[z,1];
      c:=tcentre[loop1].x;
      tcentre[loop1].x:=a;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        mov   a,dx
      end;
      b:=lookup[z,2];
      c:=tcentre[loop1].y;
      asm
        mov   ax,b
        imul  c
        sal   ax,1
        rcl   dx,1
        sal   ax,1
        rcl   dx,1
        add   a,dx
      end;
      tcentre[loop1].y:=a;
    END;
  END;
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure DrawPoints;
  { This draws the translated object to the virtual screen }
VAR loop1,loop2:Integer;
    temp, normal:integer;
    nx:integer;
    tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4:integer;
BEGIN
  For loop2:=1 to maxpolys do BEGIN
    loop1:=order[loop2];
    If (translated[loop1,1].z+zoff<0) and (translated[loop1,2].z+zoff<0)
       and (translated[loop1,3].z+zoff<0) and (translated[loop1,4].z+zoff<0)
       then BEGIN
      temp:=round (translated[loop1,1].z)+zoff;
      nx:=translated[loop1,1].X;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,YOfs
        mov   nx,ax
      end;
      tx1:=nx;
      nx:=translated[loop1,1].Y;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,XOfs
        mov   nx,ax
      end;
      ty1:=nx;


      temp:=round (translated[loop1,2].z)+zoff;
      nx:=translated[loop1,2].X;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,YOfs
        mov   nx,ax
      end;
      tx2:=nx;
      nx:=translated[loop1,2].Y;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,XOfs
        mov   nx,ax
      end;
      ty2:=nx;


      temp:=round (translated[loop1,3].z)+zoff;
      nx:=translated[loop1,3].X;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,YOfs
        mov   nx,ax
      end;
      tx3:=nx;
      nx:=translated[loop1,3].Y;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,XOfs
        mov   nx,ax
      end;
      ty3:=nx;


      temp:=round (translated[loop1,4].z)+zoff;
      nx:=translated[loop1,4].X;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,YOfs
        mov   nx,ax
      end;
      tx4:=nx;
      nx:=translated[loop1,4].Y;
      asm
        mov   ax,nx
        mov   dx,ax
        sal   ax,8
        sar   dx,8
        idiv  temp
        add   ax,XOfs
        mov   nx,ax
      end;
      ty4:=nx;

      normal:=(ty1-ty3)*(tx2-tx1)-(tx1-tx3)*(ty2-ty1);
      if normal<0 then
        drawpoly (tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4,loop1,vaddr);
    END;
  END;
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SortPoints;
VAR loop1,curpos, temp:integer;
BEGIN
  for loop1:=1 to maxpolys do BEGIN
    order[loop1]:=loop1;
  END;
  curpos := 1;
  while curpos<maxpolys do BEGIN
    if tcentre[curpos].z > tcentre[curpos+1].z then BEGIN
      temp := tcentre[curpos+1].x;
      tcentre[curpos+1].x := tcentre[curpos].x;
      tcentre[curpos].x := temp;

      temp := tcentre[curpos+1].y;
      tcentre[curpos+1].y := tcentre[curpos].y;
      tcentre[curpos].y := temp;

      temp := tcentre[curpos+1].z;
      tcentre[curpos+1].z := tcentre[curpos].z;
      tcentre[curpos].z := temp;

      temp := order[curpos+1];
      order[curpos+1] := order[curpos];
      order[curpos] := temp;

      curpos:=0;
    END;
    curpos:=curpos+1;
  END;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure MoveAround;
  { This is the main display procedure. }
VAR deg,deg2,loop1,loop2:integer;
    ch:char;

BEGIN
  pal (1,  0, 0,63);
  pal (2,  0,32,63);
  pal (3, 32, 0,63);
  pal (4, 32,32,63);
  pal (5,  0,63,63);
  pal (6, 32,63,63);

  pal ( 7,  0,63, 0);
  pal ( 8,  0,63,32);
  pal ( 9, 32,63, 0);
  pal (10, 32,63,32);
  pal (11,  0,63,63);
  pal (12, 32,63,63);

  pal (13, 63, 0, 0);
  pal (14, 63,32, 0);
  pal (15, 63, 0,32);
  pal (16, 63,32,32);
  pal (17, 63,63, 0);
  pal (18, 63,63,32);
{  for loop1:=1 to 15 do
    pal (loop1,0,loop1*4+3,63-(loop1*4+3));}
  pal (100,50,50,50);

  deg:=0;
  deg2:=0;
  ch:=#0;
  Cls (vaddr,0);
  For loop1:=1 to maxpolys do
    For loop2:=1 to 4 do BEGIN
      Lines [loop1,loop2].x:=a [loop1,loop2,1]*8;
      Lines [loop1,loop2].y:=a [loop1,loop2,2]*8;
      Lines [loop1,loop2].z:=a [loop1,loop2,3]*8;
    END;

  SetUpPoints;

  cls (vaddr,0);
  cls (vga,0);
  Xoff := 160;
  Yoff:=100;
  zoff:=-500;

  ytopclip:=101;
  ybotclip:=100;
  line (0,100,319,100,100,vga);
  delay (2000);
  for loop1:=1 to 25 do BEGIN
    RotatePoints (deg2,deg,deg2);
    SortPoints;
    DrawPoints;
    line (0,ytopclip,319,ytopclip,100,vaddr);
    line (0,ybotclip,319,ybotclip,100,vaddr);
    flip (vaddr,vga);
    cls (vaddr,0);
    deg:=(deg+5) mod 360;
    deg2:=(deg2+1) mod 360;
    ytopclip:=ytopclip-4;
    ybotclip:=ybotclip+4;
  END;
  Repeat
    if keypressed then ch:=upcase (Readkey);
    RotatePoints (deg2,deg,deg2);
    SortPoints;
    DrawPoints;
    line (0,0,319,0,100,vaddr);
    line (0,199,319,199,100,vaddr);
    flip (vaddr,vga);
    cls (vaddr,0);
    deg:=(deg+5) mod 360;
    deg2:=(deg2+3) mod 360;
  Until ch=#27;
  for loop1:=1 to 25 do BEGIN
    ytopclip:=ytopclip+4;
    ybotclip:=ybotclip-4;
    RotatePoints (deg2,deg,deg2);
    SortPoints;
    DrawPoints;
    line (0,ytopclip,319,ytopclip,100,vaddr);
    line (0,ybotclip,319,ybotclip,100,vaddr);
    flip (vaddr,vga);
    cls (vaddr,0);
    deg:=(deg+5) mod 360;
    deg2:=(deg2+1) mod 360;
  END;
END;


BEGIN
  clrscr;
  writeln ('Welcome to the twentieth(sp) trainer! This one is on face sorting');
  writeln ('and back face removal.');
  writeln;
  writeln ('Just hit a key to view the 3d shape. You will notice that you');
  writeln ('won''t see any of the faces you shouldn''t see :-)');
  writeln ('The code is based on that from the glenzing tut, so you should');
  writeln ('be able to understand it fairly quickly.');
  writeln;
  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  SetUpVirtual;
  SetMCGA;
  MoveAround;
  SetText;
  ShutDown;
  Writeln ('All done. This concludes the twentieth sample program in the ASPHYXIA');
  Writeln ('Training series. You may reach DENTHOR under the names of GRANT');
  Writeln ('SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS.I also occasinally');
  Writeln ('RSAProg, comp.lang.pascal and comp.sys.ibm.pc.demos. E-mail me at :');
  Writeln ('    denthor@goth.vironix.co.za');
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
