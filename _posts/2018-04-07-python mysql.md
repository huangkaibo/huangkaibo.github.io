---
title: python mysql
date: 2018-04-07
tags: [python,mysql]
---

内容: python mysql操作

<!-- more -->

# 环境配置

python2的mysql connector使用mysqldb

mysqldb最大支持到3.6.4

python3以后mysql connector主要使用pymysql

```
pip install PyMySQL
```

`import pymysql` 测试是否安装成功

# 连接操作

```
# 引入库
import pymysql

# 获取数据库连接
# ip/用户名/密码/数据库名
# 两个编码的语句不能少, 要不错误很多
conn = pymysql.connect(
    host = "localhost",
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

## 事务回滚

```
try:
   cursor.execute(sql)
   conn.commit()
except:
   conn.rollback()
```
