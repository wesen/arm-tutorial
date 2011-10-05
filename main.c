/**
 * Demonstration program for Atmel AT91SAM7S256 processor
 *
 * Runs on an olimex SAM7-HXXX board
 *
 * Adapter from James P Lynch ARM tutorial
 **/

#include "board.h"
#include "timer.h"

void leds_init(void) {
}

void button_init(void) {
}

/**
 * Main entry point
 **/
int main(void) {
  /* initialize low level function */
  board_init();

  leds_init();
  button_init();

  timer_init();

  /* enable interrupts */

  for (;;) {
  }

  return 0;
}
