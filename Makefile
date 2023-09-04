BIN = kfs.bin
ISO = kfs.iso
CC = i686-elf-gcc
AS = i686-elf-as
CFLAGS += -ffreestanding -O2 -Wall -Werror -nostdlib

BOOTDIR = isodir/boot/
ISODIR = isodir/

BOOT = src/boot
KERNEL = src/kernel

OBJSRC = src/$(patsubst %, %.o, $(BOOT))
OBJSRC += src/$(patsubst %, %.o, $(KERNEL))

all: $(OBJSRC)
	$(CC) -T linker.ld -o $(BIN) $(CFLAGS) $(OBJSRC) -lgcc
	cp $(BIN) $(BOOTDIR)
	grub-mkrescue -o $(ISO) $(ISODIR)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

installPackage:
	brew install $(CC)
	brew install qemu

run: docker-run

docker-run: 
	clear 
	@-docker stop docker-kfs 
	@-docker rm docker-kfs 
	@docker build --platform linux/amd64 -t docker-kfs . 
	@docker run -d --name docker-kfs --rm -i -t docker-kfs 
	@docker cp src/. docker-kfs:/kfs 
	@docker cp grub.cfg docker-kfs:/kfs 
	@docker exec -t docker-kfs nasm -f elf32 boot.s -o boot.o 
	@docker exec -t docker-kfs gcc -m32 -ffreestanding ${CFLAGS} -c ${KERNEL} 
	@docker exec -t docker-kfs ld -m elf_i386 -T linker.ld -o kfs.bin ${OBJSRC} 
	docker exec -t docker-kfs mkdir -p isodir/boot/grub 
	docker exec -t docker-kfs mv grub.cfg isodir/boot/grub 
	docker exec -t docker-kfs mv kfs.bin isodir/boot 
	docker exec -t docker-kfs grub-mkrescue -o kfs.iso ./isodir/ 
	docker cp docker-kfs:/kfs/kfs.iso boot/kfs.iso 
	qemu-system-i386 -cdrom boot/kfs.iso 

startWithBIN:
	qemu-system-i386 -kernel $(BIN)

startWithISO:
	qemu-system-i386 -cdrom $(ISO)

clean:
	rm -f $(OBJSRC)
	rm -f $(BIN)
	rm -f $(BOOTDIR)$(BIN)

fclean: clean
	rm -f $(ISO)

.PHONY: clean fclean startWithBIN startWithISO installPackage
