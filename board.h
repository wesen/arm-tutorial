#ifndef BOARD_H__
#define BOARD_H__

#include "at91sam7s256.h"

void low_level_init(void);

/*
 * external interrupt handler definitions written in ARM
 * assembler. These must be written in ARM mode as they are called
 * directly by the exception handler
 */
extern void at91_spurious_handler(void);
extern void at91_default_irq_handler(void);
extern void at91_default_fiq_handler(void);

#endif /* BOARD_H__ */
