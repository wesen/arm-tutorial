#ifndef CDC_H__
#define CDC_H__

#define AT91_EP_IN_SIZE 0x40

/* CDC Class Specific Request Code */
#define GET_LINE_CODING               0x21A1
#define SET_LINE_CODING               0x2021
#define SET_CONTROL_LINE_STATE        0x2221

typedef struct at91_cdc_s {
  AT91PS_UDP pUdp;
  uint8_t currentConfiguration;
  uint8_t currentConnection;
  uint8_t currentRcvBank;
} at91_cdc_t;

typedef struct at91_cdc_line_coding_s {
  unsigned int dwDTERRate;
  char bCharFormat;
  char bParityType;
  char bDataBits;
} at91_cdc_line_coding_t;

void at91_cdc_init(at91_cdc_t *cdc, AT91PS_UDP pUdp);
uint8_t at91_cdc_is_configured(at91_cdc_t *cdc);

void at91_cdc_enumerate(at91_cdc_t *cdc);

#endif /* CDC_H__ */
