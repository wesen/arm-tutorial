/**
 * Demonstration program for Atmel AT91SAM7S256 processor
 *
 * Runs on an olimex SAM7-HXXX board
 *
 * Adapted from James P Lynch ARM tutorial
 **/

#include "board.h"
#include "timer.h"

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

/*
 * initialize the switch pin
 */
void button_init(void) {
  volatile AT91PS_PIO pPIO = AT91C_BASE_PIOA; /* pointer to PIO data structure */
  pPIO->PIO_PER           |= SW1_MASK;        /* allow PIO to control pin 19 */
  pPIO->PIO_BSR            = SW1_MASK;        /* select P19 to be peripheral B */

  /*
   * route SW1 to FIQ
   *
   * see datasheet pp. 161-176
   */
  volatile AT91PS_AIC pAIC = AT91C_BASE_AIC;
  WRITE_BIT(pAIC->AIC_IDCR, AT91C_ID_FIQ);   /* disable FIQ in AIC */
  pAIC->AIC_SVR[AT91C_ID_FIQ] =
    (AT91C_AIC_SRCTYPE_INT_POSITIVE_EDGE); /* set interrupt type and priority */
  WRITE_BIT(pAIC->AIC_ICCR, AT91C_ID_FIQ);   /* clear the interrupt in clear command register */
  WRITE_BIT(pAIC->AIC_IECR, AT91C_ID_FIQ);   /* enable tc0 interrupt in AIC */
}

uint32_t idle_count = 0;
uint32_t fiq_count = 0;

/**
 * Main entry point
 **/
int main(void) {
  /* initialize low level function */
  board_init();

  leds_init();
  /*
  button_init();

  timer_init();
  */

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

    idle_count++;

    pPIO->PIO_SODR = LED3; /* turn LED3 off (set by FIQ) */
  }

  return 0;
}
