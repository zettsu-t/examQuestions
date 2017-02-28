#!/usr/bin/python3
# coding: utf-8
#
# 出題元
# 麻布中学校 2008年 入試問題 算数 問4 解法

import itertools

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

def printMatchedSums(minNumLeft, maxNumLeft, minNumRight, maxNumRight):
    for resultLeft in expressions(minNumLeft, maxNumLeft):
        for resultRight in expressions(minNumRight, maxNumRight):
            if resultLeft[0] == resultRight[0]:
                print (resultLeft[1] + " == " + resultRight[1])

printSums(1,4)
printMatchedSums(1, 5, 2, 6)
