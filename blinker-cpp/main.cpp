/**
 * Demonstration program for Atmel AT91SAM7S256 processor
 *
 * Runs on an olimex SAM7-HXXX board
 *
 * Adapted from James P Lynch ARM tutorial
 **/

#include <stdlib.h>
#include "board.h"

/* no dynamic allocation */
void *operator new(size_t size) throw() { return NULL; }
void operator delete(void *p) throw() { }

extern "C" int __aeabi_atexit(void *object,
                              void (*destructor)(void *),
                              void *dso_handle) {
  return 0;
}

/*
 * initialize the PIO LED pins, and turn them off
 *
 * see datasheet pp. 239-264
 */
void leds_init(void) {
  volatile AT91PS_PIO pPIO = AT91C_BASE_PIOA; /* pointer to PIO data structure */
  pPIO->PIO_PER           |= LED_MASK;        /* allow PIO to control pins P0 - P3 */
  pPIO->PIO_OER            = LED_MASK;        /* set pins P0 - P3 to output */
  pPIO->PIO_SODR           = LED_MASK;        /* turn off all four LEDs */
}

/**
 * Main entry point
 **/
int main(void) {
  /* initialize low level function */
  board_init();

  leds_init();

  /* enable interrupts */
  irq_enable();
  fiq_enable();

  volatile AT91PS_PIO pPIO = AT91C_BASE_PIOA;

  for (;;) {
    if ((pPIO->PIO_ODSR & LED1) == LED1) {
      pPIO->PIO_CODR = LED1;
    } else {
      pPIO->PIO_SODR = LED1;
    }

    for (volatile uint32_t j = 1000000; j != 0; j--) {
      /* wait a tad */
    }
  }

  return 0;
}
