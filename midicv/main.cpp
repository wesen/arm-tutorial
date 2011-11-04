#include <stdlib.h>
#include "board.h"

class ADC {
  volatile AT91PS_PIO pPIO;
  uint32_t startPin;

public:
  ADC(AT91PS_PIO _pPIO, uint32_t _startPin): pPIO(_pPIO), startPin(_startPin) {
    pPIO->PIO_PER = (0xFF << startPin);
    pPIO->PIO_OER = (0xFF << startPin);
  }

  void set(uint8_t val) {
    pPIO->PIO_OWER = (0xFF << startPin);
    pPIO->PIO_ODSR = (val << startPin);
    pPIO->PIO_OWDR = (0xFF << startPin);
  }

  void wait() {
    for (volatile uint32_t j = 10000000; j != 0; j--) {
      /* wait a bit */
    }
  }
};

int main(void) {
  /* initialize low level function */
  board_init();

  /* enable irqs */
  irq_enable();
  fiq_enable();

  ADC adc(AT91C_BASE_PIOA, 0);

  uint8_t i = 0;
  
  for (;;) {
    adc.set(0x00);
    adc.wait();
    adc.set(0x55);
    adc.wait();
    adc.set(0xAA);
    adc.wait();
    adc.set(0xFF);
    adc.wait();
  }

  return 0;
}
