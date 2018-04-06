---
title: python iterator
date: 2018-04-07
tags: [python]
---

内容: python迭代器

精华: 区分了iterable和iterator, 讲解原理, 自制iterator

<!-- more -->

# 概述

相关词汇: generator/yield/iterator/iterable

iterator的意义:

可以按需生成并“返回”结果，而不是一次性产生所有的返回值，况且有时候根本就不知道“所有的返回值”

generator包括

* \_\_iter\_\_()和next()生成的iterator
* yield生成的iterator

# yield

[该小节引用自 廖雪峰-Python yield 使用浅析](https://www.ibm.com/developerworks/cn/opensource/os-cn-python-yield/#icomments)

推荐看上面的网站而不是看我的yield小节, 我只是便于个人回顾才摘抄一点点, 不是面向新手的教学

输出斐波那契数列

```
# 问题在于一次生成所有斐波那契数列
# L很占空间
def fab(max): 
    n, a, b = 0, 0, 1 
    L = [] 
    while n < max: 
        L.append(b) 
        a, b = b, a + b 
        n = n + 1 
    return L
    
for n in fab(5):
    print n
```

```
# 实现了__iter__()和next()方法, 该类就可以生成一个iterator
# for in返回的不是一串list, 而是一个iterator, 每次访问就生成下一个值
# 但是问题是这样做好复杂, 不简洁
class Fab(object): 
    def __init__(self, max): 
        self.max = max 
        self.n, self.a, self.b = 0, 0, 1 
    
    def __iter__(self): 
        return self
    
    def next(self): 
        if self.n < self.max: 
            r = self.b 
            self.a, self.b = self.b, self.a + self.b 
            self.n = self.n + 1
            return r
        raise StopIteration()

for n in Fab(5):
    print n
```

```
# yield 的作用就是把一个函数变成一个 generator
def fab(max): 
    n, a, b = 0, 0, 1 
    while n < max: 
        yield b
        a, b = b, a + b 
        n = n + 1 
```

# iterator/iterable

iterable
:   只实现了\_\_iter\_\_的对象, 可以进行for循环, 大小确定

iterator
:   同时实现了\_\_iter\_\_和\_\_next\_\_方法的对象, 可以进行for循环和next(), 大小不确定

序列数据结构(字符串、列表、元组)及非序列数据结构(字典、文件)都是iterable而非iterator

for循环本质是调用next(), for开始时，会通过iter()利用iterable获得iterator，利用iterator的next()进行遍历, 当没有下一个时会返回StopIteration异常， 该异常for会自动处理， 遇到StopIteration异常就for就停止

迭代器能够多次进入， 多次返回， 每次会保留现场， 直到下一次next回复现场

# 判断iterable/iterator

```
# 判断是否iterable
isinstance(blabla, Iterable)
# 判断是否iterator
isinstance(blavla, Iterator)
```

# 构造iterator

## 常见数据结构转iterator

### .__iter__()

```
# 使用对象内置的__iter__()方法生成iterator
>>> list = [1,2,3,4,5,6]
>>> iter = list.__iter__()
>>> print iter
<listiterator object at 0x7fe4fd0ef550>
>>> iter.next()
1
>>> iter.next()
2
>>> iter.next()
3
```

### iter()

```
# 使用iter()生成iterator
>>> list = [1,2,3,4,5,6]
>>> iter = iter(list)
>>> print iter
<listiterator object at 0x7fe4fd0ef610>
>>> iter.next()
1
>>> iter.next()
2
>>> iter.next()
3
```

# 自定义iterator

```
class AccountIterator():
    def __init__(self, accounts):
        # 账户集合
        self.accounts = accounts
        self.index = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.index >= len(self.accounts):
            raise StopIteration("到头了...")
        else:
            self.index += 1
            return self.accounts[self.index-1]
```

实现\_\_iter\_\_和\_\_next\_\_方法即可

# range()和xrange()

range(100)返回一个list, 包含1-100的list, 占内存

xrange(100)返回一个iterator, 仅占一个数据空间

# 参考资料

[Python迭代器(Iterator)](https://www.cnblogs.com/spiritman/p/5158331.html)

[generator 廖雪峰](https://www.liaoxuefeng.com/wiki/001434446689867b27157e896e74d51a89c25cc8b43bdb3000/00143450083887673122b45a4414333ac366c3c935125e7000)

[yield小节引用自 廖雪峰-Python yield 使用浅析](https://www.ibm.com/developerworks/cn/opensource/os-cn-python-yield/#icomments)
