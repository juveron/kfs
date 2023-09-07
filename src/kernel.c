#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>

#if defined(__linux__)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif
 
#if !defined(__i386__)
#error "This tutorial needs to be compiled with a ix86-elf compiler"
#endif

enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};
 
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
	return fg | bg << 4;
}
 
static inline uint16_t vga_entry(unsigned char uc, uint8_t color) 
{
	return (uint16_t) uc | (uint16_t) color << 8;
}
 
size_t strlen(const char* str) 
{
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}
 
static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
 
size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;
 
void terminal_initialize(void) 
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xB8000;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}
 
void terminal_setcolor(uint8_t color) 
{
	terminal_color = color;
}
 
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) 
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}
 
void terminal_putchar(char c) 
{
	if (c == '\n') {
		terminal_row++;
		terminal_column = 0;
	}
	else {
		terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
		if (++terminal_column == VGA_WIDTH) {
			terminal_column = 0;
			if (++terminal_row == VGA_HEIGHT)
				terminal_row = 0;
		}
	}
}
 
void terminal_write(const char* data, size_t size) 
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}
 
void terminal_writestring(const char* data) 
{
	terminal_write(data, strlen(data));
}

void terminal_itoa_base(uint32_t num, uint32_t base) {
	const char* b = "0123456789abcdef";

	uint32_t divisor = 1;

	while (divisor * base < num) {
		divisor *= base;
	}
	while (divisor > 0) {
		terminal_putchar(b[num / divisor]);
		num = num % divisor;
		divisor = divisor / base;
	}
}

void printk(const char *s, ...) {
	va_list	args;

	va_start(args, s);
	for (uint32_t i = 0 ; s[i] ; i++)
	{
		if (s[i] != '%') {
			terminal_putchar(s[i]);
			continue;
		}

		++i;
		if (s[i] == '%') {
			terminal_putchar('%');
			continue;
		}
		else if (s[i] == 'c') {
			terminal_color = VGA_COLOR_CYAN;
			terminal_putchar(va_arg(args, int));
			terminal_color = VGA_COLOR_WHITE;
			continue;
		}
		else if (s[i] == 's') {
			terminal_color = VGA_COLOR_LIGHT_BLUE;
			terminal_writestring(va_arg(args, char *));
			terminal_color = VGA_COLOR_WHITE;
		}
		else if (s[i] == 'd') {
			terminal_color = VGA_COLOR_LIGHT_RED;
			terminal_itoa_base(va_arg(args, uint32_t), 10);
			terminal_color = VGA_COLOR_WHITE;
			continue;
		}
		else if (s[i] == 'x') {
			terminal_color = VGA_COLOR_LIGHT_MAGENTA;
			terminal_writestring("0x");
			terminal_itoa_base(va_arg(args, uint32_t), 16);
			terminal_color = VGA_COLOR_WHITE;
			continue;
		}
	}
	va_end(args);
}

struct gdt_entry {
    uint16_t limit_low;
    uint16_t base_low;
    uint8_t base_middle;
    uint8_t access;
    uint8_t granularity;
    uint8_t base_high;
};

struct gdt_ptr {
    uint16_t limit;
    uint32_t base;
};

extern void load_gdt(struct gdt_ptr* gdt_ptr);
struct gdt_entry gdt[6];

void init_gdt(void) {

    gdt[0] = (struct gdt_entry) {0, 0, 0, 0, 0, 0};
    gdt[1] = (struct gdt_entry) {0xFFFF, 0x0000, 0x00, 0x9A, 0xCF, 0x00};
    gdt[2] = (struct gdt_entry) {0xFFFF, 0x0000, 0x00, 0x92, 0xCF, 0x00};
    gdt[3] = (struct gdt_entry) {0xFFFF, 0x0000, 0x00, 0xFA, 0xCF, 0x00};
    gdt[4] = (struct gdt_entry) {0xFFFF, 0x0000, 0x00, 0xF2, 0xCF, 0x00};
    gdt[5] = (struct gdt_entry) {0xFFFF, 0x0000, 0x00, 0xF0, 0xCF, 0x00};

    struct gdt_ptr gdt_ptr = {
        .limit = sizeof(gdt) - 1,
        .base = (uint32_t)&gdt[0]
    };

    load_gdt(&gdt_ptr);
}


void kernel_main(void) 
{

    init_gdt();

	/* Initialize terminal interface */
	terminal_initialize();
 	
    printk("GDT segments:\n");
    for (int i = 0; i < 6; i++) {
        struct gdt_entry* entry = &gdt[i];
        printk("Segment %d:\n", i);
        printk("  Limit Low: %x", entry->limit_low);
        printk("  Base Low: %x", entry->base_low);
        printk("  Base Middle: %x", entry->base_middle);
        printk("  Access: %x\n", entry->access);
        printk("  Granularity: %x", entry->granularity);
        printk("  Base High: %x\n", entry->base_high);
    }

}