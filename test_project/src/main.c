#include <stdio.h>

extern long add(long a, long b);

int main(void) {
    printf("%ld\n", add(20, 22));
    return 0;
}