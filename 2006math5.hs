-- 麻布中学校 2006年 入試問題 算数 問5 解法
-- 引数は必須で、引数として1,2,3を指定すると解法1,2,3で解く

import Data.List
import Data.Maybe
import System.Environment (getArgs)

-- 7個の数字を以下の通り配置する
-- a b c
--  [o]
-- d e f
-- 3個の数字の並びを上(top row : abc)、下(bottom row : def)、縦(column : boe)、
-- 斜め上(スラッシュ / :doc)、斜め下(バックスラッシュ \ : aof)と表現する

-- 解を読めるように整形する
toString (o:a:b:c:d:e:f:_) = (row [a,b,c]) ++ (center o) ++ (row [d,e,f]) ++ "-----\n"
  where row (i:j:k:_) = (show i) ++ " " ++ (show j) ++ " " ++ (show k) ++ "\n"
        center i = "  " ++ show i ++ "  \n"

-- 解法1 : 総当たりで解く
-- マスに入れた数字が、解であるかどうか判定する
isSolution (o:a:b:c:d:e:f:_) = foldr compare True [bottom, column, slash, backslash]
  where compare i accum = (i == top) && accum
        top       = a + b + c
        bottom    = d + e + f
        column    = b + o + e
        slash     = d + o + c
        backslash = a + o + f

-- 四隅のマスのうち、左上に最も小さい数字がくるように並び替える
sortSolution = flipHorizontal.flipVertical.rotate
  where flipHorizontal arg@(o:a:b:c:d:e:f:_) | a > c = [o,c,b,a,f,e,d]
                                             | otherwise = arg
        flipVertical arg@(o:a:b:c:d:e:f:_) | a > d = [o,d,e,f,a,b,c]
                                           | otherwise = arg
        rotate arg@(o:a:b:c:d:e:f:_) | a > f = [o,f,e,d,c,b,a]
                                     | otherwise = arg

-- 反転回転を考慮して一意な解の集まりを文字列にする
formatSolutions xs = concatMap toString $ nub.sort $ map sortSolution xs

-- 1..9の順列をマスに当てはめて解を選ぶ
solutions1 = formatSolutions $ filter isSolution allNumberSet
  where allNumberSet = map (take 7) $ permutations [1..9]

-- 解のすべてのマスを、10から引いた値に置き換えたものも、また解である
swapSolutions = (original == swapped, [original, swapped])
  where original = unique $ filter isSolution allNumberSet
        swapped  = unique $ map (map (\x -> 10 - x)) original
        allNumberSet = map (take 7) $ permutations [1..9]
        unique xs = nub.sort $ map sortSolution xs


-- 解法2 : 縦横斜めの和が等しいものを探す
sizeOfCells = 7
digits = [1..9]

-- 和がsとなる、異なる一桁の数字二個の組を選ぶ。先頭の数字の方が小さい。
pairSet s = filter f $ map pair [1..((s - 1) `div` 2)]
  where pair i = [i, s - i]
        f (l:r:_) = l < (last digits) && r > (head digits) && r <= (last digits)

-- ある数字の組と、反転した組を返す
mirrorPair (l:r:_) = [[l,r], [r,l]]

-- 中心にoを置き、縦横斜めの3個の数字を足すとcellsSumになり、
-- afdcにfilledを置き、pairとその前後を入れ替えたものをbeに置くすべての解
setColumn o cellsSum _ filled pair = map f (mirrorPair pair)
  where f nextPair = check (filled ++ nextPair)
        check (a:f:d:c:b:e:_) |
          (a+b+c) == cellsSum && (d+e+f) == cellsSum = Just [o,a,b,c,d,e,f]
        check _ = Nothing

-- pairとその前後を入れ替えたものを、nextFuncで置くすべての解
apply nextFunc o cellsSum pairs filled pair = concatMap f newPairs
  where newPairs = delete pair pairs
        f nextPair = concatMap (g nextPair) (mirrorPair pair)
        g nextPair p = nextFunc o cellsSum newPairs (filled ++ p) nextPair

-- 中心にoを置き、縦横斜めの3個の数字を足すとcellsSumになり、
-- afにfilledを置き、pairとその前後を入れ替えたものをdcに置くすべての解
setSlash o cellsSum pairs filled pair = apply setColumn o cellsSum pairs filled pair

-- 中心にoを置き、縦横斜めの3個の数字を足すとcellsSumになり、
-- pairとその前後を入れ替えたものをafに置くすべての解
setBackslash o cellsSum pairs pair = apply setSlash o cellsSum pairs [] pair

-- 中心にoを置き、縦横斜めの3個の数字を足すとcellsSumになるような、すべての解
withSum o cellsSum = concatMap f pairs
  where f p = setBackslash o cellsSum pairs p
        pairs = pairSet (cellsSum - o)

-- 中心にoを置いたときのすべての解
atCenter o = concatMap (withSum o) [sumMin..sumMax]
  where rest = delete o digits
        sizeOfUsedDigits = sizeOfCells - 1
        sizeOfUnusedDigits = (length rest) - sizeOfUsedDigits
        sumMin = o + (head rest) + (last $ take sizeOfUsedDigits rest)
        sumMax = o + (head (drop sizeOfUnusedDigits rest)) + (last rest)

solutions2 = formatSolutions $ concatMap catMaybes $ map atCenter digits


-- 和がsとなる、異なる一桁の数字二個の組を選ぶ。先頭の数字の方が小さい。
-- ただし組の要素にoを含まない
pairSetExcept s o = filter f $ map pair [1..((s - 1) `div` 2)]
  where pair i = [i, s - i]
        f (l:r:_) = l /= o && r /= o && l < r && r <= 9

-- 中心に1..9をそれぞれ置いたときに、
-- 和がsとなる数字二個の組を3組以上作れるようなsの集合
-- ただし各組の要素にoを含まない
centerAndSums = map f digits
  where f o = (o, [x | x <- range, hasThreePairs x o])
        range = [(head digits)..((last digits)*2)]
        hasThreePairs s o = (length (pairSetExcept s o)) >= 3

-- 上記に、以下の制約を加えたもの
-- 直線にある3マスの和は、3の倍数に限る
-- 点対称な2マスの和 * 2 + 中心のマスは、5の倍数に限る
centerAndSum35 = filter g $ map f centerAndSums
  where f (o,xs) = (o, [s | s <- xs, match s o])
        g (o,xs) = not $ null xs
        match s o = ((o + s) `rem` 3 == 0) && ((o + s * 2) `rem` 5 == 0)

-- 解法2に、上記の制約を加えたもの
atCenter3 o = concatMap f [sumMin..sumMax]
  where rest = delete o digits
        sizeOfUsedDigits = sizeOfCells - 1
        sizeOfUnusedDigits = (length rest) - sizeOfUsedDigits
        sumMin = o + (head rest) + (last $ take sizeOfUsedDigits rest)
        sumMax = o + (head (drop sizeOfUnusedDigits rest)) + (last rest)
        f s | (s `rem` 3 == 0) && ((s + s - o) `rem` 5 == 0) = withSum o s
            | otherwise = [Nothing]

solutions3 = formatSolutions $ concatMap catMaybes $ map atCenter3 digits

-- 引数によって、解く関数を変える
solver ("1":xs) = solutions1
solver ("2":xs) = solutions2
solver ("3":xs) = solutions3
solver _ = error "Unexpected argument"

main = do
  args <- getArgs
  let (f) = solver args
  putStrLn $ f
