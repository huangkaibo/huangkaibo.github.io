---
title: python eval()和ast.literal_eval()
date: 2018-07-29
tags: [python]
---

内容: python eval()使用

精华: 有说明用途

<!-- more -->

# 概述

把一个字符串当做python语句来执行

类似shell的\`\`, \`\`里面当做bash语句来执行

# 使用

```python
res = eval("{1: 'a', 2: 'b'}")
# res就会变成一个字典, 因为{1: 'a', 2: 'b'}直接输入python就是创建一个字典
```

# 作用

## 数据类型转化

可以很便捷的做到一些类型转换

比如从后台获取到返回值`"{'k1':'v1', 'k2':'v2'}"`这个json串

但是这个并不是json格式, 而是str格式

我们可以用`json.loads()`将其转化为dict

还可以简单的`eval()`一下, 就得到了一个dict类型

---

而且`json.loads()`对于原str的格式要求很严, 所以有时候会转化失败

而`eval()`就没那么讲究

比如下面这个str, 因为开头结尾多了一个括号, 所以`json.loads([1:-1])`才能转化, 而`eval()`直接就能转化

虽然`()`本来应该转化为一个元组, 但是只有一个元素, 所以直接转化为元素本身, 不信可以试试, 两个元素的话就转化为元组了

```
"({"data":[{"group":{"time":{"code":["400","400"],"reque":[5090,450]}},"totl":{"reque":5.0}}],"resu":0,"resu":"Success"}\n)"
```

## 数值计算

比如接受了用户输入的式子`"1+1"`, 是一个字符串, 就很难搞, 但是用`eval("1+1")`就很轻松的解决了

# eval()的安全问题

因为直接把字符串当做命令来执行, 所以会有类似sql注入的风险, 比如用户输入的字符串是`"open('C://tmp.txt', 'rw')"`那就被看光了

所以出来了`ast.literal_eval()`, 这个eval()利用了ast的抽象语法树技术, 判断用户的字符串是否合法, 不合法就不让运行, 保障安全

简单说, open这类危险操作不让做了, 连"1+1"这种计算也不让做了, 我暂时看到可以让做的只有类型转换

# 参考资料

[Python:eval的妙用和滥用](https://blog.csdn.net/zhanh1218/article/details/37562167)

[Python中函数eval和ast.literal_eval的区别详解](https://www.jb51.net/article/120815.htm)