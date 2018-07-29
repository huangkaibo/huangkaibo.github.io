---
title: python exception
date: 2018-07-29
tags: [python]
---

内容: python异常/try/except/traceback

精华: traceback的原理讲述(抄的)

<!-- more -->

# 概述

python异常类体系如下

![](http://p1rbtn7qp.bkt.clouddn.com/18-7-29/50874123.jpg)

常规错误的基类是Exception

# try/except/else/finally

```python
try:
    # 发生异常时不再执行后续语句
    # 开始从上往下匹配第一个符合的except
    pass
except:
    # 捕捉所有异常
    pass
except IOError:
    # 捕捉IOError异常
    pass
except IOError, TabError:
    # 捕捉多个异常
    pass
except FloatingPointError, number:
    # 捕捉FloatingPointError异常, 这个异常还能给你传递一个值number
    pass
except IOError as e:
    # 将异常赋予变量e
    # 2.5之前语法是 except IOError, e
    pass
else:
    # try执行完, 未发生异常, 执行else语句
    pass
finally:
    # 无论是否发生异常, 最后都执行finally语句
    # 如果有else, else必须在finally之前
    pass
```

如果try下面的except都无法捕捉该异常, 该异常会被抛向外层的try/except捕捉

# raise

可以手动抛出异常

```python
# 基本用法
raise ImportError

# 传递值
raise ImportError("haha", "oooo")

# 在except中还想再次触发该except
except ZeroDivisionError:
    if not input("输入除数"):
        print('ok')
    else:
        # 除数为零, 再次触发该异常
        raise
```

# 自定义异常

网上资料不多, 这里只是简单记录下

```python
# 首先继承一个异常类, 也可以是IOError这种更具体的异常类
class MyException(Exception):
    # 重写__init__函数
    def __init__(self, args):
        self.args = args
    # 其他函数自便    
    def __str__():
        return self.args

# 使用
raise MyException("hahaha")
```

# 输出异常信息

## 不加处理

```python
l = [0, 1, 2]
print(l[3])
```

如果不加处理, print越界会显示traceback信息

![](http://p1rbtn7qp.bkt.clouddn.com/18-7-29/88983415.jpg)

## 加try/expect

```python
try:
    l = [0, 1, 2]
    print(l[3])
except:
    pass
```

加了try/expect, print越界不显示报错, 什么都不会显示

要在except中输出异常信息有以下几种方式

### print(e)

显示异常的值

```python
try:
    raise ImportError("sadfds", "123123")
exception Exception as e:
    print(e)
# 结果: ('sadfds', '123123')
```

### print(repr(e))

显示异常加异常的值

```python
try:
    raise ImportError("sadfds", "123123")
exception Exception as e:
    print(repr(e))
# 结果: ImportError('sadfds', '123123')
```

### traceback.print_exc()

异常里不包含所在行数, 要想输出需要用traceback这个包

```python
import traceback

exception Exception as e:
    traceback.print_exc()
```

结果如下

```text
Traceback (most recent call last):
  File "test.py", line 6, in <module>
    print(l[3])
IndexError: list index out of range
```

本身就会输出, 无返回值

### print(traceback.format_exc())

```python
import traceback

exception Exception as e:
    print(traceback.format_exc())
```

结果如下

```text
Traceback (most recent call last):
  File "test.py", line 6, in <module>
    print(l[3])
IndexError: list index out of range
```

本身不输出, 将异常信息返回, 可以存入变量

# traceback模块

traceback模块用于处理异常栈

在java中, 异常和异常栈是存在一起的, 但是python中分离了, 异常只包含异常名和值, 不包含异常栈

* `traceback.print_exc()`: 用于打印异常信息, exc表示exception
* `traceback.format_exc()`: 用于返回异常信息

## 原理

### traceback的信息来源

traceback中的信息来自`sys.exc_info()`

```python
import sys

try:
    raise ImportError("sadfds", "123123")
except Exception as e:
    # sys.exc_info()能获取异常类型, 异常值, 异常栈(exc_tb是一个traceback对象)
    exc_type, exc_value, exc_tb = sys.exc_info()
    print(exc_type)
    print("***********")
    print(exc_value)
    print("***********")
    print(exc_tb)
    print("***********")
    # traceback.print_exc()利用这三个值进行处理
    traceback.print_exc(exc_type, exc_value, exc_tb)
```

结果是

```text
<class 'ImportError'>
***********
('sadfds', '123123')
***********
<traceback object at 0x7fe9429e15c8>
***********
Traceback (most recent call last):
  File "test.py", line 5, in <module>
    raise ImportError("sadfds", "123123")
ImportError: ('sadfds', '123123')

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "test.py", line 15, in <module>
    traceback.print_exc(exc_type, exc_value, exc_tb)
  File "/usr/lib64/python3.4/traceback.py", line 252, in print_exc
    print_exception(*sys.exc_info(), limit=limit, file=file, chain=chain)
  File "/usr/lib64/python3.4/traceback.py", line 170, in print_exception
    print(line, file=file, end="")
AttributeError: 'ImportError' object has no attribute 'write'
```

### exc\_tb对象解析

上面的exc\_tb是个traceback对象, traceback提供了`traceback.extract_tb`来解析该对象

```python
for filename, linenum, funcname, source in traceback.extract_tb(exc_tb):
    # 错误位于的文件名
    print(filename)
    print("**********************************")
    # 错误位于的行号
    print(linenum)
    print("**********************************")
    # 错误位于的函数名
    print(funcname)
    print("**********************************")
    # 错误发生在哪句话
    print(source)
    print("**********************************")
```

结果是

```text
test.py
**********************************
5
**********************************
<module>
**********************************
raise ImportError("sadfds", "123123")
**********************************
```

module意思应该是, 无外层函数, 位于主函数内

# 参考资料

[Python 异常之后不知多少行的解决办法](https://blog.csdn.net/vevenlcf/article/details/51837193)

[异常类体系](https://www.jianshu.com/p/24e6fb03d6d6)

[把traceback讲的很详细, 还有个cglib我没看](https://blog.csdn.net/lengxingxing_/article/details/56317838)