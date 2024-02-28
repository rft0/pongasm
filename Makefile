ASM = nasm
ARCH = -f elf64

SRCS = $(wildcard ./src/*.asm)

TARGET = out

all: dene

dene:
	$(ASM) $(ARCH) $(SRCS) -o $(TARGET).o && ld $(TARGET).o -o ./bin/$(TARGET) && rm -rf *.o && ./bin/$(TARGET)

sdl:
	$(ASM) $(ARCH) $(SRCS) -o $(TARGET).o && ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 $(TARGET).o -o ./bin/$(TARGET) -lSDL && rm -rf *.o && ./bin/$(TARGET)

dev:
	$(ASM) $(ARCH) $(SRCS) -o $(TARGET).o && ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lX11 $(TARGET).o -o ./bin/$(TARGET) && rm -rf *.o && ./bin/$(TARGET)

libc:
	$(ASM) $(ARCH) $(SRCS) -o $(TARGET).o && ld -m elf_i386 $(TARGET).o -o ./bin/$(TARGET) -lc -e main -dynamic-linker /lib/ld-linux.so.2 && rm -rf *.o && ./bin/$(TARGET)
