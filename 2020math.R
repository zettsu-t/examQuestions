## 出題元
## 麻布中学校 2020年 入試問題 算数 解法

library(assertthat)
library(dplyr)
library(forcats)
library(ggpubr)
library(gmp)
library(ggplot2)
library(purrr)
library(purrrlyr)
library(stringr)
library(tibble)
library(tidyr)

## Q3-1
## 6 * 3 (an odd/even) * 2 (an even/odd) * 2 (an odd/even) = 72
library(combinat)
ns <- 1:6
ys <- rep(0, NROW(ns) - 1)
zs <- na.omit(t(sapply(combinat::permn(ns), function(xs) {
    if (all(abs(diff(xs %% 2)) != ys)) {
        matrix(xs, nrow=1)
    } else {
        matrix(NA, nrow=1, ncol=NROW(ns))
    }
})))
NROW(zs)

## Q3-2
## 1 2 3 4 5 6
##   6 5 4 3 2
## And replace 1 to 2..6
library(combinat)
zs <- na.omit(t(sapply(combinat::permn(ns), function(xs) {
    if (all(abs(diff(xs %% 2)) != ys) && all(abs(diff(xs %% 3)) != ys)) {
        matrix(xs, nrow=1)
    } else {
        matrix(NA, nrow=1, ncol=NROW(ns))
    }
})))
NROW(zs)

## Q4
## 300 * 7 = 120 * a + 180 * b
## 500 * 7 = 320 * (a - 3) + 180 * b
## 500 * 7 + 320 * 3 = 320 * a + 180 * b
s <- solve(matrix(c(320, 120, 180, 180), 2, 2), matrix(c(500 * 7 + 320 * 3, 300 * 7)))
s <- s - matrix(c(3.0, 0), ncol = 1, nrow = 2)
s[1,1]
s[2,1]
(matrix(c(120, 180), ncol = 2, nrow = 1) %*% s / (120 + 180))[1,1]

(matrix(c(320, 180), ncol = 2, nrow = 1) %*% s / (320 + 180))[1,1]

## Q6
epsilon <- 1e-6

swap_loop_ends <- function(df, period, forward, x_step, two_rings) {
    purrrlyr::by_row(df, function(row) {
        cond <- FALSE
        yend <- 1.0

        if (forward > 0) {
            cond <- (row$y > row$yend)
            yend <- 1.0
        } else {
            cond <- (row$y < row$yend)
            yend <- if (two_rings) -1.0 else 0.0
        }

        if (cond) {
            row$yend <- yend
        }
        row
    })$.out %>% dplyr::bind_rows()
}

make_position_df <- function(period, forward, func_to_y, width, x_step, two_rings) {
    df <- lapply(seq(0, width, x_step), function(x) {
        y <- func_to_y(x, period, two_rings)
        tibble(x=x, y=y)
    }) %>% dplyr::bind_rows()

    df_left <- df[1:NROW(df)-1,]
    df_right <- df[2:NROW(df),] %>% dplyr::rename(xend=x, yend=y)
    df <- dplyr::bind_cols(df_left, df_right)
    df$period <- period
    swap_loop_ends(df=df, period=period, forward=forward, x_step=x_step, two_rings=two_rings)
}

make_curve_df <- function(xs, period, forward) {
    lapply(xs, function(x) {
        theta <- x / period
        theta <- (theta - ceiling(theta)) * 2 * pi
        if (!forward) {
            theta <- 2 * pi - theta
        }
        y_sin <- sin(theta)
        y_cos <- cos(theta)
        result <- tibble(x=x, y_sin=y_sin, y_cos=y_cos)
    }) %>% dplyr::bind_rows()
}

func_to_y_forward <- function(x, period, two_rings) {
    if (two_rings) {
        2.0 * ((x + period) %% (period * 2)) / (period * 2) - 1.0
    } else {
        (x %% period) / period
    }
}

func_to_y_reverse <- function(x, period, two_rings) {
    if (two_rings) {
        -1.0 * func_to_y_forward(x=x, period=period, two_rings=two_rings)
    } else {
        1.0 - func_to_y_forward(x=x, period=period, two_rings=two_rings)
    }
}

make_diagram <- function(periods, two_rings) {
    x_scale <- 2
    periods_reduced <- periods / gmp::gcd(periods[1], periods[2])
    period_slow_reduced <- periods_reduced[1]
    period_fast_reduced <- periods_reduced[2]
    title <- sprintf("Periods = %d and %d", period_slow_reduced, period_fast_reduced)
    suffix <- paste0("_", period_slow_reduced, "_", period_fast_reduced)

    scaled_periods <- rev(sort(periods_reduced)) * x_scale
    period_slow_scaled <- scaled_periods[1]
    period_fast_scaled <- scaled_periods[2]

    width_scaled <- gmp::lcm.default(period_slow_reduced, period_fast_reduced) * x_scale
    x_step <- 1
    df_forward_line <- make_position_df(period=period_slow_scaled, forward=TRUE,
                                        func_to_y=func_to_y_forward, width=width_scaled,
                                        x_step=x_step, two_rings=two_rings)

    df_reverse_line <- make_position_df(period=period_fast_scaled, forward=FALSE,
                                        func_to_y=func_to_y_reverse, width=width_scaled,
                                        x_step=x_step, two_rings=two_rings)

    df_line <- dplyr::bind_rows(df_forward_line, df_reverse_line)

    width_reduced <- gmp::lcm.default(period_slow_reduced, period_fast_reduced)
    n_step <- gmp::lcm.default(width_reduced, sum(period_slow_reduced, period_fast_reduced))
    xs <- width_reduced * seq(0, n_step) / n_step
    if (two_rings) {
        xs <- xs / 2
    }
    df_forward_curve <- make_curve_df(xs=xs, period=period_slow_reduced, forward=TRUE) %>%
        dplyr::rename(y_slow=y_sin, x_slow=y_cos)

    df_reverse_curve <- make_curve_df(xs=xs, period=period_fast_reduced, forward=FALSE) %>%
        dplyr::rename(y_fast=y_sin, x_fast=y_cos)

    df_curve <- dplyr::inner_join(df_forward_curve, df_reverse_curve, by='x')

    df_curve_wide <- purrrlyr::by_row(df_curve, function(row) {
        (abs(row$y_slow - row$y_fast) < epsilon) && (abs(row$x_slow - row$x_fast) < epsilon)
    }, .collate = c("rows"), .to = "meet")

    marked_index <- which(df_curve_wide$meet)
    count <- NROW(setdiff(marked_index, c(1, NROW(df_curve_wide))))

    df_curve_long <- tidyr::pivot_longer(df_curve, cols=-c('x'), names_to='position', values_to='y')
    df_curve_long$position <- factor(df_curve_long$position)
    df_curve_long$position <- forcats::fct_relevel(df_curve_long$position, setdiff(colnames(df_curve), 'x'))

    list(periods=periods_reduced, two_rings=two_rings, x_scale=x_scale, df_line=df_line,
         df_curve_wide=df_curve_wide, df_curve_long=df_curve_long,
         count=count, title=title, suffix=suffix)
}

draw_line_diagram <- function(result, png_width, png_height, font_size, out_dirname, png_basename) {
    periods <- result$periods
    two_rings <- result$two_rings
    x_scale <- result$x_scale

    write_to_png <- !is.na(png_basename) && (stringr::str_length(png_basename) > 0)
    if (write_to_png) {
        png_filename <- paste0(png_basename, 'line', result$suffix, '.png')
        png(filename=file.path(out_dirname, png_filename), width=png_width, height=png_height)
    }

    df_line <- result$df_line
    g <- ggplot(df_line)
    g <- g + geom_vline(xintercept=seq(0, max(df_line$x) + 1, x_scale), color='gray')
    g <- g + geom_segment(aes(x=x, y=y, xend=xend, yend=yend, color=period), size=2)
    g <- g + ggtitle(result$title)
    g <- g + xlim(0, max(df_line$x) + 1)
    g <- g + xlab('Epoch')
    g <- g + ylab('Position')
    g <- g + theme(legend.position='none',
                   plot.background=element_blank(),
                   panel.background=element_blank(),
                   axis.text=element_blank(),
                   axis.title=element_text(size=font_size),
                   strip.text=element_text(size=font_size),
                   plot.title=element_text(size=font_size))

    if (!is.na(png_basename)) {
        plot(g)
        if (write_to_png) {
            dev.off()
        }
        g <- NA
    }

    g
}

draw_curve_diagram <- function(result, png_width, png_height, font_size, out_dirname, png_basename) {
    periods <- result$periods
    two_rings <- result$two_rings
    x_scale <- result$x_scale

    write_to_png <- !is.na(png_basename) && (stringr::str_length(png_basename) > 0)
    if (write_to_png) {
        png_filename <- paste0(png_basename, 'curve', result$suffix, '.png')
        png(filename=file.path(out_dirname, png_filename), width=png_width, height=png_height)
    }

    marked_index <- which(result$df_curve_wide$meet)
    xs_marked <- result$df_curve_wide$x[marked_index]

    df <- result$df_curve_long
    g <- ggplot(df)
    g <- g + geom_line(aes(x=x, y=y, color=position, size=position, linetype=position), size=1.5)
    g <- g + geom_vline(xintercept=xs_marked, color='black')
    g <- g + geom_hline(yintercept=0, color='black')
    g <- g + scale_linetype_manual(values=c('solid', 'solid', 'solid', 'solid'))
    g <- g + scale_size_manual(values=c(2, 2, 1, 1))
    g <- g + scale_color_manual(values=c('dodgerblue4', 'goldenrod3', 'dodgerblue2', 'goldenrod1'))
    g <- g + ggtitle(result$title)
    g <- g + xlim(0, max(df$x) + 1)
    g <- g + xlab('Epoch')
    g <- g + ylab('Position')
    g <- g + theme(legend.position='top',
                   legend.key.width = unit(3, "lines"),
                   plot.background=element_blank(),
                   panel.background=element_blank(),
                   axis.text=element_blank(),
                   axis.title=element_text(size=font_size),
                   strip.text=element_text(size=font_size),
                   plot.title=element_text(size=font_size))

    if (!is.na(png_basename)) {
        plot(g)
        if (write_to_png) {
            dev.off()
        }
        g <- NA
    }

    g
}

draw_all <- function(periods, two_rings, expected_count, png_width, png_height, font_size, out_dirname, png_basename, by_row) {
    result <- make_diagram(periods=periods, two_rings=two_rings)
    actual_count <- result$count
    g <- NA

    if (is.na(expected_count) || (expected_count == actual_count)) {
        if (!is.na(png_basename)) {
            draw_line_diagram(result=result, png_width=png_width, png_height=png_height, font_size=font_size,
                              out_dirname=out_dirname, png_basename=png_basename)
            draw_curve_diagram(result=result, png_width=png_width, png_height=png_height, font_size=font_size,
                               out_dirname=out_dirname, png_basename=png_basename)
        }
        g_line <- draw_line_diagram(result=result, png_width=png_width, png_height=png_height, font_size=font_size,
                                    out_dirname=NA, png_basename=NA)
        g_curve <- draw_curve_diagram(result=result, png_width=png_width, png_height=png_height, font_size=font_size,
                                      out_dirname=NA, png_basename=NA)

        if (is.na(png_basename)) {
            g <- ggarrange(g_line, g_curve, ncol=2, nrow=1)
        } else {
            png_filename <- paste0(png_basename, 'all', result$suffix, '.png')
            png(filename=file.path(out_dirname, png_filename), width=png_width, height=png_height * 2)
            g <- ggarrange(g_line, g_curve, ncol=1, nrow=2)
            plot(g)
            dev.off()
            g <- NA
        }
    }

    list(count=actual_count, g=list(g))
}

## Q6-1
png_width <- 800
png_height <- 320
font_size  <- 16
out_dirname <- 'images2020'
dir.create(out_dirname)
draw_all(periods=c(3,5), two_rings=FALSE, expected_count=NA,
         png_width=png_width, png_height=png_height,
         font_size=font_size, out_dirname=out_dirname, png_basename='q6_1_')

## Q6-2
find_combination <- function(n) {
    lapply(1:(n %/% 2), function(x_slow) {
        x_fast <- n - x_slow
        if (gmp::gcd(x_slow, x_fast) == 1) {
            tibble(x_slow=x_slow, x_fast=x_fast)
        } else {
            NULL
        }
    }) %>% dplyr::bind_rows()
}

find_combination(14 + 1)

max_slow <- 15
max_fast <- (max_slow + 1) %/% 2
expected_count <- 14
result_df <- lapply(1:max_fast, function(x_fast) {
    lapply((x_fast+1):max_slow, function(x_slow) {
        actual <- draw_all(periods=c(x_fast, x_slow), two_rings=FALSE, expected_count=expected_count,
                           png_width=png_width, png_height=png_height, font_size=font_size,
                           out_dirname=out_dirname, png_basename='q6_2_')
        if (expected_count == actual$count) {
            tibble(x_fast=x_fast, x_slow=x_slow, g=actual$g)
        } else {
            NULL
        }
    }) %>% dplyr::bind_rows()
}) %>% dplyr::bind_rows()

## Q6-3
draw_all(periods=c(3,8), two_rings=TRUE, expected_count=NA,
         png_width=png_width, png_height=png_height,
         font_size=font_size, out_dirname=out_dirname, png_basename='q6_3_')

## Q6-4
bind_rows(find_combination(13), find_combination(14)) %>%
    dplyr::arrange(x_slow)

max_slow <- 15
max_fast <- (max_slow + 1) %/% 2
expected_count <- 6

lapply(1:max_fast, function(x_fast) {
    lapply((x_fast+1):max_slow, function(x_slow) {
        actual <- draw_all(periods=c(x_fast, x_slow), two_rings=TRUE, expected_count=expected_count,
                           png_width=png_width, png_height=png_height, font_size=font_size,
                           out_dirname=out_dirname, png_basename='q6_4_')
        if (expected_count == actual$count) {
            tibble(x_fast=x_fast, x_slow=x_slow)
        } else {
            NULL
        }
    }) %>% dplyr::bind_rows()
}) %>% dplyr::bind_rows()
