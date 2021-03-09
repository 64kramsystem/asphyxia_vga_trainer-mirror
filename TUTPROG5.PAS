{$X+} {$R-}
Uses Crt;

CONST VGA = $a000;
      XSize = 16;
      YSize = 16;

TYPE
        Letter = Array[1..xsize,1..ysize] of Byte;
        Letters = Array[' '..']'] of Letter;

VAR Font : ^Letters;

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
  { This waits until you are in a Verticle Retrace }

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
Procedure PutPixel (X,Y : Integer; Col : Byte; Where : Word);
   { This puts a pixel at X,Y using color col, on VGA or the Virtual Screen}
BEGIN
  Mem [Where:X+(Y*320)]:=col;
END;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure LoadPal (FileName : string);
   { This loads the Pallette file and puts it on screen }
type DACType = array [0..255] of record
                                R, G, B : byte;
                              end;
var DAC : DACType;
    Fil : file of DACType;
    I : integer;
BEGIN
  assign (Fil, FileName);
  reset (Fil);
  read (Fil, DAC);
  close (Fil);
  for I := 0 to 255 do Pal(I,Dac[I].R,Dac[I].G,Dac[I].B);
end;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
function Exist(FileName: string): Boolean;
    { Checks to see if filename exits or not }
var f: file;
begin
  {$I-}
  Assign(f, FileName);
  Reset(f);
  Close(f);
  {$I+}
  Exist := (IOResult = 0) and
   (FileName <> '');
end;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Setup;
  { This loads the font and the pallette }
VAR f:file;
    loop1:char;
    loop2,loop3:integer;
BEGIN
  getmem (font,sizeof (font^));
  If exist ('softrock.fnt') then BEGIN
    Assign (f,'softrock.fnt');
    reset (f,1);
    blockread (f,font^,sizeof (font^));
    close (f);
    Writeln ('SoftRock.FNT from TEXTER5 found in current directory. Using.');
  END
  ELSE BEGIN
    Writeln ('SoftRock.FNT from TEXTER5 not found in current directory.');
    For loop1:=' ' to ']' do
      For loop2:=1 to 16 do
        for loop3:=1 to 16 do
          font^[loop1,loop2,loop3]:=loop2;
  END;
  If exist ('pallette.col') then
    Writeln ('Pallette.COL from TEXTER5 found in current directory. Using.')
  ELSE
    Writeln ('Pallette.COL from TEXTER5 not found in current directory.');
  Writeln;
  Writeln;
  Write ('Hit any key to continue ...');
  readkey;
  setmcga;
  If exist ('pallette.col') then loadpal ('pallette.col');
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure ScrollMsg (Msg : String);
  { This scrolls the string in MSG across the screen }
Var Loop1,loop2,loop3 : Integer;
Begin
  For loop1:=1 to length (msg) do BEGIN
    For loop2:=1 to xsize do BEGIN

      { This bit scrolls the screen by one then puts in the new row of
        letters }

      waitretrace;
      For Loop3 := 100 to 99+ysize do
        move (mem[vga:1+(loop3*320)],mem[vga:(loop3*320)],319);
      for loop3:=100 to 99+ysize do
        putpixel (319,loop3,font^[msg[loop1],loop2,loop3-99],vga);
           { Change the -99 above to the minimum of loop3-1, which you
             will change in order to move the position of the scrolly }
    END;

    {This next bit scrolls by one pixel after each letter so that there
      are gaps between the letters }

    waitretrace;
    For Loop3 := 100 to 99+ysize do
      move (mem[vga:1+(loop3*320)],mem[vga:(loop3*320)],319);
      for loop3:=100 to 99+ysize do
        putpixel (319,loop3,0,vga);
  END;
End;


BEGIN
  ClrScr;
  Writeln ('This program will give you an example of a scrolly. If the file');
  Writeln ('SOFTROCK.FNT is in the current directory, this program will scroll');
  Writeln ('letters, otherwise it will only scroll bars. It also searches for');
  Writeln ('PALLETTE.COL, which it uses for it''s pallette. Both SOFTROCK.FNT');
  Writeln ('and PALLETTE.COL come with TEXTER5.ZIP, at a BBS near you.');
  Writeln;
  Writeln ('You will note that you can change what the scrolly says merely by');
  Writeln ('changing the string in the program.');
  Writeln;
  Setup;
  repeat
    ScrollMsg ('ASPHYXIA RULZ!!!   ');
  until keypressed;
  Settext;
  freemem (font, sizeof (font^));
  Writeln ('All done. This concludes the fifth sample program in the ASPHYXIA');
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
