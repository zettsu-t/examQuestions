# 2006math5.hs のコンパイルとテスト
# 実行方法
# $ make (引数なし)
#
# 動作確認を行った環境
# - Windows 10
# - Cygwin 64bit版 (2.6.1)
# - GHC 8.0.1 (Windows 64bit版)

TARGET_2006=2006math5
TARGETS=$(TARGET_2006)

SOURCE_2006=2006math5.hs

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

.PHONY: all clean rebuild

all: $(TARGETS)

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

clean:
	$(RM) ./$(TARGETS) ./$(LOGS) ./*.o ./*.hi

rebuild: clean all
