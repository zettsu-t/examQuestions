#!/usr/bin/perl
# coding: utf-8
#
# 出題元
# 麻布中学校 2008年 入試問題 算数 問4 解法

sub expressions {
    my ($minNum, $maxNum) = @_;
    my @ls;
    my $num = "" . $minNum;

    if ($minNum == $maxNum) {
        push(@ls, $num);
    } else {
        foreach my $subExpr (expressions($minNum + 1, $maxNum)) {
           push(@ls, $num . "+" . $subExpr);
           push(@ls, $num . "*" . $subExpr);
        }
    }

    @ls;
}

sub printSums {
    my ($minNum, $maxNum) = @_;
    my @results;
    foreach my $expr (expressions($minNum, $maxNum)) {
        my $result = eval($expr);
        push(@results, ($result . " = " . $expr));
    }

    foreach my $result (sort { $a <=> $b } @results) {
        print $result . "\n";
    }
}

sub printMatchedSums {
    my ($minLeft, $maxLeft, $minRight, $maxRight) = @_;
    foreach my $leftExpr (expressions($minLeft, $maxLeft)) {
        foreach my $rightExpr (expressions($minRight, $maxRight)) {
            if (eval($leftExpr) == eval($rightExpr)) {
                print $leftExpr . " == " . $rightExpr . "\n";
            }
        }
    }
}

printSums(1, 4);
printMatchedSums(1, 5, 2, 6);
0;
