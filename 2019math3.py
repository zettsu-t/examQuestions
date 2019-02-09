#!/usr/bin/python3
# coding: utf-8

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as pat
from matplotlib import animation
from mpl_toolkits.mplot3d import Axes3D
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import mpl_toolkits.mplot3d.art3d as art3d

def main():
    cube_edges = [[[0.0, 1.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 1.0, 0.0], [0.0, 0.0, 0.0, 0.0, 0.0]],
                  [[0.0, 1.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 1.0, 0.0], [0.5, 0.5, 0.5, 0.5, 0.5]],
                  [[0.0, 1.0, 1.0, 0.0, 0.0], [0.0, 0.0, 1.0, 1.0, 0.0], [1.0, 1.0, 1.0, 1.0, 1.0]],
                  [[0.0, 0.0], [0.0, 0.0], [0.0, 1.0]],
                  [[1.0, 1.0], [0.0, 0.0], [0.0, 1.0]],
                  [[1.0, 1.0], [1.0, 1.0], [0.0, 1.0]],
                  [[0.0, 0.0], [1.0, 1.0], [0.0, 1.0]]]

    ratio_front = 4.0
    ratio_back = 3.0
    cube_out_z = -ratio_front / ratio_back
    cube_out_x = -0.5 / (0.5 - cube_out_z)

    cube_point1  = [1.0, 1.0, 1.0]
    cube_point2  = [1.0, ratio_front/(ratio_front + ratio_back), 0.0]
    cube_point3  = [0.0, 0.0, 0.5]

    cut_point1 = [1.0, 1.0 - ratio_back / (2.0 * (ratio_front + ratio_back)), 0.5]
    cut_point2 = [1.0 + (cube_out_z / (0.5 - cube_out_z)), 0.0, 0.0]
    cut_point3 = [0.0, -cube_out_x / (1.0 - cube_out_x), 1.0]

    cut_upper_edges = [cube_point1, cut_point1, cube_point3, cut_point3, cube_point1]
    cut_lower_edges = [cut_point1, cube_point2, cut_point2, cube_point3, cut_point1]

    view_upper_poly = [[0.0, 0.0], cut_point1[0:2], [1.0, 1.0], cut_point3[0:2]]
    view_lower_poly = [[0.0, 0.0], cut_point1[0:2], cube_point2[0:2], cut_point2[0:2]]
    view_edges = [[[0.0, 1.0], [0.0, 1.0]], [[cut_point1[0], cut_point2[0]], [cut_point1[1], cut_point2[1]]]]

    cube_out_edges = [[[1.0, 1.0], [0.0, 0.0], [0.0, cube_out_z]],
                      [[0.0, cube_out_x], [0.0, 0.0], [1.0, 1.0]]]

    cut_lines = [[[1.0, 1.0], [1.0, 0.0], [1.0, cube_out_z]],
                 [[1.0, cube_out_x], [0.0, 0.0], [cube_out_z, 1.0]],
                 [[cube_out_x, 1.0], [0.0, 1.0], [1.0, 1.0]]]

    frame_per_line = 20
    n_lines = 3
    interval_msec = 66
    n_frames = frame_per_line * n_lines + 2000 // interval_msec

    def plot(frame):
        plt.cla()

        for (xs, ys, zs) in cube_edges:
            ax.plot(xs, ys, zs, 'o-', color='black')

        ax.plot([cube_point2[0]], [cube_point2[1]], [cube_point2[2]], 'o-', color='black')

        for (xs, ys, zs) in cube_out_edges:
            ax.plot(xs, ys, zs, 'o-', color='black')

        current_line = frame // frame_per_line
        for line_index in range(0, min(n_lines, current_line)):
            points = cut_lines[line_index]
            ax.plot(points[0], points[1], points[2], 'o--', color='blue')

        if current_line < n_lines:
            sub_frame = 1 + frame % frame_per_line
            line = [[l, l + (r - l) * sub_frame / frame_per_line] for (l, r) in cut_lines[current_line]]
            ax.plot(line[0], line[1], line[2], 'o--', color='blue')

        if current_line >= n_lines:
            ax.add_collection3d(Poly3DCollection([list(cut_upper_edges)], color='orange'))
            ax.add_collection3d(Poly3DCollection([list(cut_lower_edges)], color='royalblue'))

        ax.set_xlim(-1.5, 1.1)
        ax.set_ylim(-1.5, 1.1)
        ax.set_zlim(-1.5, 1.1)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_zlabel('z')

    fig_2d = plt.figure()
    ax = fig_2d.add_subplot(111)
    ax.add_patch(pat.Polygon(xy=view_upper_poly, fc='orange', ec='black'))
    ax.add_patch(pat.Polygon(xy=view_lower_poly, fc='royalblue', ec='black'))
    plt.text(0.0, 3/14 + 0.05, '3/14={0:.3f}'.format(3/14))
    plt.text(3/11 + 0.05, 0.0, '3/11={0:.3f}'.format(3/11))
    plt.text(1.0 + 0.05, 11/14, '11/14')
    plt.text(1.0 + 0.05, 4/7, '4/7')
    for (xs, ys) in view_edges:
        ax.plot(xs, ys, '-', color='black')
    plt.savefig('2019math3_2d.png')

    fig_still = plt.figure()
    ax = fig_still.add_subplot(111, projection='3d')
    plot(n_frames - 1)
    plt.savefig('2019math3_3d.png')

    fig_animation = plt.figure()
    ax = fig_animation.add_subplot(111, projection='3d')
    ax.set_aspect('equal')

    anim = animation.FuncAnimation(
        fig_animation, plot, interval=interval_msec,
        frames=range(0, n_frames),
        repeat=True,
    )
    anim.save('2019math3_3d.gif', writer='pillow')

if __name__ == '__main__':
    main()
