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

TARGET = blinker
OBJS   = crt.o main.o board.o timer.o blinker.o

all: $(TARGET)-flash.bin $(TARGET)-sram.bin

$(TARGET)-flash.elf: $(OBJS)
	$(LD) -Map $(TARGET).map -Tat91sam7s256-flash.ld -o $@ $^

$(TARGET)-sram.elf: $(OBJS)
	$(LD) -Map $(TARGET).map -Tat91sam7s256-sram.ld -o $@ $^

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

OPENOCD_ARGS = -d0
OPENOCD_ARGS += -c "arm7_9 dcc_downloads enable"
OPENOCD_ARGS += -c "arm7_9 fast_memory_access enable"
FLASH_ARGS = -c init -c targets
FLASH_ARGS += -c halt
FLASH_ARGS += -c "flash write_image erase $(TARGET).bin 0x100000 bin" -c "verify_image $(TARGET).bin 0x100000"
FLASH_ARGS += -c "reset run"
FLASH_ARGS += -c "resume"
FLASH_ARGS += -c shutdown

%.upload: %.bin
	./openocd-flash.sh $< -f $(OPENOCD_ADAPTER) -f openocd/at91sam7s256.cfg

debug:
	$(OPENOCD) -f $(OPENOCD_ADAPTER) -f openocd/at91sam7s256.cfg $(OPENOCD_ARGS) -c init -c halt

clean:
	- rm -f $(OBJS) *.lst *.hex *.map *.bin *.elf
