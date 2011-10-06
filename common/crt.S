/*
 *
 * C startup code for AT91SAM7S256
 *
 * datasheet: http://www.atmel.com/dyn/resources/prod_documents/doc6175.pdf
 *
 * inspired by atmel Cstartup.S and james p lynch tutorial code
 *
 */

        /* stack sizes */
        .set    UND_STACK_SIZE, 0x10
        .set    ABT_STACK_SIZE, 0x10
        .set    SVC_STACK_SIZE, 0x10
        .set    FIQ_STACK_SIZE, 0x80
        .set    IRQ_STACK_SIZE, 0x80

        /* mode bits */
        .set ARM_MODE_USR, 0x10
        .set ARM_MODE_FIQ, 0x11
        .set ARM_MODE_IRQ, 0x12
        .set ARM_MODE_SVC, 0x13
        .set ARM_MODE_ABT, 0x17
        .set ARM_MODE_UND, 0x1b
        .set ARM_MODE_SYS, 0x1f
        .set I_BIT, 0x80
        .set F_BIT, 0x40

        /*
         * addresses of AIC and PIO
         *
         * see datasheet: pp. 20
         */
        .set AT91C_BASE_AIC, 0xfffff000 /* AIC base address */
        .set AT91C_AIC_IVR, 0xfffff100  /* AIC IRQ interrupt vector register */
        .set AT91C_AIC_FVR, 0xfffff104  /* AIC FIQ interrupt vector register */
        .set AIC_IVR, 256               /* irq vector register offset from base above */
        .set AIC_FVR, 260               /* fiq vector register offset from base above */
        .set AIC_EOICR, 304             /* end of intterupt command register */

        .text
        .arm
        .align

        .global _startup
        .global _vec_reset
        .func   _startup

_startup:
_vec_reset:     b       _init_reset
_vec_undef:     b       _vec_undef
_vec_swi:       b       _vec_swi
_vec_pabt:      b       _vec_pabt /* prefetch abort */
_vec_dabt:      b       _vec_dabt /* data abort vector */
_vec_rsv:       b       _vec_rsv
_vec_irq:       b       at91_irq_handler
_vec_fiq:

        /** Handle the FIQ **/
at91_fiq_handler:
        mov     r9, r0 // save r0
        ldr     r0, [r8, #AIC_FVR] // ack interrupt
        msr     CPSR_c, #I_BIT | F_BIT | ARM_MODE_SVC // switch to SVC mode

        stmfd   sp!, {r1-r3, r12, lr} // save registers in user stack

        mov     r14, pc
        bx      r0 // branch to the routine pointed to by AIC_FVR

        ldmia   sp!, {r1-r3, r12, lr} // restore regs

        msr     CPSR_c, #I_BIT | F_BIT | ARM_MODE_FIQ
        mov     r0, r9 // restore r0 ARM_MODE_SVC register

        subs    pc, lr, #4 // restore pc directly from lr_fiq

        /**
         * Initialize stacks, data and bss segments
         **/
_init_reset:
        // call at91_low_level_init C function
        /*
        .extern at91_low_level_init
        ldr     r13, .ram_top // temporary stack
        ldr     r0, =at91_low_level_init
        mov     lr, pc
        bx      r0
        */

        /*
         * initialize stacks
         */
        ldr     r0, =_stack_end

        /* switch to undefined instruction mode */
        msr     CPSR_c, #ARM_MODE_UND|I_BIT|F_BIT
        mov     sp, r0

        sub     r0, r0, #UND_STACK_SIZE

        /* switch to abort mode */
        msr     CPSR_c, #ARM_MODE_ABT|I_BIT|F_BIT
        mov     sp, r0

        sub     r0, r0, #ABT_STACK_SIZE

        /* switch to FIQ mode */
        msr     CPSR_c, #ARM_MODE_FIQ|I_BIT|F_BIT
        mov     sp, r0

        sub     r0, r0, #IRQ_STACK_SIZE

        /* switch to IRQ mode */
        msr     CPSR_c, #ARM_MODE_IRQ|I_BIT|F_BIT
        mov     sp, r0

        sub     r0, r0, #SVC_STACK_SIZE

        /* switch to system mode */
        msr     CPSR_c, #ARM_MODE_SYS|I_BIT|F_BIT
        mov     sp, r0

        /* copy initialized variables .data section (copy from ROM to RAM) */
        ldr     r1, =_etext
        ldr     r2, =_data
        ldr     r3, =_edata

1:      cmp     r2, r3
        ldrlo   r0, [r1], #4
        str     r0, [r2], #4
        blo     1b

        /* clear .bss */
        mov     r0, #0
        ldr     r1, =_bss_start
        ldr     r2, =_bss_end

2:      cmp     r1, r2
        strlo   r0, [r1], #4
        blo     2b

        /* branch to c code */
        ldr     lr, =_exit
        ldr     r0, =main
        bx      r0
        .size   _startup, . - _startup
        .endfunc

        /* after exiting main, loop indefinitely */
        .global _exit
        .func   _exit
_exit:
        b       .
        .size   _exit, . - _exit
        .endfunc

/*
 *
 * at91 irq handler
 *
 * IRQ handler taken from Atmel website (www.at91.com)
 * Keil example project: AT91SAM7S-Interrupt_SAM7S
 *
 */

        .global at91_irq_handler
        .func   at91_irq_handler

at91_irq_handler:
        /* adjust and save lr_irq in IRQ stack */
        sub     lr, lr, #4
        stmfd   sp!, {lr}

        /* save r0 and SPSR (for nested interrupts) */
        mrs     r14, SPSR
        stmfd   sp!, {r0, r14}

        /*
         * read AIC_IVR to acknowledge interrupt
         */
        ldr     r14, =AT91C_BASE_AIC
        ldr     r0,  [r14, #AIC_IVR]

        /*
         * write in the IVR to support protect mode (no action on reading AIC to help debuggers).
         * this has no effect in normal mode, in protect mode, it deasserts the nIRQ and clears the source
         */
        str     r14, [r14, #AIC_IVR]

        /* enable interrupt and switch to superviso mode */
        msr     CPSR_c, #ARM_MODE_SVC // CPSR_c = only control field only, not flags

        /* save scratch / used register and LR in user stack */
        stmfd   sp!, { r1-r3, r12, r14 }

        /* branch to the routine pointed by the AIC_IVR */
        mov     r14, pc
        bx      r0              /* branch and exchange instruction set */

        /* restore registers and Lr from user stack */
        ldmia   sp!, { r1-r3, r12, r14 }

        /* switch back to IRQ mode, disable interrupts */
        msr     CPSR_c, #I_BIT | ARM_MODE_IRQ

        /* mark end of interrupt by writing to EOICR */
        ldr     r14, =AT91C_BASE_AIC
        str     r14, [r14, #AIC_EOICR]

        /* restore SPSR_irq and r0 from IRQ stack */
        ldmia   sp!, {r0, r14}
        msr     SPSR_cxsf, r14  // cxsf = control, flags, extension, status

        /* restore adjusted lr_irq directly from the stack into pc */
        ldmia   sp!, {pc}^

        .size   at91_irq_handler, . - at91_irq_handler
        .endfunc

/*
 *
 * Default IRQ handlers
 *
 */
        .global at91_default_fiq_handler
        .func   at91_default_fiq_handler
at91_default_fiq_handler:
        b       at91_default_fiq_handler
        .size   at91_default_fiq_handler, . - at91_default_fiq_handler
        .endfunc

        .global at91_default_irq_handler
        .func   at91_default_irq_handler
at91_default_irq_handler:
        b       at91_default_irq_handler
        .size   at91_default_irq_handler, . - at91_default_irq_handler
        .endfunc

        .global at91_spurious_handler
        .func   at91_spurious_handler
at91_spurious_handler:
        b       at91_spurious_handler
        .size   at91_spurious_handler, . - at91_spurious_handler
        .endfunc

/***************************************************************************
*
* IRQ helpers (for C)
*
***************************************************************************/

        .global irq_disable
        .func   irq_disable
irq_disable:
        mrs     r0, CPSR        /* read CPSR into r0 */
        orr     r3, r0, #I_BIT  /* set the I bit to disable IRQs */
        msr     CPSR_fc, r3     /* write back to CPSR (flags + control) */
        bx      lr              /* return the old CPSR value */
        .size   irq_disable, . - irq_disable
        .endfunc

        .global irq_enable
        .func   irq_enable
irq_enable:
        mrs     r0, CPSR
        bic     r3, r0, #I_BIT  /* clear the I bit to enable IRQs */
        msr     CPSR_fc, r3
        bx      lr              /* return the previous CPSR value */
        .size   irq_enable, . - irq_enable
        .endfunc

        .global irq_restore
        .func   irq_restore
irq_restore:
        mrs     r3, CPSR
        bic     r2, r3, #I_BIT  /* clear the I_BIT in CPSR */
        and     r0, r0, #I_BIT  /* get the I_BIT of the passed CPSR argument */
        orr     r0, r2, r0      /* set the I_BIT in CPSR to the I_BIT of the passed CPSR */
        msr     CPSR_fc, r0     /* store in CPSR */
        mov     r0, r3          /* return the previous CPSR value */
        bx      lr
        .size   irq_restore, . - irq_restore
        .endfunc

        .global fiq_disable
        .func   fiq_disable
fiq_disable:
        mrs     r0, CPSR        /* read CPSR into r0 */
        orr     r3, r0, #F_BIT  /* set the F bit to disable FIQs */
        msr     CPSR_fc, r3     /* write back to CPSR (flags + control) */
        bx      lr              /* return the old CPSR value */
        .size   fiq_disable, . - fiq_disable
        .endfunc

        .global fiq_enable
        .func   fiq_enable
fiq_enable:
        mrs     r0, CPSR
        bic     r3, r0, #F_BIT  /* clear the F bit to enable FIQs */
        msr     CPSR_fc, r3
        bx      lr              /* return the previous CPSR value */
        .size   fiq_enable, . - fiq_enable
        .endfunc

        .global fiq_restore
        .func   fiq_restore
fiq_restore:
        mrs     r3, CPSR
        bic     r2, r3, #F_BIT  /* clear the F_BIT in CPSR */
        and     r0, r0, #F_BIT  /* get the F_BIT of the passed CPSR argument */
        orr     r0, r2, r0      /* set the F_BIT in CPSR to the F_BIT of the passed CPSR */
        msr     CPSR_fc, r0     /* store in CPSR */
        mov     r0, r3          /* return the previous CPSR value */
        bx      lr
        .size   fiq_restore, . - fiq_restore
        .endfunc

        .end
