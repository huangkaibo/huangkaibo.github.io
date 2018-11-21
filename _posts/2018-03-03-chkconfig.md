---
title: chkconfig
date: 2018-03-03
tags: [Linux, 命令]
---

内容: 解释了chkconfig命令的使用

<!-- more -->

# 概述

RedHat系列的命令

检查编辑服务自启动情况

服务分自启动和启动(自启动指开机启不启动, 启动指当前有没有启动)

chkconfig就是检查/etc/init.d/目录下的脚本文件(不过脚本文件里要加上一些特殊标识)

# 参数

```
//列出服务自启动情况
chkconfig --list [name]
//添加自启动服务
chkconfig --add
//删除自启动服务
chkconfig --del
//编辑服务在某些等级的自启动情况
chkconfig --level 等级 name on/off/reset
```

# 等级代号

```
等级0表示：表示关机
等级1表示：单用户模式
等级2表示：无网络连接的多用户命令行模式
等级3表示：有网络连接的多用户命令行模式
等级4表示：不可用
等级5表示：带图形界面的多用户模式
等级6表示：重新启动
```

# --list

![](http://media.huangkaibo.cn/18-2-2/19288088.jpg)

![](http://media.huangkaibo.cn/18-2-2/6367819.jpg)

# --level

![](http://media.huangkaibo.cn/18-2-2/43712597.jpg)

chkconfig原理是在/etc/init.d/下的服务脚本里加上两个注释

![](http://media.huangkaibo.cn/18-2-2/38512318.jpg)

```
chkconfig: 2345 10 90
//2345指2345级别
//10指S10 90指K90
```

description是描述信息, 无所谓

同时把启停脚本放在/etc/rcX.d/下

![](http://media.huangkaibo.cn/18-2-2/87321059.jpg)

# --add

--add用于源码包服务想被chkconfig管理

直接把源码包脚本ln到/etc/init.d/可以被service使用, 但是要被chkconfig和ntsysv管理还要一句

```
chkconfig --add 服务
```

然后chkconfig和ntsysv就可以找到这个服务了

```
chkconfig --level 2345 服务 on
```
