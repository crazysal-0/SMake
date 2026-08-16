#include <stdio.h>

extern int answer(void);

int main(void)
{
    printf("The answer is %d\n", answer());
    return 0;
}