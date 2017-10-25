library("qcc")
library("reldist")

args <- commandArgs(trailingOnly=TRUE)
in_filename <- ifelse(length(args) > 1, args[2], "../data/language_ratings.csv")
out_filename <- ifelse(length(args) > 2, args[3], "../data/language_ratings.png")

ratings_table <- read.csv(file=file.path(in_filename))
ratings <- ratings_table[,3]
names(ratings) <- ratings_table[,2]

sprintf("Gini coefficient :%f", gini(ratings))
png(filename=out_filename, width=600, height=400)
ratings_chart <- pareto.chart(ratings)
dev.off()
