/*
  tut7.c
  10/30/94
  from tutprog7.pas
  Adapted from Denthor's tutprog7.pas
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut7.c
           to compile this program.
*/

#include "tutheadr.h"

struct toastinfo
{
  int x;
  int y;
  int speed;
  int frame;
  int active;
} toaster[10];

char ourpal[256][3];

char frame1[30*48]={
0,0,0,0,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,5,5,
7,7,7,7,0,0,0,0,0,0,0,5,5,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,
5,7,7,7,7,7,7,7,8,8,7,7,7,7,7,7,0,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,
0,0,0,0,0,5,5,7,7,7,7,7,8,8,7,8,8,7,8,7,8,7,7,7,5,8,8,8,8,5,5,5,5,5,5,5,5,5,5,5,
5,0,0,0,0,0,0,0,0,0,0,0,5,7,7,7,7,7,7,8,7,7,7,8,7,7,7,7,7,7,0,0,0,0,0,0,8,5,5,5,
5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,5,7,7,8,8,7,7,8,7,7,8,7,7,7,7,7,0,0,0,0,0,
0,0,0,0,0,0,5,5,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,5,7,8,8,8,7,7,8,7,7,8,7,7,7,
7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,5,7,8,8,8,7,7,
8,8,8,8,8,8,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,
9,5,7,8,8,8,8,8,7,7,8,8,7,7,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,
1,1,1,1,9,9,9,9,5,7,7,8,8,8,8,7,7,8,8,7,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,
1,1,0,0,0,1,1,1,1,1,1,1,9,9,9,5,7,8,8,7,7,8,8,7,8,8,8,7,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,5,7,8,8,7,7,7,7,8,8,7,7,7,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,7,8,8,8,8,8,8,8,7,
7,7,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,7,
7,7,7,7,7,7,7,7,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,
1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,
1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,
2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,
2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,
1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,4,
4,6,6,6,6,6,6,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,3,3,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,
9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,
9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,
1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
char frame2[30*48]={
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,
9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,
1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,
1,1,0,0,0,1,1,1,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,
2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,5,
5,5,5,5,5,5,5,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,
1,1,1,2,2,2,2,2,5,5,5,5,5,5,5,5,5,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,
1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,5,5,5,5,5,5,5,5,5,2,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,5,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,5,5,5,5,5,5,5,5,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,5,5,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,5,5,5,5,
5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,
2,2,2,2,2,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,5,1,1,1,1,1,1,0,0,0,1,1,1,
1,1,1,2,2,2,2,2,2,2,2,2,2,2,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,5,1,7,1,4,
4,6,6,6,6,6,6,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,
0,0,0,5,5,1,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,5,5,5,5,5,5,5,5,0,0,
0,0,0,0,0,0,0,0,0,0,0,5,5,1,1,1,1,1,1,1,1,1,3,3,1,1,1,1,9,9,9,9,9,9,9,9,9,9,5,5,
5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,
9,9,9,9,9,9,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,
1,1,1,1,9,9,9,9,9,9,9,9,9,9,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,
1,7,7,1,7,1,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,5,5,1,7,7,7,1,1,5,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,5,5,5,5,5,5,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,1,1,5,5,5,5,0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,5,
5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,0,0,0,0,0,0,0,0,0,0,0,
0,0,5,5,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
char frame3[30*48]={
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,
9,9,9,9,9,9,9,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,1,1,1,1,1,1,1,1,1,1,1,
1,1,1,1,9,9,9,9,9,9,9,9,9,5,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,0,0,7,1,1,1,1,1,
1,1,0,0,0,1,1,1,1,1,1,1,9,9,9,9,9,9,9,5,5,5,5,5,5,5,5,5,5,5,5,5,0,0,0,0,0,0,0,0,
0,7,1,1,7,7,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,5,5,5,1,7,7,7,7,5,5,5,5,5,5,
5,0,0,0,0,0,0,0,7,1,7,7,7,1,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,5,5,1,1,1,7,7,
1,1,7,5,5,5,5,5,5,5,0,0,0,0,0,0,1,1,7,1,1,7,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,
2,1,7,7,7,1,7,7,7,7,7,5,5,5,5,5,5,5,5,0,0,0,0,0,1,7,7,7,7,1,1,1,1,1,0,0,0,1,1,1,
1,1,1,2,2,2,2,2,2,1,7,7,7,7,7,7,7,1,1,5,5,5,5,5,5,5,5,5,0,0,0,0,7,7,1,7,1,7,1,1,
1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,1,1,1,1,1,1,2,2,5,5,5,5,5,5,5,5,5,5,5,0,0,0,
7,7,7,7,7,1,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,5,5,5,5,5,5,
5,5,5,5,5,0,0,0,7,7,0,0,7,7,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,
2,2,5,5,0,0,5,5,0,5,5,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,1,1,1,2,2,2,2,2,
2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,1,1,1,
1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,4,
4,6,6,6,6,6,6,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,3,3,1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,
9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,9,9,9,9,
9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,
1,1,1,1,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};


// DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure putico(X,Y:Word;VAR sprt : icon;Where:Word); ASSEMBLER;
//   { This puts an icon, EXCEPT it's color 0 (black) pixels, onto the screen
//     "where", at position X,Y }
// label
//   _Redraw, _DrawLoop, _Exit, _LineLoop, _NextLine, _Store, _NoPaint;
void putico(int X, int Y, char far* Sprt, int where)
{
  _asm
  {
    push  ds
    push  es
    lds   si,Sprt
    mov   ax,X    ; { ax = x }
    mov   bx,Y    ; { bx = y }
; _Redraw:
    push    ax
    mov     ax,where
    mov     es,ax

    mov     ax, bx   ;               {; ax = bx  x = y}
    mov     bh, bl   ;               {; y = y * 256  bx = bx * 256}
    xor     bl, bl
    shl     ax, 1
    shl     ax, 1
    shl     ax, 1
    shl     ax, 1
    shl     ax, 1
    shl     ax, 1    ;     {; y = y * 64   ax = ax * 64}
    add     bx, ax   ;     {; y = (y*256) + (Y*64)  bx = bx + ax (ie y*320)}

    pop     ax       ;               {; get back our x}


    add     ax, bx   ;               {; finalise location}
    mov     di, ax

    mov   dl,30    ;{ dl = height of sprite }
    xor   ch,ch
    mov   cl,48    ; { cx = width of sprite }
    cld
    push  ax
    mov   ax,cx
_DrawLoop:
    push  di       ;     { store y adr. for later }
    mov   cx,ax    ;      { store width }
_LineLoop:
    mov   bl,byte ptr [si]
    or    bl,bl
    jnz   _Store
; _NoPaint:
    inc    si
    inc    di
    loop   _LineLoop
    jmp    _NextLine
_Store:
    movsb
    loop  _LineLoop
_NextLine:
    pop   di
    dec   dl
    jz    _Exit
    add   di,320   ;     { di = next line of sprite }
    jmp   _DrawLoop
_Exit:
    pop   ax
    pop   es
    pop   ds
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure SetUpScreen;
//   { This procedure sets up the static background to be used in the program }
void SetUpScreen()
{
  char circ[5][5]=
         {{0,10,10,10,0},
         {10,13,12,11,10},
         {10,12,12,11,10},
         {10,11,11,11,10},
          {0,10,10,10,0}};
  int x,y,loop1,loop2,loop3;
  Pal (1,22,22,22);
  Pal (2,45,45,45);
  Pal (3,59,59,59);
  Pal (4,63,63,27);
  Pal (5,39,63,3);
  Pal (6,51,39,3);
  Pal (7,3,27,3);
  Pal (8,15,39,15);
  Pal (9,35,35,35);
  Pal (10, 0, 0,40);
  Pal (11,10,10,50);
  Pal (12,20,20,60);
  Pal (13,30,30,63);

  for(loop1=50;loop1<101;loop1++)
    Pal ((char)loop1,(char)0,(char)0,(char)(loop1-36));

  for(loop1=0;loop1<256;loop1++)
     GetPal ((char)loop1,&ourpal[loop1][1],&ourpal[loop1][2],&ourpal[loop1][3]);

  for(loop1=0;loop1<320;loop1++)
  {
    Funny_Line (0,199,loop1,0,Vaddr);
  }
  for(loop1=0;loop1<200;loop1++)
  {
    Funny_Line (0,199,319,loop1,Vaddr);
  }

  for(loop1=0;loop1<200;loop1++)
  {
    x=random(315);
    y=random(195);
	for(loop2=0;loop2<5;loop2++)
	  for(loop3=0;loop3<5;loop3++)
        if(circ[loop2][loop3]!=0) 
          PutPixel (x+loop2,y+loop3,circ [loop2][loop3],Vaddr);
  }
  Flip2(Vaddr,VGA);  //{ Copy the entire screen at vaddr, our virtual screen }
                     //{ on which we have done all our graphics, onto the    }
                     //{ screen you see, VGA }
  Flip2(Vaddr,Vaddr2);
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure ScreenTrans (x,y:word);
//   { This is a small procedure to copy a 30x30 pixel block from coordinates
//     x,y on the virtual screen to coordinates x,y on the true vga screen }
void ScreenTrans(int x, int y)
{
  _asm 
  {
    push    ds
    push    es
    mov     ax,Vaddr
    mov     es,ax
    mov     ax,Vaddr2
    mov     ds,ax
    mov     bx,x
    mov     dx,y
    push    bx        ;             {; and this again for later}
    mov     bx, dx    ;             {; bx = dx}
    mov     dh, dl    ;             {; dx = dx * 256}
    xor     dl, dl
    shl     bx, 1
    shl     bx, 1
    shl     bx, 1
    shl     bx, 1
    shl     bx, 1
    shl     bx, 1     ;             {; bx = bx * 64}
    add     dx, bx    ;             {; dx = dx + bx (ie y*320)}
    pop     bx        ;             {; get back our x}
    add     bx, dx    ;             {; finalise location}
    mov     di, bx    ;             {; es:di = where to go}
    mov     si, di
    mov     al,60
    mov     bx, 30    ;    { Height of block to copy }
move1:
    mov     cx, 24    ;    { Width of block to copy divided by 2 }
    rep     movsw
    add     di,110h   ;    { 320 - 48 = 272 .. or 110 in hex }
    add     si,110h
    dec     bx
    jnz     move1

    pop     es
    pop     ds
  }
  // { I wrote this procedure late last night, so it may not be in it's
  //   most optimised state. Sorry :-)}
}


// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure NewToaster;
//   { This adds a new toaster to the screen }
void NewToaster() 
{
  int loop1;
  for(loop1=0;loop1<10;loop1++)
  {
    if (!(toaster[loop1].active))
	{
      toaster[loop1].x=random (200)+70;
      toaster[loop1].y=0;
      toaster[loop1].active=1;
      toaster[loop1].frame=1;
      toaster[loop1].speed=random (3)+1;
      break;
	}
  }
}

// {DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD}
// Procedure Fly;
//   { This is the procedure where we move and put the toasters }
void Fly()
{
  int loop1;
  int ch;
  for(loop1=0;loop1<10;loop1++)
    toaster[loop1].active=0;
  ch=0x0;
  NewToaster();
  while(ch!=0x1b)  // escape
  {
    if(_bios_keybrd(_KEYBRD_READY))
	{
	  ch=(getch()&0x00ff);
	  if(ch==0x71)break; // 'q'
	  if(ch==0x51)break; // 'Q'
	  if(ch==0x1b)break; // ESC
      if(ch==0x20)NewToaster();  //  { If ' ' is pressed, add a toaster }
      if(ch==0x2b)NewToaster();  //  { If '+' is pressed, add a toaster }
      if(ch==0x2d)               //  { if '-' is pressed, remove a toaster }
	  {
		for(loop1=0;loop1<10;loop1++)
		{
          if(toaster[loop1].active)
		  {
            ScreenTrans (toaster[loop1].x,toaster[loop1].y);
            toaster[loop1].active=0;
            break;
          }
        }
      }
    }
	for(loop1=0;loop1<10;loop1++)
	{
      if(toaster[loop1].active)
	  {
        ScreenTrans (toaster[loop1].x,toaster[loop1].y);
          // { Restore the backgrond the toaster was over }
        toaster[loop1].x-=toaster[loop1].speed;
        toaster[loop1].y+=toaster[loop1].speed;
         //  { Move the toaster }
        if((toaster[loop1].x<1)||(toaster[loop1].y>170)) 
		{
          toaster[loop1].active=0;
          NewToaster();
		}
      }
        //{ When toaster reaches the edge of the screen, render it inactive
        //  and bring a new one into existance. }
    }
	for(loop1=0;loop1<10;loop1++)
	{
      if(toaster[loop1].active)
	  {
		switch(toaster[loop1].frame)
		{
           case 1: 
		     putico (toaster[loop1].x,toaster[loop1].y,frame1,Vaddr);
			 break;
           case 3: 
		     putico (toaster[loop1].x,toaster[loop1].y,frame2,Vaddr);
			 break;
           case 2: 
		   case 4: 
		     putico (toaster[loop1].x,toaster[loop1].y,frame3,Vaddr);
		}
	  }
      toaster[loop1].frame++;
      if(toaster [loop1].frame==5) toaster[loop1].frame=1;
      //  { Draw all the toasters on the VGA screen }
    }
    WaitRetrace();
    Flip2(Vaddr,VGA);
    rotatepal(ourpal,(int)50,(int)100);
  } // end while ch!=ESC
}


void main()
{
  VirtPtr=&Virtual[0];
  Vaddr = FP_SEG(VirtPtr);
  VirtPtr=&Virtual2[0];
  Vaddr2 = FP_SEG(VirtPtr);
  randomize;     //  { Make sure that the RANDOM funcion really is random }
  _clearscreen(_GCLEARSCREEN);
  printf(  "Hello! This program will demonstrate the principals of animation.\n");
  printf(  "The program will firstly generate an arb background screen to a\n");
  printf(  "virtual page, then flip it to the VGA. A toaster will then start\n");
  printf(  "to move across the screen. Note that the background will be restored\n");
  printf(  "after the toaster has passed over it. You may add or remove toasters\n");
  printf(  "by hitting + or - respectively. Note that the more frames you\n");
  printf(  "use, usually the better the routine looks. Because of space\n");
  printf(  "restrictions, we only had room for three frames.\n");
  printf(  "\n");
  printf(  "The toasters were drawn by Fubar (Pieter Buys) in Autodesk Animator.\n");
  printf(  "I wrote a small little program to convert them into CONSTANTS. See\n");
  printf(  "the main text to find out how to load up AA CEL files directly.\n");
  printf(  "\n");
  printf(  "\n");
  printf(  "Hit any key to contine ...");
  getch();
  SetMCGA();
  SetUpScreen(); //    { Draw the background screen to VADDR, then flip it to
                 //      the VGA screen }
  Fly();         //    { Make the toasters fly around the screen }
  SetText();
  printf(  "All done. This concludes the seventh sample program in the ASPHYXIA\n");
  printf(  "Training series. You may reach DENTHOR under the names of GRANT\n");
  printf(  "SMITH/DENTHOR/ASPHYXIA on the ASPHYXIA BBS. I am also an avid\n");
  printf(  "Connectix BBS user, which is unfortunatly offline for the moment.\n");
  printf(  "For discussion purposes, I am also the moderator of the Programming\n");
  printf(  "newsgroup on the For Your Eyes Only BBS.\n");
  printf(  "The numbers are available in the main text. You may also write to me at:\n");
  printf(  "             Grant Smith\n");
  printf(  "             P.O. Box 270\n");
  printf(  "             Kloof\n");
  printf(  "             3640\n");
  printf(  "I hope to hear from you soon!\n");
  printf("\n\n Translated into Microsoft C by Steve Pinault, \n  scp@ohm.att.com\n\n");
}
