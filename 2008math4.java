import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import javax.script.Invocable;
import java.util.List;
import java.util.ArrayList;

class NumberSet {
    private class Result {
        Result(Integer value, String expr) {
            value_ = value;
            expr_ = expr;
        }
        public Integer value_;
        public String  expr_;
    }

    private ScriptEngineManager manager_;
    private ScriptEngine engine_;
    private String       statement_;
    private String       funcName_;
    private Invocable    invocable_;
    private List<Result> resultSet_;

    public NumberSet(int minNum, int maxNum) {
        manager_ = new ScriptEngineManager();
        engine_ = manager_.getEngineByName("javascript");
        statement_ = "function evalExpr(expr) { return eval(expr); }";
        try {
            engine_.eval(statement_);
        } catch (Exception e) {
            System.err.println("Errors in eval : " + e.getMessage());
            System.exit(1);
        }

        funcName_ = "evalExpr";
        invocable_ = (Invocable) engine_;
        resultSet_ = expressions(minNum, maxNum);
        resultSet_.sort((l,r)-> l.value_ - r.value_);
    }

    public void PrintSums() {
        for(Result result : resultSet_) {
            System.out.println(result.value_ + "=" + result.expr_);
        }
    }

    public void PrintMatchedSums(NumberSet other) {
        for(Result resultA : resultSet_) {
            for(Result resultB : other.resultSet_) {
                if ((resultA.value_ - resultB.value_) == 0) {
                    System.out.println(resultA.expr_ + "=" + resultB.expr_);
                }
            }
        }
    }

    private List<Result> expressions(int minNum, int maxNum) {
        List<String> strSet = new ArrayList<String>();
        List<Result> resultSet = new ArrayList<Result>();
        strSet.add(String.valueOf(minNum));

        for(String expr : getExprSet(minNum + 1, maxNum, strSet)) {
            Integer value = evaluate(expr);
            Result  result = new Result(value, expr);
            resultSet.add(result);
        }
        return resultSet;
    }

    private List<String> getExprSet(int minNum, int maxNum, List<String> strSet) {
        List<String> nextStrSet = new ArrayList<String>();

        for(String str : strSet) {
            nextStrSet.add(str + "*" + String.valueOf(minNum));
            nextStrSet.add(str + "+" + String.valueOf(minNum));
        }

        if (minNum == maxNum) {
            return nextStrSet;
        }

        return getExprSet(minNum + 1, maxNum, nextStrSet);
    }

    private Integer evaluate(String expr) {
        Integer result = new Integer(0);
        try {
            result = (Integer) invocable_.invokeFunction(funcName_, expr);
        } catch (Exception e) {
            System.err.println("Errors in eval : " + e.getMessage());
            System.exit(1);
        }

        return result;
    }
}

class Exam2008Q4 {
    public static void main(String[] args){
        // Question 4-1
        NumberSet numberSet = new NumberSet(1,4);
        numberSet.PrintSums();
        // Question 4-2
        NumberSet numberSet1to5 = new NumberSet(1,5);
        NumberSet numberSet2to6 = new NumberSet(2,6);
        numberSet1to5.PrintMatchedSums(numberSet2to6);
    }
}
