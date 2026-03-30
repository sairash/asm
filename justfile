
build file *args:
    @nasm -f elf64 {{file}} -o main.o
    @ld main.o -o main
    @./main {{args}}
