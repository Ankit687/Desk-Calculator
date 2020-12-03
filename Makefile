all:
	as --32 -g mydc.s -o dc.o
	gcc209 -g -m32 dc.o -o dc
clean:
	rm -rf dc *~ dc.o core
