ASM = nasm
ARCH = -f elf32

SRCS = $(wildcard ./src/*.asm)

TARGET = out

all: mk

mk:
	nasm ./src/main.asm -o ./bin/$(TARGET) && qemu-system-i386 -drive format=raw,file="./bin/$(TARGET)"

dev:
	$(ASM) $(ARCH) $(SRCS) -o $(TARGET).o && ld -m elf_i386 $(TARGET).o -o ./bin/$(TARGET) && rm -rf *.o && ./bin/$(TARGET)

sdl:
	$(ASM) $(ARCH) $(SRCS) -o $(TARGET).o && ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 $(TARGET).o -o ./bin/$(TARGET) -lSDL && rm -rf *.o && ./bin/$(TARGET)

devn:
	$(ASM) $(ARCH) $(SRCS) -o $(TARGET).o && ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lX11 $(TARGET).o -o ./bin/$(TARGET) && rm -rf *.o && ./bin/$(TARGET)