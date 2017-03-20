-- 京都大学 2017年 入試問題 数学(理系) 第6問
import Data.Ratio
import Control.Monad
import System.Random
import System.Environment (getArgs)

probabilityList = map (\x -> (0.0 + fromRational x, x)) $ pList (1 % 1)
  where pList r = p:pList(p) where p = (1 % 5) * ((2 % 1) - r)

run sizeOfCards numberOfTrials = do
  lists <- sequence $ take numberOfTrials $ repeat (deck sizeOfCards)
  filterM f lists
  where deck n = sequence $ replicate n $ pickUpCard
        pickUpCard = getStdRandom $ randomR (1,5) :: IO Int
        f ls = return ((sum ls) `rem` 3 == 0) :: IO Bool

param [] = 10000
param (n:xs) = read n :: Int

main = do
  args <- getArgs
  let numberOfTrials = param args
  lists <- run 5 numberOfTrials
  putStrLn $ show $ length lists
