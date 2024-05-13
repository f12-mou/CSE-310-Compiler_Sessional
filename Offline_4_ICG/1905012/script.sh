yacc -d 1905012.y
g++ -w -c -o y.o y.tab.c
flex -o start.c 1905012.l
g++ -w -c -o l.o start.c
g++ y.o l.o -lfl -o simple
./simple input.c