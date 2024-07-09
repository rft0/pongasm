# Pongasm
A 16-bit pong game that lives in boot sector!

![](https://github.com/rft0/pongasm/blob/main/img/pong.png?raw=true)

## Requirements
* nasm
* qemu-i386 (for testing)
* make (optional)

## Building
### Manually
```
nasm ./src/main.asm -o ./bin/image
```
Run it via
```
qemu-system-i386 -drive format=raw,file="./bin/image"
```

### With Make
For build & run just run `make dev`<br>
For just building run `make`

## Making Bootable USB Drive
* Build image with either `make` or commands above
* Plug your USB Drive
* search it via commands like `lsblk`
* use `dd` to write image into your USB drive

## Controls
`w` - Move upward.\
`s` - Move downward.\
`r` - Restart game.\
