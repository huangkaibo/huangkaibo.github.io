---
title: Arch Linux安装全过程
date: 2017-07-28 10:33:13
tags: [Linux]
---

内容: 安装arch linux系统全过程

精华: 完全原创, 亲自安装, 解释很详细!!

<!-- more -->

# 前言

以下所有markdown行内代码是实际要运行的, 不用运行的都以普通文本形式展现

以下代码都是我刚装好Arch后按照记忆和资料手动打的, 不是copy, 所以可能有我没注意的错误, 如果有的话敬请斧正

以下只是简单做到跑出桌面环境, 很多可有可无的细节配置都没有

比如配置触摸板, 配置输入法, 配置有线连接, 配置普通用户等

# 分区

lsblk或者df都能列出存储设备

1. 开始分区: `gdisk /dev/sda`
2. p查看分区情况: `p`
3. o创建GPT分区表: `o`
4. n创建分区: `n`
5. 回车默认第一分区: `回车`
6. 回车默认承接上一分区最后柱面: `回车`
7. 512M分配给boot: `+512M` `回车`
8. 接下来hex什么的不晓得干嘛: `回车`
9. n创建第二分区17G给根目录
10. 第三分区剩下所有给swap

# 格式化分区

格式化为FAT32格式: `mkfs.fat -F32 /dev/sda1`

FAT32缺点虽然多, 但是好在各大系统都兼容, 所以经常来放些各个系统交互的东西

这里作为EFI挂载点, 大概是叫做ESI分区

格式化为ext4: `mkfs.ext4 /dev/sda2`

一般目录都格式化为ext4

格式化为swap: `mkswap /dev/sda3`

一般只用到这三种格式化

# 挂载分区

`mount /dev/sda2 /mnt`

把硬盘第二分区挂在到 /mnt

硬盘第二分区是要作为硬盘linux系统的根目录

现在映射到iso文件内的linux系统的/mnt

接下来往iso的linux系统的/mnt传输系统文件, 也就是把硬盘linux系统的根目录安装好了

挂载到/mnt是惯例, 只要不挂在/就好, 因为挂载/的话, iso的linux系统的所有东西就都用不了了

`mkdir -p /mnt/boot`在硬盘根目录, 也就是iso的linux系统的/mnt目录创建/boot文件夹

`mkdir -p /mnt/boot/efi`生成efi目录

`mount /dev/sda1 /mnt/boot/efi` 

**挂载efi哦, 不是boot**,要不然会错

我了解了下efi文件结构, 不过还是没明白为什么是挂载efi目录而不是boot

`swapon /dev/sda3`这是挂载swap分区的方法

df或者lsblk查看分区情况

free查看swap情况

# 往/dev/sda2里注入arch系统

安装系统是在线进行的

没网自行百度

## 添加源

`nano /etc/pacman.d/mirrorlist`修改一下源

添加几个国内源

```
Server = http://mirrors.163.com/archlinux/$repo/os/$arch
Server = http://mirrors.cqu.edu.cn/archlinux/$repo/os/$arch
Server = http://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
```

nano编辑器按Ctrl+x可以退出

更新源: `pacman -Syy`

## 下载安装部署arch

`pacstrap /mnt base base-devel`

/mnt是硬盘根目录挂载点

base是基本软件(连vim都没...)

base-devel是拓展软件, 可以不加

这一步会在/mnt/boot里写入几个东西的

所以上面一定要挂载/mnt/boot/efi

要不然挂错了boot, umount, 重新mount efi, 这一步写入的文件就隐藏了

我试过umount前cp到/tmp

可是mount efi后/tmp里居然也找不到, 很邪门, 不理解, 明白的人麻烦指点一下迷津

## 生成分区表

`genfstab -U -p /mnt >> /mnt/etc/fstab`

fstab这个文件开机自动加载

里面是一些硬盘挂载信息

可以帮你自动挂载硬盘

要不然一开机硬盘就都umount了

生成后查看一下fstab文件是否每个盘都挂好了

没好自行百度

前面的UUID不是必须的使用label也可以(label就是/dev/sda1这样子)

UUID是唯一标示, 换硬盘/dev/sda1就映射到新硬盘的第一分区

而UUID找不到, 无法映射

# 进入硬盘Linux系统设置

`arch-chroot /mnt /bin/bash`

chroot是进入某个Linux系统, 并且使用里面的shell

而cd /mnt是进入这个linux系统, 使用的仍然是iso文件的Linux系统的shell

大概区别就是cd的话配置的文件是针对iso Linux的

chroot配置的才是针对硬盘Linux的

/bin/bash是使用bash 不加的话使用sh

## 设置区域配置

`nano /etc/locale.gen`

这个东西里有很多关于区域设置的选项
语言/时区什么的

去掉这三个前面的#号

```
en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_CN GB2312
```

`locale-gen`生成区域配置

`echo LANG=en_US.UTF-8 > /etc/locale.conf`设置默认区域配置

## RAM

`mkinitcpio -p linux`不知道干嘛的

## 设置root的密码

`passwd`

## 安装引导程序

注意了, 引导程序是在**硬盘linux系统里**安装

这里选用grub, 据说system boot简单但是wiki说有什么缺点, 好像是只能运行efi程序(听不懂...)

`pacman -S dosfstools grub efibootmgr`

下载grub,有些人只下了grub,我没试过,这是官方的

grub-install --target=x86_64-efi --efi-directory=<EFI 分区挂载点> --bootloader-id=grub

比如

`grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub`

这里注意了, 因为现在是在硬盘linux系统了

所以是/boot/efi不是/mnt/boot/efi

这里我也不明白, 我还以为引导程序要安在/boot目录下呢, 可是试了几次, 只有/boot/efi才行

反正就是对于efi文件结构和grub关系很混乱, 也找不到什么相关资料

`grub-mkconfig -o /boot/grub/grub.cfg`

这个是按在/boot目录下, 不用在/efi

## 网络

我上面完了直接重启

重启后我遇到问题就是上不了网

执行以下命令后就可以了

`dhcpcd`

但是reboot后就要重新dhcpcd

以下是有人说的, 没试过

`systemctl enable dhcpcd.service`

在现在这个位置执行(也就是grub-mkconfig后, 感觉其实就是还在arch-chroot时执行)

然后如果要用wifi, 要安装以下, 否则重启后无法联网

重启后连不了网也就无法下载安装, 所以现在安好

`pacman -S iw wpa_supplicant dialog`

# 退回iso的linux系统

`exit`退回

`umount -R /mnt`卸载根目录挂载点

这一步看着没用, 官方说是可以看看会不会出什么错方便调整, 没细究

`reboot`重启

现在iso可以卸载了, grub负责引导到硬盘linux系统了

如果不能进确认自己一开始挂载的是/mnt/boot/efi而不是/mnt/boot

grub-install的是/boot/efi而不是/boot

grub-mkconfig的是/boot而不是/boot/efi

要是都对了........不好意思.....我小白....没辙.....

---

这里也有个问题很迷不明白

就是我一开始几次安措了, 重启后grub引导失败

我挂载, 然后arch-chroot

进入/boot重新安装引导

结果!!!发现/boot下居然是空的!!!

然后更奇怪的 他说我/boot/efi不是EFI分区该有的格式(也就是FAT32)

奇葩, 不明白, 退回去df查看的确是FAT32呀

就算重新mkfs.fat -F32也没用, 就是说我不是EFI分区该有的格式

我还试过换一个引导程序, 也报错说不是EFI分区该有的格式

懂得大佬请指点

---

以上参考了

[Virtualbox上面UEFI/GPT安装Archlinux](http://www.iyunv.com/thread-182002-1-1.html)

[官方安装指南](http://bbs.archlinuxcn.org/viewtopic.php?id=1037)

[官方wiki](https://wiki.archlinux.org/index.php/Main_Page_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

# 桌面环境

## 安装显卡驱动

`lspci | grep VGA`确认自己显卡型号

`pacman -S <驱动包>`

```
# # 官方仓库提供的驱动包：
# # +----------------------+--------------------+--------------+
# # |                      |        开源        |     私有     |
# # +----------------------+--------------------+--------------+
# # |         通用         |   xf86-video-vesa  |              |
# # +----------------------+--------------------+--------------+
# # |         Intel        |  xf86-video-intel  |              |
# # +--------+-------------+--------------------+--------------+
# # |        | GeForce 9+  |                    |    nvidia    |
# # +        +-------------+                    +--------------+
# # | nVidia | GeForce 8/9 | xf86-video-nouveau | nvidia-340xx |
# # +        +-------------+                    +--------------+
# # |        | GeForce 6/7 |                    | nvidia-304xx |
# # +--------+-------------+--------------------+--------------+
# # |        AMD/ATI       |   xf86-video-ati   |              |
# # +----------------------+--------------------+--------------+
```

我是VM安装, VM显卡是个.....额....记不住了,反正不是N卡A卡

我安装了通用的

`pacman -S xf86-video-vesa`

## 安装Xorg

`pacman -S Xorg`

这里我没弄清

查到的资料简单来说: Xorg是其他所有桌面环境(Gnome/KDE/Xfce等)的基础框架

所以按这样子来说必须要先安装Xorg, 网上也有人肯定了我的想法

但是官方安装文档里没有安装Xorg, 直接安了桌面环境, 懂得大佬请指点

还有就是有些人是

pacman -S xorg-server  xorg-xinit   xorg-utils xorg-server-utils mesa

说只要安好这些核心组件就好了, 不用安装所有Xorg

但是这里几个组件我都找不到..........

所以就全安了

`pacman -S xorg-twm xorg-xclock xterm`

这个说是测试X工作是否正常

我是安了这个才能进入Gnome, 要不然进不了, Xfce倒是没受影响

接下来startx就可以看到一个简陋的图形界面了

这就是Xorg提供的基础图形界面, 其他桌面环境的基础框架(大概就是基本的人机交互吧)

## 安装Xfce

`pacman -S xfce4 xfce4-goodies`

如果上面startx进入了简陋界面, 先reboot重启一下(要不然打开Xfce, Xfce和Xorg会重叠)

重启后`startxfec4`就能进入xfce4桌面环境了

## 安装Gnome

一个桌面环境就够了, 我是想都看看

`pacman -S gnome gnome-extra`

`nano ~/.xinitrc`

添加一行`exec gnome-session`

Ctrl+x保存退出

`startx`

这里startx命令是先会去~/.xinitrc找看看要执行什么

就启动成功了

以上参考了

[VMware 虚拟机安装 ArchLinux 系统全过程记录](http://blog.csdn.net/tangaowen/article/details/52002174)

[在计算机中安装Arch Linux](http://www.jianshu.com/p/928dc93a32b5)

# 安装到U盘

参考资料

[Guide full install of Arch on a USB key.](http://www.ritano.fr/guide-full-install-of-arch-on-a-usb-key/)

[XPS 13 (9343) install Archlinux (Deepin DE) to usb disk use vmware](https://www.zybuluo.com/yangxuan/note/744430)

[Installing Arch Linux on a USB key](https://wiki.archlinux.org/index.php/Installing_Arch_Linux_on_a_USB_key_(简体中文))

我是安装到U盘成功了, 不过没有立即整理成笔记, 现在已经忘了怎么搞的.....捂脸.........

肯定是按照上面两篇文章中的一个, 然后记得安到U盘只是在grub命令时, 命令不一样而已
