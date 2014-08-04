# Makefile for libyrmcds

PREFIX = /usr/local

CC = gcc
CXX = g++ -std=gnu++11
CPPFLAGS = -D_GNU_SOURCE
OPTFLAGS = -gdwarf-3 -O2
CFLAGS = -Wall $(OPTFLAGS)
CXXFLAGS = $(CFLAGS) -Wnon-virtual-dtor -Woverloaded-virtual
LDFLAGS = -L.
LDLIBS = -lyrmcds -lpthread

EXE = yc yc-cnt
LIB = libyrmcds.a
PACKAGES = build-essential subversion doxygen

CHEADERS = $(wildcard *.h)
CSOURCES = $(wildcard *.c)
COBJECTS = $(patsubst %.c,%.o,$(CSOURCES))
LIB_OBJECTS = $(filter-out yc.o yc-cnt.o,$(COBJECTS)) lz4/lz4.o

all: lib $(EXE)
lib: $(LIB)

lz4/lz4.c:
	svn checkout http://lz4.googlecode.com/svn/trunk/ lz4
lz4/lz4.o: lz4/lz4.c
	$(CC) -std=c99 -O3 -Ilz4 -c -o $@ $<

yc: yc.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

yc-cnt: yc-cnt.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

$(COBJECTS): $(CHEADERS)
$(EXE): $(LIB)

$(LIB): $(LIB_OBJECTS)
	$(AR) rcus $@ $^

html:
	rm -rf html
	doxygen

serve: html
	@cd html; python -m SimpleHTTPServer 8888 || true

clean:
	rm -rf *.o html $(EXE) $(LIB)

setup:
	sudo apt-get install -y --install-recommends $(PACKAGES)

.PHONY: all lib tests install html serve clean setup
