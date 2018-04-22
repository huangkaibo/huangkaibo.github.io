---
title: ifconfig ifup ifdown
date: 2018-04-21
tags: [Linux,命令,web]
---

内容: ifconfig和ifup/ifdown详解

精华: 很详细的介绍了ifconfig输出解析,ifconfig各种用,以及和ifup/ifdo区别

<!-- more -->

# 概述

配置和查看Linux内核中网络接口的网络参数

重启后失效

![](http://p1rbtn7qp.bkt.clouddn.com/18-4-20/8515797.jpg)

# 输出解析

```bash
# 第一块网卡enp1s0
# flags代表网卡状态
# UP: 网卡开启(也有说: 网卡有地址, 有路由表, 连接到了网络层)
# BROADCAST: 支持广播
# RUNNING: 网卡网线被接上(也有说: 网卡驱动已加载, 网卡被初始化)
# MULTICAST: 支持组播
# mtu: 最大传输大小为1500字节
enp1s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500

    # 一般还有这么一句
    # 代表网络层的数据经过这个网卡会被打包成以太网帧再发出去
    # Link encap:Ethernet
    # encap是encapsulation 封装, Link encap应该代表链路层封装
    
    # 网卡ip地址 子网掩码地址 广播地址
    # 数据包的目的ip如果是广播地址, 网卡会将数据包泛洪发出
    # 很明显可以看出广播地址就是网段最大ip
    inet 125.216.245.179  netmask 255.255.255.0  broadcast 125.216.245.255
    
    inet6 fe80::278b:7aef:9b07:890  prefixlen 64  scopeid 0x20<link>
    inet6 2001:250:3000:3cc2:6146:e3b4:ae0c:cacb  prefixlen 64  scopeid 0x0<global>
    inet6 2001:250:3000:3cc2:765:55f5:8d04:f3a4  prefixlen 64  scopeid 0x0<global>
    
    # mac地址 数据包里的mac地址就是这个
    # 有些也显示为
    # HWaddr 68:f7:28:d4:57:06
    ether 68:f7:28:d4:57:06  txqueuelen 1000  (以太网)
    
    # 接收数据包数量, 总字节数
    RX packets 5300543  bytes 845484182 (845.4 MB)
    # errors: 接收出错的包数(包括 too-long-frames 错误, Ring Buffer 溢出错误, crc 校验错误，帧同步错误, fifo overruns 以及 missed pkg 等等)
    # dropped: 接收到了网卡buffer, 但是因为内存不够之类原因放弃掉, 没有进入内存的包数
    # overruns: 没有接收到网卡buffer, 但是并非buffer太小, 而是cpu处理速度太慢
    # droppe和overruns区别: dropped是已经接收到buffer, 内存小而丢弃; overruns是cpu来不及处理, buffer满了而丢弃
    RX errors 0  dropped 9  overruns 0  frame 0
    
    TX packets 248549  bytes 28427033 (28.4 MB)
    # collision: CSMA/CD冲突次数
    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# 环回设备没有网卡的物理限制, 所以mtu可以很大
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
    
    # Link encap:Local Loopback
    # 环回设备是纯软件实现的, 不会把数据报封装成以太帧
    
    inet 127.0.0.1  netmask 255.0.0.0
    inet6 ::1  prefixlen 128  scopeid 0x10<host>
    loop  txqueuelen 1000  (本地环回)
    RX packets 650254  bytes 353724200 (353.7 MB)
    RX errors 0  dropped 0  overruns 0  frame 0
    TX packets 650254  bytes 353724200 (353.7 MB)
    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

# 选项参数

格式: `ifconfig interface 要修改的东西 修改数据`

如: `ifconfig eth0 mtu 1400`

## 开启关闭网卡

```
ifconfig eth0 up
# 关闭后ifconfig就查不到eth0了
# ifconfig -a可以查到关闭的
ifconfig eth0 down
```

若要重启eth0推荐用这种方法, 而不要`service network restart`, 这样会重启每个网卡

## 网卡配置IPv4地址

```
ifconfig eth0 192.168.120.56 
ifconfig eth0 192.168.120.56 netmask 255.255.255.0 
ifconfig eth0 192.168.120.56 netmask 255.255.255.0 broadcast 192.168.120.255
```

子网掩码默认255.255.255.0

广播地址默认用子网掩码算后的网段的最大IP

## 网卡配置IPv6地址

```
ifconfig eth0 add 33ffe:3240:800:1005::2/64
ifconfig eth0 del 33ffe:3240:800:1005::2/64
```

## 网卡修改MAC地址

```bash
# 网上都说要先关闭网卡, 但是我实测不用关闭就能改
ifconfig eth0 down
ifconfig eth0 hw ether 00:AA:BB:CC:DD:EE
ifconfig eth0 up
```

## 网卡开启关闭arp

```bash
# 这个实测效果是重启, 因为使用后arp表清空了
ifconfig eth0 arp
# 关闭后效果就是arp查不到任何东西
ifconfig eth0 -arp
```

## 设置MTU

```
ifconfig eth0 mtu 1400
```

## -s 摘要

![](http://p1rbtn7qp.bkt.clouddn.com/18-4-21/10419990.jpg)

## 混杂模式

```
# 普通模式时只有发给自己的, 或者广播包才会被接收发往模型上层
# 混杂模式时什么包都接收发给模型上层
ifconfig eth0 promisc
ifconfig eth0 -promisc
```

## 创建虚拟网卡

![](http://p1rbtn7qp.bkt.clouddn.com/18-4-21/56799392.jpg)

虚拟网卡依附于真实网卡, 名字是`真实网卡:别名`(别名不一定要是数字, 字母也行)

`ifconfig`不会修改配置文件, 建立虚拟网卡也没有配置文件, 所以`ifconfig 虚拟网卡 down`后就没了, 再也开启不了了

虚拟网卡还有一个作用是让网卡具有多个IP

## 其他

`ifconfig -a` 关闭的网卡也可以查到

# 原理

`ifconfig`读取`/etc/sysconfig/network-scripts/`下的文件进行统计

每个网卡对应`ifcfg-`开头的配置文件, 如`ifcfg-eth0`

所以, 编辑这些文件才是永久生效的, ifconfig重启就失效

## 添加网卡

网卡的软件存在就只有一个`/etc/sysconfig/network-scripts/`下的配置文件

所以`cp`一个, 修改网卡名, ip等必要信息, 然后重启network服务就好了

```bash
service network restart
```

# ifup/ifdown

## 概述

只能用于启停网卡, 不能修改

## 和ifconfig区别

ifup和ifdown是利用`/etc/sysconfig/network-scripts/`下的配置文件进行启停

而ifconfig是查看网卡设备进行启停配置

所以添加新网卡配置文件, ifconfig不能启动, 因为还并没有加载这个设备, 所以要重启network服务来加载, 然后利用ifconfig操作

而ifup/ifdown就可以直接启停

## 注意

ifdown停止时会检测当前网卡信息和网卡配置文件信息是否一致, 不一致就不允许停止

也就是, ifconfig修改网卡后, 不能用ifdown来关闭网卡, 只能ifconfig关闭, 或撤销修改后ifdown

## 使用

```
# 重启网卡
ifdown eth0 && ifup eth0
```

# 特别注意

谨慎使用停止网卡命令, 一般都是远程连接, 停止后得跑到电脑那里重新开启

所以, 如果重启网卡必须写成`down && up`的形式

# 参考资料

[The Missing Man Page for ifconfig](http://blog.hyfather.com/blog/2013/03/04/ifconfig/)

[dropped与overruns的区别](http://www.lenky.info/archives/2012/02/1028)

[【Linux】ifconfig命令详解](https://blog.csdn.net/wait_for_taht_day5/article/details/51143242)