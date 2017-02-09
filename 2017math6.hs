-- 麻布中学校 2017年 入試問題 算数 問6 解法

import Data.List
toDigits x = map (read . (:"")) x :: [Int]
toString = concatMap show
convert (1:x:xs) = toString (x:xs)
convert (2:x:xs) = s ++ s where s = convert (x:xs)
convert (1:xs) = toString [2]
convert (2:xs) = toString [1]
convert _ = ""
allLists = nextList [[]]
  where nextList x = nextPair x ++ (nextList $ (drop 1 x) ++ nextPair x)
        nextPair x = [nextLeft x, nextRight x]
        nextLeft x = head x ++ [1]
        nextRight x = head x ++ [2]
q1 = map convert [toDigits "2112", toDigits "2212"]
q2 = take 3 $ filter (\x -> (convert x) == "22") allLists
q3 = take 1 $ filter (\x -> x == (toDigits $ convert x)) allLists
q4 = filter match $ map makePair $ takeWhile (\x -> (length x) <= 6) allLists
  where makePair x = (x, convert x)
        match (l,s) = (length s) == 8 && ((read s :: Int) `rem` 292) == 0

listUpTo4 = map makePair $ takeWhile (\x -> (length x) <= 4) allLists
  where makePair x = (x, convert x)

rems = map f [0..7]
  where f i = (value i, minAbs $ value i `rem` base)
        value x = 10 ^ x
        minAbs x = if abs x < abs (negRem x) then x else negRem x
        negRem x = x - base
        base = 73

sums = sort $ map makePair $ filter nonZero $ sequence $ map expand [1,10,22,27]
  where makePair x = (sum x, x)
        expand x = [-x,0,x]
        nonZero xs = not $ all (\i -> (i == 0)) xs
