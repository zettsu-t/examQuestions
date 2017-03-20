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
TARGET_2008_CPP=2008math4c
TARGET_2008_ASM=2008math4a
TARGET_2008_HASKELL=2008math4hs
TARGET_2008_RUST=2008math4rs
TARGETS=$(TARGET_2006) $(TARGET_2008_CPP) $(TARGET_2008_ASM) $(TARGET_2008_HASKELL) $(TARGET_2008_RUST)
TEST_SCRIPT=2008math4check.rb

OBJ_2008_CPP=2008math4c.o
OBJ_2008_ASM_C=2008math4a.o
OBJ_2008_ASM_S=2008math4asm.o
OBJ_2008_HASKELL=2008math4.hi
OBJS=$(OBJ_2008_CPP) $(OBJ_2008_ASM_C) $(OBJ_2008_ASM_S) $(OBJ_2008_HASKELL)

SOURCE_2006=2006math5.hs
SOURCE_2008_CPP=2008math4c.cpp
SOURCE_2008_ASM_C=2008math4a.c
SOURCE_2008_ASM_S=2008math4asm.s
SOURCE_2008_HASKELL=2008math4.hs
SOURCE_2008_RUST=2008math4rs.rs

OPT_2006_1=1
OPT_2006_2=2
OPT_2006_3=3

LOG_2006_1=log2006_1.txt
LOG_2006_2=log2006_2.txt
LOG_2006_3=log2006_3.txt
LOG_2008_HS=log2008_hs.txt
LOGS_2006=$(LOG_2006_1) $(LOG_2006_2) $(LOG_2006_3) $(LOG_2008_HS)
LOGS=$(LOGS_2006)

DIFF=diff
HASKELL=ghc
RUST=rustc
RUBY=ruby
HASKELLPROFILE=-with-rtsopts="-hT -H512m" -rtsopts
HASKELLRTS=+RTS -sstderr -RTS
LOG_2008_HS_OPT=$(HASKELLRTS) nomap
HASKELLFLAGS=-O
RUSTFLAGS=
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

.PHONY: all profile clean rebuild force

all: $(TARGETS)
	./$(TARGET_2008_CPP)
	./$(TARGET_2008_ASM)
	./$(TARGET_2008_HASKELL)
	./$(TARGET_2008_RUST)
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

$(TARGET_2008_RUST): $(SOURCE_2008_RUST)
	$(RUST) $(RUSTFLAGS) -o $@ $<

$(OBJ_2008_CPP): $(SOURCE_2008_CPP)
	$(CXX) $(CPPFLAGS) -c -o $@ $<

$(OBJ_2008_ASM_C) : $(SOURCE_2008_ASM_C)
	$(CC) $(CFLAGS) $(CASMFLAGS) -c -o $@ $<

$(OBJ_2008_ASM_S) : $(SOURCE_2008_ASM_S)
	$(AS) $(ASFLAGS) -o $@ $<

measure=echo './$(TARGET_2008_HASKELL) nomap' $1 $2 $3 $4 >> $(LOG_2008_HS) ; time ./$(TARGET_2008_HASKELL) $(LOG_2008_HS_OPT) $1 $2 $3 $4 > /dev/null 2>> $(LOG_2008_HS)

profile: force
	$(RM) $(TARGET_2008_HASKELL) $(OBJ_2008_HASKELL) $(LOG_2008_HS)
	$(HASKELL) $(HASKELLPROFILE) $(HASKELLFLAGS) -o $(TARGET_2008_HASKELL) $(SOURCE_2008_HASKELL) $(LDFLAGS)
	./2008math4hs $(LOG_2008_HS_OPT) 1 9 2 10 > /dev/null 2>> /dev/null
	$(call measure, 1  9 2 10)
	$(call measure, 1 10 2 11)
	$(call measure, 1 11 2 12)
	$(call measure, 1 12 2 13)
	$(call measure, 1 13 2 14)
	$(call measure, 1 14 2 15)
	$(call measure, 1 15 2 16)
	$(call measure, 1 16 2 17)

clean:
	$(RM) $(TARGETS) $(OBJS) $(LOGS) ./*.o ./*.hi ./*.hp ./*.class

rebuild: clean all
