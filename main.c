#include <stdio.h>
/* via C (1978) at 15 */
main() {/* copy input to output; 1st version */
  int c;
  c = getchar();
  while (c != EOF) {
    putchar(c);
    c = getchar();
  }
}
