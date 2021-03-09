{$X+}   (* This is a handy little trick to know. If you put this at the top
           of your program, you do not have to set a variable when calling
           a function, i.e. you may just say 'READKEY' instead of
           'CH:=READKEY'                                                *)

USES Crt;           (* This has a few nice functions in it, such as the
                       READKEY command.                                 *)

CONST VGA = $a000;  (* This sets the constant VGA to the segment of the
                       VGA screen.                                      *)

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
  Fillchar (Mem [$a000:0],64000,col);
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure INTPutpixel (X,Y : Integer; Col : Byte);
   { This puts a pixel on the screen using interrupts. }
BEGIN
  asm
     mov        ah,0Ch
     mov        al,[col]
     mov        cx,[x]
     mov        dx,[y]
     mov        bx,[1]
     int        10h
  end;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TestINTPutpixel;
   { This tests out the speed of the INTPutpixel procedure. }
VAR loop1,loop2 : Integer;
BEGIN
  For loop1:=0 to 319 do
    For loop2:=0 to 199 do
      INTPutpixel (loop1,loop2,Random (256));
  Readkey;
  Cls (0);
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure MEMPutpixel (X,Y : Integer; Col : Byte);
  { This puts a pixel on the screen by writing directly to memory. }
BEGIN
  Mem [VGA:X+(Y*320)]:=Col;
END;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure TestMEMPutpixel;
   { This tests out the speed of the MEMPutpixel procedure. }
VAR loop1,loop2 : Integer;
BEGIN
  For loop1:=0 to 319 do
    For loop2:=0 to 199 do
      MEMPutpixel (loop1,loop2,Random (256));
  Readkey;
  Cls (0);
END;



{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
BEGIN    (* Of the main program *)
  ClrScr;               { This clears the text Screen (CRT unit) }
  Writeln ('What will happen is that I will clear the screen twice. After');
  Writeln ('each clear screen you will have to hit a key. I will then fill');
  Writeln ('the screen twice with randomlly colored pixels using two different');
  Writeln ('methoods, after each of which you will have to hit a key. I will');
  Writeln ('then return you to text mode.');
  Writeln; Writeln;
  Write ('Hit any kay to continue ...');
  Readkey;

  SetMCGA;
  CLS (32);
  Readkey;
  CLS (90);
  Readkey;
  TestINTPutpixel;
  TestMEMPutpixel;
  SetText;

  Writeln ('All done. This concludes the first sample program in the ASPHYXIA');
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
END.     (* Of the main program *)