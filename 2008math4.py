#!/usr/bin/python3
# coding: utf-8
#
# 出題元
# 麻布中学校 2008年 入試問題 算数 問4 解法

import itertools
import sys

def expression(nums, ops):
    expr = "".join(str(x) for x in list(itertools.chain(*zip(list(nums), list(ops)))))
    return [eval(expr), expr]

def expressions(minNum, maxNum):
    nums = list(range(minNum, maxNum + 1))
    opList = itertools.product(*(([["*", "+"]] * (maxNum - minNum)) + [[""]]))
    return sorted(list(map(lambda ops:expression(nums, ops), list(opList))), key=lambda x:x[0])

def printSums(minNum, maxNum):
    for result in expressions(minNum, maxNum):
        print(str(result[0]) + " = " + result[1])

def printMatchedSums(printValue, minNumLeft, maxNumLeft, minNumRight, maxNumRight):
    for resultLeft in expressions(minNumLeft, maxNumLeft):
        for resultRight in expressions(minNumRight, maxNumRight):
            if resultLeft[0] == resultRight[0]:
                print (makeValueString(resultLeft[0], printValue) + resultLeft[1] + " == " + resultRight[1])

def makeValueString(value, enable):
    return (str(value) + " : ") if enable else ""

def printMatchedSumsFast(minNumLeft, maxNumLeft, minNumRight, maxNumRight):
    resultsRight = expressions(minNumRight, maxNumRight)
    sizeOfRight = len(resultsRight)
    indexRight = 0  # ある値を持つright群の最小のインデックス
    count = 0       # 同じ値を持つright群の式が何個あるか

    for resultLeft in expressions(minNumLeft, maxNumLeft):
        # 前のrightの値と比較する
        indexRight = indexRight - count
        if indexRight >= sizeOfRight:
            break
        count = 0
        while indexRight < sizeOfRight and resultLeft[0] >= resultsRight[indexRight][0]:
            if resultLeft[0] == resultsRight[indexRight][0]:
                print (makeValueString(resultLeft[0], True) + resultLeft[1] + " == " + resultsRight[indexRight][1])
                count += 1
            indexRight += 1

if len(sys.argv) < 6:
    printSums(1,4)
    printMatchedSums(False, 1, 5, 2, 6)
else:
    args = list(map(int, sys.argv[2:6]))
    if sys.argv[1] == "fast" :
        printMatchedSumsFast(*args)
    else:
        args = list(map(int, sys.argv[2:6]))
        printMatchedSums(True, *args)

0
