USES fpack,crt;

BEGIN
  total:=1;
  infodat[1]:='grim.pcx';
  asm
    mov   ax,0013h
    int   10h
  end;

  loadpcx (1,$a000,true);
  readkey;

  asm
    mov   ax,0003h
    int   10h
  end;
END.
