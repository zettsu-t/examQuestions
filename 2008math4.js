var Combinatorics = require('js-combinatorics');

function expressions(minNum, maxNum) {
    var size = maxNum - minNum + 1;
    return Combinatorics.cartesianProduct(...(Array(size - 1).fill(['+', '*']))).map(function(xs) {
        var expr = [minNum]
        for(i=0; i<(size - 1); ++i) { expr.push(xs[i], minNum + i + 1); }
        return expr.join('');
    })
}

function printSums(minNum, maxNum) {
    expressions(minNum, maxNum).map(function(str) { return String(eval(str)) + " = " + str;
    }).sort (function(a,b) { return (parseInt(a) < parseInt(b)) ? -1 : 1;
    }).forEach (function(str) { console.log(str);
    })
}

function printMatchedSums(minNumLeft, maxNumLeft, minNumRight, maxNumRight) {
    expressions(minNumLeft, maxNumLeft).map(function(left) {
        expressions(minNumRight, maxNumRight).map(function(right) {
            var str = left + " == " + right;
            if (eval(str)) { console.log(str); }})})
}

// 問4-1
printSums(1,4);
// 問4-2
printMatchedSums(1,5,2,6);
