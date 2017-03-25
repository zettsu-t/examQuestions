using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.CodeAnalysis.CSharp.Scripting;
using System.Text;
using System.Threading.Tasks;

static class Ext
{
    // https://blogs.msdn.microsoft.com/ericlippert/2010/06/28/computing-a-cartesian-product-with-linq/
    public static IEnumerable<IEnumerable<T>> CartesianProduct<T>(this IEnumerable<IEnumerable<T>> sequences)
    {
        IEnumerable<IEnumerable<T>> result = new[] { Enumerable.Empty<T>() };
        foreach (var sequence in sequences)
        {
            var s = sequence;
            result =
                from seq in result
                from item in s
                select seq.Concat(new[] { item });
        }
        return result;
    }
}

namespace cs2008math4
{
    class Expressions
    {
        Dictionary<int, List<string>> exprs_ = new Dictionary<int, List<string>> { };
        List<int> values_ = new List<int>();

        public Expressions(int minNum, int maxNum)
        {
            makeExpressions(minNum, maxNum);
        }

        public void PrintSums()
        {
            foreach (var value in values_)
            {
                foreach(var expr in exprs_[value])
                {
                    Console.Write(value.ToString() + " = " + expr + "\n");
                }
            }
        }

        public void PrintMatchedSums(Expressions other, bool printValue)
        {
            foreach (var value in values_)
            {
                if (other.exprs_.ContainsKey(value))
                {
                    if (printValue)
                    {
                        Console.Write(value.ToString() + " : ");
                    }
                    var exprs = new List<string>();
                    exprs.AddRange(exprs_[value]);
                    exprs.AddRange(other.exprs_[value]);
                    var str = string.Join(" == ", exprs);
                    Console.Write(str + "\n");
                }
            }
        }

        void makeExpressions(int minNum, int maxNum)
        {
            var ops = new List<string> { "+", "*" };
            var elements = new List<List<string>>();
            elements.Add(new List<string> { minNum.ToString() });
            foreach (var i in Enumerable.Range(minNum + 1, maxNum - minNum))
            {
                elements.Add(ops);
                elements.Add(new List<string> { i.ToString() });
            }

            foreach (var exprParts in Ext.CartesianProduct(elements).ToList())
            {
                var expr = string.Join("", exprParts.ToList());
                var result = CSharpScript.EvaluateAsync<int>("return " + expr + ";");
                var value = result.Result;

                if (!exprs_.ContainsKey(value))
                {
                    exprs_.Add(value, new List<string> { });
                }
                exprs_[value].Add(expr);
            }

            values_ = new List<int>(exprs_.Keys);
            values_.Sort();
        }
    }

    class cs2008math4
    {
        static void Main(string[] args)
        {
            if (args.Length < 4)
            {
                var q1 = new Expressions(1, 4);
                q1.PrintSums();
                var q2 = new Expressions(1, 5);
                q2.PrintMatchedSums(new Expressions(2, 6), false);
            } else
            {
                var q2 = new Expressions(int.Parse(args[0]), int.Parse(args[1]));
                q2.PrintMatchedSums(new Expressions(int.Parse(args[2]), int.Parse(args[3])), true);
            }


// Visual Studioからデバッグするときは、画面表示を見るために有効にする
//          Console.ReadKey();
        }
    }
}
