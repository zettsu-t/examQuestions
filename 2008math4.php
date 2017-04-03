<!DOCTYPE HTML>
<html lang="en">
<head>
<meta charset="utf-8" />
</head>
<body>
<?php
    function all_op_seqs($size) {
        $ops = array('+', '*');
        $op_seqs = array();
        if ($size == 1) {
            $op_seqs = $ops;
        } else {
            foreach(all_op_seqs($size - 1) as $sub_op_seq) {
                foreach ($ops as $op) {
                    $s = $op . $sub_op_seq;
                    array_push($op_seqs, $s);
                }
            }
        }
        return $op_seqs;
    }

    function calculate($nums, $ops) {
        if (count($nums) == 1) {
            return $nums[0];
        }
        $num = array_shift($nums);
        $op = array_shift($ops);
        if ($op == '+') {
            return $num + calculate($nums, $ops);
        }
        $nums[0] *= $num;
        return calculate($nums, $ops);
    }

    function expr_to_str($nums, $ops) {
        if (count($nums) == 1) {
            return $nums[0];
        }
        $num = array_shift($nums);
        $op = array_shift($ops);
        return $num . $op . expr_to_str($nums, $ops);
    }

    function compare_expr($exprl, $exprr) {
        $l = intval($exprl);
        $r = intval($exprr);
        if ($l == $r) {
            return 0;
        }
        return ($l < $r) ? -1 : 1;
    }

    function q1($minnum, $maxnum) {
        $results = array();
        $all_ops = all_op_seqs($maxnum - $minnum);
        $nums = range($minnum, $maxnum);
        foreach ($all_ops as $ops_seq) {
            $ops = str_split($ops_seq, 1);
            $result = calculate($nums, $ops);
            $result = $result . " = ". expr_to_str($nums, $ops);
            array_push($results, $result);
        }

        uasort($results, 'compare_expr');
        foreach ($results as $result) {
            echo "<p>" . $result . "</p>";
        }
    }

    function q2($minnum_l, $maxnum_l, $minnum_r, $maxnum_r) {
        $nums_l = range($minnum_l, $maxnum_l);
        $nums_r = range($minnum_r, $maxnum_r);
        foreach(all_op_seqs($maxnum_l - $minnum_l) as $ops_l_seq) {
            $ops_l = str_split($ops_l_seq, 1);
            $expr_l = expr_to_str($nums_l, $ops_l);
            $result_l = calculate($nums_l, $ops_l);
            foreach(all_op_seqs($maxnum_r - $minnum_r) as $ops_r_seq) {
                $ops_r = str_split($ops_r_seq, 1);
                $expr_r = expr_to_str($nums_r, $ops_r);
                $result_r = calculate($nums_r, $ops_r);
                if (compare_expr($result_l, $result_r) == 0) {
                    echo "<p>" . $expr_l . " == " . $expr_r . "</p>";
                }
            }
        }
    }

    q1(1,4);
    q2(1,5,2,6);
?>
</body>
</html>
