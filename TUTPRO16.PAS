{$X+}
USES crt,gfx2;

Type Pallette = Array [0..255,1..3] of byte;

VAR virscr2:virtptr;
    vaddr2:word;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure LoadCELPal (FileName : String; Var Palette : Pallette);
  { This loads in the pallette of the .CEL file into the variable Palette }
Var
  Fil : file;
Begin
  Assign (Fil, FileName);
  Reset (Fil, 1);
  Seek(Fil,32);
  BlockRead (Fil, Palette, 768);
  Close (Fil);
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Init;
VAR loop1,loop2:integer;
    tpal:pallette;
BEGIN
  getmem (virscr2,sizeof(virscr2^));
  vaddr2:=seg(virscr2^);
  cls (vaddr2,0);
  cls (vaddr,0);
  loadcelpal ('to.cel',tpal);
  for loop1:=0 to 255 do
    pal (loop1,tpal[loop1,1],tpal[loop1,2],tpal[loop1,3]);
  loadcel ('to.cel',virscr);
  for loop1:=0 to 319 do
    for loop2:=0 to 199 do
      if getpixel (loop1,loop2,vaddr)=0 then
        putpixel (loop1,loop2,(loop1+loop2) mod 256,vaddr);
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Scale (x,y,w,h,origw,origh,source,dest:word); assembler;
  { This scales the picture to the size of w and h, and places the result
    at x , y. Origw and origh are the origional width and height of the
    bitmap. The bitmap must start at the beginning of a segment, with
    source being the segment value. The image is placed in screen at dest}
VAR jx,jy,depth,temp:word;
asm
  push  ds

  mov   ax,source
  mov   ds,ax
  mov   ax,dest
  mov   es,ax
  mov   depth,0
  dec   h

  xor   dx,dx
  mov   ax,origw
  shl   ax,6
  mov   bx,w
  div   bx
  shl   ax,2
  mov   jx,ax     { jx:=origw*256/w }

  xor   dx,dx
  mov   ax,origh
  shl   ax,6
  mov   bx,h
  div   bx
  shl   ax,2
  mov   jy,ax     { jy:=origh*256/h }

  xor   cx,cx
@Loop2 :          { vertical loop }
  push  cx
  mov   ax,depth
  add   ax,jy
  mov   depth,ax

  xor   dx,dx
  mov   ax,depth
  shr   ax,8
  mov   bx,origw
  mul   bx
  mov   temp,ax   { temp:=depth shr 8*origw;}


  mov   di,y
  add   di,cx
  mov   bx,di
  shl   di,8
  shl   bx,6
  add   di,bx
  add   di,x      { es:di = dest ... di=(loop1+y)*320+x }

  mov   cx,w
  xor   bx,bx
  mov   dx,jx
  mov   ax,temp
@Loop1 :          { horizontal loop }
  mov   si,bx
  shr   si,8
  add   si,ax     { ax = temp = start of line }

  movsb           { si=temp+(si shr 8) }
  add   bx,dx

  dec   cx
  jnz   @loop1    { horizontal loop }

  pop   cx
  inc   cx
  cmp   cx,h
  jl    @loop2    { vertical loop }

  pop   ds
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Play;
VAR x,y,z,loop1:integer;
BEGIN
  z:=114;
  while keypressed do readkey;
  Repeat
    for loop1:=1 to 50 do BEGIN
      dec (z,2);
      x:=16 shl 8 div z;
      y:=10 shl 8 div z; { Perspective transforms ... makes the zoom smoother }
      cls (vaddr2,0);
      scale (160-(x shr 1),100-(y shr 1),x,y,320,200,vaddr,vaddr2);
      flip (vaddr2,vga);
    END;   { Scale towards you }
    for loop1:=1 to 50 do BEGIN
      inc (z,2);
      x:=16 shl 8 div z;
      y:=10 shl 8 div z; { Perspective transforms ... makes the zoom smoother }
      cls (vaddr2,0);
      scale (160-(x shr 1),100-(y shr 1),x,y,320,200,vaddr,vaddr2);
      flip (vaddr2,vga);
    END;   { Scale away from you }
  Until keypressed;
  while keypressed do readkey;
END;

BEGIN
  clrscr;
  writeln ('Hokay! Here is the sixteenth tutorial! This one is on nice fast 2d');
  writeln ('scaling, for any size bitmap. Just hit any key and it will scale a');
  writeln ('picture up and down. Clipping is NOT performed, so the destination');
  writeln ('pic MUST fit in the screen boundaries. In one zoom towards and away');
  writeln ('from you there is 100 frames.');
  writeln;
  Writeln ('You can make many nice effects with scaling, this "bouncing" is just');
  writeln ('one of them ... go on, amaze everyone with your ingenuity ;-) Also,');
  writeln ('why not test your coding mettle, so to speak, by implementing clipping?');
  Writeln;
  writeln ('The routine could greatly be speeded up with 386 extended registers, but');
  writeln ('for the sake of compatability I have kept it to 286 code. Also, this');
  writeln ('routine isn''t fully optimised .. you may be able to get some speedups');
  writeln ('out of it... (probably by moving the finding of DI out of the loop and');
  writeln ('just adding a constant for each line ... hint hint) ;)');
  writeln;
  writeln ('The pic was drawn by me for Tut11, I am reusing it because I am at varsity..');
  writeln ('without a mouse. :(');
  writeln;
  writeln;
  writeln ('Hit any key to continue ... ');
  readkey;
  setupvirtual;
  setmcga;
  init;
  play;
  settext;
  shutdown;
  freemem (virscr2,sizeof(virscr2^));
  Writeln ('All done. This concludes the sixteenth sample program in the ASPHYXIA');
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
