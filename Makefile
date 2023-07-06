BIN = kfs.bin
ISO = kfs.iso
CC = i686-elf-gcc
AS = i686-elf-as
CFLAGS += -ffreestanding -O2 -Wall -Werror -nostdlib

BOOTDIR = isodir/boot/
ISODIR = isodir/

BOOT = boot
KERNEL = kernel

OBJSRC = $(patsubst %, %.o, $(BOOT))
OBJSRC += $(patsubst %, %.o, $(KERNEL))

all: $(OBJSRC)
	$(CC) -T linker.ld -o $(BIN) $(CFLAGS) $(OBJSRC) -lgcc
	cp $(BIN) $(BOOTDIR)
	grub-mkrescue -o $(ISO) $(ISODIR)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJSRC)
	rm -f $(BIN)

fclean: clean
	rm -f $(ISO)
