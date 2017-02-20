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
            // iビット目が立っていたら、i番目とi+1番目の数の積をi+1番目に入れ、
            // i番目を0にする
            ".set RegValue,    rax \n\t"  // 合計
            ".set RegDigits,   rbx \n\t"  // ビットフィールドで表現する桁の並び
            ".set RegOps,      rdi \n\t"  // 演算子の並び : 1は乗算、0は加算
            ".set RegStrPtr,   rsi \n\t"  // 文字列の書き込み先
            ".set RegMulBase,  rdx \n\t"  // 乗算は暗黙にrdxレジスタを掛ける

            ".set RegBaseMask, r8   \n\t"
            ".set RegMask,     r9   \n\t"
            ".set RegOpMask,   r10  \n\t"
            ".set RegCharMul,  r11  \n\t"
            ".set RegChar,     r12  \n\t"
            ".set RegCharB,    r12b \n\t"

            // 上記とは同時に使わない
            ".set RegShift,    r10 \n\t"
            ".set RegMulLow,   r11 \n\t"
            ".set RegMulLowB,  r11b \n\t"
            // 積を12ビット > 720 = 2*3*4*5*6 で表現する
            ".set BitWidth,  12 \n\t"  // DigitBitWidthを設定する

            // 桁数分のマスクを作る
            "mov  RegBaseMask, 1 \n\t"
            "shl  RegBaseMask, BitWidth \n\t"
            "sub  RegBaseMask, 1 \n\t" // 1がBitWidth個並ぶ

            // 最小桁について、値と演算子を取り出すマスクを作る
            "mov  RegOpMask, 1 \n\t"
            "mov  RegCharMul, 0x2a \n\t"  // *のアスキーコード
            "mov  RegMask, RegBaseMask \n\t"

            "11: \n\t"
            // 一桁取り出して、数字を文字にして書き込む
            "pext RegChar, RegDigits, RegMask \n\t"
            "add  RegChar, 0x30 \n\t"     // 0のアスキーコード
            "mov  [RegStrPtr], RegCharB \n\t"
            "shl  RegMask, BitWidth \n\t"
            "add  RegStrPtr, 1 \n\t"

            // 演算子を一つ取り出して、文字にして書き込む
            "mov    RegChar, 0x2b \n\t"  // +のアスキーコード
            "test   RegOps,  RegOpMask  \n\t"
            "cmovnz RegChar, RegCharMul \n\t"
            "mov    [RegStrPtr], RegCharB \n\t"
            "shl    RegOpMask, 1 \n\t"
            "add    RegStrPtr, 1 \n\t"
            // 桁数はrcxレジスタにあらかじめ設定されている
            "loop   11b \n\t"

            // 最後の演算子は余分なのでNULに置き換える
            "sub  RegStrPtr, 1 \n\t"
            "mov  byte ptr [RegStrPtr], 0 \n\t"

            // 何桁目に乗算があるか探す
            "21: \n\t"
            "bsf  RegShift, RegOps \n\t"
            // これ以上乗算はない
            "jz   22f \n\t"

            // 掛け算の印を消す
            "mov  RegMask, 1 \n\t"
            "shlx RegMask, RegMask, RegShift \n\t"
            "xor  RegOps, RegMask \n\t"

            // i桁目とi+1桁を掛けて、i+1桁に入れる
            // 下の桁のビット位置を求める
            "mov  RegMask, RegBaseMask \n\t"
            "mov  RegMulBase, BitWidth \n\t"
            "mulx RegMulBase, RegShift, RegShift \n\t"

            // 下の桁を取り出して0にする
            "shlx RegMask, RegMask, RegShift \n\t"
            "pext RegMulBase, RegDigits, RegMask \n\t"
            "andn RegDigits, RegMask, RegDigits \n\t"

            // 上の桁を取り出して0にする
            "shl  RegMask, BitWidth \n\t"
            "pext RegMulLow, RegDigits, RegMask \n\t"
            "andn RegDigits, RegMask, RegDigits \n\t"

            // 積を上の桁に入れる
            "mulx RegMulBase, RegMulLow, RegMulLow \n\t"
            "pdep RegMulLow, RegMulLow, RegMask \n\t"
            "or   RegDigits, RegMulLow \n\t"
            "jmp  21b \n\t"

            // ビットマスクがなくなるまですべての桁を足す
            "22: \n\t"
            "xor  RegValue, RegValue \n\t"
            "mov  RegMask, RegBaseMask \n\t"

            "23: \n\t"
            "pext RegMulLow, RegDigits, RegMask \n\t"
            "add  RegValue, RegMulLow \n\t"
            "shl  RegMask, BitWidth \n\t"
            "jnc  23b \n\t"
            :"+a"(value),"+b"(digits),"+D"(ops),"+S"(pStr),"+c"(sizeOfDigits)::
             "rdx","r8","r9","r10","r11","r12","memory");

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
