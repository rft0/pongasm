ASM = nasm
ARCH = -f elf32

SRCS = $(wildcard ./src/*.asm)

TARGET = image

all: build

dev:
	nasm $(SRCS) -o ./bin/$(TARGET) && qemu-system-i386 -drive format=raw,file="./bin/$(TARGET)"

build:
	nasm $(SRCS) -o ./bin/$(TARGET)