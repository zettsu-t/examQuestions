let opToChar op =
  match op with
    | 0 -> "+"
    | _ -> "*";;

let opsToString ops = List.map (fun x -> opToChar x) ops;;
let numsToString nums = List.map (fun x -> string_of_int x) nums;;
let zipLists nums ops = List.combine (numsToString nums) (opsToString ops);;
let tailExpr nums ops = List.fold_right (fun (x,y) s -> String.concat x [y;s]) (zipLists (List.tl nums) ops) "";;
let expr nums ops = String.concat "" [string_of_int (List.hd nums); tailExpr nums ops];;

let rec calc nums ops =
  match ops with
    | 0::xs -> (List.hd nums) + (calc (List.tl nums) (List.tl ops))
    | 1::xs -> calc (List.append [(List.hd nums) * (List.nth nums 1)] (List.tl (List.tl nums))) (List.tl ops)
    | _ -> (List.hd nums);;

let sortPair l r = (fst l) - (fst r);;
let makePair nums ops = (calc nums ops, expr nums ops);;
let rec numList i maxNum = if (i == maxNum) then [maxNum] else List.append [i] (numList (i+1) maxNum);;

let rec opList s =
  match s with
    | 0 -> [[]]
    | _ -> List.concat (List.map (fun x -> [List.append [0] x; List.append [1] x]) (opList (s-1)));;

let rawExpressions minNum maxNum = List.map (fun x -> makePair (numList minNum maxNum) x) (opList (maxNum - minNum));;
let expressions minNum maxNum = List.sort sortPair (rawExpressions minNum maxNum);;
let pairString left right = String.concat "" [snd left; " == "; snd right; "\n"];;
let pairsToString left right = if ((fst right) == (fst left)) then (pairString left right) else ""
let filterPairs right minNum maxNum = List.map (fun left -> pairsToString left right) (expressions minNum maxNum);;

let q2 minNumLeft maxNumLeft minNumRight maxNumRight =
  List.concat (List.map (fun right -> filterPairs right minNumLeft maxNumLeft) (expressions minNumRight maxNumRight));;

List.iter (fun x -> print_string (String.concat "" [string_of_int(fst x); " = "; snd x; "\n"])) (expressions 1 4);;
List.iter (fun x -> print_string x) (List.filter (fun x -> String.length x > 0) (q2 1 5 2 6));;
