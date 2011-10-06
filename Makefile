TOOLCHAIN_PREFIX ?= arm-none-eabi-

CC = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)g++
LD = $(TOOLCHAIN_PREFIX)ld
AR = $(TOOLCHAIN_PREFIX)ar
AS = $(TOOLCHAIN_PREFIX)as
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
OBJDUMP = $(TOOLCHAIN_PREFIX)objdump
OPENOCD ?= openocd

MCU = arm7tdmi

C_CXX_FLAGS = -I. -fno-common -g -Icommon -mcpu=$(MCU)
CFLAGS	 += $(C_CXX_FLAGS) -std=gnu99
CXXFLAGS += $(C_CXX_FLAGS)
ASFLAGS	 += -ahls -mapcs-32 -mcpu=$(MCU)

BLINKER_OBJS   = blinker/board.o blinker/crt.o blinker/main.o blinker/timer.o blinker/blinker.o
BLINKER_CPP_OBJS   = common/board.o common/crt.o blinker-cpp/main.o
BLINKER_C_OBJS   = common/board.o common/crt.o blinker-c/main.o

all: blinker-flash.bin blinker-sram.bin

# targets

blinker-flash.elf: $(BLINKER_OBJS)
	$(LD) -Map $@.map -Tat91sam7s256-flash.ld -o $@ $^

blinker-sram.elf: $(BLINKER_OBJS)
	$(LD) -Map $@.map  -Tat91sam7s256-sram.ld -o $@ $^

blinker-cpp.elf: $(BLINKER_CPP_OBJS)
	$(CXX) -nostartfiles -nostdlib -Wl,-Map=$@.map,--cref  -Tat91sam7s256-sram.ld -o $@ $^ -lgcc -lc -lstdc++ -lnosys

blinker-cpp.elf: $(BLINKER_CPP_OBJS)
	$(CC) -nostartfiles -nostdlib -Wl,-Map=$@.map,--cref  -Tat91sam7s256-sram.ld -o $@ $^


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
	$(OPENOCD) -f $(OPENOCD_ADAPTER) -f openocd/at91sam7s256.cfg $(OPENOCD_ARGS) -c "arm7_9 dcc_downloads enable" -c "arm7_9 fast_memory_access enable" -c init -c halt

clean:
	- rm -f *.o blinker/*.o blinker-cpp/*.o *.lst *.hex *.map *.bin *.elf
