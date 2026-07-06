CC = gcc
CFLAGS = -Wall -Wextra -std=c11 -Iinc

SRC := $(wildcard src/*.c)
OBJ := $(SRC:src/%.c=obj/%.o)

TARGET = bin/smake

RES := res/helptext.txt

all: dirs $(TARGET)

dirs:
	mkdir -p obj bin

$(TARGET): $(OBJ)
	$(CC) $(OBJ) -o $(TARGET)

obj/%.o: src/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf obj bin

copy-res:
	mkdir -p bin/res
	cp $(RES) bin/res/

run: all copy-res
	./$(TARGET)

install: all copy-res
	install -m 755 $(TARGET) /usr/local/bin/smake
	mkdir -p /usr/local/share/smake
	cp $(RES) /usr/local/share/smake/helptext.txt

uninstall:
	rm -f /usr/local/bin/smake
	rm -rf /usr/local/share/smake

.PHONY: all clean dirs run install uninstall copy-res