
CC=gdc-4.6
LDFLAGS=

PROG_NAME=text2arff
SRCS=							\
	text2arff.d	

INCLUDE_DIR=include

DEBUG=0
ifeq (${DEBUG},1)
	DEBUG_FLAGS=-W -Wall -ansi -pedantic -g
endif
UNIT_TEST=0
ifeq (${UNIT_TEST},1)
	DEBUG_FLAGS=-funittest
endif


CFLAGS=${DEBUG_FLAGS} -I ${INCLUDE_DIR}


OBJS=${SRCS:.d=.o}
.PHONY: clean mrproper


${PROG_NAME}: ${OBJS}
	${CC} -o $@ ${OBJS} ${LDFLAGS} ${CFLAGS}

%.o: src/%.d
	${CC} -o $@ -c $< ${CFLAGS}


mrproper: clean
	rm -rf *~ ${PROG_NAME}

clean:
	rm -rf *.o
