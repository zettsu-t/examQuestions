#!/bin/bash
# Question 4-1
for exprStr in `echo 1{*,+}2{*,+}3{*,+}4`; do echo `echo $exprStr | bc` = $exprStr; done | sort -n

# Question 4-2
for left in `echo 1{+,*}2{+,*}3{+,*}4{+,*}5`; do
  for right in `echo 2{+,*}3{+,*}4{+,*}5{+,*}6`; do
    if [ `echo $left | bc` -eq `echo $right| bc` ] ; then
      echo $left "==" $right
    fi
  done
done
