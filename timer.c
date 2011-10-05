/**
 * AT91SAM7 demo timer routines
 *
 * Reformatted from James P Lynch
 **/

#include "timer.h"

/**
 * set up the 16 bit timer/counter
 *
 * datasheet: pp. 443-476
 *
 * We will use timer channel 0 to develop a 50 msec interrupt.
 *
 * The board uses a master clock of 48.054841 Mhz (see board.c for the
 * master clock initialization).
 *
 * TIMER_CLOCK5 = MCK / 1024 = 48054841 / 1024 = 46928 hz
 * TIMER_CLOCK5_period = 1 / 46928 = 21.309239686 microseconds
 *
 * a little algebra:
 *    0.050 sec = count * 21.309239686 * 10^-6
 *    count = .050 / 21.309239686 * 10^-6
 *    count = 2346
 *
 * Therefore:
 * - set timer channel 9 register RC to 9835
 **/
void timer_setup(void) {
  /*
   * enable timer0 peripheral clock
   *
   * see datasheet p. 204, p. 34 (peripheral identifiers)
   */
  volatile AT91PS_PMC pPMC = AT91C_BASE_PMC;
  pPMC->PMC_PCER = (1 << AT91C_ID_TC0);

  volatile AT91PS_TCB pTCB = AT91C_BASE_TCB; /* pointer to TC register structure */

  pTCB->TCB_BCR = 0; /* clear the sync trigger, see p. 460 */

  /* set the external clock signals to none */
  pTCB->TCB_BMR = ((AT91C_TCB_TC0XC0S & AT91C_TCB_TC0XC0S_NONE) /* no signal connected to XC0 */
                  | (AT91C_TCB_TC1XC1S & AT91C_TCB_TC1XC1S_NONE) /* no signal connected to XC1 */
                  | (AT91C_TCB_TC2XC2S & AT91C_TCB_TC2XC2S_NONE) /* no signal connected to XC2 */
                  );

  /* create a pointer to the channel 0 register structure */
  volatile AT91PS_TC pTC = AT91C_BASE_TC0;

  /*
   * enable the clock, assert the software trigger to reset the counter and start the clock
   *
   * see p. 462
   */
  pTC->TC_CCR = (AT91C_TC_CLKEN | AT91C_TC_SWTRG);

  /*
   * channel mode register for channel 0 (in capture mode)
   *
   * see p. 463
   */
  pTC->TC_CMR = ((AT91C_TC_CLKS & AT91C_TC_CLKS_TIMER_DIV5_CLOCK) /* select TIMER_CLOCK5 = MCK / 1024 */
                 | (AT91C_TC_CPCTRG) /* RC compare resets the counter and starts the clock */
                 );

  /*
   * set the compare register for channel 0 to the countdown value 2346 (see calculation above)
   */
  pTC->TC_RC = 2346;

  /*
   * enable interrupt on RC compare
   */
  pTC->TC_IER = AT91C_TC_CPCS;

  /* enable all interrupts except RC */
  pTC->TC_IDR = ~(AT91C_TC_CPCS);
}

uint32_t timer0_tick_count = 0;

/**
 * timer0 interrupt routine, blinks LED2 (on pin A2)
 **/
void timer0_irq_handler(void) {
  volatile AT91PS_TC  pTC  = AT91C_BASE_TC0;  /* pointer to timer 0 structure */
  volatile AT91PS_PIO pPIO = AT91C_BASE_PIOA; /* pointer to PIO structure */
  uint32_t dummy;

  dummy = pTC->TC_SR; /* read TC0 status register to clear interrupt */
  timer0_tick_count++;

  /*
   * toggle LED2
   *
   * see datasheet pp. 254-255
   */
  if ((pPIO->PIO_ODSR & LED2) == LED2) {
    pPIO->PIO_CODR = LED2;
  } else {
    pPIO->PIO_SODR = LED2;
  }

}
