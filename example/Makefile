libdumb.so: dumb.o
	gcc --shared -o libdumb.so dumb.o

dumb.o: dumb.c
	gcc -c dumb.c

clean:
	rm -f *.o *.so
