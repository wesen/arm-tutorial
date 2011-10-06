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

class LEDS {
  volatile AT91PS_PIO pPIO;
  uint32_t ledMask;

public:
  LEDS(AT91PS_PIO _pPIO, uint32_t _ledMask) : pPIO(_pPIO), ledMask(_ledMask) {
    pPIO->PIO_PER           |= ledMask;
    pPIO->PIO_OER            = ledMask;
    pPIO->PIO_SODR           = ledMask;
  }

  void set() {
    pPIO->PIO_SODR = ledMask;
  }

  void clear() {
    pPIO->PIO_CODR = ledMask;
  }

  int isSet() {
    return (pPIO->PIO_ODSR & ledMask) == ledMask;
  }

  void wait() {
    for (volatile uint32_t j = 1000000; j != 0; j--) {
      /* wait a tad */
    }
  }
};

/**
 * Main entry point
 **/
int main(void) {
  /* initialize low level function */
  board_init();

  /* enable interrupts */
  irq_enable();
  fiq_enable();

  LEDS leds(AT91C_BASE_PIOA, LED1);

  for (;;) {
    if (leds.isSet()) {
      leds.clear();
    } else {
      leds.set();
    }

    leds.wait();

  }

  return 0;
}
