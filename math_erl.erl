-module(math_erl).
-export([eval/1]).
-export([ops/2]).
-export([zipNumsOps/1]).
-export([exprsub/3]).
-export([exprs/2]).
-export([allExprs/2]).
-export([q1/2]).
-export([q2/4]).
-export([main/0]).

% http://stackoverflow.com/questions/2008777/convert-a-string-into-a-fun
eval(E) ->
  {ok, Ts, _} = erl_scan:string(E ++ "."),
  {ok, Exprs} = erl_parse:parse_exprs(Ts),
  {value, V, _} = erl_eval:exprs(Exprs, []),
  V.

ops(M, N) when M < N -> [ [L|R] || L <- ["+","*"], R <- ops(M + 1, N)];
ops(_, _) -> [" "].

zipNumsOps([{L, _}]) -> [L];
zipNumsOps([{L, R}|LS]) -> [L|R] ++ zipNumsOps(LS).

exprsub(L, M, N) -> [ zipNumsOps(lists:zip(L,R)) || R <- ops(M, N) ].
exprs(M, N) -> [ lists:flatten(L) || L <- exprsub(lists:map(fun(X) -> integer_to_list(X) end, lists:seq(M, N)), M, N)].
allExprs(M, N) -> lists:sort(fun({L, _},{R, _}) -> L < R end, lists:map(fun(X) -> {eval(X), X} end, exprs(M, N))).

q1(M, N) -> lists:map(fun({VAL, EXPR}) -> io:fwrite("~B = ~s ~n", [VAL, EXPR]) end, allExprs(M,N)).
q2(LM, LN, RM, RN) -> lists:foreach(fun({LVAL, LEXPR}) -> lists:foreach(fun({RVAL, REXPR}) ->
  case LVAL == RVAL of
    true -> io:fwrite("~s == ~s ~n", [LEXPR, REXPR]);
    false -> false
  end
end, allExprs(RM, RN)) end, allExprs(LM, LN)).

main() -> q1(1,4), q2(1,5,2,6).
