-- 一橋大学 2017年 入試問題 数学 第2問
import Data.List
import Data.Maybe

limitedSearch = [[x,y,z] | x <- range, y <- range, z <- range,
                 (x*x == (y*z+7)) && (y*y == (z*x+7)) && (z*z == (x*y+7))
                 && x <= y && y <= z]
  where range = [-10..10]

factorize 1 = [1]
factorize n = nub.sort $ concatMap (makePair n) [1..(n `div` 2)]
  where makePair n i | n `rem` i == 0 = [i, n `div` i]
                     | otherwise = []

fullSearch c = nub.sort $ concatMap f ys
  where ys = concatMap (\i -> [-i, i]) $ takeWhile (\i -> i*i < c) [0..]
        f y = [[x,y,z] | (x,z) <- factorPairs (y*y - c),
               (x*x == (y*z + c)) && (y*y == (z*x + c)) && (z*z == (x*y + c))
               && x <= y && y <= z]
        factorPairs n = zip (map negate (factors n)) (reverse (factors n))
        factors n = factorize (abs n)

intRoots i | i < 0 = Nothing
           | r * r == i = Just (nub [-r, r])
           | otherwise = Nothing
  where r = truncate(sqrt(fromIntegral i))

intSolutions (a:b:c:xs) = fmap f (intRoots d)
  where d = b*b - 4*a*c
        f xs = catMaybes $ map g xs
        g x | (x-b) `rem` (2*a) == 0 = Just ((x-b) `div` (2*a))
            | otherwise = Nothing

xyzSet i x = sort [x, x+i, 0-2*x-i]

solutions c = nub.sort.concat.catMaybes $ map varSet diffs
  where diffs = takeWhile (\i -> i*i <= 4*c) [0..]
        varSet i = fmap (fmap (\x -> xyzSet i x)) $ candidates i
        candidates i = intSolutions [3, 3*i, i*i-c]

compareAll = takeWhile (\(l,r,i) -> l == r) $ map f [1..]
  where f i = (fullSearch i, solutions i, i)

-- 東京工業大学 2017年 入試問題 数学 第1問
numberSet = filter (\xs -> (length (snd xs)) == 12 && (snd xs)!!6 == 12) $ candidates
  where candidates = map (\x -> (x, factorize x)) [1..(12*11*6*4*3*2*1)]

main = do
  putStrLn $ intercalate ", " $ map (show.fst) numberSet

-- main = do
--   putStrLn $ concatMap show compareAll
