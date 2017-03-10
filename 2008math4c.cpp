// 出題元
// 麻布中学校 2008年 入試問題 算数 問4 解法
//
// Boost C++ Libraries 1.63.0 (boost_1_63_0.zip) に含まれる
// libs/spirit/example/qi/calc_utree_ast.cpp を改変したものを用いています。
// Boost Software License は、以下から参照できます
// http://www.boost.org/LICENSE_1_0.txt
//
// 構文解析結果をASTとしてではなく、直接値として返す方法は、以下を参考にしました。
// http://www.kmonos.net/alang/boost/classes/spirit.html

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
#include <boost/lexical_cast.hpp>
#include <boost/multiprecision/cpp_int.hpp>
#include <boost/optional.hpp>
#include <boost/spirit/include/qi.hpp>
#include <boost/spirit/include/phoenix_operator.hpp>
#include <boost/spirit/include/phoenix_function.hpp>

using BigNumber = boost::multiprecision::uint512_t;  // 計算結果

class NumberSet {
    using Expression = std::string;
    struct Result {
        Expression expr;
        boost::optional<BigNumber> value;
    };
    using ExpressionSet = std::vector<Expression>;
    using ResultSet = std::vector<Result>;

public:
    NumberSet(const BigNumber& minNumber, const BigNumber& maxNumber) {
        addExpressions(minNumber, maxNumber);
        std::sort(results_.begin(), results_.end(),
                  [&](const auto& l, const auto& r) { return (*(l.value) < *(r.value)); });
    }

    virtual ~NumberSet(void) = default;
    NumberSet(const NumberSet&) = delete;
    NumberSet& operator=(const NumberSet&) = delete;

    void PrintSums(std::ostream& os) {
        for(auto& result : results_) {
            os << *(result.value) << " = " << result.expr << "\n";
        }
    }

    void PrintMatchedSums(const NumberSet& other, std::ostream& os) {
        for(auto& result : results_) {
            for(auto& otherResult : other.results_) {
                if (*(result.value) == *(otherResult.value)) {
                    os << result.expr << " == " << otherResult.expr << "\n";
                }
            }
        }
    }

private:
    void addExpressions(const BigNumber& number, const BigNumber& maxNumber) {
        ExpressionSet exprSet;
        exprSet.push_back(boost::lexical_cast<std::string>(number));
        addExpressions(exprSet, number + 1, maxNumber);
        return;
    }

    void addExpressions(const ExpressionSet& exprSet, const BigNumber& number, const BigNumber& maxNumber) {
        if (number > maxNumber) {
            for(auto& expr : exprSet) {
                results_.push_back(Result{expr, calculate(expr)});
            }
        } else {
            ExpressionSet exprSetPlus;
            for(auto& expr : exprSet) {
                exprSetPlus.push_back(expr + "*" + boost::lexical_cast<std::string>(number));
                addExpressions(exprSetPlus, number + 1, maxNumber);
            }

            ExpressionSet exprSetMul;
            for(auto& expr : exprSet) {
                exprSetMul.push_back(expr + "+" + boost::lexical_cast<std::string>(number));
                addExpressions(exprSetMul, number + 1, maxNumber);
            }
        }
        return;
    }

    template <typename Iterator>
    struct calculator : boost::spirit::qi::grammar<Iterator, boost::spirit::ascii::space_type, BigNumber()> {
        boost::spirit::qi::rule<Iterator, boost::spirit::ascii::space_type, BigNumber()> expression, term, factor;
        calculator() : calculator::base_type(expression) {
            expression = term[boost::spirit::qi::_val = boost::spirit::qi::_1]
                >> *('+' >> term[boost::spirit::qi::_val += boost::spirit::qi::_1]);
            term = factor[boost::spirit::qi::_val = boost::spirit::qi::_1]
                >> *('*' >> factor[boost::spirit::qi::_val *= boost::spirit::qi::_1]);
            factor = boost::spirit::qi::uint_[boost::spirit::qi::_val = boost::spirit::qi::_1];
        }
    };

    boost::optional<BigNumber> calculate(const std::string& str) {
        BigNumber number = 0;
        boost::optional<BigNumber> result;

        calculator<std::string::const_iterator> calc;
        if (phrase_parse(str.begin(), str.end(), calc, boost::spirit::ascii::space, number)) {
            result = number;
        }

        return result;
    }

    ResultSet results_;
};

int main(int argc, char* argv[]) {
    // 問4-1
    NumberSet s(1,4);
    s.PrintSums(std::cout);

    // 問4-2
    NumberSet l(1,5);
    NumberSet r(2,6);
    l.PrintMatchedSums(r, std::cout);

//  NumberSet u(2002,2017);
//  u.PrintSums(std::cout);
    return 0;
}

/*
Local Variables:
mode: c++
coding: utf-8-dos
tab-width: nil
c-file-style: "stroustrup"
End:
*/
