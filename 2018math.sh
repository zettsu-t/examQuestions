#! /usr/bin/bash
# 2018年の麻布中学校の入試問題(算数 問4)の解答例です。
# 問題は以下のサイトにあります。
# https://www.inter-edu.com/nyushi/azabu/
ruby -e "r=->(a){['+','*','=='].repeated_permutation(a.size-1).map{|x|a.zip(x).join}.select{|s|s.count('=')==2&&eval(s)}};p r[[1,4,5,6,7,8]];p r[[2,3,5,7,11,13,17]]"
