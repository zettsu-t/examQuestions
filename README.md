# 麻布中学校 2017年 入試問題 算数 問6

問題は以下の通りです。

http://www.inter-edu.com/nyushi/2017/azabu/

## 総当たりで解く

Haskellで書いたコードは以下の通りです。GHC 8.0.1 で実行できます。本ページの全ソースコードは[2017math6.hs](2017math6.hs)です。

```haskell
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
```

|関数|値|
|:-----|:-----|
|toDigits|文字列の文字を、それぞれ1桁の数字に変換したリスト|
|toString|リストの数字を、それぞれ文字にしてからつなげた文字列|
|convert|問題の規則に従って、数字のリストを文字列に変換したもの|
|allLists|問題の入力となりうるリストの無限集合|
|q1,q2,q3,q4|各問題の答え |

* GHCiまたはWinGHCiから、q1, q2, q3およびq4を実行(評価)することで、問6-1,2,3,4 の答えが得られます
* convertは、数値1または2からなるリストを入力し、文字1または2からなる文字列を出力にします
* allListsは、リストの長さについて昇順(長さ1のリスト群、長さ2のリスト群、...)の集合を、幅優先探索を用いて求めます

WinGHCiで実行するとこのように出力されます。

```text
*Main> q1
["1212","2222"]
*Main> q2
[[2,1],[1,2,2],[2,1,2]]
*Main> q3
[[2,1,2,1]]
*Main> q4
[([2,2,1,1,2],"12121212"),([2,1,1,1,1,2],"11121112"),([2,1,1,2,1,2],"12121212"),([2,1,2,1,1,2],"21122112"),([2,1,2,2,1,2],"22122212")]
```

総当たりと言っていますが、allListsが無限集合なので、問6-2, 6-3は取り出す解の数が多すぎると(それぞれ3,1個を超えると)、関数が返ってこなくなります。やはり証明が必要なようです。

## 問6-2, 6-3

問6-2, 6-3では、解が何個あるかが問題で指定されています。では解が何個あるかは、どうやったら分かるでしょうか。無限に桁数が長い入力を調べつくすことはできませんので、どれだけの範囲の入力を調べるか決めましょう。

実は入力Aが5桁以上であれば、出力[A]は入力より1桁少ないか、そうでなければ出力の桁数は入力の桁数より多いといえます。そうと分かっていれば、問6-2, 6-3は4桁以下の入力だけ調べればよいです。

* 問6-2 : 入力が5桁以上であれば、出力は4桁以上なので、"22"が出力されることはない
* 問6-3 : 入力が5桁以上であれば、出力は入力と同じ桁数にはならない

からです。ですのでこれを証明しましょう。入力の先頭が1であるか、2であれば何個連続しているかで場合分けします。入力をn桁とします。

### 先頭が1

規則2を1回適用して終わりなので、出力は入力より1桁少なくなります。

### 最後以外が2、つまり先頭から2がn-1個連続し、最後が1または2

規則3をn-1回適用し、分割したものにそれぞれ規則1を適用して、出力は 2^(n-1) (2をn-1回掛けたもの、2のn-1乗) になります。

### 先頭に連続するk個の2(1 <= k < n-2)があり、その次に1がある、以後は何でもよい

k=1のとき、規則3を1回適用して2分割し、分割したものにそれぞれ規則2を適用して n-2 桁になるので、出力は 2 * (n-2) 桁になります。入力からは n-4 桁増えているので、n = 4 なら入力と出力の桁数は同じ(これが問6-3の手掛かりですね)、n > 4 なら入力より出力の方が桁数が多いです。

1を含む任意のkについて、規則3をk回適用して分割し、分割したものにそれぞれ規則2を適用して n-1-k 桁になるので、出力は (2^k) * (n-1-k) 桁になります。

さてkを1増やしたとき、増やす前の出力の桁数 (2^k) * (n-1-k) と、増やした後の桁数 (2^(k+1)) * (n-1-(k+1)) を比較します。増加率は両者の比 2 * (n-k-2) / (n-k-1) = 2 - 2 / (n-k-1) です。この値は、k = n-3 のとき(増やした後の k = n-2)は1、それ以外は1より大きいです。よってkを1から2,3,...と増やすとき、出力の桁数は増えることはあっても減ることはありません。

最初に述べた通り、n > 4 なら k=1 でも入力より出力の桁数の方が多く、kが増えると出力の桁数が増えます。よって、入力が5桁以上では、出力の方が入力より桁数が多くなります。

### まとめ

入力が5桁以上では、出力の桁数は、以下のいずれかになります。

* 規則2を1回適用することで、出力は入力より1桁少なくなる
* 規則3を1回以上適用することで、出力の桁数はは入力より多くなる
* 入力と出力の桁数は同じにはならない

これより、問6-2, 6-3は、広く取っても4桁以下の入力だけ調べればよいことが分かります。4桁以内のすべての1と2の並びであれば、手作業でも調べられるでしょう。

```haskell
listUpTo4 = map makePair $ takeWhile (\x -> (length x) <= 4) allLists
  where makePair x = (x, convert x)
```

問6-2,3の解き方の方針を示すと以下の通りです。

#### 問6-2

出力から逆算して、どの規則を適用できるか考えると、入力が求まります。規則2 * 2組を思いつくかどうかが鍵です。さらに言うと前述の証明から、4桁の入力を2桁の出力にすることはできないので、3桁以下の入力だけ調べればよいです。

* [21] → 規則3 → [1][1] → 規則1 * 2組 → 22
* [122] → 規則2 → 22
* [212] → 規則3 → [12][12] → 規則2 * 2組 → 22

#### 問6-3

前述の証明より、先頭が2かつ4桁以内の入力が候補になります。

* 4桁かつk=1 : [21ab] → [1ab][1ab] → abab 。つまりab=21なので、入力は[2121] (答)
* 4桁かつk=2 : [221a] → [21a][21a] → [1a][1a][1a][1a] → aaaa と出力が全桁同じになるので、解なし
* 4桁かつk>2 : 出力が8桁になるので、解なし
* 3桁 : [2ab] → [ab][ab] 。aが1だとbbと2桁になり、aが2だと[b][b][b][b]を経て出力は4桁になる。桁数が合わないので解なし。
* 2桁 : [21] → [1][1] → 22、[22] → [2][2] → 11なので、解なし
* 1桁 : 規則1そのものなので、解なし

## 問6-4

出力の下一桁は11, 12, 21, 22のいずれかです。292 = 73 * 4 なので、292で割り切れる出力[A]の下一桁は必ず 12 になります。

ところで、10001 = 73 * 137 なので、一の位と万の位が同じで他が0の数字、つまり10001と20002は73の倍数です。一の位と万の位が同じ、十の位と十万の位が同じ、百の位と百万の位が同じ、千の位と千万の位が同じ、であれば、これら73の倍数(10001 or 20002 * {1, 10, 100, 1000})を足した8桁の数字もやはり73の倍数になります。

よって ab12ab12　という形式 { 11121112, 12121212, 21122112, 22122212 } 、つまり上位4桁と下位4桁が同じで下2桁が12の数(うち一つは12を4回繰り返したもの)となる出力を得られるような入力を探せばよいです。入力としては、規則3を1,2度適用する対象の、6桁以下の数が該当します。

|出力|変換|入力|
|:-----|:-----|:-----|
|11121112|[11112][11112]|[211112]|
|12121212|[11212][11212]|[211212]|
|同上|[112][112][112][112] <- [2112][2112]|[22112]|
|21122112|[12112][12112]|[212112]|
|22122212|[12212][12212]|[212212]|

ここに挙げた入出力以外に解がないことを示します。8桁のすべての1と2の並びは256通りあるので、すべて手作業で調べるのは大変です。

まず一の位と万の位の組、十の位と十万の位、百の位と百万の位、千の位と千万の位、の組のうち、一組だけで値が異なるものとします。このとき出力が73の倍数にならないことを証明します。

解となる出力5通りのうち一つから、一の位と万の位のどちらか一方を変更すると仮定します。このとき変更前と変更後の出力の差は、1または10000です。1を73で割った余りは1、10000を73で割った余りは72(1足すと73になるので-1とも言える)です。これを1|10000 mod 73 = +/-1 と書きます。

同様にして、十の位と十万の位、百の位と百万の位、千の位と千万の位の組についても、どちらか一方だけ変更した場合は、
10|100000 mod 73 = +/-10、100|1000000 mod 73 = +/-27、1000|10000000 mod 73 = +/-51 = -/+22 です。念のため確認しましょう。

```haskell
rems = map f [0..7]
  where f i = (value i, minAbs $ value i `rem` base)
        value x = 10 ^ x
        minAbs x = if abs x < abs (negRem x) then x else negRem x
        negRem x = x - base
        base = 73
```

```text
*Main> rems
[(1,1),(10,10),(100,27),(1000,-22),(10000,-1),(100000,-10),(1000000,-27),(10000000,22)]
```

以上より、解を満たす出力からある1桁だけ変えた数字は、73では割り切れません。73で割り切れないなら292でも割り切れないので、解になることはありません。

次に一の位と万の位の組、十の位と十万の位、百の位と百万の位、千の位と千万の位、の組のうち、一つ以上の組で値が異なるものとします。
+/-1, +/-10, +/-27, +/-22から一つ以上選んで足しても、73の倍数にはなりません。各組から、{+を選ぶ、-を選ぶ、選ばない}という組み合わせは3^4=81通りあります(うち一つはどれも選ばない=解と分かっているものそのものなので除外します)。

下一桁に注目して、これらの数を足し引きして0か3にすることを考えます。0になるものはなく、3にするには1+22=23にすればよいが他のどの数を足しても73にはならないので、どうやら73の倍数にする足し方はなさそうです。実際に確認すると、確かに和が0になる組み合わせはありませんでした。

```haskell
sums = sort $ map makePair $ filter nonZero $ sequence $ map expand [1,10,22,27]
  where makePair x = (sum x, x)
        expand x = [-x,0,x]
        nonZero xs = not $ all (\i -> (i == 0)) xs
```

よって一の位と万の位の組、十の位と十万の位、百の位と百万の位、千の位と千万の位、の組のうち、少なくとも一つ以上の組で値が異なるものは、解となる出力ではありません。言い換えると、出力の上4桁と下4桁は等しくなければなりません。これが既に求めた5通りの解です。

## ライセンス

本記事とソースコードはMITライセンスのもとで配布しています。詳しくは[LICENSE.txt](LICENSE.txt)をご覧ください。リンク先の内容は、リンク先保有者の著作権に従ってください。出題者(麻布中学校)は、本記事の内容に一切関与していません。
