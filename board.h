#ifndef BOARD_H__
#define BOARD_H__

#include <inttypes.h>
#include "at91sam7s256.h"
#include "helpers.h"

/**
 * board settings
 **/
#define LED1 (1UL << 8) /* PA8 */
#define LED2 (1 << 1) /* PA1 */
#define LED3 (1 << 2) /* PA2 */
#define LED4 (1 << 3) /* PA3 */
#define LED_MASK (LED1|LED2|LED3|LED4)

#define SW1_MASK (1 << 19)
#define SW_MASK (SW1_MASK)
#define SW1      (1 << 19)

#define EXT_OC 18432000 /* external oscillator */
#define MCK    47923200 /* main clock frequency */
#define MCKKHz ((MCK)/1000) /* main clock in khz */

void board_init(void);

/*
 * external interrupt handler definitions written in ARM
 * assembler. These must be written in ARM mode as they are called
 * directly by the exception handler
 */
extern void at91_spurious_handler(void);
extern void at91_default_irq_handler(void);
extern void at91_default_fiq_handler(void);

/*
 * enable/disable IRQ/FIQ helpers
 */
extern uint32_t irq_enable(void);
extern uint32_t irq_disable(void);
extern uint32_t irq_restore(uint32_t cpsr);

extern uint32_t fiq_enable(void);
extern uint32_t fiq_disable(void);
extern uint32_t fiq_restore(uint32_t cpsr);

/*
 * blinker debug routine
 */
extern uint32_t blink_count;
void blinker(uint8_t code);

#endif /* BOARD_H__ */
