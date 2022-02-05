## 麻布中学校 2022年 入試問題 算数5
## https://inter-edu.s3.amazonaws.com/edunavi/wp-content/uploads/2022/02/azabu-mat-2022-01.pdf

library(tidyverse)
library(assertthat)

## 面積6の正六角形作るための、
## 辺=1の正三角形に対する拡大率を求める
height_for_base <- sqrt(3) / 2.0
triangle_scale <- sqrt(1.0 / (1.0 * height_for_base / 2.0))

## 正三角形の辺をY軸上に乗せる
height <- triangle_scale
width <- height * height_for_base
half_height <- height / 2.0

## 六角形の各点を求める
df_hexagon <- tibble::tibble(
  x = c(0, -width, -width, 0, width, width),
  y = c(height, half_height, -half_height, -height, -half_height, half_height),
  name = c("A", "B", "C", "D", "E", "F")
)

x_to_set <- c(tail(df_hexagon$x, -1), head(df_hexagon$x, 1))
y_to_set <- c(tail(df_hexagon$y, -1), head(df_hexagon$y, 1))
df_hexagon$x_to <- x_to_set
df_hexagon$y_to <- y_to_set

## 2:1分点を求める
point_g <- (c(df_hexagon$x[1], df_hexagon$y[1]) * 2 + c(df_hexagon$x[6], df_hexagon$y[6]) * 1) / 3
point_h <- (c(df_hexagon$x[3], df_hexagon$y[3]) * 2 + c(df_hexagon$x[2], df_hexagon$y[2]) * 1) / 3
point_i <- (c(df_hexagon$x[5], df_hexagon$y[5]) * 2 + c(df_hexagon$x[4], df_hexagon$y[4]) * 1) / 3

df_dividing <- tibble::tibble(
  x = c(point_g[1], point_h[1], point_i[1]),
  y = c(point_g[2], point_h[2], point_i[2]),
  x_to = c(df_hexagon$x[3], df_hexagon$x[5], df_hexagon$x[1]),
  y_to = c(df_hexagon$y[3], df_hexagon$y[5], df_hexagon$y[1]),
  name = c("G", "H", "I")
)

point_left <- c(-width * 2.0, 0)
point_bottom <- c(width, -height * 1.5)

## A-Cと補助線
df_external <- tibble::tibble(
  x = c(df_hexagon$x[3], point_left[1], point_left[1], point_bottom[1], point_bottom[1]),
  y = c(df_hexagon$y[3], point_left[2], point_left[2], point_bottom[2], point_bottom[2]),
  x_to = c(df_hexagon$x[1], df_hexagon$x[2], df_hexagon$x[3], df_hexagon$x[4], point_i[1]),
  y_to = c(df_hexagon$y[1], df_hexagon$y[2], df_hexagon$y[3], df_hexagon$y[4], point_i[2]),
  name = c(NA, "P", NA, "Q", NA)
)

## 交わる線分の交点を求める。以下を参考にした。
## https://hcpc-hokudai.github.io/archive/geometry_004.pdf
get_crossing_point <- function(df, index_from) {
  index_to <- (index_from %% NROW(df)) + 1
  a_from <- c(df$x[index_from], df$y[index_from])
  a_to <- c(df$x_to[index_from], df$y_to[index_from])
  b_from <- c(df$x[index_to], df$y[index_to])
  b_to <- c(df$x_to[index_to], df$y_to[index_to])

  cross <- function(v1, v2) {
    v1[1] * v2[2] - v1[2] * v2[1]
  }

  a_from +
    cross(a_from - b_from, b_to - b_from) / cross(b_to - b_from, a_to - a_from) *
      (a_to - a_from)
}

## 六角形内の交点を求める
df_internal <- tibble::tibble(
  x = c(df_hexagon$x[1], df_hexagon$x[3], df_hexagon$x[5]),
  y = c(df_hexagon$y[1], df_hexagon$y[3], df_hexagon$y[5]),
  x_to = c(point_i[1], point_g[1], point_h[1]),
  y_to = c(point_i[2], point_g[2], point_h[2])
)

point_j <- get_crossing_point(df_internal, 1)
point_k <- get_crossing_point(df_internal, 2)
point_l <- get_crossing_point(df_internal, 3)

df_crossings <- tibble::tibble(
  x = c(point_j[1], point_k[1], point_l[1]),
  y = c(point_j[2], point_k[2], point_l[2]),
  x_to = c(point_j[1], point_k[1], point_l[1]),
  y_to = c(point_j[2], point_k[2], point_l[2]),
  name = c("J", "K", "L")
)

## 点 J, K, L は、C-G, E-H, A-I を 6:1に分ける点であることを確認する
point_j_calcuated <- (c(df_hexagon$x[3], df_hexagon$y[3]) * 1 + c(point_g[1], point_g[2]) * 6) / 7
point_k_calcuated <- (c(df_hexagon$x[5], df_hexagon$y[5]) * 1 + c(point_h[1], point_h[2]) * 6) / 7
point_l_calcuated <- (c(df_hexagon$x[1], df_hexagon$y[1]) * 1 + c(point_i[1], point_i[2]) * 6) / 7
assertthat::assert_that(assertthat::are_equal(point_j, point_j_calcuated, tol = 1e-7))
assertthat::assert_that(assertthat::are_equal(point_k, point_k_calcuated, tol = 1e-7))
assertthat::assert_that(assertthat::are_equal(point_l, point_l_calcuated, tol = 1e-7))

df_all_points <- dplyr::bind_rows(df_hexagon, df_dividing) %>%
  dplyr::bind_rows(df_external) %>%
  dplyr::bind_rows(df_crossings) %>%
  na.omit()

g <- ggplot()
g <- g + geom_segment(aes(x = x, y = y, xend = x_to, yend = y_to), color = "orange", size = 1.5, linetype = 1, data = df_hexagon)
g <- g + geom_segment(aes(x = x, y = y, xend = x_to, yend = y_to), color = "royalblue", size = 1.0, linetype = 1, data = df_dividing)
g <- g + geom_segment(aes(x = x, y = y, xend = x_to, yend = y_to), color = "royalblue", size = 1.0, linetype = 2, data = df_external)
g <- g + geom_text(aes(x = x, y = y, label = name), cex = 5, data = df_all_points)
g <- g + theme_light()
g <- g + theme(
  aspect.ratio = 1,
  panel.border = element_blank(), axis.ticks = element_blank(),
  panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
  axis.text = element_blank(), axis.title = element_blank()
)
plot(g)
ggsave("math2022_5.png", width = 640, height = 640, units = "px")

## 答5-1
## 正六角形を構成する正三角形の、幅が1/3で高さが2倍の三角形と面積が等しい(2/3 cm^2)
## 答5-2
## 補助線より、AG:CQ = GJ:JC = 1:6 である。よって三角形ACG の 1/7 の面積は 2/21 cm^2
## 答5-3
## ABCJ = ABC + ACG - AJG = 1 + 2/3 - 2/21 = 11/7
## JKL = 正六角形全体 - ABCJ * 3 = 6 - 33/7 = 9/7 cm^2
