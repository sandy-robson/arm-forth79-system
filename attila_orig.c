#include <stdio.h> 
#include <termios.h> 
#include <unistd.h>
 
extern void thread(unsigned char * start, unsigned long len);


#define bfrlen 65536 
   
unsigned char bfr[bfrlen]; 
struct termios saved_attr;

void resetmode(void)
{
  tcsetattr (STDIN_FILENO, TCSANOW, &saved_attr);
}
 
void setmode (void)
{
 struct termios tattr;
 char *name;

 tcgetattr (STDIN_FILENO, &saved_attr);
 atexit (resetmode); 

 tcgetattr (STDIN_FILENO, &tattr);
 tattr.c_lflag &= ~(ICANON|ECHO);
 tattr.c_cc[VMIN] = 1;
 tattr.c_cc[VTIME] = 0;
 tcsetattr (STDIN_FILENO, TCSAFLUSH, &tattr);
}

  
int main()
{ 
  setmode();

  thread(&bfr[0], bfrlen); 
  return 0; 
} 
