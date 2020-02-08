#!/usr/bin/python3
# coding: utf-8
#
# 出題元
# 麻布中学校 2020年 入試問題 算数 問2-2 解法

import math
import matplotlib.pyplot as plt
import matplotlib.patches as patches

def main():
    fig = plt.figure(figsize=(6.4, 6.4))
    ax = fig.add_subplot(111)
    x1 = math.sqrt(0.5)
    y1 = x1
    y2 = y1 / 2.0
    x2 = math.sqrt(1.0 - y2 * y2)
    x12 = x1 * y2 / y1

    c = patches.Circle(xy=(0, 0), radius=1.0, fc='white', ec='black')

    ps1 = patches.Polygon(xy=[(0, y2), (0, y1), (x1, y1), (x12, y2)], fill=True, hatch='|', linestyle='dotted', facecolor='lightblue')
    ps2 = patches.Polygon(xy=[(0, 0), (x12, y2), (x1, y2), (x1, 0)], fill=True, hatch='|', linestyle='dotted', facecolor='lightblue')
    ps3 = patches.Polygon(xy=[(0, 0), (0, y2), (x12, y2)], fill=True, hatch='-', linestyle='dotted', facecolor='orange')
    ps4 = patches.Polygon(xy=[(x12, y2), (x1, y2), (x1, y1)], fill=True, hatch='-', linestyle='dotted', facecolor='orange')

    v1 = patches.Polygon(xy=[(x1, 0), (x1, y2)], linestyle='dotted', edgecolor='orange', linewidth=3)
    v2 = patches.Polygon(xy=[(x1, y2), (x1, y1)], linestyle='dotted', edgecolor='blue', linewidth=3)
    v3 = patches.Polygon(xy=[(-x1, 0), (-x1, y2)], linestyle='dotted', edgecolor='orange', linewidth=3)
    v4 = patches.Polygon(xy=[(-x1, y2), (-x1, y1)], linestyle='dotted', edgecolor='blue', linewidth=3)

    h1 = patches.Polygon(xy=[(-x1, y1), (x1, y1)], edgecolor='blue')
    h2 = patches.Polygon(xy=[(-x2, y2), (x2, y2)], edgecolor='blue')
    h3 = patches.Polygon(xy=[(-x1, -y1), (x1, -y1)], edgecolor='blue')
    h4 = patches.Polygon(xy=[(-x2, -y2), (x2, -y2)], edgecolor='blue')

    e1l = patches.Polygon(xy=[(-x2, y2), (-x1, y1)], linestyle='dotted', edgecolor='blue', linewidth=3)
    e2l = patches.Polygon(xy=[(-1, 0), (-x2, y2)], linestyle='dotted', edgecolor='orange', linewidth=3)
    e1r = patches.Polygon(xy=[(x2, y2), (x1, y1)], linestyle='dotted', edgecolor='blue', linewidth=3)
    e2r = patches.Polygon(xy=[(1, 0), (x2, y2)], linestyle='dotted', edgecolor='orange', linewidth=3)

    b1 = patches.Polygon(xy=[(-1.0, 0), (1.0, 0)], linestyle='dotted', edgecolor='black', linewidth=2)
    b2 = patches.Polygon(xy=[(-x1, -y1), (x1, y1)], edgecolor='black', linewidth=2)

    for element in [c, ps1, ps2, ps3, ps4, v1, v2, v3, v4, h1, h2, h3, h4, e1l, e1r, e2l, e2r, b1, b2]:
        ax.add_patch(element)

    xtext = x1 - 0.1
    yofs = - 0.1
    ax.text(-xtext, (y1 + y2) * 0.5, "i", size = 24, color = "blue", ha='center')
    ax.text(-xtext, y2 * 0.5, "u", size = 24, color = "orange", ha='center')
    ax.text(-xtext, -y2 * 0.5, "e", size = 24, color = "blue", ha='center')
    ax.text(-xtext, -(y1 + y2) * 0.5, "o", size = 24, color = "orange", ha='center')
    ax.text(xtext, yofs + (y1 + y2) * 0.5, "o", size = 24, color = "black", ha='center')
    ax.text(xtext, yofs + y2 * 0.5, "e", size = 24, color = "blue", ha='center')
    ax.text(xtext, yofs + -y2 * 0.5, "u", size = 24, color = "orange", ha='center')
    ax.text(xtext, yofs + -(y1 + y2) * 0.5, "i", size = 24, color = "blue", ha='center')

    ax.set_aspect('equal')
    ax.set_xlim(-1, 1)
    ax.set_ylim(-1, 1)
    plt.savefig('images2020/2020math2.png')

if __name__ == '__main__':
    main()
