# 京都大学 2017年 入試問題 数学(理系) 問6

## 解法

1から5のカードを並べて各桁とみなした数字が3で割り切れるかどうかは、すべてのカードの数字を足して3で割り切れるかどうかと同値です。

カードを何枚か引いた時点で、カードの数字の合計を3で割った余りが1, 2, 0である確率をそれぞれ、p, q, r (r=1-p-q)とおきます。このとき追加でカード(1..5)を一枚を当確率(1/5)で引いた後、全カードの数字の合計を3で割った余りが0になる確率は、

- 引く前のカードの合計が3で割って1余るときに、3で割って2余るカード(2,5)を引く
- 引く前のカードの合計が3で割って2余るときに、3で割って1余るカード(1,4)を引く
- 引く前のカードの合計が3で割って0余るときに、3で割って0余るカード(3)を引く

の合計つまり、p * 2/5 * + q * 2/5 + r * 1/5 = 1/5 * (1+p+q) = 1/5 * (2-r)です。よって一枚カードを引いたとき、カードの合計が3で割って0余る確率は、rから1/5 * (2-r)になります。カードを一枚も引いていないときにr=1とすると、

```haskell
probabilityList = map (\x -> (0.0 + fromRational x, x)) $ pList (1 % 1)
  where pList r = p:pList(p) where p = (1 % 5) * ((2 % 1) - r)
```

より、

```text
*Main> take 5 $ probabilityList
[(0.2,1 % 5),(0.36,9 % 25),(0.328,41 % 125),(0.3344,209 % 625),(0.33312,1041 % 3125)]
```

ですから、5枚引いた時点では、1041/3125 = 0.33312です(答)。

## シミュレーション

この値が正しいかどうか、乱数を用いたシミュレーションで確かめてみましょう。ここはC++ではなく、敢えてHaskellで書いてみます。本ページの全ソースコードは[univ2017math2.hs](univ2017math2.hs)です。乱数の質は確認していませんので、同様のシミュレーションを行うときはご注意ください。

```haskell
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
```

起動時の引数が試行回数(省略時は10000回)です。実行すると、題意を満たすカードの組み合わせが何回出現したか表示します。

```text
*Main> :main 1000000
333298
```
