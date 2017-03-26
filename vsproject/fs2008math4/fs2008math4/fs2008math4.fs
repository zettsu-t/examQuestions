open System

let opToChar op =
  match op with
    | 0 -> "+"
    | _ -> "*";;

let opsToString ops = ops |> List.map (fun x -> opToChar x);;
let numsToString nums = List.map (fun x -> x.ToString()) nums;;
let zipLists nums ops = List.zip (numsToString nums) (opsToString ops);;
let tailExpr nums ops = List.fold (fun s (x,y) -> String.concat y [s;x]) "" (zipLists (List.tail nums) ops);;
let expr (nums : int list) ops = String.concat "" [nums.Head.ToString(); (tailExpr nums ops)];;

let rec calc nums ops =
  match ops with
    | 0::xs -> (List.head nums) + (calc (List.tail nums) (List.tail ops))
    | 1::xs -> calc (List.append [(List.head nums) * nums.[1]] (List.tail (List.tail nums))) (List.tail ops)
    | _ -> (List.head nums);;

let sortPair l r = (fst l) - (fst r);;
let makePair nums ops = (calc nums ops, expr nums ops);;

let rec opList s =
  match s with
    | 0 -> [[]]
    | _ -> List.concat (List.map (fun x -> [List.append [0] x; List.append [1] x]) (opList (s-1)));;

let rec numList i maxNum = if (i = maxNum) then [maxNum] else List.append [i] (numList (i+1) maxNum)
and rawExpressions minNum maxNum = List.map (fun x -> makePair (numList minNum maxNum) x) (opList (maxNum - minNum))
and expressions minNum maxNum = List.sortWith sortPair (rawExpressions minNum maxNum)
and pairString left right = String.concat "" [snd left; " == "; snd right]
and pairsToString left right = if ((fst right) = (fst left)) then (pairString left right) else ""
and filterPairs right minNum maxNum = List.map (fun left -> pairsToString left right) (expressions minNum maxNum)
and q2 minNumLeft maxNumLeft minNumRight maxNumRight =
  List.concat (List.map (fun right -> filterPairs right minNumLeft maxNumLeft) (expressions minNumRight maxNumRight));;

List.iter (fun x -> Console.WriteLine (String.concat "" [(fst x).ToString(); " = "; snd x])) (expressions 1 4);;
List.iter (fun x -> (Console.WriteLine (x : string))) (List.filter (fun x -> String.length x > 0) (q2 1 5 2 6));;

[<EntryPoint>]
let main argv = 
    0

