Uses Crt,GFX;

Const Size : Byte = 80;      { Size =  40 = 1 across, 4 down }
                             { Size =  80 = 2 across, 2 down }
                             { Size = 160 = 4 across, 1 down }

      bit : Array [1..897] of byte = (
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,33,2,151,5,149,6,148,7,147,8,49,2,95,8,49,
4,93,9,49,3,93,4,2,3,49,4,92,4,3,3,48,4,92,4,3,4,48,4,91,4,4,3,48,4,92,4,3,4,
48,3,58,2,32,4,4,4,47,4,57,3,31,4,5,3,48,3,57,4,30,4,5,4,47,3,57,5,29,4,6,4,46,
4,57,4,29,4,7,3,47,3,58,2,30,4,7,4,46,4,90,4,7,4,46,3,90,4,8,4,27,2,16,3,90,4,
8,9,22,3,16,3,89,4,5,13,8,6,8,3,15,3,90,4,2,15,6,10,6,3,16,3,6,1,21,1,9,2,7,1,
21,6,14,18,9,5,2,4,5,4,1,4,10,3,4,5,10,2,7,3,8,2,5,3,9,3,7,8,13,13,1,4,9,4,5,3,
5,3,1,6,9,3,3,6,9,4,5,4,8,3,3,4,9,3,6,9,11,10,6,4,8,4,6,3,4,11,8,3,2,7,9,5,4,4,
9,3,2,4,9,3,6,4,4,2,8,10,9,4,7,4,6,3,5,5,3,3,8,3,1,8,8,5,4,5,8,3,3,3,9,4,5,4,5,
2,5,10,12,4,7,3,5,5,4,5,4,3,7,3,1,4,1,3,9,4,5,4,9,3,2,3,10,3,6,3,5,3,4,10,13,3,
8,3,2,7,5,4,5,3,7,7,1,3,9,4,5,5,9,3,1,3,10,3,6,3,5,4,4,5,1,4,12,4,8,3,2,5,6,4,
5,4,6,6,2,4,8,4,5,5,10,6,10,4,5,4,5,3,5,2,3,4,13,4,8,3,3,1,9,3,6,3,7,5,3,3,5,1,
3,3,5,5,4,2,5,5,11,3,6,3,5,4,10,3,14,4,8,3,12,3,6,4,6,5,3,3,5,2,2,4,4,6,4,2,5,
5,6,1,3,4,5,3,6,3,10,4,14,4,5,1,2,4,11,3,6,3,7,5,3,3,4,3,1,4,4,6,4,3,5,4,6,2,3,
3,6,3,5,4,9,4,15,3,5,2,3,4,9,3,6,4,7,4,3,3,5,2,2,3,4,7,3,3,6,3,6,3,2,4,5,4,5,3,
10,3,15,4,4,3,4,3,9,3,6,3,7,4,4,3,4,3,1,4,3,3,1,3,3,3,6,4,6,2,3,3,6,3,5,4,9,4,
15,4,4,3,4,4,7,3,6,4,7,4,3,3,4,3,2,3,3,3,2,3,2,4,5,5,5,3,2,4,6,3,5,4,8,4,16,4,
4,2,6,3,7,3,5,4,7,4,4,3,3,3,3,8,2,3,2,4,5,6,4,3,3,3,7,3,4,5,8,4,16,4,4,2,6,3,6,
3,5,4,8,3,5,8,3,9,2,3,1,4,6,6,3,3,4,3,7,3,3,6,7,4,17,4,4,3,5,3,6,3,4,4,9,3,5,8,
3,7,3,8,6,3,1,4,1,4,3,4,7,3,2,3,1,3,7,4,17,4,4,3,5,3,5,11,9,3,6,7,4,6,4,7,6,3,
2,8,4,3,8,7,2,3,6,4,18,3,5,4,3,4,5,10,10,3,6,6,6,4,4,6,7,3,4,6,5,3,8,7,2,4,4,4,
19,3,5,10,5,3,1,6,11,3,7,3,16,5,7,4,4,5,6,3,8,6,3,5,3,4,19,3,6,9,5,3,18,2,25,5,
9,3,6,3,7,2,10,3,6,4,3,3,20,3,8,5,6,3,44,6,10,2,39,3,3,2,22,2,19,3,43,7,101,3,
42,8,102,3,41,4,1,4,101,4,39,5,2,3,102,3,39,4,4,3,102,3,38,4,4,4,101,3,38,4,5,
3,102,3,37,4,5,4,101,4,36,4,6,3,102,3,37,3,6,4,102,3,36,4,6,3,102,3,37,3,6,3,
103,3,37,3,5,4,102,4,37,3,4,4,103,3,38,10,104,3,38,9,105,2,40,7,106,2,41,4,0);


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
Procedure Putpic (x,y:integer);
  { This put's the picture at coordinates x,y on the chain-4 screen }
Var loop1,loop2:integer;
    depth,cur:integer;
BEGIN
   depth:=1;
   cur:=0;
   For loop1:=1 to 897 do BEGIN
     for loop2:=1 to bit [loop1] do BEGIN
       if cur<>0 then c4putpixel ((depth mod 155)+x,(depth div 155)+y,depth div 155);
       inc (depth);
     END;
     cur:=(cur+1) mod 2;
   END;
END;


Procedure Play;
Var loop1,loop2:integer;
    xpos,ypos,xdir,ydir:integer;
    ch:char;
Begin
   for loop1:=1 to 62 do
     pal (loop1,loop1,0,62-loop1); { This sets up the pallette for the pic }

   MoveTo(0,0); { This moves the view to the top left hand corner }

   for loop1:=0 to 3 do
     for loop2:=0 to 5 do
       putpic (loop1*160,loop2*66); { This places the picture all over the
                                      chain-4 screen }
   readkey;
   ch:=#0;
   xpos:=random (78)+1;
   ypos:=random (198)+1; { Random start positions for the view }
   xdir:=1;
   ydir:=1;
   repeat
     moveto (xpos,ypos);
     waitretrace;          { Take this out and watch the screen go crazy! }
     xpos:=xpos+xdir;
     ypos:=ypos+ydir;
     if (xpos>79) or (xpos<1) then xdir:=-xdir;
     if (ypos>199) or (ypos<1) then ydir:=-ydir;  { Hit a boundry, change
                                                    direction! }
     if keypressed then ch:=readkey;
   until ch=#27;  { Quit when escape is pressed }
End;


BEGIN
  clrscr;
  writeln ('Hello there! Here is the tenth tutorial, on Chain-4! You will notice');
  writeln ('that there are two pascal files here : one is a unit containing all');
  writeln ('our base graphics routines, and one is the demo program.');
  writeln;
  writeln ('In the demo program, we will do the necessary port stuff to get into');
  writeln ('Chain-4. Once in Chain-4 mode, I will put down text saying ASPHYXIA');
  writeln ('over the entire screen. After a key is pressed, the viewport will');
  writeln ('bounce around, displaying the entire Chain-4 screen. The program will');
  writeln ('end when [ESC] is pressed. The code here is really basic (except for');
  writeln ('those port values), and should be very easy to understand.');
  writeln;
  writeln;
  Write ('  Hit any key to contine ...');
  Readkey;
  initChain4;
  play;
  SetText;
  Writeln ('All done. This concludes the tenth sample program in the ASPHYXIA');
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