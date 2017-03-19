e=->(m,n){(m+1..n).inject([m]){|x,i|x.product(["+","*"],[i])}.map &:join}
p e[1,4].map{|x|"#{eval x}=#{x}"}.sort_by &:to_i
p e[1,5].product(e[2,6]).map{|x|x.join"=="}.select{|x|eval x}
exit(0)
