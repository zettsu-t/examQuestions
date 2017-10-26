library(data.table)

ops <- factor(c('+', '*'))

make_exprs <- function(rows) {
    strsplit(apply(rows, 1, paste, collapse=""), split=" ")
}

make_value_expr <- function(expr) {
    c(eval(parse(text=expr)), expr)
}

make_value_expr_list <- function(exprs) {
    lapply(exprs, make_value_expr)
}

print_result <- function(l) {
    sprintf("%s = %s", l[1], l[2])
}

q1rows <- expand.grid('1', ops, '2', ops, '3', ops, '4')
q1exprs <- make_exprs(q1rows)
q1list <- make_value_expr_list(q1exprs)
q1result <- q1list[order(sapply(q1list, function(x) strtoi(x[1])), decreasing=FALSE)]
lapply(q1result, print_result)

q2left <- make_exprs(expand.grid('1', ops, '2', ops, '3', ops, '4', ops, '5'))
q2right <- make_exprs(expand.grid('2', ops, '3', ops, '4', ops, '5', ops, '6'))
q2left_list <- make_value_expr_list(q2left)
q2right_list <- make_value_expr_list(q2right)

for (left in q2left_list) {
    for (right in q2right_list) {
        if (left[1] == right[1]) {
            print(sprintf("%s == %s", left[2], right[2]))
        }
    }
}
