SDK=$(shell xcrun --sdk macosx --show-sdk-path)
BUILD_DATE=$(shell date +%Y-%m-%d)
LLVM=/usr/local/opt/llvm
CC=xcrun clang
CFLAGS=-Os -Wall -std=c++1y -lc++ --sysroot $(SDK) -DCOMPILE_DATE=\"$(BUILD_DATE)\" -framework Foundation -I$(LLVM)/include -L$(LLVM)/lib -lclang

C_PATH='$(HOME)/Library/Application Support/TextMate/Bundles/c.tmbundle/Syntaxes/Platform'
OBJC_PATH='$(HOME)/Library/Application Support/TextMate/Bundles/objective-c.tmbundle/Syntaxes/Platform'

all: c objective-c

c: generator
	./generator --sdk=$(SDK) --grammar=$(C_PATH).tmLanguage --text=$(C_PATH).md --suffix='.c' includes.c

objective-c: generator
	./generator --sdk=$(SDK) --grammar=$(OBJC_PATH).tmLanguage --text=$(OBJC_PATH).md --suffix='.objc' --cocoa includes.mm

generator: generator.mm Makefile
	@$(CC) $(CFLAGS) -o $@ $<

.PHONY: all c objective-c
