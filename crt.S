/*
 *
 * C startup code for AT91SAM7S256
 *
 * datasheet: http://www.atmel.com/dyn/resources/prod_documents/doc6175.pdf
 *
 * reformatted version of James P Lynch - at91 tutorial
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
        .set AT91_PIOA_CODR, 0xfffff434 /* PIO clear output data register */
        .set AT91C_AIC_IVR, 0xfffff100  /* AIC IRQ interrupt vector register */
        .set AT91C_AIC_FVR, 0xfffff104  /* AIC FIQ interrupt vector register */
        .set AIC_IVR, 256               /* irq vector register offset from base above */
        .set AIC_FVR, 260               /* fiq vector register offset from base above */
        .set AIC_EOICR, 304             /* end of intterupt command register */

        /* global symbols */
        .global _vec_reset
        .global _vec_undef
        .global _vec_swi
        .global _vec_pabt
        .global _vec_dabt
        .global _vec_rsv
        .global _vec_irq
        .global _vec_fiq
        .global at91_irq_handler
        .global at91_fiq_handler
        .global at91_default_fiq_handler
        .global at91_default_irq_handler
        .global at91_spurious_handler
        .global at91_dabt_handler
        .global at91_pabt_handler
        .global at91_undef_handler

        .global irq_disable
        .global irq_enable
        .global irq_restore
        .global fiq_disable
        .global fiq_enable
        .global fiq_restore

        .text
        .arm   /* compiler for ARM 32-bit instruction set */
        .align /* align on 32-bit boundary */

/*
 *
 * vector table
 *
 */

_vec_reset:     b       _init_reset
_vec_undef:     b       at91_undef_handler
_vec_swi:       b       _vec_swi
_vec_pabt:      b       at91_pabt_handler /* prefetch abort */
_vec_dabt:      b       at91_dabt_handler /* data abort vector */
_vec_rsv:       nop
_vec_irq:       b       at91_irq_handler  /* interrupt request vector */
_vec_fiq:


/*
 *
 * simple fiq handler that turns on LED3 (port PA2) when SW1 is pressed
 *
 *
 */

at91_fiq_handler:
        /* store return address in lr */
        sub     lr, lr, #4

        /* read AIC FIQ vector to clear the interrupt */
        ldr     r12, =AT91C_AIC_FVR
        ldr     r11, [r12]

        /* turn on LED3 (write 0x4 to PIOA_CODR) */
        ldr     r12, =AT91C_PIOA_CODR
        mov     r11, #0x04
        str     r11, [r12]

        /* increment the _fiq_count variable */
        ldr     r12, =fiq_count
        ldr     r11, [r12]
        add     r11, r11, #1
        str     r11, [r12]

        /* return from fiq */
        movs    pc, lr

/*
 *
 * init reset handler (called on boot)
 *
 * SVU mode, interrupts disabled
 *
 * - create a stack for each ARM mode
 * - set up a stack pointer for each ARM mode
 * - turns off interrupts in each mode
 * - leave CPU in SYS (system) mode
 * - block copies the initializers to .data section
 * - clears the .bss section to zero
 * - branches to main()
 *
 */

        .text
        .align
_init_reset:
        /* setup a stack for each mode */
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

        /* start execution in system mode */

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
        b main

/*
 *
 * at91 irq handler
 *
 * IRQ handler taken from Atmel website (www.at91.com)
 * Keil example project: AT91SAM7S-Interrupt_SAM7S
 *
 */

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

/*
 *
 * at91 data abort handler
 *
 * entered on data abort exception
 * enters blink routine (3 blinks)
 *
 */
at91_dabt_handler:
        mov     r0, #3
        b       blinker

/*
 *
 * at91 prefetch abort handler
 *
 * entered on prefetch abort exception
 * enters blink routine (2 blinks)
 *
 */
at91_pabt_handler:
        mov     r0, #2
        b       blinker

/*
 *
 * at91 undefined instruction handler
 *
 * entered on undefined instruction exception
 * enters blink routine (1 blink)
 *
 */
at91_undef_handler:
        mov     r0, #1
        b       blinker

/*
 *
 * Default IRQ handlers
 *
 */
at91_default_fiq_handler:
        b       at91_default_fiq_handler

at91_default_irq_handler:
        b       at91_default_irq_handler

at91_spurious_handler:
        b       at91_spurious_handler

/***************************************************************************
*
* IRQ helpers (for C)
*
***************************************************************************/

irq_disable:
        mrs     r0, CPSR        /* read CPSR into r0 */
        orr     r3, r0, #I_BIT  /* set the I bit to disable IRQs */
        msr     CPSR_fc, r3     /* write back to CPSR (flags + control) */
        bx      lr              /* return the old CPSR value */

irq_enable:
        mrs     r0, CPSR
        bic     r3, r0, #I_BIT  /* clear the I bit to enable IRQs */
        msr     CPSR_fc, r3
        bx      lr              /* return the previous CPSR value */

irq_restore:
        mrs     r3, CPSR
        bic     r2, r3, #I_BIT  /* clear the I_BIT in CPSR */
        and     r0, r0, #I_BIT  /* get the I_BIT of the passed CPSR argument */
        orr     r0, r2, r0      /* set the I_BIT in CPSR to the I_BIT of the passed CPSR */
        msr     CPSR_fc, r0     /* store in CPSR */
        mov     r0, r3          /* return the previous CPSR value */
        bx      lr

fiq_disable:
        mrs     r0, CPSR        /* read CPSR into r0 */
        orr     r3, r0, #F_BIT  /* set the F bit to disable FIQs */
        msr     CPSR_fc, r3     /* write back to CPSR (flags + control) */
        bx      lr              /* return the old CPSR value */

fiq_enable:
        mrs     r0, CPSR
        bic     r3, r0, #F_BIT  /* clear the F bit to enable FIQs */
        msr     CPSR_fc, r3
        bx      lr              /* return the previous CPSR value */

fiq_restore:
        mrs     r3, CPSR
        bic     r2, r3, #F_BIT  /* clear the F_BIT in CPSR */
        and     r0, r0, #F_BIT  /* get the F_BIT of the passed CPSR argument */
        orr     r0, r2, r0      /* set the F_BIT in CPSR to the F_BIT of the passed CPSR */
        msr     CPSR_fc, r0     /* store in CPSR */
        mov     r0, r3          /* return the previous CPSR value */
        bx      lr

        .end
