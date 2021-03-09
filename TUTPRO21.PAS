{$X+}
USES Crt,GFX3;

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

     Pictype = array [0..127,0..127] of byte;


VAR Lines : Array [1..maxpolys,1..4] of Point; { The base object to be rotated }
    Translated : Array [1..maxpolys,1..4] of Point; { The rotated object }
    centre, tcentre : Array [1..maxpolys] of Point;
    Order : Array[1..maxpolys] of integer;
    lookup : Array [0..360,1..2] of integer; { Our sin and cos lookup table }
    poly : array [0..199,1..2] of integer;
    ytopclip,ybotclip:integer;  {where to clip our polys to}
    xoff,yoff,zoff:integer;

    pic : ^pictype;
    lefttable : array [-200..400,0..2] of integer;
    righttable : array [-200..400,0..2] of integer;


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

Procedure LoadGFX;
  { This loads up our texture }
VAR f1 : File;
    bob : array [0..255, 1..3] of byte;
    loop1 : Integer;
BEGIN
  getmem (pic,sizeof(pic^));
  loadcel ('side1.cel',pic);

  assign (f1, 'side1.cel');
  reset (f1, 1);
  seek (f1, 32);
  blockread (f1, bob, 768);
  close (f1);
  for loop1:=0 to 255 do
    Pal (loop1, bob[loop1,1], bob[loop1,2], bob[loop1,3]);
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


Procedure TextureMapPoly (x1,y1,x2,y2,x3,y3,x4,y4:integer;where:word);
  { The main procedure, contains various nested procedures }
VAR miny, maxy, loop1 : integer;

Procedure scanleftside (x1,x2,ytop,lineheight:integer;side:byte);
  { Scan in our needed variables ... X on the left, texturmap X, texturemap Y}
VAR x,px,py,xadd,pxadd,pyadd:integer;
    y:integer;
BEGIN
  lineheight:=lineheight+1;
  xadd:=(x2-x1) shl 7 div lineheight;
  if side = 1 then BEGIN
    px:=(127-1) shl 7;
    py:=0;
    pxadd:=(-127 shl 7) div lineheight;
    pyadd:=0;
  END;
  if side = 2 then BEGIN
    px:=127 shl 7;
    py:=127 shl 7;
    pxadd:=0;
    pyadd:=(-127 shl 7) div lineheight;
  END;
  if side = 3 then BEGIN
    px:=0;
    py:=127 shl 7;
    pxadd:=127 shl 7 div lineheight;
    pyadd:=0;
  END;
  if side = 4 then BEGIN
    px:=0;
    py:=0;
    pxadd:=0;
    pyadd:=127 shl 7 div lineheight;
  END;
  x:=x1 shl 7;
  for y:=0 to lineheight do BEGIN
    lefttable[ytop+y,0]:=x shr 7;
    lefttable[ytop+y,1]:=px shr 7;
    lefttable[ytop+y,2]:=py shr 7;
    x:=x+xadd;
    px:=px+pxadd;
    py:=py+pyadd;
  END;
END;

Procedure scanrightside (x1,x2,ytop,lineheight:integer;side:byte);
  { Scan in our needed variables ... X on the right, texturmap X, texturemap Y}
VAR x,px,py,xadd,pxadd,pyadd:integer;
    y:integer;
BEGIN
  lineheight:=lineheight+1;
  xadd:=(x2-x1) shl 7 div lineheight;
  if side = 1 then BEGIN
    px:=0;
    py:=0;
    pxadd:=127 shl 7 div lineheight;
    pyadd:=0;
  END;
  if side = 2 then BEGIN
    px:=127 shl 7;
    py:=0;
    pxadd:=0;
    pyadd:=127 shl 7 div lineheight;
  END;
  if side = 3 then BEGIN
    px:=127 shl 7;
    py:=127 shl 7;
    pxadd:=(-127) shl 7 div lineheight;
    pyadd:=0;
  END;
  if side = 4 then BEGIN
    px:=0;
    py:=127 shl 7;
    pxadd:=0;
    pyadd:=(-127) shl 7 div lineheight;
  END;
  x:=x1 shl 7;
  for y:=0 to lineheight do BEGIN
    righttable[ytop+y,0]:=x shr 7;
    righttable[ytop+y,1]:=px shr 7;
    righttable[ytop+y,2]:=py shr 7;
    x:=x+xadd;
    px:=px+pxadd;
    py:=py+pyadd;
  END;
END;


Procedure Texturemap;
  { This uses the tables we have created to actually draw the texture }
VAR px1,py1:integer;
    px2,py2:integer;
    polyx1,polyx2,y,linewidth:integer;
    pxadd,pyadd:integer;
    bob, twhere :word;
BEGIN
  bob:=seg (pic^);
  tWhere := Where;      { ds is used elsewhere ... variables are not accessable }
  if miny<0 then miny:=0;
  if maxy>199 then maxy:=199;
  if miny<ytopclip then miny:=ytopclip;
  if maxy>ybotclip then maxy:=ybotclip;
  if maxy-miny<2 then exit;
  if miny>199 then exit;
  if maxy<0 then exit;
  for y:=miny to maxy do BEGIN
    polyx1:=lefttable[y,0];      { X Starting position }
    px1:=lefttable[y,1] shl 7;   { Texture X at start  }
    py1:=lefttable[y,2] shl 7;   { Texture Y at stary  }
    polyx2:=righttable[y,0];     { X Ending position   }
    px2:=righttable[y,1] shl 7;  { Texture X at end    }
    py2:=righttable[y,2] shl 7;  { Texture Y at end    }
    linewidth:=polyx2-polyx1;    { Width of line }
    if linewidth<=0 then linewidth:=1;
    pxadd:=(px2-px1) div linewidth;
    pyadd:=(py2-py1) div linewidth;
      asm
        push    ds
        mov     bx,polyx1
        mov     di,bx

        mov     dx,[Y]
        mov     bx, dx
        shl     dx, 8
        shl     bx, 6
        add     dx, bx
        add     di, dx
        mov     ax,twhere        { es:di points to start of line }
        mov     es,ax

        mov     bx, px1

        mov     cx,lineWidth
        mov     dx, bob
        mov     ds, dx

        mov     dx,py1
@Loop1 :
        xor     si,si
        mov     ax,bx
        and     ax,1111111110000000b;   { Get rid of fixed point }
        add     si,ax
        mov     ax,dx
        shr     ax,7
        add     si,ax           { get the pixel in our texture }
        movsb                   { draw the pixel to the screen }
        mov     ax,pxadd
        add     bx,ax
        mov     ax,pyadd
        add     dx,ax           { increment our position in the texture }
        loop    @loop1
        pop     ds
      end;
  END;
END;

BEGIN
  miny:=32767;
  maxy:=0;

  if y1<miny then miny:=y1;
  if y1>maxy then maxy:=y1;
  if y2<miny then miny:=y2;
  if y2>maxy then maxy:=y2;
  if y3<miny then miny:=y3;
  if y3>maxy then maxy:=y3;
  if y4<miny then miny:=y4;
  if y4>maxy then maxy:=y4;

  if miny>maxy-5 then exit;     { Why paint slivers? }

  if (y2<y1) then
    scanleftside (x2,x1,y2,y1-y2,1)
  else
    scanrightside (x1,x2,y1,y2-y1,1);
  { If point2.y is above point1.y, Point1 to Point2 is on the "left",
    and our leftside array must be altered }

  if (y3<y2) then
    scanleftside (x3,x2,y3,y2-y3,2)
  else
    scanrightside (x2,x3,y2,y3-y2,2);

  if (y4<y3) then
    scanleftside (x4,x3,y4,y3-y4,3)
  else
    scanrightside (x3,x4,y3,y4-y3,3);

  if (y1<y4) then
    scanleftside (x1,x4,y1,y4-y1,4)
  else
    scanrightside (x4,x1,y4,y1-y4,4);

  texturemap;
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
        TextureMapPoly (tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4,vaddr);
{        drawpoly (tx1,ty1,tx2,ty2,tx3,ty3,tx4,ty4,loop1,vaddr);}
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
  LoadGFX;

  cls (vaddr,0);
  cls (vga,0);
  Xoff := 160;
  Yoff:=100;
  zoff:=-600;

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
  writeln ('Welcome to the twenty first trainer! This one is on texure mapping.');
  writeln;
  writeln ('Just sit bak and watch, it''s non interactive. Total reuse of Tut 20''s');
  writeln ('code, aside from the texure mapping procedure. Have fun!');
  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  SetUpVirtual;
  SetMCGA;
  MoveAround;
  SetText;
  ShutDown;
  Writeln ('All done. This concludes the twenty first sample program in the ASPHYXIA');
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
