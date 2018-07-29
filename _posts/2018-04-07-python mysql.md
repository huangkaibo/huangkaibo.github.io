---
title: python mysql
date: 2018-04-07
updated: 2018-07-29
tags: [python,mysql]
---

内容: python mysql操作

<!-- more -->

# 环境配置

python2的mysql connector使用mysqldb, mysqldb最大支持到3.6.4

python3以后mysql connector主要使用pymysql

```
pip install PyMySQL
```

# 连接操作

```
# 引入库
import pymysql

# 获取数据库连接
# ip/用户名/密码/数据库名
# 两个编码的语句不能少, 要不错误很多
conn = pymysql.connect(
    host = "localhost",
    port = 3306,
    user = "root",
    passwd = "root",
    db = "vip",
    charset="utf8",
    use_unicode=True
)

# 获取游标对象
# 游标对象用于增删查改
cursor = conn.cursor()

# 关闭游标
cursor.close()
# 关闭连接
conn.close()
```

# 数据库操作

```
# 基本操作
# 这两句就可以进行增删查改了
cursor.execute("SELECT * FROM TESTTABLE")
conn.commit()

# 对于查还要获取查询结果
# fetchone()获取下一查询结果， 一次一条
# fetchall()获取全部查询结果, list形式
# fetchmany(n) 获取前n条数据
data = cursor.fetchone()

# 对于增删查改要获取影响的行数
count = cursor.rowcount
# cursor.excute()也会返回影响的行数
```

# 事务回滚

```
try:
    cursor.execute(sql)
    conn.commit()
except:
    conn.rollback()
finally:
    conn.close()
```

# 其他

## 一个sql里拼接多条语句

似乎不支持一个sql里面字符串拼接了多个语句

但是支持多次执行sql, 如下

```python
sql = "set @var = 1;"
cursor.execute(sql)
sql = "SELECT * FROM TESTTABLE;"
cursor.execute(sql)
sql = "select @var;"
cursor.execute(sql)
conn.commit()
```

三个sql是在同一作用域, 所以最后是可以拿到@var的

但是cursor.fetchall()只能拿到最后一个select的数据

## 插入多个数据

```python
# 这里%s似乎是写死的, 就算age是传入数字, 这里也要写s%, 而不能写d%, 但是写了s%, 传入数字也没错, 数据库也是数字没错, 很奇怪
sql = "insert into test_table(name, age) values(%s, %s)"
# %s这里可以做mysql函数处理的
sql = "insert into test_table(name, age) values(%s, inet_aton(%s))"
values_list = [("huangkaibo", 11), ("mazeli", 22)]
# values_list = [["huangkaibo", 11], ["mazeli", 22]] 也可以
cursor.executemany(sql, values_list)
```

## 自动帮你转义

```
sql = "insert into test_table values(" + conn.escape(cmd) + ")"
```

`df -h.\"""|`

变为(单引号也是它加的)

`'df -h.\\\"\"\"|'`

* conn.escape会自动帮你转义, 结果就是等同于cmd为原始字符串, 也就是python中r的效果
* 连左右的单引号/双引号都不用加, 也不能加