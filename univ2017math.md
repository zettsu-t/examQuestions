# 一橋大学 2017年 入試問題 数学 第2問

## 解を予想する

まずHaskellスクリプトに解を探させて、あたりをつけましょう。

```haskell
limitedSearch = [[x,y,z] | x <- range, y <- range, z <- range,
                 (x*x == (y*z+7)) && (y*y == (z*x+7)) && (z*z == (x*y+7))
                 && x <= y && y <= z]
  where range = [-10..10]
```

```text
*Main> limitedSearch
[[-3,1,2],[-2,-1,3]]
```

これだけではx, y, zが絶対値で10を超える解があるかどうか分かりませんが、おそらくこれが解のすべてだと思われます。xが負で、x, y, zを足すと0になるのがヒントになりそうです。ここから論証を組み立てます。

## 等式が対称なことに注目して解く

xが正の整数であると仮定します。x <= y <= z より、yもzも正の数なので、

```text
z*z = x*y + 7 <= y*y + 7 = z*x + 14 より、 z*(z-x) <= 14
              >= x*x + 7 = y*z + 14 より、 z*(z-y) >= 14
z*(z-x) <= 14 <= z*(z-y)
z-x <= z-y
```

より、x <= y かつ y <= x であることから、x = yです。併せて

```text
x*x = y*z + 7 <= z*z + 7 = x*y + 14 より、 x*(x-y) <= 14
              >= y*y + 7 = z*x + 14 より、 x*(x-z) >= 14
x*(x-y) <= 14 <= x*(x-z)
x-y <= x-z
```

より、y <= z かつ z <= y であることから、y = zです。つまりx = y = zですが、問題文の変数をすべてxに置き換えると、```x*x = x*x + 7```となります。これを満たすxはありませんので、xが正の整数であると仮定が間違っていたことになります。

同様に、zが負の整数であると仮定します。x <= y <= z より、xもyも負の数なので、

```text
x*x = y*z + 7 >= z*z + 7 = x*y + 14
              <= y*y + 7 = z*x + 14 より x*(x-z) <= 14 <= x*(x-y)
z*z = x*y + 7 >= y*y + 7 = z*x + 14
              <= x*x + 7 = y*z + 14 より z*(z-y) <= 14 <= z*(z-x)
```

からzが負の整数ではないことを導けます。

* xは0以下の整数
* zは0以上の整数
* x = y = z ではない

ここで```y*y = z*x + 7```に注目します。z * xは0以下なので、```0 <= y * y <=7```です。そのためyの候補は-2, -1, 0, 1, 2に限られます。yをそれぞれの値に固定してxとzを求めましょう。factorizeは整数のすべての約数を返す関数ですが、もっとよい実装があるでしょう。後の考察のために、定数7はfullSearchの引数として与えるようにします。

```haskell
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
```

予想と同じ答えが出ました。

```text
*Main> fullSearch 7
[[-3,1,2],[-2,-1,3]]
```

## 二次方程式を立てて解く

問題文の上二式、下二式の差は下記のとおりです。

- (x + y + z)(x - y) = 0
- (x + y + z)(y - z) = 0

これら両方の式を満たす解を探します。まず x - y = 0かつy - z = 0はx = y = zということですが、これを満たす解がないのは既に説明した通りです。よってx + y + z = 0を満たす解を探します。

x + y + z = 0であるということは、x, y, zのうち少なくとも一つは負の数があるので、それをxとおきます。x <= yなので、x <=0, i >= 0, y = x + i とします。さらに z = 0 - x - y = -2*x - iです。ここではz >= 0という条件は設けません。これを問題文の式に代入すると、

```text
3*x*x + 3*i*x + (i*i - 7) = 0
```

が得られます。この式をxについての二次方程式と考えたとき、xの実数解が得られるのは、解の公式から、```9*i*i - 4*3*(i*i - 7) >= 0```のときです。つまり、i*i <= 4 * 7のときです。このようなiについて、xの整数解を列挙しましょう。後の考察のために、定数7はsolutionsの引数として与えるようにします。

```haskell
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
```

先ほどと同じ答えが出ました。

```text
*Main> solutions 7
[[-3,1,2],[-2,-1,3]]
```

## 解を比べる

両方の解き方が、同じ解を出すことを確認してみましょう。両者の解が異なる例はみつからなさそうです。

```haskell
compareAll = takeWhile (\(l,r,i) -> l == r) $ map f [1..]
  where f i = (fullSearch i, solutions i, i)
```

解の候補を狭めることを考えます。xは0になりません。なぜならxが0ならy, z, y * z は0以上ですが、```x*x = 0 = y*z + 7```を満たすyとzが存在しないからです。同様にzが0ならx, yは0以下、x * y は0以上ですが、```z*z = 0 = x*y + 7```を満たすxとyが存在しません。よってxは負の整数、zは正の整数です。

yについてはこの条件がないので、正でも負でも0でもよいです。yが0のときを考えましょう。

```text
x*x = 0*z + 7 = 7
0*0 = z*x + 7
z*z = x*0 + 7 = 7
```

7についてはxとzの整数解はありません。しかし定数が7ではなく平方数c*c (c>0)であれば、x=-c, y=0, z=cになります。最初の解き方であればyは1からではなく0から始まりますし、二番目の解き方であれば二次方程式が重解を持つ場合を考慮するということです。このことはコードを書くときに忘れやすいので、二通りの解き方を比較することは重要ですね。

## 東京工業大学 2017年 入試問題 数学 第1問

先に求めた因数分解を使って、東京工業大学 2017年 入試問題 数学 第1問を解いてみましょう。WinGHCiだとかなり時間が掛かりますが、コンパイルすると数秒で解けます。

```haskell
numberSet = filter (\xs -> (length (snd xs)) == 12 && (snd xs)!!6 == 12) $ candidates
  where candidates = map (\x -> (x, factorize x)) [1..(12*11*6*4*3*2*1)]

main = do
  putStrLn $ intercalate ", " $ map (show.fst) numberSet
```

12を約数に持つ整数は、12の約数{1,2,3,4,6,12}もすべて約数に持ちます。よって12が7番目に大きい約数であれば、これら以外に{5,7,8,9,10,11}のいずれか一つだけを約数に持つ可能性がある、ということです。ですので、12*{5,7,8,9,10,11}を因数分解して、12が何番目に大きい約数か確認すればよいです。5の倍数(60, 120)を除外できるかどうかが肝でしょう。

```text
*Main> factorize 60
[1,2,3,4,5,6,10,12,15,20,30,60]
*Main> factorize 120
[1,2,3,4,5,6,8,10,12,15,20,24,30,40,60,120]
```
