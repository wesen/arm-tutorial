/**
 *
 * USB demo
 *
 * Inspired by Atmel USB demo
 *
 **/

#include "board.h"
#include "usb.h"
#include "cdc.h"

at91_cdc_t cdc;

void at91_usb_open(void) {
  /*
   * Set the PLL USB divider to PLL output / 2
   *
   * This should be 48 Mhz, 96Mhz or 192 Mhz within 0.25%
   *
   * see datasheet p. 208
   */
  AT91C_BASE_CKGR->CKGR_PLLR |= AT91C_CKGR_USBDIV_1;

  /**
   * Enable the USB system and peripheral clock
   *
   * see datasheet pp. 201, 204
   **/
  AT91C_BASE_PMC->PMC_SCER = AT91C_PMC_UDP;
  AT91C_BASE_PMC->PMC_PCER = (1 << AT91C_ID_UDP);

  /**
   *
   * Enable the UDP pullup
   *
   * - enable and clear the corresponding PIO
   * - set in PIO mode and configure as output
   **/
  /* not needed on olimex board
  at91_pio_cfg_output(AT91C_BASE_PIOA, AT91C_PIO_PA16);
  at91_pio_clear_output(AT91C_BASE_PIOA, AT91C_PIO_PA16);
  */

  at91_cdc_init(&cdc, AT91C_BASE_UDP);
}

int main(void) {

  /**
   * enable user reset
   * set minimal assertion to 960 us
   *
   * see datasheet pp. 53 - 70
   **/
  AT91C_BASE_RSTC->RSTC_RMR =
    (AT91C_RSTC_URSTEN |
     (4 << 8) |
     (uint32_t)(0xA5 << 24));

  at91_usb_open();

  for (;;) {
    if (cdc_is_configured(&cdc)) {
      char data[1024];
      uint32_t len = cdc_read(&cdc, data, sizeof(data));
      /* loopback */
      cdc_write(&cdc, data, length);
    }
  }
}
