# 2006math5.hs, 2008math4.cpp のコンパイルとテスト
# 実行方法
# $ make (引数なし)
#
# 動作確認を行った環境
# - Windows 10
# - Cygwin 64bit版 (2.6.1)
# - GHC 8.0.1 (Windows 64bit版)
# - GCC 5.4.0

TARGET_2006=2006math5
TARGET_2008_CPP=2008math4
TARGET_2008_ASM=2008math4a
TARGET_2008_HASKELL=2008math4hs
TARGETS=$(TARGET_2006) $(TARGET_2008_CPP) $(TARGET_2008_ASM) $(TARGET_2008_HASKELL)
TEST_SCRIPT=2008math4check.rb

OBJ_2008_CPP=2008math4.o
OBJ_2008_ASM_C=2008math4a.o
OBJ_2008_ASM_S=2008math4asm.o
OBJS=$(OBJ_2008_CPP) $(OBJ_2008_ASM_C) $(OBJ_2008_ASM_S)

SOURCE_2006=2006math5.hs
SOURCE_2008_CPP=2008math4.cpp
SOURCE_2008_ASM_C=2008math4a.c
SOURCE_2008_ASM_S=2008math4asm.s
SOURCE_2008_HASKELL=2008math4.hs

OPT_2006_1=1
OPT_2006_2=2
OPT_2006_3=3

LOG_2006_1=log2006_1.txt
LOG_2006_2=log2006_2.txt
LOG_2006_3=log2006_3.txt
LOGS_2006=$(LOG_2006_1) $(LOG_2006_2) $(LOG_2006_3)
LOGS=$(LOGS_2006)

DIFF=diff
HASKELL=ghc
RUBY=ruby
HASKELLFLAGS=-O
LDFLAGS=

AS=as
CC=gcc
CXX=g++
ASFLAGS=
CFLAGS=-std=gnu99 -g -O -Wall
CPPFLAGS=-std=c++14 -g -O -Wall
CASMFLAGS=-mavx2 -masm=intel
LIBPATH=
LIBS=

.PHONY: all clean rebuild

all: $(TARGETS)
	./$(TARGET_2008_CPP)
	./$(TARGET_2008_ASM)
	./$(TARGET_2008_HASKELL)
	$(RUBY) ./$(TEST_SCRIPT)

$(TARGET_2006): $(SOURCE_2006)
	$(HASKELL) $(HASKELLFLAGS) -o $@ $< $(LDFLAGS)
	./$@ $(OPT_2006_1) | tee $(LOG_2006_1)
	./$@ $(OPT_2006_2) | tee $(LOG_2006_2)
	./$@ $(OPT_2006_3) | tee $(LOG_2006_3)
	$(DIFF) $(LOG_2006_1) $(LOG_2006_2)
	$(DIFF) $(LOG_2006_1) $(LOG_2006_3)
	time ./$@ $(OPT_2006_1) > /dev/null
	time ./$@ $(OPT_2006_2) > /dev/null
	time ./$@ $(OPT_2006_3) > /dev/null
	time ./$@ $(OPT_2006_1) > /dev/null
	time ./$@ $(OPT_2006_2) > /dev/null
	time ./$@ $(OPT_2006_3) > /dev/null

$(TARGET_2008_CPP): $(OBJ_2008_CPP)
	$(CXX) $(LIBPATH) -o $@ $^ $(LDFLAGS) $(LIBS)
	./$@

$(TARGET_2008_ASM): $(OBJ_2008_ASM_C) $(OBJ_2008_ASM_S)
	$(CC) $(LIBPATH) -o $@ $^ $(LDFLAGS) $(LIBS)
	./$@

$(TARGET_2008_HASKELL): $(SOURCE_2008_HASKELL)
	$(HASKELL) $(HASKELLFLAGS) -o $@ $< $(LDFLAGS)

$(OBJ_2008_CPP): $(SOURCE_2008_CPP)
	$(CXX) $(CPPFLAGS) -c -o $@ $<

$(OBJ_2008_ASM_C) : $(SOURCE_2008_ASM_C)
	$(CC) $(CFLAGS) $(CASMFLAGS) -c -o $@ $<

$(OBJ_2008_ASM_S) : $(SOURCE_2008_ASM_S)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	$(RM) $(TARGETS) $(OBJS) $(LOGS) ./*.o ./*.hi

rebuild: clean all
