---
title: Matplotlib入门
date: 2018-08-13
tags: [python,数据分析]
---

内容: Matplotlib入门知识整理

精华: 来源是莫烦的教程,学习后整理而成,去掉了我认为复杂以及不常用的

<!-- more -->

# 概述

matplotlib是一个python的绘图库

```
pip install matplotlib
```

# 使用

## 引入

```
import matplotlib.pyplot as plt
```

pyplot将matplotlib中众多类/函数/细节封装在一起, 提供为简单的函数给用户来使用

普通人使用pyplot即可满足需求

只有大型项目, 需要复杂定制化之类的, 才会绕过pyplot直接使用matplotlib的众多类/函数/细节

## 基本使用

```python
import matplotlib.pyplot as plt

x = [1, 2, 3, 4, 5]
y = [2, 4, 10, 8, 10]

# 创建一个图表对象
plt.figure()
# 在当前图表对象中绘图
# plot(绘图): 默认直接折线图
plt.plot(x, y)
# 显示图表
plt.show()
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/48844489.jpg)

## 基本元素控制

### 图表和线条简单控制

```python
x = [1, 2, 3, 4, 5]
y1 = [2, 4, 10, 8, 10]
y2 = [1, 2, 3, 4, 5]

# 可以有很多图表, num是他们的标号
# figsize是图表大小, 单位英寸, 1英寸=72像素
plt.figure(num=3, figsize=(8, 5))
# label是线条描述, 就是平常看线图, 右上角会显示每条线是什么含义
# 这里只是描述, 不负责显示在右上角
plt.plot(x, y1, label='line111')
# 定制线条属性
# linestyle: -实线, --虚线
plt.plot(x, y2, label='line222', color='red', linewidth=4.0, linestyle='--')
plt.show()
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/50350433.jpg)

### 坐标轴控制

#### 限制范围

```python
x = [1, 2, 3, 4, 5]
y = [2, 4, 10, 8, 10]

plt.figure(num=3, figsize=(8, 5))
plt.plot(x, y, label='line111')

plt.xlim((1.5, 3.5))
plt.ylim((3, 8))
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/66501660.jpg)

#### 控制轴值

```python
import matplotlib.pyplot as plt
import numpy as np

x = [1, 2, 3, 4, 5]
y = [2, 4, 10, 8, 10]

plt.figure(num=3, figsize=(8, 5))
plt.plot(x, y, label='line111')

# np.linspace是numpy的函数, 用于生成等差数列, 1-5, 10个点, 返回一个列表
# 传入plt.xticks()的值会作为轴的值来显示
plt.xticks(np.linspace(1, 5, 10))
# 还可以起别名
plt.yticks([2, 4, 6, 9], ['low', 'mid', 'high', 'very high'])
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/3656813.jpg)

#### 进阶控制

直接获取坐标轴对象来进行更加详细的控制

```python
x = [-2, -1, 3, 4, 5]
y = [-6, 5, -10, 8, 10]

plt.figure(num=3, figsize=(8, 5))
plt.plot(x, y, label='line111')

# get current axes: 获取坐标轴对象
ax = plt.gca()
# 设置右轴颜色为空, 就是不显示右轴了
ax.spines['right'].set_color('none')
# 设置上轴颜色为红
ax.spines['top'].set_color('red')
# 设置下轴位置为数据0点
# 'data'是常量, 就要这么写
ax.spines['bottom'].set_position(('data', 0))
# 设置左轴位置为数据0点
ax.spines['left'].set_position(('data', 0))
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/89975809.jpg)

### 显示图例

图例就是图表右上角, 说明每条线是啥意思的

```python
x = [1, 2, 3, 4, 5]
y1 = [2, 4, 10, 8, 10]
y2 = [1, 2, 3, 4, 5]

plt.figure(num=3, figsize=(8, 5))
plt.plot(x, y1, label='line111')
plt.plot(x, y2, label='line222', color='red', linewidth=4.0, linestyle='--')
# 表示右上角
# 可以upper/lower/center/left/right自行组合, 还有best表示自动
plt.legend(loc='upper right')
plt.show()
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/35363032.jpg)

## 各类图表

### 散点图/scatter

```python
n = 1024
# np.random.normal(): 按照正态分布, 从0-1获取n个值
X = np.random.normal(0,1,n)
Y = np.random.normal(0,1,n)

# s为点的大小, alpha为透明度
plt.scatter(X, Y, s=35, alpha=.5)
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/33022208.jpg)

还能更详细控制, 详见莫烦教程

### 柱状图

```python
n = 12
# np.arange: 返回0-11的列表
X = np.arange(n)
# 均匀分布, 0.5-1.0, 取12个值
Y1 = np.random.uniform(0.5, 1.0, n)
Y2 = np.random.uniform(0.5, 1.0, n)

# 生成一个柱状图
plt.bar(X, +Y1)
# 再生成一个
plt.bar(X, -Y2)

# 添加标注
for x, y in zip(X, Y1):
    # 标注位置是(x, y+0.05)
    # ha/va为对齐方式: 标注占据了一个小矩形, 这里设置文字在矩形内的位置, 默认应该是右下
    # 标注内容是: "%.2f" % y
    plt.text(x, y + 0.05, "%.2f" % y, ha='center', va='bottom')
for x, y in zip(X, Y2):
    plt.text(x, -y - 0.05, "%.2f" % y, ha='center', va='top')
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/31713102.jpg)

### 3D图

```python
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure()
ax = Axes3D(fig)

X = np.arange(-4, 4, 0.25)
Y = np.arange(-4, 4, 0.25)
# np.meshgrid详见我numpy的博文
X, Y = np.meshgrid(X, Y)
Z = np.sin(np.sqrt(X ** 2 + Y ** 2))

# cmap是颜色映射
ax.plot_surface(X, Y, Z, cmap=plt.get_cmap('rainbow'))
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/70424850.jpg)

3D图较为复杂, 我也是浅尝而止, 详见莫烦的博文

## 子图表

意思就是在一张图上显示好几个表

### 均匀分布

```python
plt.figure()

# 生成一个子图表
# 将整张图表分为2行2列, 现在编辑第1个子图
plt.subplot(2,2,1)
# 第1个子图绘制内容
plt.plot([0,1], [0,1])

# 将整张图表分为2行2列, 现在编辑第2个子图
# 每次都要说明如何划分, 具体原因看到非均匀分布就懂了
plt.subplot(2,2,2)
plt.plot([0,1],[0,2])

# 可以简写为223
plt.subplot(223)
plt.plot([0,1],[0,3])

plt.subplot(224)
plt.plot([0,1],[0,4])
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/76880937.jpg)

### 非均匀分布

```python
plt.figure()

# 2行1列, 编辑第1个子图
plt.subplot(2,1,1)
plt.plot([0,1],[0,1])

# 2行3列, 编辑第4个子图
# 注意上面第1个子图在现在这种划分下占据了3格, 所以现在要编辑4
plt.subplot(2,3,4)
plt.plot([0,1],[0,2])

plt.subplot(235)
plt.plot([0,1],[0,3])

plt.subplot(236)
plt.plot([0,1],[0,4])
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-8-13/43500488.jpg)

# 参考资料

[我就是学莫烦python的博文, 学后将常用功能精简整理的, 原博文见这里](https://morvanzhou.github.io/tutorials/data-manipulation/plt/)

[matplotlib绘图基础](https://blog.csdn.net/pipisorry/article/details/37742423)

[matplotlib（一）-就是这么一个画图的](https://www.jianshu.com/p/142aeef5f183)