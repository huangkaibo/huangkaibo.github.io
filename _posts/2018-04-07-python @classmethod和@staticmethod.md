---
title: python @classmethod和@staticmethod
date: 2018-04-07
tags: [python]
---

内容: python @classclassmethod和@staticmethod

精华: 有说明用处是什么, 用在哪些地方

<!-- more -->

# 概述

都是将类函数指定为静态函数

# @classmethod

## 使用案例

```
class DemoClass:
    @classmethod
    def classPrint(cls):
        print("class method")
        
    def objPrint(self):
        print("obj method")

obj = DemoClass()

obj.objPrint()
obj.classPrint()

DemoClass.classPrint()
DemoClass.objPrint()
```

```
程序的执行结果如下：
obj method

class method

class method

Traceback (mostrecent call last):
```

## 使用解析

`@classmethod`修饰的函数的第一个参数不用是self(self是对象的指针)， 而是cls(即class)， 表示类本身

# @staticmethod

```
@staticmethod
def classPrint():
    print("class method")
```

用法一样， 只是@staticmethod的函数不用参数， self和cls都不用

# 用处

@staticmethod用于某些时候， 函数与该类有些关系， 但是不直接引用类成员或类函数

```
FLAG = 'ON'

def checkflag():
    return (FLAG == 'ON')

class Test(object):
    def __init__(self,data):
        self.data = data
    def do_reset(self):
        if checkflag():
            print('Reset done for:', self.data)
    def set_db(self):
        if checkflag():
            self.db = 'new db connection'
            print('DB connection made for:',self.data)

ik1 = Test(12)
ik1.do_reset()
ik1.set_db()
```

如上， 类的每个成员函数都需要获取类外部flag状态， 而checkflag仅被该类使用，也不会调用类成员， 却不得不待在类在外部， 如果使用@classmethod， checkflag会与类产生关系， 类本身会被传入checkflag， 而checkflag并不需要它

这时候用@staticmethod就完美解决这个问题了

# 区别

区别仅在对类自身成员的访问上

@classmethod因为有cls参数， 所以可以直接访问类成员

@staticmethod因为没有参数， 所以只能以外人身份访问类成员

```
class Test(object):
    # 在构造器外的成员为静态成员
    bar = 1
	
    def fun(self):
	    print("this is common function")
        # bar无法访问
	    print(self.bar)

    @staticmethod
    def static_fun():
        print("this is static function")
        print(Test.bar)
        # 访问不了fun()

    @classmethod
    def class_fun(cls):
        print("this is class function")
        print(cls.bar)
        cls().fun()

Test.static_fun()
Test.class_fun()
```

# 参考资料

[@staticmethod和@classmethod的用法](https://blog.csdn.net/GeekLeee/article/details/52624742)
