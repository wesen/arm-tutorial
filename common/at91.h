#ifndef AT91_H__
#define AT91_H__

#include <inttypes.h>
#include "at91sam7s256.h"

#ifdef __cplusplus
extern "C" {
#endif

__inline void at91_pio_cfg_output(AT91PS_PIO pPio, uint32_t pio) {
  pPio->PIO_PER = pio; /* pio enable */
  pPio->PIO_OER = pio; /* output enable */
}

__inline void at91_pio_cfg_input(AT91PS_PIO pPio, uint32_t pio) {
  pPio->PIO_ODR = pio; /* output disable */
  pPio->PIO_PER = pio; /* pio enable */
}

__inline void at91_pio_cfg_open_drain(AT91PS_PIO pPio, uint32_t pio) {
  /* see datasheet pp. 244, 259 */
  /* configure multidrive */
  /* XXX why disable all others */
  pPio->PIO_MDDR = ~pio;
  pPio->PIO_MDER = pio;
}

__inline void at91_pio_cfg_pullup(AT91PS_PIO pPio, uint32_t pio) {
  /* see datasheet p. 260 */
  /* configure pullup */
  /* XX why disable all others */
  pPio->PIO_PPUDR = ~pio;
  pPio->PIO_PPUER = pio;
}

__inline void at91_pio_cfg_input_filter(AT91PS_PIO pPio, uint32_t pio) {
  /* configure input filter */
  pPio->PIO_IFDR = ~pio;
  pPio->PIO_IFER = pio;
}

__inline uint32_t at91_pio_get_input(AT91PS_PIO pPio) {
  return pPio->PIO_PDSR;
}

__inline uint32_t at91_pio_is_input_set(AT91PS_PIO pPio, uint32_t flag) {
  return (at91_pio_get_input(pPio) & flag);
}

__inline void at91_pio_set_output(AT91PS_PIO pPio, uint32_t flag) {
  pPio->PIO_SODR = flag;
}

__inline void at91_pio_clear_output(AT91PS_PIO pPio, uint32_t flag) {
  pPio->PIO_CODR = flag;
}

__inline void at91_pio_force_output(AT91PS_PIO pPio, uint32_t flag) {
  pPio->PIO_ODSR = flag;
}

__inline void at91_pio_enable(AT91PS_PIO pPio, uint32_t flag) {
  pPio->PIO_PER = flag;
}

__inline void at91_pio_disable(AT91PS_PIO pPio, uint32_t flag) {
  pPio->PIO_PDR = flag;
}

#ifdef __cplusplus
}
#endif

#endif /* AT91_H__ */
