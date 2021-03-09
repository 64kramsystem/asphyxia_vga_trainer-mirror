(*
Well folks, here it is - the long awaited for Chain-4 trainer. The
routines are commented so I'm not going to say too much more here,
except a few things.

1: If ya don't understand this (not suprising its bloody cryptic!)
   then if ur serious go out and buy - Programming the EGA & VGA Cards
   I don't know who the book is by, so don't ask. Perhaps you know Greg?

2: The code is unoptimised. I wrote it specifically for this conf. and
   I'm buggered if I'm gonna give out my wholely (sp? ahh stuff it :-))
   optimised code. If you want it faster, OPTIMISE IT!!
   HINT: Its faster to load ax, with a low byte/high byte combination
         and out a word instead of a byte at a time. If u don't know
         what I'm talking about, too bad :-)

3: If you use/like/whatever this code, please give Asphyxia a mention.
   It wos bloody hard work figuring out how all this cr*p works, we
   couldn't have done it with out a little guidence (thanx Gregie Poo).

4: LiveWire got interested in the whole tut/trainer idea and MAY be
   putting together a doc on how the whole thing works, including
   Pel-Panning which I haven't included here.


5: Good luck with the code, and if you write anything with it, I'd
   appreciate having a look at it :-). Feel free to direct any comments
   about the code to me in this conf. Or at one of the contact addresses
   given in the code.


l8rs
EzE / Asphyxia



--------------------------------=[ Cut Here ]=-------------------------
*)
{$X+,G+}
Program Chain4_Tut;
Uses
   Crt;


Const
   Size : Byte = 80;


Var Loop : Integer;



Procedure Init_C4; Assembler;
Asm
   mov   ax, 0013h
   int   10h               { set up bios initially for 13h            }

   mov   dx, 03c4h         { Sequencer Address Register               }
   mov   al, 4             { Index 4 - Memory mode                    }
   out   dx, al            { select it.                               }
   inc   dx                { 03c5h - here we set the mem mode.        }
   in    al, dx            { get whats already inside the reg         }
   and   al, 11110111b     { un-set 4th bit - chain4                  }
   out   dx, al

   mov   dx, 3d4h
   mov   al, 13h           { Offset Register - allocates amt. mem for }
   out   dx, al            { 1 displayable line as - length div 8, so }
   inc   dx                { we use 80 (80*8) = 640 = 2 pages across  }
   mov   al, [Size]        { and cause of chain-4 i.e. 256k display   }
   out   dx, al            { mem, 2 pages down for four pages         }

                           { NOTE: setting AL above to 40 selects 1   }
                           { page across and four down (nice for      }
                           { 1942 type scrolling games) and setting   }
                           { AL to 160 selects 4 pages across and 1   }
                           { down, nice for horizontal scrolling      }

End;



Procedure Cls_C4; Assembler;
Asm
   mov   dx, 03c4h         { 03c4h                                    }
   mov   al, 2             { Map Mask Register                        }
   out   dx, al
   inc   dx
   mov   al, 00001111b     { Select all planes to write to            }
   out   dx, al            { Doing this to clear all planes at once   }

   mov   ax, 0a000h
   mov   es, ax
   xor   di, di            { set es:di = Screen Mem                   }
   mov   ax, 0000h         { colour to put = black                    }
   mov   cx, 32768         { 32768 (words) *2 = 65536 bytes - vga mem }
   cld
   rep   stosw             { clear it                                 }
End;



Procedure PutPixel_C4(X, Y : Integer; Col : Byte); Assembler;
Asm
   mov   ax, [Y]           { Y val multiplied by...                   }
   xor   bx, bx
   mov   bl, [Size]        { Size....                                 }
   shl   bx, 1             { *2 - just 'cause! (I can't remember why!)}
   mul   bx
   mov   bx, ax

   mov   ax, [X]
   mov   cx, ax
   shr   ax, 2
   add   bx, ax            { add X val div 4 (four planes)            }

   and   cx, 00000011b     { clever way of finding x mod 4, i.e.      }
   mov   dx, 03c4h         { which plane we're in.                    }
   mov   al, 2             { then use 03c4h index 2 - write plane sel.}
   out   dx, al            { to set plane to write to.                }
   mov   al, 1             { plane to write to = 1 shl (X mod 4)      }
   shl   al, cl
   inc   dx
   out   dx, al

   mov   ax, 0a000h
   mov   es, ax
   mov   al, [Col]
   mov   es: [bx], al      { then write pixel.                        }
End;


Function GetPixel_C4(X, Y : Integer): Byte; Assembler;
Asm
   mov   ax, [Y]           { Y val multiplied by...                   }
   xor   bx, bx
   mov   bl, [Size]        { Size....                                 }
   shl   bx, 1             { *2 - just 'cause! (I can't remember why!)}
   mul   bx
   mov   bx, ax

   mov   ax, [X]
   mov   cx, ax
   shr   ax, 2
   add   bx, ax            { add X val div 4 (four planes)            }

   and   cx, 00000011b     { clever way of finding x mod 4, i.e.      }
   mov   dx, 03c4h         { which plane we're in.                    }
   mov   al, 4h            { then use 03c4h index 4 - read plane sel. }
   out   dx, al            { to set plane to read from.               }
   mov   al, cl            { Plane to read from = X mod 4             }
   inc   dx
   out   dx, al

   mov   ax, 0a000h
   mov   es, ax
   mov   al, es: [bx]      { then return pixel read                   }
End;



Procedure MoveScr_C4(X,Y : Integer); Assembler;
Asm
   mov   ax, [Y]           { Y val multiplied by...                   }
   xor   bx, bx
   mov   bl, [Size]        { Size....                                 }
   shl   bx, 1             { *2 - just 'cause! (I can't remember why!)}
   mul   bx
   mov   bx, ax

   add   bx, [X]           { Add X val                                }

   mov   dx, 03d4h
   mov   al, 0ch           { CRTC address reg.                        }
   out   dx, al            { Start Address High Reg.                  }
   inc   dx
   mov   al, bh            { send high byte of start address.         }
   out   dx, al

   dec   dx
   mov   al, 0dh           { Start Address Low Reg.                   }
   out   dx, al
   inc   dx
   mov   al, bl            { send low byte of start address.          }
   out   dx, al

End;


Procedure SetText; Assembler;
Asm
   mov   ax, 0003h
   int   10h
End;

Procedure Creds;
Begin
   SetText;
   While KeyPressed do ReadKey;

   Asm
      mov   ah, 1
      mov   ch, 1
      mov   cl, 0
      int   10h
   End;

   WriteLn('Chain-4 Trainer...');
   WriteLn('By EzE of Asphyxia.');
   WriteLn;
   WriteLn('Contact Us on ...');
   WriteLn;
   WriteLn;
   WriteLn('the Asphyxia BBS (031) - 7655312');
   WriteLn;
   WriteLn('Email :       eze@');
   WriteLn('         asphyxia@');
   WriteLn('          edwards@');
   WriteLn('           bailey@');
   WriteLn('          mcphail@');
   WriteLn('                  beastie.cs.und.ac.za');
   WriteLn;
   WriteLn('or  peter.edwards@datavert.co.za');
   WriteLn;
   WriteLn('Write me snail-mail at...');
   WriteLn('P.O. Box 2313');
   WriteLn('Hillcrest');
   WriteLn('Natal');
   WriteLn('3650');
   Asm
      mov   ah, 1
      mov   ch, 1
      mov   cl, 0
      int   10h
   End;

End;




Begin
   Init_C4;
   Cls_C4;
   Repeat
      Putpixel_C4(Random(320),Random(200),Random(256)+1);
   Until KeyPressed;
   For Loop := 0 to 80 do
   begin
      MoveScr_C4(0,Loop);
      Delay(10);
   End;
   ReadKey;
   Loop := GetPixel_C4(100,100);
   Creds;
   WriteLn('Colour at location X:100, Y:100 was: ',Loop);
End.

--------------------------------=[ Cut Here ]=-------------------------