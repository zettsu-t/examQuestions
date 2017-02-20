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
TARGETS=$(TARGET_2006) $(TARGET_2008_CPP) $(TARGET_2008_ASM)

OBJ_2008_CPP=2008math4.o
OBJ_2008_ASM=2008math4a.o
OBJS=$(OBJ_2008_CPP) $(OBJ_2008_ASM)

SOURCE_2006=2006math5.hs
SOURCE_2008_CPP=2008math4.cpp
SOURCE_2008_ASM=2008math4a.cpp

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
HASKELLFLAGS=-O
LDFLAGS=

CXX=g++
LD=g++
CPPFLAGS=-std=c++14 -g -O -Wall
CPPASMFLAGS=-mavx2 -masm=intel
LIBPATH=
LIBS=

.PHONY: all test clean rebuild

all: $(TARGETS)

test: $(TARGET_2008_CPP) $(TARGET_2008_ASM)
	./$(TARGET_2008_CPP)
	./$(TARGET_2008_ASM)

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
	$(LD) $(LIBPATH) -o $@ $< $(LDFLAGS) $(LIBS)
	./$@

$(TARGET_2008_ASM): $(OBJ_2008_ASM)
	$(LD) $(LIBPATH) -o $@ $< $(LDFLAGS) $(LIBS)
	./$@

$(OBJ_2008_CPP): $(SOURCE_2008_CPP)
	$(CXX) $(CPPFLAGS) -c -o $@ $<

$(OBJ_2008_ASM): $(SOURCE_2008_ASM)
	$(CXX) $(CPPFLAGS) $(CPPASMFLAGS) -c -o $@ $<

clean:
	$(RM) $(TARGETS) $(OBJS) $(LOGS) ./*.o ./*.hi

rebuild: clean all
