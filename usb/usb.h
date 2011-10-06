#ifndef USB_H__
#define USB_H__

typedef struct at91_usb_s {
  AT91PS_UDP pUdp;
  uint8_t currentConfiguration;
  uint8_t currentRcvBank;
} at91_usb_t;

/* USB standard request code */
#define STD_GET_STATUS_ZERO           0x0080
#define STD_GET_STATUS_INTERFACE      0x0081
#define STD_GET_STATUS_ENDPOINT       0x0082

#define STD_CLEAR_FEATURE_ZERO        0x0100
#define STD_CLEAR_FEATURE_INTERFACE   0x0101
#define STD_CLEAR_FEATURE_ENDPOINT    0x0102

#define STD_SET_FEATURE_ZERO          0x0300
#define STD_SET_FEATURE_INTERFACE     0x0301
#define STD_SET_FEATURE_ENDPOINT      0x0302

#define STD_SET_ADDRESS               0x0500
#define STD_GET_DESCRIPTOR            0x0680
#define STD_SET_DESCRIPTOR            0x0700
#define STD_GET_CONFIGURATION         0x0880
#define STD_SET_CONFIGURATION         0x0900
#define STD_GET_INTERFACE             0x0A81
#define STD_SET_INTERFACE             0x0B01
#define STD_SYNCH_FRAME               0x0C82

int at91_udp_is_configured(at91_usb_t *cdc);
uint32_t at91_udp_read(at91_usb_t *cdc, char *data, uint32_t length);
uint32_t at91_udp_write(at91_usb_t *cdc, char *data, uint32_t length);

void at91_usb_send_data(AT91PS_UDP pUdp, const char *data, uint32_t length);
void at91_usb_send_zlp(AT91PS_UDP pUdp);
void at91_usb_send_stall(AT91PS_UDP pUdp);

#endif /* USB_H__ */
