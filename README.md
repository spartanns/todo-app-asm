# TODO List App in x64 NASM Assembly

### Installation

Get the source:

```sh
git clone https://github.com/spartanns/todo-app-asm.git
```

Enter the source directory:

```sh
cd todo-app-asm
```

Compile the source with NASM:

```
nasm -f elf64 todo.asm
ld todo.o -o todo
```

Run:

```sh
./todo
```
