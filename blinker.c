/*
 * Blinking debug routine
 *
 * reformatted version of James P Lynch - at91 tutorial
 *
 */

#include "board.h"

uint32_t blink_count;

void blinker(uint8_t code) {
  volatile AT91PS_PIO pPIO = AT91C_BASE_PIOA;

  for (;;) {
    for (uint8_t j = 0; j < code; j++) {
      pPIO->PIO_CODR = LED1;
      for (volatile uint32_t k = 0; k < 60000; k++) {
      }

      pPIO->PIO_SODR = LED1;
      for (volatile uint32_t k = 0; k < 60000; k++) {
      }
    }

    for (volatile uint32_t k = 0; k < 5000000; k++) {
    }

    blink_count++;
  }
}
