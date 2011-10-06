TOOLCHAIN_PREFIX ?= arm-none-eabi-

CC = $(TOOLCHAIN_PREFIX)gcc
LD = $(TOOLCHAIN_PREFIX)ld
AR = $(TOOLCHAIN_PREFIX)ar
AS = $(TOOLCHAIN_PREFIX)as
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
OBJDUMP = $(TOOLCHAIN_PREFIX)objdump
OPENOCD ?= openocd

CFLAGS	 += -I. -fno-common -g -std=gnu99
CXXFLAGS += -I. -fno-common -g
ASFLAGS	 += -ahls -mapcs-32

BLINKER_OBJS   = blinker/board.o blinker/crt.o blinker/main.o blinker/timer.o blinker/blinker.o

all: blinker-flash.bin blinker-sram.bin

blinker-flash.elf: $(BLINKER_OBJS)
	$(LD) -Map $@.map -Tat91sam7s256-flash.ld -o $@ $^

blinker-sram.elf: $(BLINKER_OBJS)
	$(LD) -Map $@.map  -Tat91sam7s256-sram.ld -o $@ $^

# common rules

%.bin: %.elf
	$(OBJCOPY) --output-target=binary $< $@

%.hex: %.elf
	$(OBJCOPY) --output-target=ihex $< $@

%.srec: %.elf
	$(OBJCOPY) --output-target=srec $< $@

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

%.s: %.c
	$(CC) -S $(CFLAGS) -fverbose-asm $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.hex: %.elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

OPENOCD_ADAPTER = openocd/jtagrs232.cfg

%.upload: %.bin
	./openocd-flash.sh $< -f $(OPENOCD_ADAPTER) -f openocd/at91sam7s256.cfg

debug:
	$(OPENOCD) -f $(OPENOCD_ADAPTER) -f openocd/at91sam7s256.cfg $(OPENOCD_ARGS) -c init -c halt

clean:
	- rm -f *.o blinker/*.o *.lst *.hex *.map *.bin *.elf
