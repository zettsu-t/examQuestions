(use 'clojure.math.combinatorics)

(defn calc [num nums ops]
  (if (= 0 (count nums)) num
    (if (= "+" (first ops))
      (+ num (calc (first nums) (rest nums) (rest ops)))
      (calc (* num (first nums)) (rest nums) (rest ops)))))

(defn evalExpr [num nums ops]
   [(calc num nums ops), (cons num (interleave ops nums))])

(defn expressions [minNum maxNum]
  (sort-by first
        (map (fn [ops] (evalExpr minNum (range (+ 1 minNum) (+ 1 maxNum) 1) ops))
             (apply cartesian-product (repeat (- maxNum minNum) '("*" "+"))))))

(defn matchExpr [exprSetA exprSetB]
  (filter (fn [x] (== (first (first x)) (first (second x))))
          (apply cartesian-product [exprSetA exprSetB])))

; Question 4-1
(run! println (expressions 1 4))

; Question 4-2
(run! println (matchExpr (expressions 1 5) (expressions 2 6)))
