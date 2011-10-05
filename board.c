#include <inttypes.h>

#include "board.h"

void low_level_init(void) {
  /* pointer to power management controller */
  AT91PS_PMC pPMC = AT91C_BASE_PMC;

  /*
   * set flash wait state
   *
   * single cycle access at up to 30 Mhz, or 40
   *
   * See datasheet pp. 116-117
   */
  AT91C_BASE_MC->MC_FMR = ((AT91C_MC_FMCN & (50 << 16)) /* set to 50 cycles per microseconds */
                           | AT91C_MC_FWS_1FWS          /* 2 cycles for read, 3 cycles for write */
                           );

  /*
   * disable watchdog
   *
   * see datasheet: pp. 92-94
   */
  AT91C_BASE_WDTC->WDTC_WDMR = AT91C_WDTC_WDDIS; /* disable the watchdog timer */

  /*
   * set master clock
   *
   * see datasheet: pp. 191-214
   */
  pPMC->PMC_MOR = ((AT91C_CKGR_OSCOUNT & (0x06 << 8)) /* 6 * 8 = 48 slow clock cycles for oscillator startup */
                   | (AT91C_CKGR_MOSCEN)              /* enable main oscillator */
                   );

  /* wait the startup time until the status register shas the main oscillator stabilized flag set */
  while (!(pPMC->PMC_SR & AT91C_PMC_MOSCS))
    ;

  /*
   * PMC clock generator PLL register setup
   *
   * following settings are used:
   * DIV      = 14
   * MUL      = 72
   * PLLCOUNT = 10
   *
   * main clock (MAINCK from crystal oscillator) = 18.432 Mhz
   *
   * MAINCK / DIV = 18432000 / 14 = 1316571 hz
   * PLLCK = 1316571 * (MUL + 1) = 1316571 * (72 + 1) = 1316571 * 73 = 96109683 hz = 96.109683 Mhz
   *
   * PLLCOUNT = number of slow clock cycles before the LOCK bit is set in PMC_SR after CKGR_PLLR is written
   * PLLCOUNT = 10
   */
  pPMC->PMC_PLLR = ((AT91C_CKGR_DIV & 14) | /* set DIV */
                    (AT91C_CKGR_PLLCOUNT & (10 << 8)) | /* set PLLCOUNT */
                    (AT91C_CKGR_MUL & (72 << 16)) /* set MUL */
                    );

  /* wait the start up time (until PMC status register LOCK bit is set) */
  while (!(pPMC->PMC_SR & AT91C_PMC_LOCK))
    ;

  /*
   * PMC master clock register setup
   *
   * CSS  = 3 (select PLL clock)
   * PRES = 1 (MCK = PLLCK / 2 = 96109683 / 2 = 48054841 hz = 48.054 Mhz)
   */
  pPMC->PMC_MCKR = AT91C_PMC_CSS_PLL_CLK | AT91C_PMC_PRES_CLK_2;

  /*
   * set up the default interrupts handler vectors by writing the AIC SVR vectors
   *
   * see datasheet pp. 161-186
   */
  AT91C_BASE_AIC->AIC_SVR[0] = (uint32_t)at91_default_fiq_handler;
  for (uint8_t i = 0; i < 31; i++) {
    AT91C_BASE_AIC->AIC_SVR[i] = (uint32_t)at91_default_irq_handler;
  }
  AT91C_BASE_AIC->AIC_SPU = (uint32_t)at91_spurious_handler;
}
