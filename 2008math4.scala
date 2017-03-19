import scala.reflect.runtime.universe
import scala.tools.reflect.ToolBox

object NumberSetS {
    def exprSet(minNum:Int, maxNum:Int) : List[(Any, String)] = {
        val nums = Range(minNum, maxNum + 1, 1).map(_.toString)
        val opSeq = List.fill(maxNum - minNum)(List("+", "*"))
        val opStrs = opSeq.foldLeft(List(""))((l, r) => l.flatMap { x => r.map{ y => x + y }})
        val opLists = opStrs.map(List("") ++ _.toList)
        val exprs = opLists.map(List(_, nums).transpose.flatten.mkString(""))
        val toolbox = universe.runtimeMirror(getClass.getClassLoader).mkToolBox()

        val startTime = System.currentTimeMillis()
        val result = exprs.map(expr => (toolbox.eval(toolbox.parse(expr)), expr)).sortBy{ case (x:Int, y) => x }
        val elapsedTime = System.currentTimeMillis() - startTime
        println(elapsedTime + " msec")
        result
    }

    def q1() : Unit = exprSet(1,4).foreach(println _)
    def q2() : Unit = {
        exprSet(1,5).map{ case (l, lexpr) =>
            (l, exprSet(2,6).filter{case (r, _) => l == r}
                .map{case (r, rExpr) => lexpr + "==" + rExpr})
        }.filter{case (_, l) => !l.isEmpty}.foreach(println _)
    }

    def q2fast() : Unit = {
        val resultsRight = exprSet(2,6)
        var indexRight = 0
        var count = 0

        for (expr <- exprSet(1,5)) {
            indexRight -= count
            if (indexRight < resultsRight.length) {
                count = 0
                val leftValue = expr._1.asInstanceOf[Int]
                while ((indexRight < resultsRight.length) &&
                       (leftValue >= resultsRight(indexRight)._1.asInstanceOf[Int])) {
                    if (leftValue == resultsRight(indexRight)._1.asInstanceOf[Int]) {
                        val s = "(" + expr._1 + ",List(" + expr._2 + "==" + resultsRight(indexRight)._2 + "))"
                        println(s)
                        count += 1
                    }
                    indexRight += 1
                 }
            }
        }
    }

    def main(args: Array[String]) {
        q1()
        if (args.length == 0) {
            q2()
        } else {
            q2fast()
        }
    }
}
