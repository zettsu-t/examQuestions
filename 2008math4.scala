import scala.reflect.runtime.universe
import scala.tools.reflect.ToolBox

object NumberSet {
    def exprSet(minNum:Int, maxNum:Int) : List[(Any, String)] = {
        val nums = Range(minNum, maxNum + 1, 1).map(_.toString)
        val opSeq = List.fill(maxNum - minNum)(List("+", "*"))
        var opStrs = opSeq.foldLeft(List(""))((l, r) => l.flatMap { x => r.map{ y => x + y }})
        var opLists = opStrs.map(List("") ++ _.toList)
        var exprs = opLists.map(List(_, nums).transpose.flatten.mkString(""))
        val toolbox = universe.runtimeMirror(getClass.getClassLoader).mkToolBox()
        exprs.map(expr => (toolbox.eval(toolbox.parse(expr)), expr))
    }

    def q1() : Unit = exprSet(1,4).sortBy{ case (x:Int, y) => x }.foreach(println _)
    def q2() : Unit = {
        exprSet(1,5).map{ case (l, lexpr) =>
            (l, exprSet(2,6).filter{case (r, _) => l == r}
                .map{case (r, rExpr) => lexpr + "==" + rExpr})
        }.filter{case (_, l) => !l.isEmpty}.foreach(println _)
    }

    def main(args: Array[String]) {
        q1()
        q2()
    }
}
