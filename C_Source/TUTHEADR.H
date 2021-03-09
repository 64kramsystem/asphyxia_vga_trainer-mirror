/* 
  tutheadr.h 
  10/30/94
  Header file to go with files tut2.c, tut4.c, etc.
  Translated into C, from Denthor's VGA Trainer, by
  Steve Pinault, scp@ohm.att.com
  Compiled with Microsoft Visual C++ 1.5 (Microsoft C 8.0)
  To compile:
  First compile the subroutines in tutsubs.c with the batch file 
  cltutsub.bat
  Then compile any of the tutor programs with the batch file
  cltut.bat
  Example: C:>cltutsub
           C:>cltut tut2.c
*/

#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>
#include <conio.h>
#include <graph.h>
#include <bios.h>
#include <string.h>
#include <time.h>

#define VGA 0xa000
#define PI (float) 3.14159
#define TRUE 1
#define FALSE 0
#define RAND_MX1 (long)((long)RAND_MAX + (long)1)
        // Note: need the outer parentheses because this expression
        // is what is substituted, not the result!

struct Point
{
  float x;
  float y;
  float z;
}; 

char  Virtual[(unsigned)64000];  // Virtual Screen.
char  Virtual2[(unsigned)64000];  // Virtual Screen.
char far* VirtPtr;
char far* VirtPtr2;
unsigned int Vaddr;
unsigned int Vaddr2;
char Pall[256][3];
char Pall2[256][3];

void SetMCGA();
void SetText();
void WaitRetrace();
void GetPal(char ColorNo, char* R, char* G, char* B);
void Pal(char ColorNo, char R, char G, char B);
void SetAllPal(char far* pal);
void PutPixel(int X, int Y, char Color, int Where);
void Line(int x1, int y1, int x2, int y2, unsigned char Color);
void Line2(int x1, int y1, int x2, int y2, unsigned char Color, int where);
void Funny_Line(int x1, int y1, int x2, int y2, int Where);
void PalPlay();
void rotatepal(char locpal[][3], int start, int end);
void GrabPallette();
void Blackout();
void FadeUp();
void FadeDown();
void RestorePallette();
void Cls(char Color, int Where);
void Flip();
void Flip2(int Source, int Dest);
void randomize();
int  random(int x);
float rad(float theta);
int round(float x);
void SetUpVirtual();
void Hline(int x1, int x2, int y, char col, int where);
void PutPixel2(int x, int y, char col, int where);
char GetPixel(int x, int y, int where);  
void LoadCEL(char* FileName, char far* ScrPtr);
void delay(int wait);
void InitChain4(int Size);
void C4PutPixel(int x, int y, char col, int Size);
void Plane(char Which);
void moveto(int x, int y, int Size);
