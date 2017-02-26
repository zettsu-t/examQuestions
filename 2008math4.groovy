class NumberSetG {
    def resultSet_

    NumberSetG(minNum, maxNum) { resultSet_ = expressions(minNum, maxNum) }

    def PrintSums() { resultSet_.each { result -> println "" + result.head() + "=" + result.last() }}

    def PrintMatchedSums(NumberSetG other) {
        resultSet_.each{ r -> other.resultSet_.findAll { r.head() == it.head() }.
            each{println r.last() + " == " + it.last()} }
    }

    def expressions(minNum, maxNum) {
        getExprSet(minNum + 1, maxNum, [minNum.toString()]).inject([],
            { sum, expr -> sum + [evaluate(expr)]
        }).sort{ l,r -> l.head() <=> r.head() }
    }

    def getExprSet(minNum, maxNum, strSet) {
        def nextStrSet = strSet.inject([], { sum, str ->
            sum + [str + "*" + minNum.toString(), str + "+" + minNum.toString()]})
        (minNum == maxNum) ? nextStrSet : getExprSet(minNum + 1, maxNum, nextStrSet)
    }

    def evaluate(expr) { [Eval.me(expr), expr] }

    static main(args) {
        NumberSetG q1 = new NumberSetG(1,4)
        q1.PrintSums()
        NumberSetG q2l = new NumberSetG(1,5)
        NumberSetG q2r = new NumberSetG(2,6)
        q2l.PrintMatchedSums(q2r)
    }
}
