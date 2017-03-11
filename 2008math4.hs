-- 麻布中学校 2008年 入試問題 算数 問4 解法

import Data.List
import Data.MultiMap
import System.Environment (getArgs)

-- 演算子
opToChar 0 = "+"
opToChar 1 = "*"

-- 最初のリストの先頭2個の数字に、演算子のリスト(0が加算、1が乗算)を適用する
apply (x:y:xs) (0:os) = x + apply (y:xs) os
apply (x:y:xs) (1:os) = apply ((x*y):xs) os
apply (x:xs) _ = x

makePair nums ops = (value, str)
  where value = apply nums ops
        str = concat $ concat $ transpose [Data.List.map show nums, Data.List.map opToChar ops ++ [""]]

allLists minNum maxNum = Data.List.map f opLists
  where nums = [minNum..maxNum]
        opLists = sequence (replicate (maxNum - minNum) [0,1])
        f ops = makePair nums ops

allListMap minNum maxNum = Data.MultiMap.fromList $ allLists minNum maxNum

-- 問4-1
q1 = sort $ allLists 1 4
-- 問4-2
q2full leftMin leftMax rightMin rightMax =
  [(snd p, snd q) | p <- (allLists leftMin leftMax), q <- (allLists rightMin rightMax), fst p == fst q]

q2map leftMin leftMax rightMin rightMax =
  Data.List.concatMap f4 $ filter f3 $ Data.List.map f2 $ Data.List.map f1 (allLists leftMin leftMax)
  where f1 l = (l, Data.MultiMap.lookup (fst l) (allListMap rightMin rightMax))
        f2 (l,r) = (snd l, r)
        f3 (l,r) = (not $ Data.List.null r)
        f4 (l,r) = [(l, x) | x <-r]

q2 = q2full 1 5 2 6

paramSet (mode:lMin:lMax:rMin:rMax:xs) =
  (True, mode, read lMin :: Int, read lMax :: Int, read rMin :: Int, read rMax :: Int)
paramSet _ = (False, "", 0, 0, 0, 0)

solveAll :: IO ()
solveAll = do
  putStrLn $ show q1
  putStrLn $ show q2

solve :: String -> Int -> Int -> Int -> Int -> IO ()
solve mode leftMin leftMax rightMin rightMax = do
  putStrLn $ show $ f leftMin leftMax rightMin rightMax
  where f = if (mode == "map") then q2map else q2full

main = do
  args <- getArgs
  let (fixed, mode, leftMin, leftMax, rightMin, rightMax) = paramSet args
  case fixed of
    False -> solveAll
    True  -> solve mode leftMin leftMax rightMin rightMax
