{$X+}
USES GFX2,crt;  { Please use the GFX2 unit from now on! The GFX unit had
                  quite a big bug in it, and less routines... }

Type Pallette = Array [0..255,1..3] of byte;

VAR source,dest:Pallette;
    VirScr2 : VirtPtr;                     { Our second Virtual screen }
    Vaddr2 : Word;                      { The segment of our 2nd virt. screen}
    dir:boolean;     { Fade up or fade down? }
    loop1:integer;

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
  { We get memory for our pointers here }
BEGIN
  fillchar (source,sizeof(source),0);
  fillchar (dest,sizeof(dest),0);
  GetMem (VirScr2,64000);
  vaddr2 := seg (virscr2^);
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure SetItUp;
  { We define our third screen here }
VAR loop1,loop2,loop3:integer;
    pal1,pal2:pallette;
    change:boolean;
    where:integer;
    r,g,b,r1,g1,b1:byte;
BEGIN
  cls (vaddr2,0);

  For loop1:=0 to 255 do
    pal (loop1,0,0,0);

  loadcel ('to.cel',virscr);
  loadcelpal ('to.cel',pal2);
  flip (vaddr,vga);
  loadcel ('from.cel',virscr);
  loadcelpal ('from.cel',pal1);

  where:=0;

  For loop1:=0 to 319 do
    for loop2:=0 to 199 do BEGIN
      if (getpixel(loop1,loop2,vaddr)<>0) or (getpixel (loop1,loop2,vga)<>0) then BEGIN
        change:=false;
        r:=pal1[getpixel(loop1,loop2,vaddr),1];
        g:=pal1[getpixel(loop1,loop2,vaddr),2];
        b:=pal1[getpixel(loop1,loop2,vaddr),3];
        r1:=pal2[getpixel(loop1,loop2,vga),1];
        g1:=pal2[getpixel(loop1,loop2,vga),2];
        b1:=pal2[getpixel(loop1,loop2,vga),3];

        for loop3:=0 to where do
          if (source[loop3,1]=r) and (source[loop3,2]=g) and (source[loop3,3]=b) and
             (dest[loop3,1]=r1) and (dest[loop3,2]=g1) and (dest[loop3,3]=b1) then BEGIN
             putpixel (loop1,loop2,loop3,vaddr2);
             change:=TRUE;
          END;
          { Here we check that this combination hasn't occured before. If it
            has, put the appropriate pixel onto the third screen (vaddr2) }

        if not (change) then BEGIN
          inc (where);
          if where=256 then BEGIN
            settext;
            writeln ('Pictures have too many colors! Squeeze then retry!');
            Halt;
            { There were too many combinations of colors. Alter picture and
              then retry }
          END;
          putpixel(loop1,loop2,where,vaddr2);
          source[where,1]:=pal1[getpixel(loop1,loop2,vaddr),1];
          source[where,2]:=pal1[getpixel(loop1,loop2,vaddr),2];
          source[where,3]:=pal1[getpixel(loop1,loop2,vaddr),3];
          dest[where,1]:=pal2[getpixel(loop1,loop2,vga),1];
          dest[where,2]:=pal2[getpixel(loop1,loop2,vga),2];
          dest[where,3]:=pal2[getpixel(loop1,loop2,vga),3];
            { Create a new color and set it's from and to pallette values }
        END;
      END;
    END;
  cls (vga,0);
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Crossfade (direction:boolean;del,farin:word);
  { This fades from one picture to the other in the direction specified
    with a del delay. It crossfades one degree for every value in farin.
    If farin=63, then a complete crossfade occurs }
VAR loop1,loop2:integer;
    temp:pallette;
BEGIN
  if direction then BEGIN
    temp:=source;
    for loop1:=0 to 255 do
      pal (loop1,source[loop1,1],source[loop1,2],source[loop1,3]);
    flip (vaddr2,vga);
    For loop1:=0 to farin do BEGIN
      waitretrace;
      for loop2:=0 to 255 do
        pal (loop2,temp[loop2,1],temp[loop2,2],temp[loop2,3]);
      for loop2:=0 to 255 do BEGIN
        if temp[loop2,1]<dest[loop2,1] then inc (temp[loop2,1]);
        if temp[loop2,1]>dest[loop2,1] then dec (temp[loop2,1]);
        if temp[loop2,2]<dest[loop2,2] then inc (temp[loop2,2]);
        if temp[loop2,2]>dest[loop2,2] then dec (temp[loop2,2]);
        if temp[loop2,3]<dest[loop2,3] then inc (temp[loop2,3]);
        if temp[loop2,3]>dest[loop2,3] then dec (temp[loop2,3]);
          { Move temp (the current pallette) from source to dest }
      END;
      delay (del);
    END;
  END
  else BEGIN
    temp:=dest;
    for loop1:=0 to 255 do
      pal (loop1,dest[loop1,1],dest[loop1,2],dest[loop1,3]);
    flip (vaddr2,vga);
    For loop1:=0 to farin do BEGIN
      waitretrace;
      for loop2:=0 to 255 do
        pal (loop2,temp[loop2,1],temp[loop2,2],temp[loop2,3]);
      for loop2:=0 to 255 do BEGIN
        if temp[loop2,1]<source[loop2,1] then inc (temp[loop2,1]);
        if temp[loop2,1]>source[loop2,1] then dec (temp[loop2,1]);
        if temp[loop2,2]<source[loop2,2] then inc (temp[loop2,2]);
        if temp[loop2,2]>source[loop2,2] then dec (temp[loop2,2]);
        if temp[loop2,3]<source[loop2,3] then inc (temp[loop2,3]);
        if temp[loop2,3]>source[loop2,3] then dec (temp[loop2,3]);
          { Move temp (the current pallette) from dest to source }
      END;
      delay (del);
    END;
  END
END;

BEGIN
  clrscr;
  writeln ('Hello there! This trainer program is on cross fading. What will happen');
  writeln ('is this : The program will load in two .CEL files, FROM.CEL and TO.CEL');
  writeln ('into the virtual screen at vaddr and to the VGA screen. The pallettes');
  writeln ('of these two pictures are loaded into pal1 and pal2. Note that you');
  writeln ('could easily rewrite this to load in other types of files if you do');
  writeln ('not own Autodesk Animator to draw your files (The pictures presented');
  writeln ('here were drawn by Fubar, sqeezed by me ;)). A third screen is then');
  Writeln ('generated into vaddr2 (this takes 5-10 seconds on my 386-40). Note');
  writeln ('that you could dump vaddr2 to disk as a file instead of calculating it');
  writeln ('each time...it would be faster and be half the size of the two pictures.');
  Writeln ('The picture will then crossfade between the two. Hit a key and it will');
  writeln ('crossfade halfway and then exit.');
  writeln;
  writeln ('After one particular comment E-Mailed to me, I thought I should just add');
  writeln ('this : I am not an employee of Autodesk, and they do not pay me to promote');
  writeln ('their product. You have no idea how much I wish they would :)  I recieve');
  writeln ('absolutely _nothing_ for writing the trainer...');
  writeln;
  writeln;
  write ('Hit any key to continue ...');
  readkey;
  randomize;
  setupvirtual;
  setmcga;
  init;
  SetItUp;
  for loop1:=0 to 255 do
    pal (loop1,source[loop1,1],source[loop1,2],source[loop1,3]);
  flip (vaddr2,vga);
  delay (3000);

  dir:=TRUE;
  while keypressed do readkey;
  repeat
    crossfade(dir,20,63);
    dir:=not (dir);
    delay (1000);
  until keypressed;
  Readkey;
  crossfade(dir,20,20);
  readkey;
  settext;
  Writeln ('All done. This concludes the eleventh sample program in the ASPHYXIA');
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
  shutdown;
  FreeMem (VirScr2,64000);
END.