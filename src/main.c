#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
        if (argc > 1 && strcmp(argv[1], "--help") == 0) {
                FILE* help = fopen("res/helptext.txt", "r");

                if (help == NULL) {
                        fprintf(stderr, "Error: res/helptext.txt not found.\n");
                        return 1;
                }

                char c;
                while ((c = fgetc(help)) != EOF) {
                        putchar(c);
                }

                putchar('\n');

                fclose(help);
                return 0;
        }

        else if (argc > 1 && strcmp(argv[1], "--version") == 0) {
                printf("smake version 0.1.0\n");
                return 0;
        }

        FILE* config = fopen("SMake.toml", "r");

        if (config == NULL) {
                fprintf(stderr, "Error: SMake.toml not found.\n");
                return 1;
        }

        return 0;
}