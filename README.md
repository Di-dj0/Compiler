# Compiler
A compiler capable of understanding and creating code with a new language.

# How to Create the Compiler
To use this compiler, you will need the Flex and Bison applications installed.

- First use the command to create the bison files and headers. The prefix '-d' make it explicit to bison to create a header file alongside its C file:

```console
bison -d syntax-parser.y
```

- Then create the flex files. This must create the file "lex.yy.c":

```console
flex lexical-parser.l
```

- Finally, create the executable file using gcc:

```console
gcc -o <name_of_file> lex.yy.c syntax-parser.tab.c
```

- Done!

# How to use it
The new <name_of_file>.exe that you create it can be use in bash to create .pil files. Using the 'testes.txt' file you can create your first .pil file, using these commands (in a prompt window):
<name_of_file> testes.txt

This creates a file named "input.pil", wich can be used with pilheitor to use your programm (you need to compile pilheitor.cpp first). An example of use:
pilheitor input.pil
