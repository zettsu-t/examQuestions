defmodule Expr do
  def applyOps([x], "") do
    x
  end

  def applyOps([x|xs], "+" <> rest) do
    x + applyOps(xs, rest)
  end

  def applyOps([x|xs], "*" <> rest) do
    [y|ys] = xs
    applyOps([x * y] ++ ys, rest)
  end

  def makeExpr([x], "") do
    Integer.to_string(x)
  end

  def makeExpr([x|xs], ops) do
    Integer.to_string(x) <> String.first(ops) <> makeExpr(xs, String.slice(ops, 1..-1))
  end

  def allExprs(minNum, maxNum) do
    nums = Enum.to_list(minNum..maxNum)
    opLists = Stream.unfold({[""]}, fn {xs} -> {xs, {Enum.flat_map(xs, fn (x) -> [x <> "+", x <> "*"] end)}} end)
    ops = opLists |> Enum.at(maxNum - minNum)
    exprs = Enum.map(ops, fn x -> {applyOps(nums, x), makeExpr(nums, x)} end)
    Enum.sort(exprs, &(elem(&1, 0) < elem(&2, 0)))
  end

  def q1(minNum, maxNum) do
    allExprs(minNum, maxNum) |> Enum.map(fn x -> Integer.to_string(elem(x, 0)) <> " = " <> elem(x, 1) end) |> Enum.each(&IO.puts(&1))
  end

  def q2(leftMin, leftMax, rightMin, rightMax) do
    Enum.each(allExprs(leftMin, leftMax), fn(left) ->
      Enum.each(allExprs(rightMin, rightMax), fn(right) ->
        if elem(left, 0) == elem(right, 0) do
          IO.puts(elem(left, 1) <> " == " <> elem(right, 1))
        end
      end)
    end)
  end
end

Expr.q1(1,4)
Expr.q2(1,5,2,6)
