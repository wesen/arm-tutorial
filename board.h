#ifndef BOARD_H__
#define BOARD_H__

#include <inttypes.h>
#include "at91sam7s256.h"

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

#endif /* BOARD_H__ */
