-- 麻布中学校 2008年 入試問題 算数 問4 解法

import Data.List

-- 演算子
add x y = x + y
mul x y = x * y
opToChar 0 = "+"
opToChar 1 = "*"

-- 最初のリストの先頭2個の数字に、演算子のリスト(0が加算、1が乗算)を適用する
apply (x:y:xs) (0:os) = x + apply (y:xs) os
apply (x:y:xs) (1:os) = apply ((x*y):xs) os
apply (x:xs) _ = x

makePair nums ops = (value, str)
  where value = apply nums ops
        str = concat $ concat $ transpose [map show nums, map opToChar ops ++ [""]]

allLists minNum maxNum = map f opLists
  where nums = [minNum..maxNum]
        opLists = sequence (replicate (maxNum - minNum) [0,1])
        f ops = makePair nums ops

-- 問4-1
q1 = sort $ allLists 1 4
-- 問4-2
q2 = [(snd p, snd q) | p <- (allLists 1 5), q <- (allLists 2 6), fst p == fst q]
