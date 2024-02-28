import subprocess

SRC_FILES = [
    "./src/constants.asm",
    "./src/main.asm"
]

TARGET_NAME = "out"
TARGET = f"./bin/{TARGET_NAME}"

objs = []

def asm(src, out):
    objs.append(out)
    subprocess.run(["nasm", "-f", "elf32", src, "-o", out])

def link():
    subprocess.run(["ld", "-m", "elf_i386", "-o", TARGET] + objs)

def clear():
    for obj in objs:
        subprocess.run(["rm", obj])

if __name__ == "__main__":
    for src in SRC_FILES:
        obj = src.replace(".asm", ".o")
        asm(src, obj)

    link()