#include "usb.h"

uint32_t at91_udp_read(at91_usb_t *usb, char *data, uint32_t length) {
  AT91PS_UDP pUdp = usb->pUdp;

  uint32_t bytes_received = 0;

  while (length > 0) {
  }

  return bytes_received;
}
