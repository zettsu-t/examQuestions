use std::string::String;
use std::vec::Vec;
use std::collections::LinkedList;

struct Result {
    value : usize,
    expr  : String
}

fn make_result(value : usize, nums: Vec<usize>, ops: Vec<usize>) -> Result {
    let mut s : String = nums[0].to_string();
    let mut restnums = nums.clone();
    restnums.remove(0);
    for op in ops {
       if op == 0 {
          s += "+";
       } else {
          s += "*";
       }
       s += &restnums[0].to_string();
       restnums.remove(0);
    }

    let result = Result {value : value, expr : s};
    result
}

fn op_lists(x: usize) -> LinkedList<Vec<usize>> {
    let mut result : LinkedList<Vec<usize>> = LinkedList::new();
    if x == 0 {
        result.push_back(vec![]);
    } else {
        for sub in op_lists(x - 1) {
            let elements : Vec<usize> = vec![0,1];
            for element in elements {
                let mut s = sub.clone();
                s.push(element);
                result.push_back(s);
            }
        }
    }
    result
}

fn apply_op_lists(nums: Vec<usize>, ops: Vec<usize>) -> usize {
    let mut result : usize = nums[0];
    if ops.len() > 0 {
        let mut newnums = nums.clone();
        let mut newops = ops.clone();
        newnums.remove(0);
        newops.remove(0);
        if ops[0] == 0 {
            result = nums[0] + apply_op_lists(newnums, newops);
        } else {
            newnums[0] = newnums[0] * nums[0];
            result = apply_op_lists(newnums, newops);
        }
    }

    result
}

fn expressions(min_num: usize, max_num: usize) -> Vec<Result> {
    let mut results : Vec<Result> = Vec::new();
    for ops in op_lists(max_num - min_num) {
       let nums : Vec<usize> = ((min_num)..(max_num+1)).collect();
       let vops = ops.clone();
       let vnums = nums.clone();
       let result = make_result(apply_op_lists(nums, ops), vnums, vops);
       results.push(result);
    }

    results.sort_by(|x,y| x.value.cmp(&y.value));
    results
}

fn q1(min_num: usize, max_num: usize) {
    for result in expressions(min_num, max_num) {
        println!("{} = {}", result.value, result.expr);
    }
}

fn q2(min_left: usize, max_left: usize, min_right: usize, max_right: usize) {
    for left in expressions(min_left, max_left) {
        for right in expressions(min_right, max_right) {
            if left.value == right.value {
                println!("{} == {}", left.expr, right.expr);
            }
        }
    }
}

fn main() {
    q1(1,4);
    q2(1,5,2,6);
}
