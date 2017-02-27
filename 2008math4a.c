// 出題元
// 麻布中学校 2008年 入試問題 算数 問4 解法

#include "inttypes.h"
#include "stdint.h"
#include "stdio.h"
#include "stdlib.h"
#include "string.h"

typedef uint64_t Register;
typedef uint8_t  Digit;

// レジスタの各bitをcharにしたとして十分長い文字列を格納できる領域
// 終端のNUL0と、演算子を1文字余分に書き込む分と、strcpyの終端分が必要
#define RESULT_EXPR_SIZE ((sizeof(Register) + 1) * 8)

// 式と結果
typedef struct tagResult {
    Register value;
    char     expr[RESULT_EXPR_SIZE];
} Result;

// 各桁を何bitで計算するか
#define DIGIT_BIT_WIDTH (12)

void get_expression(size_t sizeOfDigits, Register digits, Register ops, Result* pResult) {
    Register value = 0;
    char str[RESULT_EXPR_SIZE] = {0};
    char* pStr = str;

    asm volatile (
        "call getExpressionInAsm \n\t"
        :"+a"(value),"+b"(digits),"+D"(ops),"+S"(pStr),"+c"(sizeOfDigits)::
         "rdx","r8","r9","r10","r11","r12","r13","r14","r15","memory");

    pStr = NULL;
    pResult->value = value;
    // バッファが十分長いので、明示的に0終端する必要はない
    strncpy(pResult->expr, str, sizeof(pResult->expr)/sizeof(pResult->expr[0]));
    return;
}

// qsortから呼び出す関数
int sort_expressions(const void* pLeft, const void* pRight) {
    return (((const Result*)pLeft)->value < ((const Result*)pRight)->value) ? -1 : 1;
}

// ppResultSetが指す先に、長さが返り値の、Resultの配列を設定する
// 配列をfreeで解放するのは呼び出し元の責務である
size_t set_expressions(Digit minNum, Digit maxNum, Result** ppResultSet) {
    *ppResultSet = NULL;
    size_t sizeOfDigits = maxNum - minNum + 1;
    size_t sizeOfPatterns = 1 << (maxNum - minNum);
    Register digits = 0;
    Register i = maxNum;  // 0ではないと仮定している

    do {
        digits <<= DIGIT_BIT_WIDTH;
        digits |= i;
        --i;
    } while ((i != 0) && (i >= minNum));

    size_t size = 0;
    size_t capacity = 1;
    Result* pResultSet = malloc(sizeof(*pResultSet) * capacity);
    *ppResultSet = pResultSet;

    for(size_t ops = 0; ops < sizeOfPatterns; ++ops) {
        Result result;
        get_expression(sizeOfDigits, digits, ops, &result);

        if (capacity <= size) {
            capacity <<= 1;
            // 本当はreallocに失敗したときのために、引数と返り値は別の変数にすべきだが
            // 本プログラムでmallocとreallocに失敗することはないと想定している
            pResultSet = realloc(pResultSet, sizeof(*pResultSet) * capacity);
            *ppResultSet = pResultSet;
        }

        pResultSet[size++] = result;
    }

    qsort(pResultSet, size, sizeof(*pResultSet), sort_expressions);
    return size;
}

void print_sums(size_t size, const Result* pResultSet) {
    for(size_t i=0; i < size; ++i) {
        printf("%" PRIu64 " = %s\n", pResultSet[i].value, pResultSet[i].expr);
    }

    return;
}

void print_matched_sums(size_t sizeLeft, const Result* pLeft, size_t sizeRight, const Result* pRight) {
    for(size_t il=0; il < sizeLeft; ++il) {
        for(size_t ir=0; ir < sizeRight; ++ir) {
            if (pLeft[il].value == pRight[ir].value) {
                printf("%s == %s\n", pLeft[il].expr, pRight[ir].expr);
            }
        }
    }

    return;
}

int main(int argc, char* argv[]) {
    // 問4-1
    Result* pResultSet = NULL;
    size_t size = set_expressions(1, 4, &pResultSet);
    print_sums(size, pResultSet);
    free(pResultSet);
    pResultSet = NULL;

    // 問4-2
    Result* pLeft = NULL;
    size_t sizeLeft = set_expressions(1, 5, &pLeft);
    Result* pRight = NULL;
    size_t sizeRight = set_expressions(2, 6, &pRight);
    print_matched_sums(sizeLeft, pLeft, sizeRight, pRight);

    free(pLeft);
    pLeft = NULL;
    free(pRight);
    pRight = NULL;
    return 0;
}

/*
Local Variables:
mode: c
coding: utf-8-dos
tab-width: nil
c-file-style: "stroustrup"
End:
*/
