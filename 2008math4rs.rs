use std::string::String;
use std::string::ToString;
use std::vec::Vec;
use std::collections::LinkedList;
use std::env;

type ExprValue = usize;

struct Result {
    value : ExprValue,
    expr  : String
}

fn make_result(value : ExprValue, nums: Vec<ExprValue>, ops: Vec<ExprValue>) -> Result {
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

fn op_lists(x: ExprValue) -> LinkedList<Vec<ExprValue>> {
    let mut result : LinkedList<Vec<ExprValue>> = LinkedList::new();
    if x == 0 {
        result.push_back(vec![]);
    } else {
        for sub in op_lists(x - 1) {
            let elements : Vec<ExprValue> = vec![0,1];
            for element in elements {
                let mut s = sub.clone();
                s.push(element);
                result.push_back(s);
            }
        }
    }
    result
}

fn apply_op_lists(nums: Vec<ExprValue>, ops: Vec<ExprValue>) -> ExprValue {
    let mut result : ExprValue = nums[0];
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

fn expressions(min_num: ExprValue, max_num: ExprValue) -> Vec<Result> {
    let mut results : Vec<Result> = Vec::new();
    for ops in op_lists(max_num - min_num) {
       let nums : Vec<ExprValue> = ((min_num)..(max_num+1)).collect();
       let vops = ops.clone();
       let vnums = nums.clone();
       let result = make_result(apply_op_lists(nums, ops), vnums, vops);
       results.push(result);
    }

    results.sort_by(|x,y| x.value.cmp(&y.value));
    results
}

fn q1(min_num: ExprValue, max_num: ExprValue) {
    for result in expressions(min_num, max_num) {
        println!("{} = {}", result.value, result.expr);
    }
}

fn q2(print_value: bool, min_left: ExprValue, max_left: ExprValue, min_right: ExprValue, max_right: ExprValue) {
    let right_exprs = expressions(min_right, max_right);
    let size = right_exprs.len();
    let mut index = 0;
    let mut count = 0;

    for left in expressions(min_left, max_left) {
        index -= count;
        if index >= size {
            break
        }

        count = 0;
        while index < size && left.value >= right_exprs[index].value {
            if left.value == right_exprs[index].value {
                if print_value {
                    println!("{} : {} == {}", left.value, left.expr, right_exprs[index].expr);
                } else {
                    println!("{} == {}", left.expr, right_exprs[index].expr);
                }
                count += 1;
            }
            index += 1;
        }
    }
}

fn main() {
    if env::args().len() < 5 {
        q1(1,4);
        q2(false, 1,5,2,6);
    } else {
        let args : Vec<String> = env::args().collect();
        q2(true,
           args[1].parse::<ExprValue>().unwrap(),
           args[2].parse::<ExprValue>().unwrap(),
           args[3].parse::<ExprValue>().unwrap(),
           args[4].parse::<ExprValue>().unwrap());
    }
}
