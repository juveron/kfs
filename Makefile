BIN = kfs.bin
ISO = kfs.iso
CC = i686-elf-gcc
AS = i686-elf-as
SCRIPT = install_grub.sh 
CFLAGS += -ffreestanding -O2 -Wall -Werror -nostdlib

BOOTDIR = isodir/boot/
ISODIR = isodir/
GRUBDIR = isodir/boot/grub/

BOOT = src/boot
KERNEL = src/kernel

OBJSRC = $(patsubst %, %.o, $(BOOT))
OBJSRC += $(patsubst %, %.o, $(KERNEL))

all: $(OBJSRC)
	$(CC) -T linker.ld -o $(BIN) $(CFLAGS) $(OBJSRC) -lgcc
	mkdir -p $(GRUBDIR)
	cp $(BIN) $(BOOTDIR)
	cp grub.cfg $(GRUBDIR)
	grub-mkrescue -o $(ISO) $(ISODIR)
	cp $(ISO) $(BOOTDIR)
	rm -f $(BIN)
	rm -f $(ISO)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

installQEMU:
	brew install qemu

installCOMPILATOR:
	brew install $(CC)

installDEPENDENCIES:
	chmod +x $(SCRIPT)
	./$(SCRIPT)

startWithBIN:
	qemu-system-i386 -kernel $(BOOTDIR)$(BIN)

startWithISO:
	qemu-system-i386 -cdrom $(BOOTDIR)$(ISO)

clean:
	rm -f $(OBJSRC)

fclean: clean
	rm -rf $(ISODIR)

.PHONY: clean fclean startWithBIN startWithISO installQEMU installCOMPILATOR installDEPENDENCIES
