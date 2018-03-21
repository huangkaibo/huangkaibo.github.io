---
title: Restful-API
date: 2018-03-21
tags: [web]
---

内容: 介绍Restful API

精华: 从不使用Restful API的混乱, 到优化, 到使用Restful API, 一步步对比来介绍Restful API的优缺点

<!-- more -->

# 概述

Restful API是一个url的命名规范

# 非Restful API

列举一下我之前项目定的乱七八糟的url

```
# 下载文件列表
/downloadList
# 下载指定文件
/download/pro?fileName=文件全名

# 查询城市信息
/query_data/coun/matrix

# 检测账户是否注册
/checkAccount
# 如果没注册就注册账户
/registerUser
/login
```

当时没有统一命名的意识

现在来改一下， 按照动作来规范命名如下

# 动作分类API

```
# 规范: 动作/文件类型/文件名称
# download和query_data都可以归结为get这个动作
/get/file/all
/get/file/1.txt
/get/coun/2.txt

# 没必要区分checkAccount和register
/register
/login
```

# Restful API

```
# 规范: /资源类型/资源名
# 动作利用http method来表述
/file/all GET
/file/1.txt GET

/coun/2.txt GET

# 登录就是生成一个session
/session POST
# 退出登录就是删除一个session
/session DELETE
```

* url仅描述资源， 不插入动作
* 动作由http method描述
    * GET: 获取
    * POST: 插入
    * PUT: 更新
    * DELETE: 删除
* 返回状态由http状态码表示， 而非封在json里

# 动作分类API vs Restful API

## Restful API优点

* Restful API url将动作抽离， 状态码抽离， url简短
* 资源分散与操作分散
    * 动作分类API的后端Controller操作集中, 资源分散
        * @Controller get()
            * if(file) getFile()
            * if(coun) getCoun()
        * @Controller delete()
            * if(file) deleteFile()
            * if(coun) deleteCoun()
    * Restful API的后端Controller操作分散, 资源集中
        * @Controller file()
            * doGet() 下载文件
            * doPost() 上传文件
        * @Controller coun()
            * doGet() 下载城市信息
            * doPost() 上传城市信息
    * 个人认为Restful API这种好, 动作分类API感觉很混乱

## Restful API缺点

说是把动作抽离， 实际只抽离了CURD动作， 其余动作难以转成CURD描述(比如登录我就是没想到， 查了才知道可以用/session POST描述)

### 非CURD动作转CURD操作

* 重构动作: 转成/动作作用对象 CURD
* 复杂动作分解再一个个重构: 对一个git仓库加星操作: /gits/:id/star PUT 取消星操作： /gists/:id/star DELETE

但是还是有难以转化的， 比如search， 那就Restful API+动作分类API共用吧， Restful API也不是万能的
