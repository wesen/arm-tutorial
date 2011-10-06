#ifndef TIMER_H__
#define TIMER_H__

#include "board.h"

void timer_init(void);
void timer0_irq_handler(void);

extern uint32_t tick_count;

#endif /* TIMER_H__ */
