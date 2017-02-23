// 出題元
// 麻布中学校 2008年 入試問題 算数 問4 解法

#include <cstdint>
#include <algorithm>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

class NumberSet {
    using Register = uint64_t;
    using Expression = std::string;
    struct Result {
        Expression expr;
        Register   value;
    };
    using ExpressionSet = std::vector<Expression>;
    using ResultSet = std::vector<Result>;
    static constexpr Register DigitBitWidth = 12;  // 各桁を何bitで計算するか

public:
    using Digit = uint8_t;
    NumberSet(Digit minNum, Digit maxNum) {
        const size_t sizeOfDigits = maxNum - minNum + 1;
        const size_t sizeOfPatterns = 1 << (maxNum - minNum);

        Register digits = 0;
        Register i = maxNum;  // 0ではないと仮定している
        do {
            digits <<= DigitBitWidth;
            digits |= i;
            --i;
        } while ((i != 0) && (i >= minNum));

        for(size_t ops = 0; ops < sizeOfPatterns; ++ops) {
            // Ruby版と出力順序を合わせる
            results_.push_back(getExpression(sizeOfDigits, digits, sizeOfPatterns - 1 - ops));
        }

        std::sort(results_.begin(), results_.end(),
                  [&](const auto& l, const auto& r) { return (l.value < r.value); });
        return;
    }

    void PrintSums(std::ostream& os) {
        for(auto& result : results_) {
            os << result.value << " = " << result.expr << "\n";
        }
    }

    void PrintMatchedSums(const NumberSet& other, std::ostream& os) {
        for(auto& result : results_) {
            for(auto& otherResult : other.results_) {
                if (result.value == otherResult.value) {
                    os << result.expr << " == " << otherResult.expr << "\n";
                }
            }
        }
    }

    Result getExpression(size_t sizeOfDigits, Register digits, Register ops) {
        // 式の結果
        Register value = 0;
        // 各bitをcharにしたとして十分長い文字列を格納できる領域
        // 終端のNUL0と、演算子を1文字余分に書き込む分が必要
        char str[(sizeof(Register) + 1) * 8] {0};
        auto pStr = str;

        asm volatile (
            "call getExpressionInAsm \n\t"
            :"+a"(value),"+b"(digits),"+D"(ops),"+S"(pStr),"+c"(sizeOfDigits)::
             "rdx","r8","r9","r10","r11","r12","r13","r14","r15","memory");

        pStr = nullptr;
        Result result { str, value };
        return result;
    }

private:
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
