---
title: python encode decode
date: 2018-04-07
tags: [python]
---

内容: python编解码

精华: 很用心的区分了文本类型和二进制类型

<!-- more -->

# 常见编码

* `\x`: 后面的数字是16进制
* `\d`: 后面的数字是10进制
* `\o`: 后面的数字是8进制

其实以上不算编码, 只是把0101010转为不同进制

## unicode编码集

`\u`: 后面的数字是`unicode`编码, unicode编码一般是4位16进制数

## 中文编码总结

* `GB2312`: 简化版的, 只支持6000个常用汉字
* `GBK`: `GB2312`+繁体字+各种字符
* `GB18030`: `GBK`+各少数民族文字

## 编码集检测

```
pip install chardet
import chardet
# 内容多时检测准确率高
print(chardet.detect())
```

# 文本文件和二进制文件

从硬件层面看两者无任何区别, 硬件上都是二进制01存储

01010100101取出来后

文本文件按照**定长**截取, 转化为相应字符

二进制文件不作处理, 直接print就表现为缩写的\\x, \\d, \\o之类的不同进制的数字, 不转化为对应字符

文本文件里面全是数据, 是存储数据的地方, 取出来定长解析回去就是源数据

但是二进制文件里面不全是数据, 比如说

```
print("hello world")
```

这里`"hello world"`是数据, 但是print不是, 我不能说存的时候就存p的ASCII码, r的ASCII码.....到)的ASCII码, 这样存下来

因为print是逻辑部分, 控制部分, 所以不是按照数据一样存, 所以取出来也就不是定长截取直接对照字符集转化为对应的字符p/r/i/n/t

而是负责的软件来对取出来的001010101进行解析

比如一个图片, 如果定长截取转为字符, 那就是乱码, 只能图片查看器按照jpg格式规定的解析方式解析0101010, 才成了图片

# python 文本/二进制类型

python3里的将数据分为了文本和二进制两种类型

* str: 文本类型, unicode编码
* bytes: 二进制类型, 非unicode编码

这里的文本和二进制不同于我上面讲的文本文件和二进制文件

这里的文本和二进制都是针对数据的

这么区分纯粹是为了区分unicode编码和其他编码

就是给unicode编码和其他编码起个名字, unicode编码叫文本类型str, 其他编码叫bytes二进制类型

# encode()/decode()

也就是所有字符串new的时候都是unicode编码, 是文本类型

如果要对字符串进行转码, 则转码后统称为二进制类型

* encode()编码是针对str类型, 将str类型转为bytes类型
* decode()解码是针对bytes类型, 将bytes类型转为str类型

所以只有编码后才能解码, 无法直接对无编码的str进行解码

## encode()

```
# 返回值是bytes类型
# str是unicode编码的, encode()将其转化为utf-8编码返回
# 空参数默认utf-8
str.encode(encoding='UTF-8',errors='strict')
```

## decode()

```
# 返回值是str
# bytes是utf-8编码的, decode()将其转化为unicode编码返回
# 空参数默认utf-8
bytes.decode(encoding='UTF-8',errors='strict')
```

## 其他转码方式

```
# str to bytes
bytes(s, encoding = "utf8")

# bytes to str
str(b, encoding = "utf-8")
```

```
str = b'hello world'
# 在python2中还有u'hello world'强转unicode
# 但是python3中默认字符串就是unicode了, 所以不用这样了
# python2默认编码是ASCII
# 所以python3不用像python2一样如下指定编码
# -*- coding:utf-8 -*- 
# coding=utf-8
# encoding: utf-8
```

![](http://p1rbtn7qp.bkt.clouddn.com/18-4-6/25800553.jpg)

## 总结

![](http://p1rbtn7qp.bkt.clouddn.com/18-4-6/16305463.jpg)

![](http://p1rbtn7qp.bkt.clouddn.com/18-4-6/66455785.jpg)

上面可以看到, 本身str是unicode编码, 所以无法转换

# unicode-escape和string-escape

看不懂了, 晕了, 两篇文章见参考资料

# 参考资料

[有很多编码的详细描述](https://www.jianshu.com/p/659ccee58fbb)

[总结string-escape和unicode-escape](https://blog.csdn.net/ggggiqnypgjg/article/details/72783356)
