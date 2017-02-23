.intel_syntax noprefix
.file   "2008math4.s"

.text
    .global getExpressionInAsm
getExpressionInAsm:
    .set   RegValue,    rax  # 合計
    .set   RegDigits,   rbx  # ビットフィールドで表現する桁の並び
    .set   RegOps,      rdi  # 演算子の並び : 1は乗算、0は加算
    .set   RegStrPtr,   rsi  # 文字列の書き込み先
    .set   RegMulBase,  rdx  # 乗算は暗黙にrdxレジスタを掛ける

    .set   RegBaseMask, r8
    .set   RegMask,     r9
    .set   RegOpMask,   r10
    .set   RegCharMul,  r11
    .set   RegChar,     r12
    .set   RegCharB,    r12b

    # 上記とは同時に使わない
    .set   RegShift,    r10
    .set   RegMulLow,   r11
    .set   RegMulLowB,  r11b
    # 積を12ビット > 720 = 2*3*4*5*6 で表現する
    .set   BitWidth,    12

    # 桁数分のマスクを作る
    mov    RegBaseMask, 1
    shl    RegBaseMask, BitWidth
    sub    RegBaseMask, 1

    # 最小桁について、値と演算子を取り出すマスクを作る
    mov    RegOpMask,   1
    mov    RegCharMul,  0x2a      # '*'のアスキーコード
    mov    RegMask, RegBaseMask

11:
    # 一桁取り出して、数字を文字にして書き込む
    pext   RegChar, RegDigits, RegMask
    add    RegChar, 0x30          # '0'のアスキーコード
    mov    [RegStrPtr], RegCharB
    shl    RegMask, BitWidth
    add    RegStrPtr, 1

    # 演算子を一つ取り出して、文字にして書き込む
    mov    RegChar, 0x2b          # '+'のアスキーコード
    test   RegOps,  RegOpMask
    cmovnz RegChar, RegCharMul
    mov    [RegStrPtr], RegCharB
    shl    RegOpMask, 1
    add    RegStrPtr, 1
    # 桁数はrcxレジスタにあらかじめ設定されている
    loop   11b

    # 最後の演算子は余分なのでNULに置き換える
    sub    RegStrPtr, 1
    mov    byte ptr [RegStrPtr], 0

    # 何桁目に乗算があるか探す
21:
    bsf    RegShift, RegOps
    #これ以上乗算はない
    jz     22f

    # 掛け算の印を消す
    mov    RegMask, 1
    shlx   RegMask, RegMask, RegShift
    xor    RegOps, RegMask

    # i桁目とi+1桁を掛けて、i+1桁に入れる
    # 下の桁のビット位置を求める
    mov    RegMask, RegBaseMask
    mov    RegMulBase, BitWidth
    mulx   RegMulBase, RegShift, RegShift

    # 下の桁を取り出して0にする
    shlx   RegMask, RegMask, RegShift
    pext   RegMulBase, RegDigits, RegMask
    andn   RegDigits, RegMask, RegDigits

    # 上の桁を取り出して0にする
    shl    RegMask, BitWidth
    pext   RegMulLow, RegDigits, RegMask
    andn   RegDigits, RegMask, RegDigits

    # 積を上の桁に入れる
    mulx   RegMulBase, RegMulLow, RegMulLow
    pdep   RegMulLow, RegMulLow, RegMask
    or     RegDigits, RegMulLow
    jmp    21b

    # ビットマスクがなくなるまですべての桁を足す
22:
    xor    RegValue, RegValue
    mov    RegMask, RegBaseMask

23:
    pext   RegMulLow, RegDigits, RegMask
    add    RegValue, RegMulLow
    shl    RegMask, BitWidth
    jnc    23b
    ret
