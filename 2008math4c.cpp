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
#include <memory>
#include <string>
#include <type_traits>
#include <unordered_map>
#include <vector>
#include <boost/lexical_cast.hpp>
#include <boost/multiprecision/cpp_int.hpp>
#include <boost/optional.hpp>
#include <boost/spirit/include/qi.hpp>
#include <boost/spirit/include/phoenix_operator.hpp>
#include <boost/spirit/include/phoenix_function.hpp>

using BigNumber = boost::multiprecision::uint512_t;  // 計算結果

// unordered_mapに格納できるようにする
namespace std {
  template <> struct hash<BigNumber> {
    std::size_t operator()(const BigNumber& key) const {
        using KeyType = size_t;
        static_assert(std::is_unsigned<KeyType>::value, "Expect unsigned key");
        return static_cast<KeyType>(key);
    }
  };
}

class NumberSet {
    using Expression = std::string;
    struct Result final {
        Result(const Expression& argExpr, const boost::optional<BigNumber>& argValue) :
            expr(argExpr), value(argValue) {}
        Expression expr;
        boost::optional<BigNumber> value;
    };
    using ExpressionSet = std::vector<Expression>;
    using ResultSet = std::vector<std::shared_ptr<Result>>;
    using ResultMap = std::unordered_map<BigNumber, std::vector<std::shared_ptr<Result>>>;

public:
    enum class FILTER {
        BY_EXPRESSION,
        BY_VALUE,
    };

    enum class PRINT_VALUE {
        NO_PRINT,
        PRINT,
    };

    NumberSet(const BigNumber& minNumber, const BigNumber& maxNumber,
              FILTER filter, PRINT_VALUE printValue) :
        filter_(filter), printValue_(printValue) {
        addExpressions(minNumber, maxNumber);
        std::sort(results_.begin(), results_.end(),
                  [&](auto& l, auto& r) { return (*(l->value) < *(r->value)); });
    }

    virtual ~NumberSet(void) = default;
    NumberSet(const NumberSet&) = delete;
    NumberSet& operator=(const NumberSet&) = delete;

    void PrintSums(std::ostream& os) {
        for(auto& result : results_) {
            os << *(result->value) << " = " << result->expr << "\n";
        }
    }

    void PrintMatchedSums(const NumberSet& other, std::ostream& os) {
        for(auto& result : results_) {
            if (other.resultMap_.empty()) {
                for(auto& otherResult : other.results_) {
                    if (*(result->value) == *(otherResult->value)) {
                        printValue(result->value, os);
                        os << result->expr << " == " << otherResult->expr << "\n";
                    }
                }
            } else {
                auto iResults = other.resultMap_.find(*(result->value));
                if (iResults != other.resultMap_.end()) {
                    printValue(result->value, os);
                    os << result->expr;
                    for(auto& otherResult : iResults->second) {
                        os << " == " << otherResult->expr;
                    }
                    os << "\n";
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
                registerExpressions(expr);
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

    void registerExpressions(const Expression& expr) {
        auto value = calculate(expr);
        if (value) {
            std::shared_ptr<Result> pResult = std::make_shared<Result>(expr, value);
            results_.push_back(pResult);

            if ((filter_ == FILTER::BY_VALUE) && value) {
                resultMap_[*value].push_back(pResult);
            }
        }
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

    void printValue(const boost::optional<BigNumber>& value, std::ostream& os) {
        if (printValue_ == NumberSet::PRINT_VALUE::PRINT) {
            os << *value << " : ";
        }
        return;
    }

    ResultSet results_;
    ResultMap resultMap_;
    FILTER filter_;
    PRINT_VALUE printValue_;
};

int main(int argc, char* argv[]) {
    NumberSet::PRINT_VALUE printValue = (argc < 2) ?
        NumberSet::PRINT_VALUE::NO_PRINT : NumberSet::PRINT_VALUE::PRINT;

    if (argc < 6) {
        // 問4-1
        NumberSet s(1,4, NumberSet::FILTER::BY_EXPRESSION, printValue);
        s.PrintSums(std::cout);

        // 問4-2
        NumberSet l(1,5, NumberSet::FILTER::BY_EXPRESSION, printValue);
        NumberSet r(2,6, NumberSet::FILTER::BY_EXPRESSION, printValue);
        l.PrintMatchedSums(r, std::cout);
    } else {
        std::string mode(argv[1]);
        // 引数mapをつけると、連想配列を使って解く
        // 引数slowをつけると総当たりで解く、実はmap以外の文字列なら何でもよい
        NumberSet::FILTER filter = (mode == "map") ?
            NumberSet::FILTER::BY_VALUE : NumberSet::FILTER::BY_EXPRESSION;

        unsigned int minLeft  = boost::lexical_cast<decltype(minLeft)>(argv[2]);
        unsigned int maxLeft  = boost::lexical_cast<decltype(maxLeft)>(argv[3]);
        unsigned int minRight = boost::lexical_cast<decltype(minRight)>(argv[4]);
        unsigned int maxRight = boost::lexical_cast<decltype(maxRight)>(argv[5]);
        NumberSet l(minLeft,  maxLeft,  filter, printValue);
        NumberSet r(minRight, maxRight, filter, printValue);
        l.PrintMatchedSums(r, std::cout);
    }

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
