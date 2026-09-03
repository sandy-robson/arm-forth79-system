# ARMv6 Forth-79 (Attila) Cross-Compilation Makefile
CC      = arm-linux-gnueabihf-gcc
CFLAGS  = -marm -march=armv6z+fp -mfpu=vfp -mfloat-abi=hard -O2 -Wall
LDFLAGS = 

QEMU    = qemu-arm
QEMU_LIB = /usr/arm-linux-gnueabihf

TARGET  = attila
C_SRCS  = attila.c
ASM_SRCS= boot4th.s
OBJS    = $(C_SRCS:.c=.o) $(ASM_SRCS:.s=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

run: $(TARGET)
	$(QEMU) -L $(QEMU_LIB) ./$(TARGET)

clean:
	rm -f $(OBJS) $(TARGET)

.PHONY: all run clean
