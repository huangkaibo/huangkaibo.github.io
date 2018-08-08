---
title: python configparser
updated: 2018-08-08
date: 2018-07-29
tags: [python]
---

内容: python 配置文件管理

<!-- more -->

# 概述

配置文件一般命名为xxx.conf, 如`project.conf`

# 配置文件格式

```
[mysql]
host = "10.0.0.0"
port = 3006
user = "xxxx"
passwd = "xxxx@xxxx"
db = "xxxxx"
charset = "utf8"
use_unicode = True

[kafka]
bootstrap_servers = amaster:9092,anode1:9092,anode2:9092
```

`[mysql]` 称为一个section, 一个section里面就是很多键值对

# 获取配置文件

```python
# configparser是第三方库, 要pip安装
import configparser

cp = configparser.SafeConfigParser()
cp.read("../conf/project.conf")

host = cp.get('mysql', 'host')
```

## 注意

注意读取出来的是字符串, 上面的host是str类型

我们平常写""就是为了告诉编译器里面是一个str类型, 真正的数据是""内部的

所以配置文件那里写错了, 应该写`host = 10.0.0.0`, 而不是`host = "10.0.0.0"`

也就是说, 键值对的值一定会被认为是str类型, 取出来自己强转就好了

# 写入配置文件

```python
# cp不用read了
cp = configparser.SafeConfigParser()

# 添加一个section
cp.add_section("app")
cp.set("app", "app1", "app_name1")
cp.set("app", "app2", "app_name2")
cp.set("app", "app3", "app_name3")

# 根据文件打开属性决定是覆盖写入还是追加
f = open('../conf/project.conf', 'a')
cp.write(f)
```

效果如下

```
[app]
app1=app_name1
app2=app_name2
app3=app_name3
```

# 其他

## 获取所有section

```python
# 返回list
cp.sections()
```

## 获取section下所有option

option就是键值对的键

```python
# 返回list
cp.options("section名")
```

## 获取section下所有键值对

```python
cp.items("section名")
```

返回结果如下

```
[('key1', 'value1'), ('key2', 'value2'), ('key2', 'value2')]
```

可以通过以下方式遍历

```python
for (key, value) in cp.items("section名"):
```

# 参考资料

[【python】 ConfigParser模块](http://blog.51cto.com/793404905/1545878)